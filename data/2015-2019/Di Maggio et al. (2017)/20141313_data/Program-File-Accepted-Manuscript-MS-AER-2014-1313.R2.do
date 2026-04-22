/*

INTEREST RATE PASS-THROUGH: MORTGAGE RATES, HOUSEHOLD CONSUMPTION, AND VOLUNTARY DELEVERAGING

Authors: Di Maggio, Marco; Kermani, Amir; Keys, Benjamin J.; Piskorski, Tomasz; Ramcharan, Rodney; Seru, Amit; Yao, Vincent.

Data: 

Our primary mortgage sample (NonAgency.dta) comes from Blackbox Logic, a private company that provides a comprehensive, dynamic dataset with information on 90% of all privately securitized mortgages from that period, and consists of non-agency mortgage loans originated during the 2005-2007 period. Importantly, we restrict attention to prime borrowers for owner-occupied residencies. These mortgage records are then matched with credit bureau reports from Equifax. 

We use a similarly structured borrower-level panel dataset (Agency.dta) from a proprietary database of conforming loans securitized by a large secondary market participant. Unlike our main sample, this data consists of conforming ARMs issued with credit guarantees from the GSEs.

For the regional data analysis, we used individual loan-level information from two databases to compute regional ARM share. The first source is the BlackBox database, which as we discussed above, covers non-agency securitized mortgages in the United States. The second source is the LPS database maintained by Black Knight Financial Services, which provides similar dynamic information on agency and bank-held loans. We complement these datasets with the Equifax Credit Trends database, which contains zip-code-level consumer credit characteristics. In addition, we collect zip-code-level demographic information (e.g., median income, percentage of households with a college degree) from the Census Bureau’s American Community Survey, house price indices from Zillow, and employment data from the Census Bureau’s ZIP Business Patterns database. All of these datasets combine with the two loan-level information databases to form the regional dataset (Regional.dta).

*/

program define macros
	global maindir "/ARM/"
	global inputdir "${maindir}input/"
	global outputdir "${maindir}output/"
	global datafile1 "${inputdir}NonAgency.dta"
	/* Non-Agency ARM Data File*/
	global datafile2 "${inputdir}Agency.dta"
	/* Conforming ARM Data File*/
	global datafile3 "${inputdir}Regional.dta"
	/* Zip-Code Level (Regional) Conforming ARM Data File */
end

program define main
	macros
	Table1
	Table2
	Table3
	Table4
	Table5
	Table6
	Figures1
	Figures2
end

/*****************************************************************************
Table 1: Summary Statistics for Borrowers with Non-Agency and Conforming ARMs
******************************************************************************/

program define Table1

	*** Panel A: Summary Statistics for Borrowers with Non-Agency ARMs

	use `datafile1', clear

	label var fico "FICO"
	label var balance "Loan Balance"
	label var ltv "LTV"
	label var preIntRate "Initial Interest Rate"
	label var payment "Average Monthly Payment"
	label var car_pay "Monthly New Car Spending"
	label var borr_new_car "Fraction of Borrowers Buying New Car per Month"
	label var vol_debt_repay "Voluntary Mortgage Debt Repayment per Month"
	label var adj_int "Interest Rate after Adjustment for 5-year ARMs"
	label var monthly_adj_pay "Monthly Payment after Adjustment for 5-year ARMs"
	label val ARM5_type "Dummy Variable Equal to 1 if the Borrower has a 5-year ARM, 0 if the Borrower has a 10-year ARM"

	* Create table of summary statistics
	quietly estpost tabstat fico balance ltv preIntRate payment car_pay borr_new_car vol_debt_repay adj_int monthly_adj_pay, by(ARM_type) columns(statistics) statistics(mean sd)

	esttab using ${outputdir}Table1_PanelA.rtf, cells("mean(fmt(a2)) sd(fmt(a2))") label eqlabels("\bf{Borrowers with 10-Year ARMs}" "\bf{Borrowers with 5-Year ARMs}" ) noobs unstack replace main("mean") aux(sd)

	*** Panel B: Summary Statistics for Borrowers with Conforming ARMs


	/* 
	See program Table1, section Panel A for general summary statistic table structuring of Table 1: Panel B, but conduct analysis on conforming ARM data (Agency.dta).
	*/


end


/**************************************************************************************************************
Table 2: Impact of Rate Reductions on Monthly Mortgage Payments, New Car Spending, and Voluntary Debt Repayment
***************************************************************************************************************/

program define Table2 

	use `datafile1', clear

	// Controls _ Cohort_Time Trend
	gen ageD=min(9,max(0,floor((m_orig-48)/3)+1)) if m_orig!=.  // m_orig: month since origination
	recode ageD (0=0) (1/4=1) (5/8=2) (9=3)   // ageD=0: more than one year before reset, 1: one year before reset, 2:one year after reset, 3:two (or more) year after reset


	xi i.ageD i.qy*i.fp_y    //fp_y: first payment year   qy: year-quarter  ageD: dummy
	xtivreg2 schedintamtcalc  _Iq*  _Ia* l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2) //cl: house prices, bcn50: credit score, g2: month, g1: loanid
	est store Table2_Col1

	xtivreg2 sched_n _Iq*  _Ia* l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)
	est store Table2_Col2


	xtivreg2 l.newcar5k_val  _Iq*  _Ia*  l2.bcn50 l.cl if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2) // for car sale measure it is our understanding that if you purchase a car in month t, it shows up on your credit report in month t+1. that is why we use l.newcar
	est store Table2_Col3

	xtivreg2 l.carsale_n  _Iq*  _Ia*  l2.bcn50 l.cl if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)  
	est store Table2_Col4

	xtivreg2 l.newcar5k  _Iq*  _Ia*  l2.bcn50 l.cl if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)  //newcar5k: dummy equal one if change in auto debt amount >=5k
	est store Table2_Col5

	xtivreg2 partialprepay  _Iq*  _Ia*  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. & partialprepay>=-1 & partialprepay<30000 , fe cluster(g1 g2)  	
	est store Table2_Col6

	xtivreg2 ppp_n  _Iq*  _Ia*  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. & partialprepay>=-1 & partialprepay<30000 , fe cluster(g1 g2)  	
	est store Table2_Col3

	outreg2   _Ia*  l2.bcn50 l.cl [Table2_*] using ${outputdir}Table2.xls , replace sortvar(_Ia*  l2.bcn50 l.cl)
end

/*****************************
Table 3: Heterogeneous Effects
******************************/

program define Table3

	use `datafile1', clear

	*Income

	egen tmp=mean(pim) if m_orig>36 & m_orig<49 , by(g1)   
	egen int_m=max(tmp) , by(g1)   // average estimated income two years before the rate reset
	drop tmp

	sum int_m if fxintperiod==5, d
	local thr=r(p50)
	gen int_d=(int_m>`thr') if int_m!=.  // dummy equal one if income is above median
	xi i.ageD*i.int_d i.qy*i.int_d i.qy*i.fp_y  , noomit
	drop _IageD_0 _IageXint_0_0 _IageXint_0_1 

	xtivreg2 sched_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1   l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)
	est store Table3_1
	xtivreg2 l.carsale_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)
	est store Table3_2
	xtivreg2 ppp_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. & partialprepay>-1 & partialprepay<30000 , fe cluster(g1 g2)
	est store Table3_3

	*LTV
	set more off
	cap: drop int -int_d 
	egen tmp=mean(clcurrentltv) if m_orig>36 & m_orig<49 , by(g1)
	egen int_m=max(tmp) , by(g1)
	drop tmp
	gen int_d=(int_m>=1.2) if int_m!=. //dummy equal one if current LTV in 24-12 months before rate reset is above 120%.

	xi i.ageD*i.int_d i.qy*i.int_d i.qy*i.fp_y  , noomit
	drop _IageD_0 _IageXint_0_0 _IageXint_0_1 

	xtivreg2 sched_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1   l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)
	est store Table3_4
	xtivreg2 l.carsale_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)
	est store Table3_5
	xtivreg2 ppp_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. & partialprepay>-1 & partialprepay<30000 , fe cluster(g1 g2)
	est store Table3_6


	*FICO
	cap: drop int-int_d
	egen tmp=mean(bcn50) if m_orig>36 & m_orig<49 , by(g1)
	egen int_m=max(tmp) , by(g1)
	sum int_m if fxintperiod==5, d
	local thr=r(p50)
	gen int_d=(int_m>660) if int_m!=.

	xi i.ageD*i.int_d i.qy*i.int_d i.qy*i.fp_y  , noomit
	drop _IageD_0 _IageXint_0_0 _IageXint_0_1 
	 
	xtivreg2 sched_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1   l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)
	est store Table3_7
	xtivreg2 l.carsale_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , fe cluster(g1 g2)
	est store Table3_8
	xtivreg2 ppp_n  _Iq*  _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. & partialprepay>-1 & partialprepay<30000 , fe cluster(g1 g2)
	est store Table3_9

	outreg2 _IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl [Table3*] using ${outputdir}HetInc.xls , replace sortvar(_IageD_*  _IageXint_1_1 _IageXint_2_1 _IageXint_3_1  l2.bcn50 l.cl)

end

/******************************************************************************************
Table 4: External Validity: Impact of Rate Reductions among Borrowers with Conforming ARMs
******************************************************************************************/

program define Table4

	*** Panel A: Main Effects
	/* 
	See program Table2 for general regression structuring of Table 4: Panel A, but conduct analysis on conforming ARM data (Agency.dta).
	*/

	*** Panel B: Heterogeneous Effects
	/* 
	See program Table3 for general regression structuring of Table 4: Panel B, but conduct analysis on conforming ARM data (Agency.dta).
	*/
end

/***************************************************************************************
Table 5: Difference-in-Differences Estimates based on the Alternative Empirical Strategy
****************************************************************************************/

program define Table5


	*** Columns 1-3: Borrowers with non-agency ARMs

	use `datafile1', clear

	gen fiveARM=(fxint==5)
	egen g4=group(fp_y fiveARM)
	xi i.ageD*i.fiveARM i.qy*i.g4

	* i.qy*i.g4: controlling for different time trends for 5-1 ARM and 10-1 ARMs originated in different years. 
	xtivreg2 schedintamtcalc  _Iq*   _IageD* _IageXf*  l2.bcn50 l.cl  if  g2>19 & begbalcalc!=. , fe cluster(g1 g2) 
	est store Table5_1

	xtivreg2 l.newcar5k_val  _Iq*   _IageD* _IageXf*  l2.bcn50 l.cl  if  g2>19 & begbalcalc!=. , fe cluster(g1 g2) 
	est store Table5_2

	xtivreg2 partialprepay  _Iq*   _IageD* _IageXf*  l2.bcn50 l.cl  if  g2>19 & begbalcalc!=. & partialprepay>-1 & partialprepay<30000, fe cluster(g1 g2) 
	est store Table5_3

	outreg2   _Ia*  l2.bcn50 l.cl [Table5_*] using ${outputdir}DifDif_nonagency.xls , replace sortvar(_Ia*  l2.bcn50 l.cl)

	*** Columns 4-6: Borrowers with conforming ARMs

	/* 
	See program Table5, Columns 1-3 for general regression structuring of Table 5: Columns 4-6, but conduct the analysis on conforming ARM data (Agency.dta).
	*/


end

/**************************
Table 6: Regional Evidence
**************************/

program define Table6

	*** Panel A: Summary Statistics for High and Low Exposure Zip Codes

	use `datafile3', clear

	* Label variables
	label var pctARM "Matching Period ARM Share"
	label var fico "FICO"
	label var ltv "LTV"
	label var preIntRate "Interest Rate"
	label var pctDel "Mortgage Delinquency Rate"
	label var annunemploymentrate "Unemployment Rate"
	label var medianIncome "Median Income"
	label var collegePlus "Percentage of Individuals with College Degree"
	label var marriedWChildren "Percentage of Households that are Married Couples with Children"
	label var credit_score "Consumer Credit Score"
	label var houseprice "Quarterly House Price Growth (in %)"
	label var percentGSE "Percent of GSE Loans"
	label var aboveMean "Dummy equal to 1 if the ZipCode is above the mean ARM Share, 0 if below"

	* Create table of summary statistics
	quietly estpost tabstat fico ltv preIntRate pctDel annunemploymentrate medianIncome collegePlus marriedWChildren credit_score houseprice percentGSE pctARM, by(aboveMean) columns(statistics) statistics(mean sd)

	esttab using ${outputdir}Table6_PanelA.rtf, cells("mean(fmt(a2)) sd(fmt(a2))") label eqlabels("\bf{Low ARM Share}" "\bf{High ARM Share}" ) noobs unstack replace main("mean") aux(sd)

	*** Panel B: Change in Mortgage Rates, Mortgage Delinquency, House Price Growth, Auto Sales Growth, Employment Growth and a Zip Code ARM Share

	* For variable labels not specified below, please see Panel A for variable identification

	use `datafile3', clear

	local yvar int
	encode state, gen(stateFE)

	* Label additional variables
	label var intDiff "Change in Mortgage Interest Rate Level"
	label var delDiff "Change in Mortgage Delinquency Growth Rate"
	label var growthDiff "Change in House Price Growth Rate"
	label var autoDiff "Change in the Auto Sales Growth Rate"
	label var empDiff "Change in the Employment Growth Rate"
	label var stateFE "State Fixed Effects"

	* zip_controls is a local for the zip-code level controls which include fico rate, delinquency rate, interest rate, house value index, the annual unemployment rate, and other socio-economic controls

	eststo: reg intDiff pctARM
	eststo: xi: reg intDiff pctARM `zip_controls' i.stateFE
	eststo: xi: reg delDiff pctARM `zip_controls' i.stateFE
	eststo: xi: reg growthDiff pctARM `zip_controls' i.stateFE
	eststo: xi: reg autoDiff pctARM `zip_controls' i.stateFE
	eststo: xi: reg empDiff pctARM `zip_controls' i.stateFE


	esttab using ${outputdir}Table6_PanelB.rtf, ///
		onecell margin num nomtitles label /// 
		title("Table6: Panel B") ///
		keep(pctARM) ///
		indicate("Zip Code Controls = fico" "State FE = _IstateFE*") ///
		stats(N r2, labels("Number of Zip Codes" "R-Squared")) ///
		star(* 0.10 ** 0.05 *** 0.01) replace nonote

	eststo clear

end


/**********************************************************************************
Figure 1: Monthly Mortgage Payments, New Car Spending, and Voluntary Debt Repayment
***********************************************************************************/

program define Figures1

	use `datafile1', clear

	xtile initpay=initialpayment, nq(4)  // initpay: quartiles of the initial monthly payment
	xi i.ageq i.qy*i.initpay

	// ageq is age of the mortgage in quarters. ageq_29 is a dummy equal to one in the first quarter after the reset. (ageq_28: dummy equal one one quarter before the reset)
	areg schedintamtcalc  _Iq*  _Iageq_25 -_Iageq_36  post_3 l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , absorb(g1) cluster(g2)
	preserve
	parmest,fast
	keep if regexm(parm,"_Iageq_")
	gen tmp=strpos(parm,"q_")
	gen event = substr(parm,tmp+2,tmp+2)
	destring event , replace force
	replace event = event-29
	keep event est min95 max95
	save schedintamtcalc_graph_date , replace
	graph twoway (scatter est event, mcolor(red)) (rcap min95 max95 event, lcolor(red)), ///
	 xtitle("Number of Quarters Since Interest Rate Reset", size(medsmall) color(black)) /// 
	 ytitle("Monthly Interest Payment", size(medsmall) color(black) margin(0 5 0 0)) graphregion(color(white))   legend(off)
	graph save ${outputdir}MonthlyInterestPayment, replace
	restore

	areg l.newcar5k_val  _Iq*  _Iageq_25 -_Iageq_36  post_3 l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , absorb(g1) cluster(g2)
	preserve
	parmest,fast
	keep if regexm(parm,"_Iageq_")
	gen tmp=strpos(parm,"q_")
	gen event = substr(parm,tmp+2,tmp+2)
	destring event , replace force
	replace event = event-29
	keep event est min95 max95
	save newcar_graph_date , replace
	graph twoway (scatter est event, mcolor(red)) (rcap min95 max95 event, lcolor(red)), ///
	 xtitle("Number of Quarters Since Interest Rate Reset", size(medsmall) color(black)) /// 
	 ytitle("Monthly Expenditure on Car", size(medsmall) color(black) margin(0 5 0 0)) graphregion(color(white))   legend(off)
	graph save ${outputdir}MonthlyCarExpenditure, replace
	restore

	areg partialprepay  _Iq*  _Iageq_25 -_Iageq_36  post_3 l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. & partialprepay>=-1 & partialprepay<30000, absorb(g1) cluster(g2)
	preserve
	parmest,fast
	keep if regexm(parm,"_Iageq_")
	gen tmp=strpos(parm,"q_")
	gen event = substr(parm,tmp+2,tmp+2)
	destring event , replace force
	replace event = event-29
	keep event est min95 max95
	save partialprepay_graph_date , replace
	graph twoway (scatter est event, mcolor(red)) (rcap min95 max95 event, lcolor(red)), ///
	 xtitle("Number of Quarters Since Interest Rate Reset", size(medsmall) color(black)) /// 
	 ytitle("Monthly Partial Prepayment of Mortgage", size(medsmall) color(black) margin(0 5 0 0)) graphregion(color(white))   legend(off)
	graph save ${outputdir}MonthlyPartialPrepayment, replace
	restore


	xi i.ageq i.qy*i.fp_y

	areg sched_n _Iq*  _Iageq_25 -_Iageq_36  post_3 l2.bcn50 l.cl  if fxintperiod==5 & g2>19 & begbalcalc!=. , absorb(g1) cluster(g2)
	preserve
	parmest,fast
	keep if regexm(parm,"_Iageq_")
	gen tmp=strpos(parm,"q_")
	gen event = substr(parm,tmp+2,tmp+2)
	destring event , replace force
	replace event = event-29
	keep event est min95 max95
	save schedintamtcalcNormalized_graph_date , replace
	graph twoway (scatter est event, mcolor(red)) (rcap min95 max95 event, lcolor(red)), ///
	 xtitle("Number of Quarters Since Interest Rate Reset", size(medsmall) color(black)) /// 
	 ytitle("Monthly Interest Payment", size(medsmall) color(black) margin(0 5 0 0)) graphregion(color(white))   legend(off)
	graph save ${outputdir}MonthlyInterestPaymentNormalized, replace
	restore

end

/*************************************************************************************
Figure 2: External Validity: The Effects among Borrowers with Conforming (Agency) ARMs
**************************************************************************************/

program define Figures2

	/* 
	See program Figures1 for the general code for creating the figures in Figure 2, but conduct the analysis on conforming ARM data (Agency.dta).
	*/

end
 
* Run Main
main

