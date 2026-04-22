/*==============================================================================
  ZHANG & ZHU (2011) - "Group Size and Incentives to Contribute:
  A Natural Experiment at Chinese Wikipedia"
  AER, 101(4), 1601-1615

  Pipeline: STEP 1 Tables 3-4 Cols 4-6 → STEP 2 twowayfeweights → STEP 3 LaTeX

  Regression specification (from main.do):
    Table 3 Cols 4-6: xtreg logY after social_participation_after
                       social_participation age agesqr, i(id) fe r
    Table 4 Cols 4-6: xtreg logY after percent_blocked_after
                       percent_blocked age agesqr, i(id) fe r
    where Y = {logTotal, logAddition, logDeletion}
    Sample: weeks -4 to -1 and 1 to 4 (excluding week 0)
    Panel: contributor (id) x week, individual FE, robust SE
==============================================================================*/

clear all
set more off
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Zhang and Zhu (2011)"
global datadir  "$paperdir/AER-2009_0165.R1_data"
global outdir   "$paperdir"

log using "$outdir/run_twowayfe.log", text replace

* Install packages if needed
cap which estout
if _rc ssc install estout, replace
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace


/*==============================================================================
  STEP 0: DATA PREPARATION (replicate main.do data construction)
==============================================================================*/

di _n "=============================================="
di    "STEP 0: DATA PREPARATION"
di    "=============================================="

use "$datadir/daily_contribution.dta", clear

* Create join and last dates
egen joindate = min(date), by(id)
egen lastdate = max(date) if (date < mdy(10, 10, 2006) | date > mdy(11, 17, 2006)) & Total > 0, by(id)
egen temp = max(lastdate), by(id)
replace lastdate = temp if lastdate==.
drop temp
format lastdate %d

* Identify contributors during 1st block
gen contributed_during_1st_block = Total > 0 & Total!=. & (date >= mdy(6, 2, 2004) & date <= mdy(6, 17, 2004))
egen temp = max(contributed_during_1st_block), by(id)
replace contributed_during_1st_block = temp
drop temp

* Identify nonblocked contributors
gen nonblocked = 0
replace nonblocked = 1 if joindate < mdy(10, 19, 2005) & lastdate >= mdy(11, 1, 2005) & lastdate !=.
replace nonblocked = 1 if joindate < mdy(10, 19, 2005) & contributed_during_1st_block == 1
drop contributed_during_1st_block

* Merge language statistics
sort id
merge id using "$datadir/userlangstat_percentage.dta"
drop if _merge == 2
drop _merge

gen overseas = .
replace overseas = percentage > 0.5 & percentage!=.
drop percentage
replace nonblocked = 1 if overseas==1 & joindate < mdy(10, 19, 2005)

* Generate week variable
gen week = .
quietly do "$datadir/genweek.do"

* Keep nonblocked contributors only
drop if nonblocked == 0

* Create weekly aggregates
gen id_week = string(id) + "_" + string(week)
egen weekly_Addition = total(Addition), by(id_week)
egen weekly_Deletion = total(Deletion), by(id_week)
egen min_date = min(date), by(id_week)
duplicates drop id_week, force
replace date = min_date
drop min_date
format joindate %d

* Create analysis variables
gen age = round((date - joindate)/7)
gen agesqr = age^2
gen logAddition = log(weekly_Addition + 1)
gen logDeletion = log(weekly_Deletion + 1)
gen logTotal = log(weekly_Addition + weekly_Deletion + 1)
gen after = week > 0

* Merge social participation data (for Table 3)
sort id
merge id using "$datadir/userpagestat2005.dta"
drop if _merge==2
drop _merge
sort id
merge id using "$datadir/usertalkstat2005.dta"
drop if _merge==2
drop _merge

replace userpage2005_add = 0 if userpage2005_add==.
replace userpage2005_deleted = 0 if userpage2005_deleted ==.
replace usertalk2005_add = 0 if usertalk2005_add ==.
replace usertalk2005_deleted = 0 if usertalk2005_deleted ==.

gen social_participation = userpage2005_add + userpage2005_deleted + usertalk2005_add + usertalk2005_deleted
replace social_participation = 0 if social_participation == .

gen temp = age if week == 0
egen age_to_block = max(temp), by(id)
replace social_participation = social_participation/(age_to_block+1)
replace social_participation = log(social_participation+1)
drop temp age_to_block

gen social_participation_after = social_participation * after

* Merge percent_blocked data (for Table 4)
sort id
merge id using "$datadir/percent_blocked.dta"
drop if _merge==2
drop _merge

gen percent_blocked_after = percent_blocked * after

* Sample restriction: weeks -4 to 4, excluding week 0
gen insample = ((week >= -4 & week < 0) | (week > 0 & week <= 4))

di "Total observations in sample: "
count if insample == 1
di "Unique contributors: "
qui tab id if insample == 1
di r(r)


/*==============================================================================
  STEP 1: TABLE 3 - COLS 4-6 (Individual FE with social participation)
==============================================================================*/

di _n "=============================================="
di    "TABLE 3: COLS 4-6 (Individual FE)"
di    "=============================================="

* Col 4: logTotal
di _n "--- Table 3, Column 4: Log(Total Contributions) ---"
xtreg logTotal after social_participation_after social_participation ///
    age agesqr if insample == 1, i(id) fe r
est store t3c4
estadd local idfe "Yes" : t3c4
estadd local sample "Weeks [-4,4]" : t3c4

* Col 5: logAddition
di _n "--- Table 3, Column 5: Log(Additions) ---"
xtreg logAddition after social_participation_after social_participation ///
    age agesqr if insample == 1, i(id) fe r
est store t3c5
estadd local idfe "Yes" : t3c5
estadd local sample "Weeks [-4,4]" : t3c5

* Col 6: logDeletion
di _n "--- Table 3, Column 6: Log(Deletions) ---"
xtreg logDeletion after social_participation_after social_participation ///
    age agesqr if insample == 1, i(id) fe r
est store t3c6
estadd local idfe "Yes" : t3c6
estadd local sample "Weeks [-4,4]" : t3c6


/*==============================================================================
  STEP 1b: TABLE 4 - COLS 4-6 (Individual FE with percent blocked)
==============================================================================*/

di _n "=============================================="
di    "TABLE 4: COLS 4-6 (Individual FE)"
di    "=============================================="

* Col 4: logTotal
di _n "--- Table 4, Column 4: Log(Total Contributions) ---"
xtreg logTotal after percent_blocked_after percent_blocked ///
    age agesqr if insample == 1, i(id) fe r
est store t4c4
estadd local idfe "Yes" : t4c4
estadd local sample "Weeks [-4,4]" : t4c4

* Col 5: logAddition
di _n "--- Table 4, Column 5: Log(Additions) ---"
xtreg logAddition after percent_blocked_after percent_blocked ///
    age agesqr if insample == 1, i(id) fe r
est store t4c5
estadd local idfe "Yes" : t4c5
estadd local sample "Weeks [-4,4]" : t4c5

* Col 6: logDeletion
di _n "--- Table 4, Column 6: Log(Deletions) ---"
xtreg logDeletion after percent_blocked_after percent_blocked ///
    age agesqr if insample == 1, i(id) fe r
est store t4c6
estadd local idfe "Yes" : t4c6
estadd local sample "Weeks [-4,4]" : t4c6

di _n "=== SUMMARY ==="
di "Table 3 Col 4 (logTotal, after):     " %9.4f _b[after]
est restore t3c5
di "Table 3 Col 5 (logAddition, after):  " %9.4f _b[after]
est restore t3c6
di "Table 3 Col 6 (logDeletion, after):  " %9.4f _b[after]
est restore t4c4
di "Table 4 Col 4 (logTotal, after):     " %9.4f _b[after]
est restore t4c5
di "Table 4 Col 5 (logAddition, after):  " %9.4f _b[after]
est restore t4c6
di "Table 4 Col 6 (logDeletion, after):  " %9.4f _b[after]


/*==============================================================================
  STEP 2: TWOWAYFEWEIGHTS DECOMPOSITION
  The regression has individual FE. Treatment = after (blocking event).
  G = id (contributor), T = week, D = after
  Note: This is a one-way FE regression (no time FE), so twowayfeweights
  results should be interpreted carefully.
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

preserve
keep if insample == 1

* Create numeric week variable centered (week is already numeric -4 to 4 excl 0)
* Need a positive integer for T
gen week_num = week + 5
replace week_num = week + 4 if week > 0
* Now week_num: 1,2,3,4 for weeks -4,-3,-2,-1 and 5,6,7,8 for weeks 1,2,3,4

di _n "--- feTR: logTotal ~ after | id + week FE ---"
cap noisily twowayfeweights logTotal id week_num after, type(feTR)

di _n "--- fdTR: logTotal ~ after | id + week FD ---"
cap noisily twowayfeweights logTotal id week_num after, type(fdTR)

restore


/*==============================================================================
  STEP 3: LATEX EXPORT
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

* --- Table 3: Cols 4-6 (AER format) ---
esttab t3c4 t3c5 t3c6 using "$outdir/table3_fe.tex", replace ///
    keep(after social_participation_after age agesqr) ///
    order(after social_participation_after age agesqr) ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    stats(r2_w N, ///
        fmt(2 %9,0gc) ///
        labels("R\$^2\$" "Observations")) ///
    varlabels(after "AfterBlock" ///
              social_participation_after "SocialParticipation \$\times\$ AfterBlock" ///
              age "Age" ///
              agesqr "Age\$^2\$") ///
    collabels(none) nomtitles nonumbers nonotes ///
    prehead("\begin{table}[htbp]" ///
            "\centering" ///
            "\small" ///
            "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" ///
            "\caption{Difference-in-Differences Estimations of the Impact of the Block on" ///
            "Contributors with Different Levels of Social Participation}" ///
            "\label{tab:table3}" ///
            "\begin{tabular}{l*{3}{c}}" ///
            "\toprule") ///
    posthead("& \multicolumn{1}{c}{Total}" ///
             "& \multicolumn{1}{c}{Addition}" ///
             "& \multicolumn{1}{c}{Deletion} \\" ///
             "& (4) & (5) & (6) \\" ///
             "\midrule") ///
    prefoot("\midrule") ///
    postfoot("Specification & FE & FE & FE \\" ///
             "\bottomrule" ///
             "\multicolumn{4}{p{0.92\linewidth}}{\footnotesize \textit{Notes:}" ///
             " SocialParticipation is the logarithm of the weekly average of total" ///
             " addition and total deletion in user pages or user-talk pages by each" ///
             " contributor before the block. The variable SocialParticipation drops" ///
             " in the fixed-effect specifications as its value is fixed for each" ///
             " contributor. Heteroskedasticity-adjusted standard errors in brackets.} \\" ///
             "\multicolumn{4}{l}{\footnotesize *** Significant at the 1 percent level," ///
             " ** 5 percent level, * 10 percent level.} \\" ///
             "\end{tabular}" ///
             "\end{table}")

di "  -> table3_fe.tex created"

* --- Table 4: Cols 4-6 (AER format) ---
esttab t4c4 t4c5 t4c6 using "$outdir/table4_fe.tex", replace ///
    keep(after percent_blocked_after age agesqr) ///
    order(after percent_blocked_after age agesqr) ///
    cells(b(star fmt(3)) se(par([ ]) fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    stats(r2_w N, ///
        fmt(2 %9,0gc) ///
        labels("R\$^2\$" "Observations")) ///
    varlabels(after "AfterBlock" ///
              percent_blocked_after "PercentageBlocked \$\times\$ AfterBlock" ///
              age "Age" ///
              agesqr "Age\$^2\$") ///
    collabels(none) nomtitles nonumbers nonotes ///
    prehead("\begin{table}[htbp]" ///
            "\centering" ///
            "\small" ///
            "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" ///
            "\caption{Difference-in-Differences Estimations of the Impact of the Block on" ///
            "Contributors with Different Percentages of Collaborators Blocked}" ///
            "\label{tab:table4}" ///
            "\begin{tabular}{l*{3}{c}}" ///
            "\toprule") ///
    posthead("& \multicolumn{1}{c}{Total}" ///
             "& \multicolumn{1}{c}{Addition}" ///
             "& \multicolumn{1}{c}{Deletion} \\" ///
             "& (4) & (5) & (6) \\" ///
             "\midrule") ///
    prefoot("\midrule") ///
    postfoot("Specification & FE & FE & FE \\" ///
             "\bottomrule" ///
             "\multicolumn{4}{p{0.92\linewidth}}{\footnotesize \textit{Notes:}" ///
             " PercentageBlocked is the percentage of collaborators blocked after the" ///
             " third block for each contributor. The variable PercentageBlocked drops" ///
             " in the fixed-effect specifications as its value is fixed for each" ///
             " contributor. Heteroskedasticity-adjusted standard errors in brackets.} \\" ///
             "\multicolumn{4}{l}{\footnotesize *** Significant at the 1 percent level," ///
             " ** 5 percent level, * 10 percent level.} \\" ///
             "\end{tabular}" ///
             "\end{table}")

di "  -> table4_fe.tex created"

* --- Master document ---
cap file close texfile
file open texfile using "$outdir/zhang_zhu_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Zhang \& Zhu (2011)}\\" _n
file write texfile "{\large Group Size and Incentives to Contribute:" _n
file write texfile "A Natural Experiment at Chinese Wikipedia}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 101(4), 1601--1615}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n

file write texfile "\input{table3_fe}" _n _n
file write texfile "\clearpage" _n _n
file write texfile "\input{table4_fe}" _n _n

file write texfile "\end{document}" _n
file close texfile

di "  -> zhang_zhu_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Zhang & Zhu (2011)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table3_fe.tex"
di "  2. $outdir/table4_fe.tex"
di "  3. $outdir/zhang_zhu_tables.tex (compilable)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
