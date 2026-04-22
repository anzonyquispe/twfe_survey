**NOTE: things that the user might want to adjust are marked with "*CUSTOM," followed by instructions

clear
capture log close
*cd c:\work\m14
*log using c:\work\m14\wage_gap, replace text  
*cd n:\km619\work\m14
*log using n:\km619\work\m14\wage_gap, replace text  
*use migstructure_final
*use migstructure4
*use migstructure_final_dups_cleaned_with_cons

log using wage_gap, replace text
use migstructure_final_dups_cleaned_with_cons_land
egen stid=group(state)
egen stcst=group(state caste)

*drop data that we won't use
keep if icrisat
keep if cvsq < 100
by stcst, sort: egen castepop = count(pminc)
drop if castepop < 30

* construct education categories from REDS data

gen edcat=1 if ed==0
replace edcat=2 if ed>=1 & ed<=4
replace edcat=3 if ed==5
replace edcat=4 if ed>=6 & ed<=9
replace edcat=5 if ed>=10

* rural wage
gen rw=40.614 if edcat==1
replace rw=49.104 if edcat==2
replace rw=52.571 if edcat==3
replace rw=58.701 if edcat==4
replace rw=109.174 if edcat==5

* real wage-gaps by educational category
gen wage_gap = 49.354-40.614 if edcat==1
replace wage_gap = 62.840-49.104 if edcat==2
replace wage_gap = 65.992-52.571 if edcat==3
replace wage_gap = 74.424-58.701 if edcat==4
replace wage_gap = 163.188-109.174 if edcat==5

* real wage-gaps by educational category (with moving costs)
gen wage_gap_adj = 45.571-40.614 if edcat==1
replace wage_gap_adj = 58.266-49.104 if edcat==2
replace wage_gap_adj = 61.095-52.571 if edcat==3
replace wage_gap_adj = 68.956-58.701 if edcat==4
replace wage_gap_adj = 153.017-109.174 if edcat==5


* construct income-change

gen income_change=(312*wage_gap)/(0.05*landval+312*q15*rw)
gen income_change_adj=(312*wage_gap_adj)/(0.05*landval+312*q15*rw)

summ income_change, detail
summ income_change_adj, detail


*construct absolute income classes
*CUSTOM - select number of absolute income classes
local ai = 5
gen absinc = `ai'
sort pminc edcat villageid q3
gen absinc_class = int((_n-1)*absinc/_N)

*find max income for each income class
bys absinc_class (pminc edcat villageid q3): egen cutoff = max(pminc)
tab absinc_class, gen(cutoff)

forvalues i = 1/`ai' {
replace cutoff`i' = cutoff if cutoff`i'
replace cutoff`i' = . if cutoff`i' == 0
egen meancut = mean(cutoff`i')
replace cutoff`i' = meancut
drop meancut
}
drop cutoff

*CUSTOM -whether to use income_change or income_change_adj
gen inc_change = income_change

forvalues i = 1/`ai' {
egen inc_change_abs`i' = mean(inc_change) if absinc_class == (`i'-1)
egen mig_abs`i' = mean(mig1) if absinc_class == (`i'-1)
egen inc_change_abs = mean(inc_change_abs`i')
egen mig_abs = mean(mig_abs`i')
replace inc_change_abs`i' = inc_change_abs
replace mig_abs`i' = mig_abs
gen pnu`i' = -ln(mig_abs`i'/2)/ln(1 + inc_change_abs`i')
drop inc_change_abs mig_abs
}

*generating relative (within-caste) income class
/*
* aggregating by caste and income class
egen p20=pctile(pminc), p(20) by(castecode)
egen p40=pctile(pminc), p(40) by(castecode)
egen p60=pctile(pminc), p(60) by(castecode)
egen p80=pctile(pminc), p(80) by(castecode)

gen inc_rank=0 if pminc<=p20
replace inc_rank=1 if pminc>p20 & pminc<=p40
replace inc_rank=2 if pminc>p40 & pminc<=p60
replace inc_rank=3 if pminc>p60 & pminc<=p80
replace inc_rank=4 if pminc>p80 

egen mincome_change=mean(income_change), by(castecode inc_rank)

sort castecode inc_rank
by castecode inc_rank: keep if _n==1

sort inc_rank
by inc_rank: summ mincome_change if total>=30 & cvsq<100 & icrisat==1, detail
*/

quietly bys stcst (pminc q3): gen f=(_n-1)/_N
*CUSTOM - specify number of relative income groups
gen ri = 5
gen inccat=int(f*ri)

gen byte notmig = 0
replace notmig = 1 if mig1 != 1

*collapse into relative income groups

collapse  (count) pop=pminc (mean) pminc pvarinc mig1 (sum) notmig (mean) ptcon = ptconr4 cutoff* inc_change* pnu*, by(stid stcst inccat)

*redefine absolute income classes (and nus) using cutoffs from above

gen absinc_class = 0 if pminc <= cutoff1
gen pnu = pnu1 if absinc_class == 0

forvalues i = 1/`ai' {
replace absinc_class = `i' if pminc > cutoff`i'
local j = `i' + 1
capture gen pnu`j' = .
replace pnu = pnu`j' if absinc_class == `i'
}
assert pnu < .

*construct predicted lambda from REDS consumption data
by stcst, sort: gen lamaut = pminc/pminc[_N]
by stcst: gen plam = ptcon/ptcon[_N]
replace plam = lamaut if plam < lamaut
replace plam = 1 if plam > 1


*prepare to generate data for Maple
count
order pop inccat pminc pvarinc mig1 stcst stid absinc_class notmig plam pnu
sort stid stcst inccat
disp _N/(inccat[_N]+1)

outfile pop inccat pminc pvarinc mig1 stcst stid absinc_class notmig plam pnu using data, replace wide

*display nus for each absolute income class
list pnu1-pnu`ai' in 1

save rawdata_wagegap.dta, replace

log close
