/* World Bank Enterprise Survey Analysis.do */
* Sampling methodology: http://www.enterprisesurveys.org/~/media/FPDKM/EnterpriseSurveys/Documents/Methodology/Sampling_Note.pdf
* Questions: http://www.enterprisesurveys.org/nada/index.php/catalog/444/datafile/F1/?offset=100&limit=100

* Note: average duration of cut appears to be sometimes reported in minutes and other times reported in hours. Don't use this, and thus don't use the TotalCutHours variable.

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
***********************************

/* DATA PREP */



/* Prep WBES */
insheet using "$data/World Bank Enterprise Survey/CityandState2005.csv", comma names clear
save "$intdata/World Bank Enterprise Survey/CityandState2005.dta", replace

use "$data/World Bank Enterprise Survey/India-2005--full data-999.dta", clear
** Get state
merge m:1 code3 using "$intdata/World Bank Enterprise Survey/CityandState2005.dta", keep(match master) keepusing(state) nogen // 6 don't match - they have code3=.
encode state, gen(statenum)

** Give variables understandable names
rename r6_1a1 NumberofCuts
rename r6_1b1 AverageDurationofCut
rename r6_1c1 PercentLossesfromCuts
rename r6_2e CostofGeneratedElectricity
rename r6_2f CostofGridElectricity
rename r6_8a QualityofPower

rename r11_5ab ElectricityGrowthProblem
rename r11_5b1 GrowthProblem_1
rename r11_5b2 GrowthProblem_2
rename r11_5b3 GrowthProblem_3

rename r13_1a1 R // Total sales
rename r13_1a2 M // Cost of materials and intermediate inputs
rename r13_1a3 EnergyCosts // Total energy costs
rename r13_1a4 E // Power costs
rename r13_1a5 FuelCosts // Fuel Costs
rename r13_1a6 SW // "Total cost of labor"
rename r14_2a3 L // Average number of workers in 2004

gen OwnGenerator = cond(r6_2==1,1,0) if r6_2!=.
rename r6_2a SGS
replace SGS=0 if OwnGenerator==0

rename code3 city
rename code2 industry

keep state statenum NumberofCuts AverageDurationofCut PercentLossesfromCuts SGS CostofGeneratedElectricity CostofGridElectricity QualityofPower OwnGenerator ///
	ElectricityGrowthProblem GrowthProblem_? ///
	R L ///
	city industry
	
/* Generate additional variables */
** Logs
foreach var in R L {
	gen ln`var' = ln(`var')
}

** Total cut hours
gen TotalCutHours = NumberofCuts*AverageDurationofCut

** Growth problem
gen ElectricityTopGrowthProblem = 0
forvalues p = 1/1 {
	replace ElectricityTopGrowthProblem = ElectricityTopGrowthProblem + 1/`p' if (GrowthProblem_`p' == "B"|GrowthProblem_`p' == "ELECTRICITY")
}



** Merge CEA shortage measures
gen year = 2005
merge m:1 state year using "$work\PDPM-PSP Merged.dta", nogen keepusing(Shortage PeakShortage) keep(match master)


/* Other data prep*/
** Indicators
char state[omit] "MAHARASHTRA"
char industry[omit] 2
xi i.state, pre(_S)
xi i.industry, pre(_I) 

** Logs
*gen lnTotalCutHours = ln(TotalCutHours)
gen lnNumberofCuts = ln(NumberofCuts)

** Labels
label var lnL "ln(Workers)"
label var lnNumberofCuts "ln(Number of Cuts)"
*label var lnTotalCutHours "ln(Annual Shortage Hours)"
label var PercentLossesfromCuts "Percent Losses from Cuts"
label var OwnGenerator "1(Own Generator)"
label var SGS "Self Generation Share"
label var ElectricityTopGrowthProblem "Top Growth Problem"

gen Large = cond(L>=100,1,0)
replace Large = . if L==.


save "$work/WBES2005.dta", replace


/* BIGGEST PROBLEM FOR GROWTH */
use "$work/WBES2005.dta", clear
*drop if Large==.

** biggest obstacle for operation/growth
tab GrowthProblem_1
* B: Electricity
* D: Access to land
* E: High taxes
* F: Tax administration
* H: Labor regulations
* I: Skills and education of available workers
* K:  Access to financing (e.g. collateral)
* O: Corruption


** second obstacle for operation/growth
tab GrowthProblem_2
* C: Transportation
* G: Customs and trade regulations
* L: Cost of financing (e.g. interest rates)

gen N = 1
drop if GrowthProblem_1==""|GrowthProblem_1=="-777"|GrowthProblem_1=="BLANK"|GrowthProblem_1=="NONE"|GrowthProblem_1=="NA"|GrowthProblem_1=="N A"
replace GrowthProblem_1="B" if GrowthProblem_1=="ELECTRICITY"
replace GrowthProblem_1="E" if GrowthProblem_1=="TAX" // High taxes
replace GrowthProblem_1="I" if GrowthProblem_1=="LABOUR" // Assume "skills and education of available workers"

gen GrowthProblem = "Other"
replace GrowthProblem = "Electricity" if GrowthProblem_1=="B"
replace GrowthProblem = "Access to Land" if GrowthProblem_1=="D"
replace GrowthProblem = "High Taxes" if GrowthProblem_1=="E"
replace GrowthProblem = "Tax Administration" if GrowthProblem_1=="F"
replace GrowthProblem = "Customs and Trade Regulations" if GrowthProblem_1=="G"
replace GrowthProblem = "Labor Regulations and Business Licensing" if GrowthProblem_1=="H"|GrowthProblem_1=="J"
replace GrowthProblem = "Skills and Education of Available Workers" if GrowthProblem_1=="I"

replace GrowthProblem = "Cost of and Access to Financing" if GrowthProblem_1=="K"|GrowthProblem_1=="L"
*replace GrowthProblem = "Cost of Financing (e.g. interest rates)" if GrowthProblem_1=="J"
replace GrowthProblem = "Corruption" if GrowthProblem_1=="O"


collapse (sum) N, by(GrowthProblem)

egen sumN = sum(N)
gen Percent = N/sumN
gen Other = cond( GrowthProblem=="Other",1,0)
gsort Other -Percent

order GrowthProblem Percent
keep GrowthProblem Percent

outsheet using "$work/WBESBiggestProblem.csv", comma names replace


/* TABLE: LARGE VS. SMALL PLANTS */
use "$work/WBES2005.dta", clear
drop if Large==.
tab Large
bysort Large: sum L
bysort Large: sum R, detail

bysort Large: sum NumberofCuts, detail

bysort Large: sum OwnGenerator
bysort Large: sum SGS

bysort Large: sum CostofGeneratedElectricity CostofGridElectricity, detail, if CostofGeneratedElectricity!=.&CostofGridElectricity!=.

bysort Large: sum PercentLossesfromCuts

drop if GrowthProblem_1==""|GrowthProblem_1=="-777"|GrowthProblem_1=="BLANK"|GrowthProblem_1=="NONE"|GrowthProblem_1=="NA"|GrowthProblem_1=="N A"
bysort Large: sum ElectricityTopGrowthProblem

ddd
/* Graph: Small vs. Large Plants */
use "$work/WBES2005.dta", clear
gen LargeName = cond(Large==1,">=100 Employees","<100 Employees")
gen GeneratorName = cond(OwnGenerator==1,"Have Generator","No Generator")
graph box PercentLossesfromCuts, noout over(LargeName, sort(Large)) legend(off) ///
	title(Reported Losses for Small vs. Large Plants) ytitle(Percent Loss from Cuts) ///
	graphregion(color(white) lwidth(medium))

graph box PercentLossesfromCuts, noout over(GeneratorName , sort(GeneratorName)) legend(off) ///
	title(Reported Losses for Plants With and Without Generators) ytitle(Percent Loss from Cuts) ///
	graphregion(color(white) lwidth(medium))

graph bar PercentLossesfromCuts, over(Large, relabel(1 "<100 Employees" 2 ">=100 Employees")) ///
	ytitle(Mean Percent Loss from Cuts) title(Reported Losses for Small vs. Large Plants) ///
	graphregion(color(white) lwidth(medium))
	graph export "$analyses/WBESLargeSmall.emf", replace as(emf)

graph bar PercentLossesfromCuts, over(OwnGenerator, relabel(1 "No Generator" 2 "Have Generator")) ///
	ytitle(Mean Percent Loss form Cuts) title(Reported Losses for Plants With and Without Generators) ///
	graphregion(color(white) lwidth(medium))
	graph export "$analyses/WBESGenerator.emf", replace as(emf)


/* REGRESSIONS: EFFECTS OF REPORTED POWER CUTS */
use "$work/WBES2005.dta", clear

*** WBES shortage measure
reg PercentLossesfromCuts lnNumberofCuts, robust
	outreg using "$RegResults/WBESShortageCorrelations1", se replace varlabels tex fragment starlevels(10 5 1) keep(lnNumberofCuts) basefont(footnotesize) ///
	ctitles("","(1)"\"","Percent"\"","Loss") hlines(1101{0}1)
reg OwnGenerator lnNumberofCuts, robust
	outreg using "$RegResults/WBESShortageCorrelations1", se replace merge varlabels tex fragment starlevels(10 5 1) keep(lnNumberofCuts) basefont(footnotesize) ///
	ctitles("","(2)"\"","1(Own"\"","Generator)") hlines(1101{0}1)
reg SGS lnNumberofCuts, robust
	outreg using "$RegResults/WBESShortageCorrelations1", se replace merge varlabels tex fragment starlevels(10 5 1) keep(lnNumberofCuts) basefont(footnotesize) ///
	ctitles("","(3)"\"","Self-Gen"\"","Share") hlines(1101{0}1)
reg ElectricityTopGrowthProblem lnNumberofCuts, robust
	outreg using "$RegResults/WBESShortageCorrelations1", se replace merge varlabels tex fragment starlevels(10 5 1) keep(lnNumberofCuts) basefont(footnotesize) ///
	ctitles("","(4)"\"","1(Top"\"","Problem)") hlines(1101{0}1)

*** Conditioning on industry:
	* This doesn't change the coefficients
reg PercentLossesfromCuts lnNumberofCuts _I* lnL, robust cluster(state)
reg OwnGenerator lnNumberofCuts _I* lnL, robust cluster(state)
reg SGS lnNumberofCuts _I* lnL, robust cluster(state)
reg ElectricityTopGrowthProblem lnNumberofCuts _I* lnL, robust cluster(state)

	
*** Conditioning on state:
	* This does change some of the coefficients.
	* OwnGenerator and SGS go to statistically zero. PercentLosses changes. ElectricityTopGrowthProblem does not.
reg PercentLossesfromCuts lnNumberofCuts _S*, robust
reg OwnGenerator lnNumberofCuts _S*, robust
reg SGS lnNumberofCuts _S*, robust
reg ElectricityTopGrowthProblem lnNumberofCuts _S*, robust



/* STYLIZED FACTS ACROSS ALL PLANTS */
use "$work/WBES2005.dta", clear
** [In fiscal 2005] how often [apparently how many times] did your establishment experience power outages or surges?
sum NumberofCuts, detail
	* Median = 48

** What was the average duration of power outages or surges?
sum AverageDurationofCut, detail
	* Median = 2, mean = 5.21
	* Problem: we don't know if this is minutes or hours. Some values very large, suggesting minutes. But then not clear what to do with values around 5. Is this minutes or hours?
	



** Does your establishment own or share a generator?
	tab OwnGenerator
	* Yes=1, No = 2
	* 52% own or share generators.

** What percent of your electricity comes from the generator?
	sum SGS, detail
	* Median = 15%, mean = 22%
	
** What is the average cost in Rs/kWh for generator electricity (2e) and public grid electricity (2f)?
sum CostofGeneratedElectricity CostofGridElectricity, detail, if CostofGeneratedElectricity!=.&CostofGridElectricity!=.


** What were your percentage losses from power outages or surges?
sum PercentLossesfromCuts, detail
	* Median = 5, mean = 7.78
	
	* For generators vs. non-generators (for table at end of simulations)
	tab OwnGenerator, sum(PercentLossesfromCuts)

/* Qualitative Ratings */
** Rate the quality of power
sum QualityofPower


** Problem for operation/growth: electricity 
tab ElectricityGrowthProblem
*0	 no obstacle	 704	 30.9%
*1	 minor obstacle	 293	 12.9%
*2	 moderate obstacle	 461	 20.2%
*3	 major obstacle	 340	 14.9%
*4	 very severe obstacle 21.1%





********************************************
********************************************


/* HOW DOES THIS DIFFERENTIALLY IMPACT DIFFERENT INDUSTRIES AND STATES? */
/* Regressions with microdata */
use "$work/WBES2005.dta", clear

*** CEA shortage measure
reg lnNumberofCuts Shortage _I* lnL, robust cluster(state)
	outreg using "$RegResults/WBESShortageCorrelations", se replace varlabels tex fragment starlevels(10 5 1) keep(Shortage lnL) basefont(footnotesize) ///
	ctitles("","Cuts per"\"","Year")
reg PercentLossesfromCuts Shortage _I* lnL, robust cluster(state)
	outreg using "$RegResults/WBESShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) keep(Shortage lnL) basefont(footnotesize) ///
	ctitles("","Percent"\"","Loss")
reg OwnGenerator Shortage _I* lnL, robust cluster(state)
	outreg using "$RegResults/WBESShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) keep(Shortage lnL) basefont(footnotesize) ///
	ctitles("","1(Own"\"","Generator)")
reg SGS Shortage _I* lnL, robust cluster(state), if OwnGenerator==1
	outreg using "$RegResults/WBESShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) keep(Shortage lnL) basefont(footnotesize) ///
	ctitles("","Self-Gen"\"","Share")
reg ElectricityTopGrowthProblem Shortage _I* lnL, robust cluster(state)
	outreg using "$RegResults/WBESShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) keep(Shortage lnL) basefont(footnotesize) ///
	ctitles("","Top"\"","Problem")



/* State-Level Averages */
global OutcomeVars = "lnNumberofCuts PercentLossesfromCuts OwnGenerator SGS ElectricityTopGrowthProblem"
/* Get unconditional averages */
foreach var in $OutcomeVars {
	gen `var'_med = `var'
}


collapse (median) *_med (mean) $OutcomeVars, by(state)
drop if state==""
save "$intdata/World Bank Enterprise Survey/WBESStateShortageMeasures.dta", replace



/* Condition on industry */
use "$work/WBES2005.dta", clear



** Need to re-label variables to make outreg and the spreadsheet re-import correctly given the code below
foreach var in $OutcomeVars {
	label var `var' "`var'"
}


foreach var in $OutcomeVars {
*foreach var in TotalCutHours {
	reg `var' _S* _I* lnL, robust
		mat `var'_mean = e(b)'
		if "`var'" == "lnNumberofCuts" {
			outreg using "$work/WBESStateandIndustryRegs", se replace varlabels
			*matrix results = `var'_mean
		}
		else {
			outreg using "$work/WBESStateandIndustryRegs", se replace varlabels merge
			*matrix results = results,`var'_mean
		}
	qreg `var' _S* _I* lnL
		mat `var'_med = e(b)'
		*matrix results = results,`var'_med
		outreg using "$work/WBESStateandIndustryRegs", se replace varlabels merge
}



/* Construct state shortage measures data */
** Before doing the below: first make WBESStateandIndustryRegs as csv file and save.
insheet using "$intdata/World Bank Enterprise Survey/WBESStateandIndustryRegs.csv", comma names clear case
drop if substr(v1,1,5)!="state"
rename v1 state
replace state = substr(state,8,length(state)-7)


** Rename variables
rename v3 lnNumberofCuts_qreg
rename v5 PercentLossesfromCuts_qreg
rename v9 SGS_qreg

foreach var in $OutcomeVars {
	rename `var' `var'_reg
}


drop v7 v11 // Top growth problem and own generator - there is no point in reporting the median regression results. OwnGenerator is binary, and TopGrowthProblem is sort of binary.
destring   lnNumberofCuts_reg lnNumberofCuts_qreg PercentLossesfromCuts_reg PercentLossesfromCuts_qreg OwnGenerator_reg SGS_reg SGS_qreg ElectricityTopGrowthProblem_reg, replace force ignore(",")


** Maharashtra was the constant. Replace as zero here.
sum PercentLossesfromCuts_reg
local N_1 = r(N)+1
set obs `N_1'
foreach var of varlist _all {
	capture replace `var' = 0 if _n==_N
}
replace state="MAHARASHTRA" if _n==_N


merge 1:1 state using "$intdata/World Bank Enterprise Survey/WBESStateShortageMeasures.dta", nogen
gen year = 2005
save "$intdata/World Bank Enterprise Survey/WBESStateShortageMeasures.dta", replace
