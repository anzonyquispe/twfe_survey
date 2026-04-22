/*** THIS FILE:
* takes the raw nss compiled data in nss_raw_data.dta (NSS employment unemployment 
rounds + UDEL rainfall data) and generates the variables used in the main analysis.

It outputs the dataset nss_replication.dta. To replicate the main exhibits in the
paper, one can directly open that dataset and run the regressions.
*/

set more off

clear
use nss_raw_data.dta

************************************************************
*  IDENTIFIERS
************************************************************
* Identifier variables
egen stateyr = group(stateid round)
egen regionyr = group(regionid round)

* unique hh-round-visit tag
by round hid visit, sort: gen hid_1 = 1 if _n==1
* unique individual-round-visit tag
by round hid indiv visit, sort: gen indiv_visit_1 = 1 if _n==1
* unique individual-round tag
by round hid indiv, sort: gen indiv_1 = 1 if _n==1
label var hid_1 "unique hh-round-visit tag"
label var indiv_visit_1 "unique individual-round-visit tag"
label var indiv_1 "unique individual-round tag"

gen year = ryear
label var year "agricultural year"

gen day = substr(datesurvey,1,2)
gen month = substr(datesurvey,3,2)
gen year_cal = substr(datesurvey,5,2) 
destring month, replace
destring day, replace
label var day "day of survey (later rounds only)"
label var month "month of survey (later rounds only)"
label var year_cal "calendar year of survey (later rounds only)"

* no district identifiers in earlier rounds - use regions when districts not available
gen districtname_allRs = districtname
replace districtname_allRs = regionname if round==38 | round==43 | round==50
label var districtname_allRs "district name (later rounds) or region name (rounds<=50)"

egen dist = group(statename districtname_allRs)
label var dist "district identifier"

* unique district-round tag - one observation per distid in each round
by round dist, sort: gen dist_1=1 if _n==1
label var dist_1 "unique district-round tag"


************************************************************
*  EMPLOYMENT STATUS VARIABLES
************************************************************

* boolean for agricultural household (based on household status in HH module)
gen aghh = 0
replace aghh = 1 if hhtype==2 | hhtype==4
label var aghh "1{agricultural household (based on household status)}"

* individual's usual or subsidiary status across the year is agricultural work
gen usualag = 0
replace usualag = 1 if (usualstatus>=11 & usualstatus<=21) | usualstatus==51 | (subsidstatus>=11 & subsidstatus<=21) | subsidstatus==51 
label var usualag "1{indiv's usual or subsidiary status across year is agri work}"

* individual's usual (primary) status across the year is casual labor wage work
gen usualab1 = 0
replace usualab1 = 1 if usualstatus==51
label var usualab1 "1{indiv's usual status across year is casual labor wage work}"
* individual's usual or subsidiary status across the year is casual labor wage work
gen usualab2 = 0
replace usualab2 = 1 if usualstatus==51 | subsidstatus==51
label var usualab2 "1{indiv's usual or subsidiary status across year is casual labor wage work}"

* identify status in 7 day employment grid as agricultural work (own farm or outside wage work)
gen agstatus = 0
replace agstatus = 1 if (status>=11 & status<=21) | status==51 
label var agstatus "1{activity type in empl grid is agri work (own farm or wage labor)}"

* identify status in 7 day employment grid as work on own farm
gen ownstatus = 0
replace ownstatus = 1 if (status>=11 & status<=21) 
label var ownstatus "1{activity type in empl grid is own farm work}"



************************************************************
*  EMPLOYMENT VARIABLES
************************************************************
/* Note:
Agricultural work is identified as work activity corresponding to agricultural 
operations. It includes all operations that fall within the period of monsoon 
arrival to harvesting: sowing, transplanting, weeding, and harvesting. These
correspond to operation codes 2-5 in the data. 

Round 62 of the NSS data does not provide operation codes; for this round, 
agricultural work is classified as all work with industry code 1 (i.e. 
agriculture). This is less precise but enables one to include round 62 in the
analysis.
*/

****** INDIVIDUAL LEVEL EMPLOYMENT *******
sort round hid indiv visit srl status

* Number of days in past week individual did agri work (sowing, transplanting, weeding, harvesting)
by round hid indiv visit: egen temp1 = total(totdays) if usualag==1 & agstatus==1 & operation>=2 & operation<=5 & round!=62
by round hid indiv visit: egen temp2 = total(totdays) if usualag==1 & agstatus==1 & industry==1 & round==62
gen temp3 = temp1 if round!=62
replace temp3 = temp2 if round==62
by round hid indiv visit: egen agemp = max(temp3) if usualag==1
by round hid indiv visit: replace agemp = 0 if usualag==1 & agemp==.
by round hid indiv visit: replace agemp = . if _n!=1
drop temp*
label var agemp "indiv's days of agri employmt in past week (own farm + wage labor)"

* Number of days in past week individual was employed as wage laborer in non-agri work
by round hid indiv visit: egen temp1 = total(totdays) if usualag==1 & status==51 & (operation<1 | operation==11 | operation>13) & (round==38 | round==50 | round==55)
by round hid indiv visit: egen temp2 = total(totdays) if usualag==1 & status==51 & (operation<1 | operation==12 | operation>14) & (round==60 | round==61 | round==64 | round==66)
by round hid indiv visit: egen temp3 = total(totdays) if usualag==1 & status==51 & (operation<1 | operation>5) & (round==43)
by round hid indiv visit: egen temp4 = total(totdays) if usualag==1 & status==51 & industry!=1 & round==62
gen temp5 = temp1 if (round==38 | round==50 | round==55)
replace temp5 = temp2 if (round==60 | round==61 | round==64 | round==66)
replace temp5 = temp3 if (round==43)
replace temp5 = temp4 if (round==62)
by round hid indiv visit: egen hiredemp = max(temp5) if usualag==1
by round hid indiv visit: replace hiredemp = 0 if usualag==1 & hiredemp==.
by round hid indiv visit: replace hiredemp = . if _n!=1
drop temp*
label var hiredemp "indiv's days of non-agri employmt in past week"


****** HOUSEHOLD LEVEL EMPLOYMENT *******
sort round hid visit

* total agri employment (own land + wage labor)
* ops 2-5 only: HH type is in agric
by round hid visit: egen temp1 = total(totdays) if aghh==1 & agstatus==1 & operation>=2 & operation<=5 & round!=62
by round hid visit: egen temp2 = total(totdays) if aghh==1 & agstatus==1 & industry==1 & round==62
gen temp3 = temp1 if round!=62
replace temp3 = temp2 if round==62
by round hid visit: egen hhagemp = max(temp3) if aghh==1 
by round hid visit: replace hhagemp = 0 if aghh==1 & hhagemp==.
by round hid visit: replace hhagemp = . if _n!=1
drop temp*
label var hhagemp "HH's total days of agri employmt in past week (own farm + wage labor)"

* HH's external wage labor employment
* ops 2-5 only: HH type is in agric 
by round hid visit: egen temp1 = total(totdays) if aghh==1 & agstatus==1 & status==51 & operation>=2 & operation<=5 & round!=62
by round hid visit: egen temp2 = total(totdays) if aghh==1 & agstatus==1 & status==51 & industry==1 & round==62
gen temp3 = temp1 if round!=62
replace temp3 = temp2 if round==62
by round hid visit: egen hhlabemp = max(temp3) if aghh==1 
by round hid visit: replace hhlabemp = 0 if aghh==1 & hhlabemp==.
by round hid visit: replace hhlabemp = . if _n!=1
drop temp*
label var hhlabemp "HH's total days of agri wage labor employmt in past week"


* HH's employment on own farm
* ops 2-5 only: HH type is in agric
by round hid visit: egen temp1 = total(totdays) if aghh==1 & agstatus==1 & ownstatus==1 & operation>=2 & operation<=5 & round!=62
by round hid visit: egen temp2 = total(totdays) if aghh==1 & agstatus==1 & ownstatus==1 & industry==1 & round==62
gen temp3 = temp1 if round!=62
replace temp3 = temp2 if round==62
by round hid visit: egen hhownemp = max(temp3) if aghh==1 
by round hid visit: replace hhownemp = 0 if aghh==1 & hhownemp==.
by round hid visit: replace hhownemp = . if _n!=1
drop temp*
label var hhownemp "HH's total days of work on own farm in past week"


************************************************************
*  WAGES VARIABLES
************************************************************

* create earn var = totalearnings in whole rupees with decimals corrected
gen earn = totearn/100 if round==38 | round==43 | round==50
replace earn = totearn if round==55 | round==60 | round==61 | round==62 | round==64 | round==66
label var earn "indiv's earnings in past week from given activity in 7 day grid"

* wage for all activities - defined only when positive payment (most analysis based on this)
gen dailywage = earn/totdays
replace dailywage=. if earn==. | earn==0
label var dailywage "indiv's avg daily wage in past week from given activity in 7 day grid"

* daily agri wage - casual labor (operations 2-5 - see note above on how agri empl is defined)
gen wage = dailywage if operation>=2 & operation<=5 & round!=62 & status==51
replace wage = dailywage if industry==1 & round==62 & status==51
gen lwage = log(wage)
label var wage "daily wage for agricultural wage labor"
label var lwage "log daily wage for agricultural wage labor"


/* CASH AND IN-KIND EARNINGS - for robustness in appendix tables only
* cash & inkind wages: whole rupees with decimals corrected
* cash earnings
gen cash = cashearn/100 if round==38 | round==43 | round==50
replace cash = earncash if round==55
replace cash = cashearn if round==60 | round==61 | round==62 | round==64 | round==66
replace cash = 0 if dailywage!=. & cash==.
* in kind earnings
gen kind = kindearn/100 if round==38 | round==43 | round==50
replace kind = earnkind if round==55
replace kind = kindearn if round==60 | round==61 | round==62 | round==64 | round==66
replace kind = 0 if dailywage!=. & kind==.

* proportion cash & inkind
gen cashprop = cash/earn
gen kindprop = kind/earn
	* note for round 55: cash + kind < earn for 30% of observations, because cash = kind = 0
	* flag for proportional sum stats later
	gen cashkind_flag55 = ( (cash + kind != earn) & round==55 )
* cash daily wage
gen dailycash = cash/totdays
gen dailykind = kind/totdays

* cash and kind daily wage
* only operations 2-5
gen cwage = dailycash if operation>=2 & operation<=5 & round!=62 & status==51
replace cwage = dailycash if industry==1 & round==62 & status==51
gen lcwage = log(cwage)

gen kwage = dailykind if operation>=2 & operation<=5 & round!=62 & status==51
replace kwage = dailykind if industry==1 & round==62 & status==51
gen lkwage = log(kwage)

* boolean for piece rate contract
gen piecerate = 1 if paymode<=15 & paymode!=.
replace piecerate = 0 if paymode>=16 & paymode!=.
*/

************************************************************
*  RAINFALL SHOCK VARIABLES
************************************************************

/* Define rainfall shocks
	Shocks are based on rain in usual arrival month of monsoon for that state.
	Define as rainfall above and below 80th and 20th percentile of district's usual rainfall distribution in the month of monsoon arrival.
	In some states, the month of monsoon arrival is June, and in others it is July (latestate). 
	Which states receive the monsoon earlier vs. later is based on the monsoon patterns from Indian Meteorological Service.

	Note: cut-offs used in paper for positive and negative shocks are 80th and 20th percentile, respectively.
	The below also computes shocks using alternate cut-offs for 70th and 75th percentiles, and 25th and 30th percentiles to show robustness (see Appendix Table 8)
*/

* positive shocks:
* note - main specification uses 80th pctile cutoff - rest for robustness checks in appendix
foreach p of numlist 70 75 80 {
	gen amons`p' = (rain6 >= m6p`p')
	replace amons`p' = (rain7 >= m7p`p') if latestate==1
	
	gen lamons`p' = (lagrain6 >= m6p`p')
	replace lamons`p' = (lagrain7 >= m7p`p') if latestate==1
	
	gen l2amons`p' = (lag2rain6 >= m6p`p')
	replace l2amons`p' = (lag2rain7 >= m7p`p') if latestate==1
	
	gen l3amons`p' = (lag3rain6 >= m6p`p')
	replace l3amons`p' = (lag3rain7 >= m7p`p') if latestate==1
	
	label var amons`p' "amonsP = 1{rain in monsoon arrival month is above Pth pctile this year}"
	label var lamons`p' "lamonsP = 1{rain in monsoon arrival month was above Pth pctile last year}"
	label var l2amons`p' "l2amonsP = 1{rain in monsoon arrival month was above Pth pctile 2 years ago}"
	label var l3amons`p' "l3amonsP = 1{rain in monsoon arrival month was above Pth pctile 3 years ago}"
}

* negative shocks:
* note - main specification uses 20th pctile cutoff - rest for robustness checks in appendix
foreach p of numlist 20 25 30 {
	gen bmons`p' = (rain6 < m6p`p')
	replace bmons`p' = (rain7 < m7p`p') if latestate==1
	
	gen lbmons`p' = (lagrain6 < m6p`p')
	replace lbmons`p' = (lagrain7 < m7p`p') if latestate==1
	
	label var bmons`p' "bmonsP = 1{rain in monsoon arrival month is below Pth pctile this year}"
	label var lbmons`p' "lbmonsP = 1{rain in monsoon arrival month was below Pth pctile last year}"
}


* shorthand
gen pos = (amons80==1)
gen neg = (bmons20==1)
gen lpos = (lamons80==1)
gen lneg = (lbmons20==1)
gen zero = (amons80==0 & bmons20==0)
gen lzero = (lamons80==0 & lbmons20==0)

label var pos "positive shock this year (amons80==1)"
label var neg "negative shock this year (bmons20==1)"
label var lpos "positive shock last year (lamons80==1)"
label var lneg "negative shock last year (lbmons20==1)"
label var zero "no shock this year (bmons20==0 & amons80==0)"
label var lzero "no shock last year (lbmons20==0 & lamons80==0)"


* create new lshock vars that are mutually exclusive from main shocks
* l2pos and l3pos are the lagged shock controls used in the specifications in paper
gen l1pos = (lamons80==1 & amons80==0)
gen l2pos = (l2amons80==1 & lamons80==0 & amons80==0)
gen l3pos = (l3amons80==1 & l2amons80==0 & lamons80==0 & amons80==0)

label var l1pos "pos shock last yr, no pos shock this year"
label var l2pos "pos shock 2 yrs ago, no pos shocks since then"
label var l3pos "pos shock 3 yrs ago, no pos shocks since then"


* SET OF SHOCK SEQUENCES: Last year shock, this year shock (3x3=9 cells)
* in shorthand: z=zero shock, p=pos shock, n=neg shock
* omitted category in regressions
gen zz = (lamons80==0 & lbmons20==0 & amons80==0 & bmons20==0)
gen nz = (lamons80==0 & lbmons20==1 & amons80==0 & bmons20==0)
* positive shock this year
gen zp = (lamons80==0 & lbmons20==0 & amons80==1 & bmons20==0)
gen pp = (lamons80==1 & lbmons20==0 & amons80==1 & bmons20==0)
gen np = (lamons80==0 & lbmons20==1 & amons80==1 & bmons20==0)
* non-positive shock last year, negative shock this year
gen zn = (lamons80==0 & lbmons20==0 & amons80==0 & bmons20==1)
gen nn = (lamons80==0 & lbmons20==1 & amons80==0 & bmons20==1)
gen nonpos_neg = (zn==1 | nn==1)
* lagged positive shock, followed by non-positive shock
gen pz = (lamons80==1 & lbmons20==0 & amons80==0 & bmons20==0)
gen pn = (lamons80==1 & lbmons20==0 & amons80==0 & bmons20==1)

label var zz "no shock last yr, no shock this yr"
label var nz "neg shock last yr, no shock this yr"
label var nz "neg shock last yr, no shock this yr"
label var zp "no shock last yr, pos shock this yr"
label var pp "pos shock last yr, pos shock this yr"
label var np "neg shock last yr, pos shock this yr"
label var zn "no shock last yr, neg shock this yr"
label var nn "neg shock last yr, neg shock this yr"
label var pn "pos shock last yr, neg shock this yr"
label var pz "pos shock last yr, no shock this yr"
label var nonpos_neg "non-pos shock last yr, neg shock this yr"



************************************************************
*  DEMOGRAPHIC VARIABLES
************************************************************

********* LAND ***********
* create landsize in acres
gen temp = landpossessed*0.4047/100 if round==38
replace temp = landpossessed/100 if round>=43 & round<=55
replace temp = landpossessed/1000 if round==61 | round==66
*  (rounds 60, 62, and 64 use codes - take min of each category bc more people there
replace temp = 0 if landpossessed==1 & (round==60 | round==62 | round==64)
replace temp = 0.005 if landpossessed==2 & (round==60 | round==62 | round==64)
replace temp = 0.02 if landpossessed==3 & (round==60 | round==62 | round==64)
replace temp = 0.21 if landpossessed==4 & (round==60 | round==62 | round==64)
replace temp = 0.41 if landpossessed==5 & (round==60 | round==62 | round==64)
replace temp = 1.01 if landpossessed==6 & (round==60 | round==62 | round==64)
replace temp = 2.01 if landpossessed==7 & (round==60 | round==62 | round==64)
replace temp = 3.01 if landpossessed==8 & (round==60 | round==62 | round==64)
replace temp = 4.01 if landpossessed==10 & (round==60 | round==62 | round==64)
replace temp = 6.01 if landpossessed==11 & (round==60 | round==62 | round==64)
replace temp = 8.01 if landpossessed==12 & (round==60 | round==62 | round==64)
* land variable in arces
gen land1_temp=temp*2.47105381
drop temp
* fill in missing land values as 0 landholding (most hhtype when missing are not self-employed in agric, so will have 0 cultivated land)
gen land = land1_temp
replace land = 0 if land1_temp==.
label var land1_temp "cultivated land (incomplete)"
label var land "cultivated landholding"

* land per capita in HH
gen landpercap = land/numadults
label var landpercap "land per capita (no. of adults) in HH"

* categorical variable for land per capita
gen lpc_cat = 1 if landpercap>0.01 & landpercap<=.4 //below median landholding (in terms of land per capita)
replace lpc_cat = 2 if landpercap>.4 & landpercap!=. //above median landholding (in terms of land per capita)
replace lpc_cat = 3 if landpercap<=.01 //landless labor household
label var lpc_cat "categorical variable - land per capita (landless, below median, above median)"
label define lpc_cat_lbl 1 "below median land" 2 "above median land" 3 "landless"
label values lpc_cat lpc_cat_lbl

* Interactions of land per capita categorical dummies with lpos shock dummy
tab lpc_cat, gen(lpc_cat_)
gen lposXlpc_cat_1 = lpos*lpc_cat_1
gen lposXlpc_cat_2 = lpos*lpc_cat_2
gen lposXlpc_cat_3 = lpos*lpc_cat_3
label var lpc_cat_1 "1{HH has below median land per capita landholding}"
label var lpc_cat_2 "1{HH has above median land per capita landholding}"
label var lpc_cat_3 "1{HH is landless}"
label var lposXlpc_cat_1 "lpos X lpc_cat_1"
label var lposXlpc_cat_2 "lpos X lpc_cat_2"
label var lposXlpc_cat_3 "lpos X lpc_cat_3"

* topcode cotninuous landper capital variable to trim gross outliers
gen lpc = landpercap
replace lpc = 3 if landpercap>3 & landpercap!=.
gen lpc_2 = lpc*lpc
label var lpc "land per capita (no. of adults) in HH - topcoded for outliers"
label var lpc_2 "lpc^2"

* Interactions of lpc with main shocks
gen lposXlpc = lpos*lpc
gen posXlpc = pos*lpc
gen nonpos_negXlpc = nonpos_neg*lpc
gen pnXlpc = pn*lpc
gen pzXlpc = pz*lpc
label var lposXlpc "interaction: lpos X lpc"
label var posXlpc "interaction: pos X lpc"
label var nonpos_negXlpc "interaction: nonpos_neg X lpc"
label var pnXlpc "interaction: pn X lpc"
label var pzXlpc "interaction: pz X lpc"


********* EDUCATION ***********
* categorical education variables
* not literate 
gen educ = 1 if educgen==0 & round<=43
replace educ = 1 if educgen==1 & round>43
* literate & no primary school
replace educ = 2 if educgen>=1 & educgen<=2 & round<=43
replace educ = 2 if educgen>=2 & educgen<=5 & (round==50 | round==55 | round==61 | round==62 | round==66)
replace educ = 2 if educgen>=2 & educgen<=3 & round==60
replace educ = 2 if educgen>=2 & educgen<=6 & round==64
* primary school
replace educ = 3 if educgen==3 & round<=43
replace educ = 3 if educgen==6 & (round==50 | round==55 | round==61 | round==62 | round==66)
replace educ = 3 if educgen==4 & round==60
replace educ = 3 if educgen==7 & round==64
* middle school
replace educ = 4 if educgen==4 & round<=43
replace educ = 4 if educgen==7 & (round==50 | round==55 | round==61 | round==62 | round==66)
replace educ = 4 if educgen==5 & round==60
replace educ = 4 if educgen==8 & round==64
* secondary school
replace educ = 5 if educgen==5 & round<=43
replace educ = 5 if educgen==8 & (round==50 | round==55 | round==61 | round==62 | round==66)
replace educ = 5 if educgen==6 & round==60
replace educ = 5 if educgen==10 & round==64
* above secondary
replace educ = 6 if educgen>5 & round<=43
replace educ = 6 if educgen>8 & (round==50 | round==55 | round==61 | round==62 | round==66)
replace educ = 6 if educgen>6 & round==60
replace educ = 6 if educgen>10 & round==64
* replace missing obs
replace educ = . if educgen==.
label var educ "categorical education variable (harmonized across rounds)"


***** MIGRATION & LABOR SUPPLY COMPOSITION VARIABLES **********
* LIKELIHOOD OF DECLARING IN AGRIC LF - only one obs per individual-round (for regressions)
sort round hid indiv
by round hid indiv: gen usualag_1 = usualag if _n==1
label var usualag_1 "usualag variable, with only 1 obs. per individual-round (for appendix regressions)"

* MIGRATION - IN MIGRATION VARIABLES
sort round hid indiv

* resdiff2 should equal 1 only if from different state & code so there is only one obs per indidividual-round (for regressions)
* use this version to test for in-migration; if inidividual migrated from locally, would have mechanically same rainfall shock and shouldnt be counted as migrant
gen resdiff2 = resdiff
replace resdiff2 = 0 if state==laststatecode
by round hid indiv: replace resdiff2 = . if _n!=1 //make so that only 1 obs per individual-round (for regressions)
label var resdiff2 "1{individual migrated into village from another state}"

* generate boolean - any migrants from outside hh in past year (use only those interviewed in q4 so reference period falls within 1 agri year)
gen anymig_y1q4 = 0 if outmigrants_y1q4==0
replace anymig_y1q4 = 1 if outmigrants_y1q4>0 & outmigrants_y1q4!=.
label var anymig_y1q4 "HH had any migrants from outside the HH in the past year"


************************************************************
*  MULTIPLERS & QUARTER (SUBROUND) IDENTIFIER
************************************************************

* MULTLPLIERS
destring mult*, replace

* Use instructions in NSS documentation for each round to create consistent harmonized multiplier variable
* all rounds except 55
gen mult1 = multiplier3 if round<=43
replace mult1 = multiplier3/100 if round==50
replace mult1 = mult_MLT/100 if round==60
replace mult1 = mult_MLT/200 if round==60 & mult_NSC>mult_NSS
replace mult1 = mult_MLT/200 if round>=61 & round!=.
replace mult1 = mult_MLT/100 if round>=61 & round!=. & mult_NSS==mult_NSC
* round 55
replace mult1 = multiplier/ss_replicate if round==55 & (stratum2==1 | stratum2==2)
replace mult1 = multiplier if round==55 & (stratum2==9)
label var mult1 "raw multiplier variable (before harmonization across rounds)"

gen mult = mult1
replace mult = mult1/4 if round==55
label var mult "multiplier variable (harmonized across rounds)"

* quarter - make consistently coded across rounds
gen quarter = subround if (round==38 | round==60)
replace quarter = 1 if subround==3 & round!=38 & round!=60
replace quarter = 2 if subround==4 & round!=38 & round!=60
replace quarter = 3 if subround==1 & round!=38 & round!=60
replace quarter = 4 if subround==2 & round!=38 & round!=60
label var quarter "quarter of year in which survey was conducted"

* Only keep observations that correspond to Kharif (monsoon) growing season - July-Jan (when harvesting of paddy finishes)
keep if (quarter>=3 |  (quarter==1 & month==1))

save data_nss_replication.dta, replace


