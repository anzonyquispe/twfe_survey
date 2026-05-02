***********************************************************************
* Program to replicate Aaronson, Agarwal, French Minimum Wage Results *
* that use the Current Expenditure Survey.                            *
***********************************************************************
clear all
set mem 3000m

global id "newid pre1986"

use ces_int_82_08

gen year = ref_yr
gen month = ref_mo

gen srvy = 0
 replace srvy = 2 if int_num=="2"
 replace srvy = 3 if int_num=="3"
 replace srvy = 4 if int_num=="4"
 replace srvy = 5 if int_num=="5"

* Bring in Minimum Wage Data
sort state year month
merge state year month using mw7909a 
drop if year<1982 | (year==1982 & month==1) // Drop Minimum Wage Observations Outside of Sample Period 
tab _m

* Drop Observations Missing Key Variables
drop if srvy==. 
drop if minwage==.


************************************
* First Set of Sample Restrictions *
************************************

* "State codes are needed to know effective minimum wage levels, 
*  but the CEX does not report actual state of residence for the 24 percent
*  of the sample residing in smaller states. These are dropped."

* To replicate the results with the assigned states,
* as is mentioned in footnote 40, simply comment out the
* line that drops state_=="R" and state=="T".

count
count if state_=="R" | state_=="T" | state==. | state==11
drop if state_=="R" | state_=="T" // Recoded State
drop if state==. | state==11 // State missing or Washington D.C.
tab state_

count
count if respstat==2 
drop if respstat==2 //Incomplete Income

*self-employed
gen selfemp=0
 replace selfemp=1 if incomey1==5
 replace selfemp=. if incomey1==.
gen selfemp2=0
 replace selfemp2=1 if incomey2==5
 replace selfemp2=. if incomey2==.
drop incomey1 incomey2
count
count if selfemp==1 | selfemp2==1
drop if selfemp==1 | selfemp2==1

*Restrict sample to households with head between ages 18 and 64
count
count if age_ref<18 | age_ref>64
drop if age_ref<18
drop if age_ref>64


*************** GENERATE VARIABLES *****************************

* age measures
gen agehead = age_ref
gen agehead2 = agehead*agehead
gen agespouse = age2
gen agespouse2 = agespouse * agespouse
drop age_ref age2

* gender
gen female = 1 if sex_ref==2
  replace female = 0 if sex_ref==1
drop sex_ref

*  composition of family
ren fam_size famsize 
ren perslt18 kids 
gen adults = famsize - kids


******************************************
* hours data
* inc_hrs1 -- usual hours per week, ref person
* inc_hrs2 -- usual hours per week, spouse
* incweek1 -- weeks worked per year, ref person
* incweek2 -- weeks worked per year, spouse
******************************************
gen annhrs1= inc_hrs1*incweek1
gen annhrs2 = inc_hrs2*incweek2

******************************************
* wage = annual income divided by annual hours
******************************************
gen wage1 = salary1 / annhrs1
gen wage2 = salary2 / annhrs2


******************************************
*  other variables in file:
*   finlwt21 = weight
*   vhome = value of home
*   mortpay = mortgage payment
*   number of earners in household = no_earnr
*   nonearner income = nonincmx
*   number of owned vehicles = vehq
*   total pretax income=fincbtax
*   total family wage and salary income pre dedctions = fsalaryx
*   member number of the principal earner = prinearn
******************************************

*****************************************************************************************
* consumption variables
*  tot_exp, housing_exp, durable_exp, non_durable_exp, ccare_exp, dur_less_housing, etc.
*****************************************************************************************

******************************************
*  specific car vars
******************************************

* net outlays, purchase not financed -- already have for new and used.  do for else
gen newcartr_pnf = tdet_newcartrkvan_pnf
gen usedcartr_pnf = tdet_usedcartrkvan_pnf
gen trelse_pnf = tdet_mcycles_pnf + tdet_boat_wom_pnf + tdet_camper_pnf + tdet_boat_wm_pnf + tdet_otherveh_pnf + tdet_pmcamper_pnf + tdet_mcamperc_pnf

* cash down
gen newcartr_dpt = tdet_newcartrkvan_dpmt
gen usedcartr_dpt = tdet_usedcartrkvan_dpmt
gen trelse_dpt = tdet_mcycles_dpmt + tdet_boat_wom_dpmt + tdet_camper_dpmt + tdet_boat_wm_dpmt + tdet_otherveh_dpmt + tdet_pmcamper_dpmt + tdet_mcamperc_dpmt


*  principal paid on loans
gen newcartr_princ = tdet_newcartrkvan_princhrg
gen usedcartr_princ = tdet_usedcartrkvan_princhrg
gen trelse_princ = tdet_mcycles_princhrg + tdet_boat_wom_princhrg + tdet_camper_princhrg + tdet_boat_wm_princhrg + tdet_otherveh_princhrg + tdet_pmcamper_princhrg + tdet_mcamperc_princhrg


* finance charges on loans
gen newcartr_fin = tdet_newcartrkvan_finchrg
gen usedcartr_fin = tdet_usedcartrkvan_finchrg
gen trelse_fin = tdet_mcycles_finchrg + tdet_boat_wom_finchrg + tdet_camper_finchrg + tdet_boat_wm_finchrg + tdet_otherveh_finchrg + tdet_pmcamper_finchrg + tdet_mcamperc_finchrg


****************************************************
* asset income (to delete from total income measure)
****************************************************
replace inclossa = 0 if inclossa==.
replace inclossb = 0 if inclossb==.
replace finincx = 0 if finincx ==.
replace intearnx = 0 if intearnx ==.

gen assinc = inclossa + inclossb + finincx + intearnx

save rep_ces8208.dta, replace

count

******************** MAKE DATA QUARTERLY ****************************

sort $id srvy year month

* Variables used to help figure out which quarter most of interview fell in
by $id srvy: egen maxmo=max(month)
by $id srvy: egen summo=sum(month)

* Set quarter of survey equal to quarter that at least 2 months of interview were in
gen qtr=0
 replace qtr = 1 if maxmo<=4 
 replace qtr = 2 if maxmo==5 | maxmo==6 | maxmo==7 
 replace qtr = 3 if maxmo==8 | maxmo==9 | maxmo==10 
 replace qtr = 4 if maxmo==11 | maxmo==12 
 replace qtr = 1 if maxmo==12 & summo==15
drop maxmo summo 

******************************************************************
* timing of minimum wage changes
******************************************************************

* the collapse command takes the average within the quarter, so it weights based on timing within quarter
* alternative is to take the max within quarter

sort newid pre1986 srvy year month

*Average Minimum Wage Over Last 12 months in Last Month Corresponding to Interview
egen _minwage12 = rowmean(minwage mw1 mw2 mw3 mw4 mw5 mw6 mw7 mw8 mw9 mw10 mw11) 
by $id srvy: gen minwage12 = _minwage12[_N]

by newid pre1986 srvy: egen maxmw = max(minwage)
by newid pre1986 srvy: egen maxxben3 = max(maxben3)
by newid pre1986 srvy: egen maxxeitc = max(maxeitc)
by newid pre1986 srvy: egen maxur = max(ur)

******************************************************************
*  first construct quarterly measures using the quarter of survey variable
*  make sure handle year when year crosses over -- this is for the year and month vars
******************************************************************

sort newid pre1986 year month

* Make expenditure numbers quarterly 
replace tot_exp = tot_exp*3
replace housing_exp = housing_exp*3
replace durable_exp = durable_exp*3
replace non_durable_exp = non_durable_exp*3
*replace durable_less_housing_exp = durable_less_housing_exp*3
replace ccare_exp = ccare_exp*3
replace furniture = furniture*3
replace floorwindow= floorwindow*3
replace otherhhitems = otherhhitems*3
replace appl_big =appl_big *3
replace electronics= electronics*3
replace funstuff = funstuff *3
replace mischhequip= mischhequip*3
replace transp =transp*3
replace newcars =newcars*3
replace usedcars =usedcars*3
replace newtrucks =newtrucks*3
replace usedtrucks =usedtrucks*3
replace clothing_exp= clothing_exp*3

replace newcartr_pnf = newcartr_pnf*3
replace usedcartr_pnf = usedcartr_pnf*3
replace newcartr_dpt = newcartr_dpt*3
replace usedcartr_dpt = usedcartr_dpt*3
replace newcartr_princ = newcartr_princ*3
replace usedcartr_princ = usedcartr_princ*3
replace newcartr_fin = newcartr_fin*3
replace usedcartr_fin = usedcartr_fin*3

sort newid pre1986 year month
collapse  year month qtr vhome tot_exp mortpay housing_exp durable_exp non_durable_exp  ///
          dur_less_hous ccare_exp finlwt21 inc_hrs1 inc_hrs2 incweek1 incweek2 no_earnr ///
 		  nonincmx vehq state fincatax fincbtax fsalaryx salary1 salary2 maxmw minwage  ///
		  minwage12 mw1 mw2 mw3 mw4 mw5 mw6 mw7 mw8 mw9 mw10 mw11 mw12 mw15 mw1ld mw2ld ///
		  mw3ld mw4ld mw5ld mw6ld mw7ld mw8ld mw9ld mw10ld mw11ld mw12ld mw15ld usmin   ///
		  dminwage3 dminwage6 dminwage9 dminwage12 dlminwage3 dlminwage6 dlminwage9     ///
		  dlminwage12 dlminwage15 dlminwage3l1 dlminwage3l2 dlminwage3l3 dlminwage3l4   ///
		  dlminwage3l5 maxeitc maxxeitc maxben3 maxxben3 maxur ur agehead agehead2      ///
		  agespouse agespouse2 female famsize annhrs1 annhrs2 wage1 wage2 adults kids   ///
		  owe_cred2 owe_cred5 respstat prinearn selfemp selfemp2 assinc furniture       ///
		  floorwindow otherhhitems appl_big funstuff electronics mischhequip transp     ///  
		  newcars usedcars newtrucks usedtrucks clothing_exp savacctx ckbkactx secestx  ///  
		  compsav compsavx compckg compckgx compsec compsecx newcartr_pnf usedcartr_pnf ///        
		  newcartr_dpt usedcartr_dpt newcartr_princ usedcartr_princ newcartr_fin usedcartr_fin, by(newid pre1986 srvy)

save rep_ces8208qtr.dta, replace

gen newid2 = real(newid)
drop newid 
gen newid = (newid2+(pre1986*0.1))*10
drop newid2 

sort newid srvy

gen yearr=round(year)
gen qtrr=round(qtr)

* Generate Year Dummies
tab yearr, gen(y)

* Generate Quarter Dummies
tab qtrr, gen(q)
 
* max and min of surveys
by newid: gen sfirst = srvy[1]
by newid: gen slast = srvy[_N]
by newid: egen stot = count(srvy)

*State Dummies
tab state, gen(s)

*Time Trend
gen time = yearr-1981
gen time2 = time*time

***********************************
* Income Measures for Regressions *
***********************************

gen qfincatax = fincatax/4
label var qfincatax "Quarterly After Tax Income"

sort newid srvy
by newid: gen srvy1=srvy[1]
by newid: gen srvy2=srvy[2]
by newid: gen srvy3=srvy[3]
by newid: gen srvy4=srvy[4]

**** real values of income. pce deflator, chain weighted. revised in 2009.

gen pce = 0
 replace pce=0.5362 if yearr == 1982
 replace pce=0.5592 if yearr == 1983
 replace pce=0.5804 if yearr == 1984
 replace pce=0.5994 if yearr == 1985
 replace pce=0.6140 if yearr == 1986
 replace pce=0.6359 if yearr == 1987
 replace pce=0.6612 if yearr == 1988
 replace pce=0.6899 if yearr == 1989
 replace pce=0.7215 if yearr == 1990
 replace pce=0.7476 if yearr == 1991
 replace pce=0.7695 if yearr == 1992
 replace pce=0.7864 if yearr == 1993
 replace pce=0.8027 if yearr == 1994
 replace pce=0.8204 if yearr == 1995
 replace pce=0.8383 if yearr == 1996
 replace pce=0.8539 if yearr == 1997
 replace pce=0.8621 if yearr == 1998
 replace pce=0.8760 if yearr == 1999
 replace pce=0.8978 if yearr == 2000
 replace pce=0.9149 if yearr == 2001
 replace pce=0.9274 if yearr == 2002
 replace pce=0.9462 if yearr == 2003
 replace pce=0.9710 if yearr == 2004
 replace pce=1.0000 if yearr == 2005
 replace pce=1.0275 if yearr == 2006
 replace pce=1.0550 if yearr == 2007
 replace pce=1.0903 if yearr == 2008

gen totexpr = tot_exp / pce
gen minwager = minwage / pce
gen minwage12r = minwage12 / pce
gen wage1r = wage1 / pce
gen wage2r = wage2 / pce
gen salary1r = salary1 / pce
gen salary2r = salary2 / pce
gen fincataxr = fincatax / pce
gen fincbtaxr = fincbtax / pce
gen qfincataxr = qfincatax / pce
gen assincr = assinc / pce
gen durexpr = durable_exp / pce
gen nondurexpr = non_durable_exp / pce

gen furnr = furniture / pce
gen fwr = floorwindow / pce
gen otherhhr = otherhhitems / pce
gen applbigr = appl_big / pce
gen electr = electronics / pce
gen fsr = funstuff / pce
gen mhher = mischhequip / pce
gen trar = transp  / pce
gen newcr = newcars / pce
gen usedcr = usedcars / pce
gen newtr = newtrucks / pce
gen usedtr = usedtrucks / pce
gen clothr = clothing_exp / pce
gen ccexpr = ccare_exp / pce
gen newcartr_pnfr =newcartr_pnf / pce
gen newcartr_dptr =newcartr_dpt / pce
gen newcartr_princr =newcartr_princ / pce
gen newcartr_finr =newcartr_fin / pce
gen usedcartr_pnfr =usedcartr_pnf / pce
gen usedcartr_dptr =usedcartr_dpt / pce
gen usedcartr_princr =usedcartr_princ / pce
gen usedcartr_finr =usedcartr_fin / pce
gen savacctxr = savacctx / pce
gen ckbkactxr = ckbkactx / pce
gen compsavxr = compsavx / pce
gen compckgxr = compckgx / pce

* This isn't totally right, because the leads and lags will be in different years, but
* once year dummies are included, it shouldn't have any effect on the results so we left it.
gen mw9ldr = mw9ld / pce
gen mw6ldr = mw6ld / pce
gen mw3ldr = mw3ld / pce
gen mw3r = mw3 / pce
gen mw6r = mw6 / pce
gen mw9r = mw9 / pce
gen mw12r = mw12 / pce
gen mw15r = mw15 / pce

drop tot_exp minwage wage1 wage2 salary1 salary2 fincatax fincbtax assinc durable_exp non_durable_exp savacctx ckbkactx compsavx compckgx ///
 furniture floorwindow otherhhitems appl_big electronics funstuff mischhequip transp newcars usedcars ///
 newtrucks usedtrucks clothing_exp ccare_exp newcartr_pnf newcartr_dpt newcartr_princ newcartr_fin usedcartr_pnf ///
 usedcartr_dpt usedcartr_princ usedcartr_fin ///
 mw9ld mw6ld mw3ld mw3 mw6 mw9 mw12 mw15 minwage12 qfincatax 

gen tot_exp = totexpr
gen minwage = minwager
gen minwage12 = minwage12r
gen wage1 = wage1r
gen wage2 = wage2r
gen salary1 = salary1r
gen salary2 = salary2r
gen fincatax = fincataxr
gen fincbtax = fincbtaxr
gen qfincatax = qfincataxr
gen assinc = assincr
gen durable_exp = durexpr
gen non_durable_exp = nondurexpr
gen savacctx = savacctxr
gen ckbkactx = ckbkactxr
gen compsavx = compsavxr
gen compckgx = compckgxr

gen furniture =  furnr
gen floorwindow = fwr
gen otherhhitems =  otherhhr
gen appl_big =  applbigr
gen electronics =  electr
gen funstuff =  fsr
gen mischhequip = mhher 
gen transp = trar
gen newcars =  newcr
gen usedcars = usedcr  
gen newtrucks = newtr 
gen usedtrucks = usedtr  
gen clothing_exp = clothr 
gen ccare_exp = ccexpr 
gen newcartr_pnf = newcartr_pnfr 
gen newcartr_dpt = newcartr_dptr
gen newcartr_princ = newcartr_princr  
gen newcartr_fin =  newcartr_finr
gen usedcartr_pnf =  usedcartr_pnfr
gen usedcartr_dpt = usedcartr_dptr 
gen usedcartr_princ = usedcartr_princr 
gen usedcartr_fin = usedcartr_finr

gen mw9ld = mw9ldr 
gen mw6ld = mw6ldr
gen mw3ld = mw3ldr 
gen mw3 = mw3r 
gen mw6 = mw6r 
gen mw9 = mw9r 
gen mw12 = mw12r 
gen mw15 = mw15r 

******************************************
********* INITIAL INCOME MEASURES ********
******************************************

*Wage's Percent Greater Than Min Wage
gen percentminwage1 = (wage1/minwage)-1
by newid: gen firstpercent1 = percentminwage1[1]
gen percentminwage2 = (wage2/minwage)-1
by newid: gen firstpercent2 = percentminwage2[1]

by newid: gen firstwage1 = wage1[1]
by newid: gen firstwage2 = wage2[1]

by newid: gen firstsalary1 = salary1[1]
 replace firstsalary1 = 0 if firstsalary1==.
by newid: gen firstsalary2 = salary2[1]
 replace firstsalary2 = 0 if firstsalary2==.
  
by newid: gen firstfincbtax_a = fincbtax[1]
by newid: gen firstassinc = assinc[1]

*Remove Asset Income from Taxable Income
gen firstfincbtax = firstfincbtax_a - firstassinc
 replace firstfincbtax = firstfincbtax if firstassinc==.
 

************* GENERATE S *****************
* The share of income coming from jobs   *
* paying less than 120% of minimum wage. *
******************************************

gen earnmw1 = 1 if firstpercent1<=0.2 // Wage less than or equal to 120% of minwage
 replace earnmw1 = 0 if firstpercent1>0.2
 replace earnmw1 = 0 if firstpercent1==. & firstpercent2~=.
 replace earnmw1 = . if firstpercent1==. & firstpercent2==.
 
gen earnmw2 = 1 if firstpercent2<=0.2
 replace earnmw2 = 0 if firstpercent2>0.2
 replace earnmw2 = 0 if firstpercent1~=. & firstpercent2==.
 replace earnmw2 = . if firstpercent1==. & firstpercent2==.

* Share of Total Income 
gen firstsharemw_bt = (firstsalary1*earnmw1 + firstsalary2*earnmw2) / firstfincbtax
 replace firstsharemw_bt = 1 if (firstsalary1*earnmw1 + firstsalary2*earnmw2)>0 & (firstsalary1*earnmw1 + firstsalary2*earnmw2)<. & firstfincbtax<=0
label var firstsharemw_bt "Share of Total Income From Jobs Paying <=120% MW - Before Tax"

drop earnmw1 earnmw2

************* GENERATE S' *****************
* The share of income coming from jobs    *
* paying 120-300% of minimum wage.        *
*******************************************

gen earnmw1 = firstpercent1>0.2 & firstpercent1<=2 // Earning 120-300% of minwage
 replace earnmw1 = 0 if firstpercent1>2 
 replace earnmw1 = 0 if firstpercent1==. & (firstpercent2>0.2 & firstpercent2<.)
 replace earnmw1 = . if (firstpercent1<=0.2 | firstpercent2<=0.2) | (firstpercent1==. & firstpercent2==.)
 
gen earnmw2 = firstpercent2>0.2 & firstpercent2<=2
 replace earnmw2 = 0 if firstpercent2>2 
 replace earnmw2 = 0 if (firstpercent1>0.2 & firstpercent1<.) & firstpercent2==.
 replace earnmw2 = . if (firstpercent1<=0.2 | firstpercent2<=0.2) | (firstpercent1==. & firstpercent2==.)

tab earnmw1 earnmw2 if firstpercent1<.2 | firstpercent2<.2, missing 

* Share of Total Income 
gen firstsharemw_bt_120300 = (firstsalary1*earnmw1 + firstsalary2*earnmw2) / firstfincbtax
 replace firstsharemw_bt_120300 = 1 if (firstsalary1*earnmw1 + firstsalary2*earnmw2)>0 & (firstsalary1*earnmw1 + firstsalary2*earnmw2)<. & firstfincbtax<=0
label var firstsharemw_bt_120300 "Share of Total Income From Jobs Paying 120-300% MW Before Tax"

su firstsharemw_bt if firstsharemw_bt_120300~=.

drop earnmw1 earnmw2


****************************************
* Small and Large Minimum Wage Changes *
****************************************
* small increases
gen small = 0
  replace small = 1 if state==4 & year==2008
  replace small = 1 if state==8 & year==2008
  replace small = 1 if state==9 & year>2000
  replace small = 1 if state==12 & year>2006
  replace small = 1 if state==23 & year>1984 & year<1991
  replace small = 1 if state==23 & year>2004
  replace small = 1 if state==25 & year>1985 & year<1991
  replace small = 1 if state==26 & year==2007
  replace small = 1 if state==27 & year>1987 & year<1992
  replace small = 1 if state==32 & year>2006
  replace small = 1 if state==33 & year>1986 & year<1992
  replace small = 1 if state==39 & year==2008
  replace small = 1 if state==41 & year>2003
  replace small = 1 if state==44 & year>1985 & year<1992
  replace small = 1 if state==44 & year>2005
  replace small = 1 if state==50 & year>1985 & year<1991
  replace small = 1 if state==50 & year>1994 & year<1997
  replace small = 1 if state==50 & year>2004
  replace small = 1 if state==53 & year>2000

gen small1 = small
  replace small1 = 1 if state==9 & year>1990 & year<1992
  replace small1 = 1 if state==19 & year>1995 & year<1997
  replace small1 = 1 if state==34 & year>1996 & year<1998
  replace small1 = 1 if state==53 & year>1996 & year<1998

gen small2 = small1
  replace small2 = 1 if state==6 &  year>1996 & year<1998
  replace small2 = 1 if state==9 &  year>1996 & year<1998
  replace small2 = 1 if state==50 &  year>1996 & year<1998
  replace small2 = 1 if state==35 &  year==2008 & month>7
  replace small2 = 1 if state==55 &  year==2008 & month>7

gen mwsmall = minwage * small
gen mwsmall1 = minwage * small1
gen mwsmall2 = minwage * small2
  

 *******************************************
 **** Transportation Spending Variables ****
 *******************************************
 
gen nontr = tot_exp - transp
gen newveh = newcars + newtrucks
gen usedveh = usedcars +  usedtrucks
gen othertr = transp - newveh - usedveh

* Purchase Indicators
gen Inewveh = .
 replace Inewveh = 1 if newveh>0 & newveh<.
 replace Inewveh = 0 if newveh==0
 
gen Iusedveh = .
 replace Iusedveh = 1 if usedveh>0 & usedveh<.
 replace Iusedveh = 0 if usedveh==0
 
gen Iothertr = .
 replace Iothertr = 1 if othertr>0 & othertr<.
 replace Iothertr = 0 if othertr==0
 
* generate financed amount variable
gen newcartr_financed = newveh - newcartr_pnf - newcartr_dpt

**********************************
* Liquidity Constraint Variables *
**********************************

gen liquid = savacctx + ckbkactx
  replace liquid = savacctx if ckbkactx==. & savacctx~=.
  replace liquid = ckbkactx if savacctx==. & ckbkactx~=. 

by newid: gen lastliquid = liquid[_N]

gen icsav = savacctx if compsav==1
 replace icsav = savacctx + compsavx if compsav==2 | compsav==3
 
gen iccheck = ckbkactx if compsav==1
 replace iccheck = ckbkactx + compckgx if compckg==2 | compckg==3

gen icliquid = icsav + iccheck
 replace icliquid = icsav if iccheck==. & icsav~=.
 replace icliquid = iccheck if icsav==. & iccheck~=.

by newid: gen firstliquid = icliquid[_N]

**********************************************
************ SAMPLE RESTRICTIONS *************
**********************************************

******************************************************************************
* For brevity, we do not include the code where these                        *
* sample restrictions are added one by one.                                  *
* To examine the effect of each or all of the sample                         *
* restrictions, comment out the drop statements below.                       *
* The following variables correspond to other gov't                          *
* programs or local characteristics by state and year:                       *
* maxben3 - Maximum Cash Welfare Benefits for a family of three              *
* avetic - Average EITC Amount                                               *
* maxeitc - Refundable EITC attainable as percent of attainable federal EITC *
* unemploymentrate - The state unemployment rate.                            *
******************************************************************************

by newid : gen firstsrvy = srvy[1]
by newid : gen lastsrvy = srvy[_N]

* Drop if only in one survey
tab stot if firstsrvy==lastsrvy, missing
count
count if firstsrvy==lastsrvy
drop if firstsrvy==lastsrvy

* Generate first and last wage, family composition, gender and age
by newid: gen lastwage1 = wage1[_N] 
by newid: gen lastwage2 = wage2[_N] 

by newid: gen firstfamsize = famsize[1] 
by newid: gen firstadults = adults[1] 
by newid: gen firstkids = kids[1]

by newid: gen lastfamsize = famsize[_N] 
by newid: gen lastadults = adults[_N] 
by newid: gen lastkids = kids[_N] 

by newid: gen firstfem = female[1] 
by newid: gen lastfem = female[_N] 

by newid: gen firstage1 = agehead[1] 
by newid: gen lastage1 = agehead[_N] 


*Drop households without an initial wage for the head and spouse
count
count if missing(firstwage1) & missing(firstwage2)
drop if missing(firstwage1) & missing(firstwage2)
drop if firstsharemw_bt==. 

*Drop households where either the head or spouse make 60% of minwage or less then 40*minwage
/* NOTE: If this set of restrictions is dropped, the coefficient for S>=0.2 corresponding to the CEX
   in Table 1 becomes 101 (465). If we drop observations below the 1st percentile and 99th percentile
   of the wage distribution, the coefficient is 12 (431).  */
count 
count if (firstpercent1<-.4 & firstpercent1>=-1)  | (firstpercent1>40 & firstpercent1<.) ///
         | (firstpercent2<-.4 & firstpercent2>=-1) | (firstpercent2>40 & firstpercent2<.)
drop if (firstpercent1<-.4 & firstpercent1>=-1) 
drop if (firstpercent1>40 & firstpercent1<.) 
drop if (firstpercent2<-.4 & firstpercent2>=-1)
drop if (firstpercent2>40 & firstpercent2<.)

*Drop if household has no expenditures
count
count if tot_exp==0 | tot_exp==.
drop if tot_exp==0 | tot_exp==.

*Drop if heads age changes by more than 2 years
gen dage = lastage1-firstage1
tab dage
drop if (dage<-2 | dage>2) & dage~=.

*Drop if heads gender changes
gen dfemale = lastfem-firstfem
tab dfemale, missing
drop if dfemale ==1 | dfemale==-1

*Drop if number of adults changes by more than 2
gen dadults = lastadults-firstadults
drop if dadults>2 & dadults<.
drop if dadults<-2

*Drop if number of kids changes by more than 2
gen dkids = lastkids-firstkids
drop if dkids>2 & dkids<.
drop if dkids<-2

*Drop if change in log hourly wages between the initial and last survey >1.5
gen lfirstwage1=log(firstwage1)
gen lfirstwage2=log(firstwage2)
gen llastwage1=log(lastwage1)
gen llastwage2=log(lastwage2)
gen dwage1 = llastwage1-lfirstwage1
gen dwage2 = llastwage2-lfirstwage2
drop if (dwage1>1.5 & dwage1<.)
drop if dwage1<-1.5 
drop if (dwage2>1.5 & dwage2<.)
drop if dwage2<-1.5

count // Number of Observations
count if srvy==firstsrvy // Number of Consumer Units

save rep_ces.dta, replace

***********
* RESULTS *
***********

xtset newid srvy

capture log close
log using cex_table1.log, replace
************
* Table 1  *
************

*****************************************************************************************************************************
* For brevity, we do not show results using different income observations.
* For example, when a new individual is added to the consumer unit. 
* We experimented with the following variations:
*   -all income measures from the individuals first interview and the 5th survey, plus new observations when an individual
*       is added to the consumer unit
*   -all unique (nominal) income measures
* E-mail the authors to obtain the code for these experiments.
*****************************************************************************************************************************

* Column 1 - Baseline Estimates
xtreg qfincatax minwage12 q1-q3 y2-y27 adults kids if firstsharemw_bt==0 & (srvy==firstsrvy | srvy==5), fe cluster(newid)
xtreg qfincatax minwage12 q1-q3 y2-y27 adults kids if firstsharemw_bt>0  & (srvy==firstsrvy | srvy==5), fe cluster(newid)
xtreg qfincatax minwage12 q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2  & (srvy==firstsrvy | srvy==5), fe cluster(newid)

* Column 5 - Re-define S as 120-300% of Minimum Wage
xtreg qfincatax minwage12 q1-q3 y2-y27 adults kids if firstsharemw_bt_120300==0  & (srvy==firstsrvy | srvy==5), fe cluster(newid)
xtreg qfincatax minwage12 q1-q3 y2-y27 adults kids if firstsharemw_bt_120300>0 & firstsharemw_bt_120300<.  & (srvy==firstsrvy | srvy==5), fe cluster(newid)
xtreg qfincatax minwage12 q1-q3 y2-y27 adults kids if firstsharemw_bt_120300>=0.2 & firstsharemw_bt_120300<.  & (srvy==firstsrvy | srvy==5), fe cluster(newid)

log close

log using cex_table2.log, replace
***********
* Table 2 *
***********

* Column 1 - Baseline Estimates
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 , fe cluster(newid)
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

* Column 2 - Re-define S as 120-300% of Minimum Wage
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt_120300==0, fe cluster(newid)
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt_120300>0 & firstsharemw_bt_120300<., fe cluster(newid)
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt_120300>=0.2 & firstsharemw_bt_120300<., fe cluster(newid)

* Column 3 - Liquid Assets < $5000
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0 & lastliquid<5000, fe cluster(newid)
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 & lastliquid<5000, fe cluster(newid)
xtreg tot_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2 & lastliquid<5000, fe cluster(newid)
 
* Columns 4 and 5 
xtreg tot_exp minwage mwsmall2 small2 q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
test minwage+mwsmall2 = 0
xtreg tot_exp minwage mwsmall2 small2 q1-q3 y2-y27 adults kids if firstsharemw_bt>0, fe cluster(newid)
test minwage+mwsmall2 = 0
xtreg tot_exp minwage mwsmall2 small2 q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)
test minwage+mwsmall2 = 0

* Column 6
summ tot_exp if firstsharemw_bt==0 [w=finlwt21]
summ tot_exp if firstsharemw_bt>0 [w=finlwt21]
summ tot_exp if firstsharemw_bt>=0.2 [w=finlwt21] 

log close


log using cex_footnote15_t2_fd.log, replace
**********************************************
* Footnote 15 - Table 2 in First Differences *
**********************************************

sort newid srvy
foreach var of varlist tot_exp minwage q1-q3 y2-y27 adults kids  {
 by newid: gen `var'_fd = `var'-`var'[_n-1]
}

*S>=0.2
reg tot_exp_fd minwage_fd q1_fd-q3_fd y2_fd-y27_fd adults_fd kids_fd if firstsharemw_bt>=0.2,  cluster(newid)

*S=0
reg tot_exp_fd minwage_fd q1_fd-q3_fd y2_fd-y27_fd adults_fd kids_fd if firstsharemw_bt==0,  cluster(newid)


log close

log using cex_table3.log, replace
***********
* Table 3 *
***********

* Column 1 - Non-durables and services
xtreg non_durable_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg non_durable_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 , fe cluster(newid)
xtreg non_durable_exp minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

su non_durable_exp if firstsharemw_bt==0 [w=finlwt21]
su non_durable_exp if firstsharemw_bt>0 [w=finlwt21]
su non_durable_exp if firstsharemw_bt>=0.2 [w=finlwt21]

foreach varname of varlist durable_exp furniture floorwindow otherhhitems appl_big electronics funstuff mischhequip transp {

 di ""
 di ""
 di "***************** `varname' *********************"
 di ""
 di ""
 
 xtreg `varname' minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
 xtreg `varname' minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 , fe cluster(newid)
 xtreg `varname' minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

 su `varname' if firstsharemw_bt==0 [w=finlwt21]
 su `varname' if firstsharemw_bt>0 [w=finlwt21]
 su `varname' if firstsharemw_bt>=0.2 [w=finlwt21]
 su `varname' if firstsharemw_bt==0 & `varname'>0 [w=finlwt21]
 su `varname' if firstsharemw_bt>0 & `varname'>0 [w=finlwt21]
 su `varname' if firstsharemw_bt>=0.2 & `varname'>0 [w=finlwt21]
}
log close

log using cex_table4.log, replace
***********
* Table 4 *
***********

* Column 1 - Probability of Purchase: New Cars/Trucks
xtreg Inewveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg Inewveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0, fe cluster(newid)
xtreg Inewveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

su Inewveh if firstsharemw_bt==0 [w=finlwt21] 
su Inewveh if firstsharemw_bt>0  [w=finlwt21]
su Inewveh if firstsharemw_bt>=0.2 [w=finlwt21]

* Column 2 - Probability of Purchase: Used Cars/Trucks
xtreg Iusedveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg Iusedveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0, fe cluster(newid)
xtreg Iusedveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

su Iusedveh if firstsharemw_bt==0 [w=finlwt21] 
su Iusedveh if firstsharemw_bt>0  [w=finlwt21]
su Iusedveh if firstsharemw_bt>=0.2 [w=finlwt21]

* Column 3 - Probability of Purchase: Other Transportation
xtreg Iothertr minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg Iothertr minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0, fe cluster(newid)
xtreg Iothertr minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

su Iothertr if firstsharemw_bt==0 [w=finlwt21] 
su Iothertr if firstsharemw_bt>0  [w=finlwt21]
su Iothertr if firstsharemw_bt>=0.2 [w=finlwt21]


* Column 4 - Expenditure: New Cars/Trucks
xtreg newveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg newveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0, fe cluster(newid)
xtreg newveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

su newveh if firstsharemw_bt==0 [w=finlwt21] 
su newveh if firstsharemw_bt>0  [w=finlwt21]
su newveh if firstsharemw_bt>=0.2 [w=finlwt21]

su newveh if firstsharemw_bt==0 & newveh>0 [w=finlwt21] 
su newveh if firstsharemw_bt>0 & newveh>0  [w=finlwt21]
su newveh if firstsharemw_bt>=0.2 & newveh>0 [w=finlwt21]
 
* Column 5 - Expenditure: Used Cars/Trucks
xtreg usedveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg usedveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0, fe cluster(newid)
xtreg usedveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

su usedveh if firstsharemw_bt==0 [w=finlwt21] 
su usedveh if firstsharemw_bt>0 [w=finlwt21]
su usedveh if firstsharemw_bt>=0.2 [w=finlwt21]

su usedveh if firstsharemw_bt==0 & usedveh>0 [w=finlwt21] 
su usedveh if firstsharemw_bt>0 & usedveh>0  [w=finlwt21]
su usedveh if firstsharemw_bt>=0.2 & usedveh>0 [w=finlwt21]

* Column 6 - Expenditure: Other Transportation
xtreg othertr minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0, fe cluster(newid)
xtreg othertr minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0, fe cluster(newid)
xtreg othertr minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)

su othertr if firstsharemw_bt==0 [w=finlwt21] 
su othertr if firstsharemw_bt>0 [w=finlwt21]
su othertr if firstsharemw_bt>=0.2 [w=finlwt21]

su othertr if firstsharemw_bt==0 & othertr>0 [w=finlwt21] 
su othertr if firstsharemw_bt>0 & othertr>0  [w=finlwt21]
su othertr if firstsharemw_bt>=0.2 & othertr>0 [w=finlwt21]


* Column 7: Expenditure on New Cars and Trucks
xtreg newveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0 & year>=1992, fe cluster(newid)
xtreg newveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 & year>=1992, fe cluster(newid)
xtreg newveh minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2 & year>=1992, fe cluster(newid)

su newveh if firstsharemw_bt==0 & year>=1992 [w=finlwt21] 
su newveh if firstsharemw_bt>0 & year>=1992  [w=finlwt21]
su newveh if firstsharemw_bt>=0.2 & year>=1992 [w=finlwt21]

su newveh if firstsharemw_bt==0 & newveh>0 & year>=1992 [w=finlwt21] 
su newveh if firstsharemw_bt>0 & newveh>0 & year>=1992  [w=finlwt21]
su newveh if firstsharemw_bt>=0.2 & newveh>0 & year>=1992 [w=finlwt21]

* Column 8: Expenditures on New Cars and Trucks, Net Outlay, Not Financed
xtreg newcartr_pnf minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0 & year>=1992, fe cluster(newid)
xtreg newcartr_pnf minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 & year>=1992, fe cluster(newid)
xtreg newcartr_pnf minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2 & year>=1992, fe cluster(newid)

su newcartr_pnf if firstsharemw_bt==0 & year>=1992 [w=finlwt21] 
su newcartr_pnf if firstsharemw_bt>0 & year>=1992  [w=finlwt21]
su newcartr_pnf if firstsharemw_bt>=0.2 & year>=1992 [w=finlwt21]

su newcartr_pnf if firstsharemw_bt==0 & newcartr_pnf>0 & year>=1992 [w=finlwt21] 
su newcartr_pnf if firstsharemw_bt>0 & newcartr_pnf>0 & year>=1992  [w=finlwt21]
su newcartr_pnf if firstsharemw_bt>=0.2 & newcartr_pnf>0 & year>=1992 [w=finlwt21]

* Column 9: Expenditures on New Cars and Trucks, Downpayment
xtreg newcartr_dpt minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0 & year>=1992, fe cluster(newid)
xtreg newcartr_dpt minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 & year>=1992, fe cluster(newid)
xtreg newcartr_dpt minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2 & year>=1992, fe cluster(newid)

su newcartr_dpt if firstsharemw_bt==0 & year>=1992 [w=finlwt21] 
su newcartr_dpt if firstsharemw_bt>0 & year>=1992  [w=finlwt21]
su newcartr_dpt if firstsharemw_bt>=0.2 & year>=1992 [w=finlwt21]

su newcartr_dpt if firstsharemw_bt==0 & newcartr_dpt>0 & year>=1992 [w=finlwt21] 
su newcartr_dpt if firstsharemw_bt>0 & newcartr_dpt>0 & year>=1992  [w=finlwt21]
su newcartr_dpt if firstsharemw_bt>=0.2 & newcartr_dpt>0 & year>=1992 [w=finlwt21]

* Column 10: Expenditures on New Cars and Trucks, Expenditure Less Downpayment
xtreg newcartr_financed minwage q1-q3 y2-y27 adults kids if firstsharemw_bt==0 & year>=1992, fe cluster(newid)
xtreg newcartr_financed minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>0 & year>=1992, fe cluster(newid)
xtreg newcartr_financed minwage q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2 & year>=1992, fe cluster(newid)

su newcartr_financed if firstsharemw_bt==0 & year>=1992 [w=finlwt21] 
su newcartr_financed if firstsharemw_bt>0 & year>=1992 [w=finlwt21]
su newcartr_financed if firstsharemw_bt>=0.2 & year>=1992 [w=finlwt21]

su newcartr_financed if firstsharemw_bt==0 & newcartr_financed>0 & year>=1992 [w=finlwt21] 
su newcartr_financed if firstsharemw_bt>0 & newcartr_financed>0 & year>=1992  [w=finlwt21]
su newcartr_financed if firstsharemw_bt>=0.2 & newcartr_financed>0 & year>=1992 [w=finlwt21]

log close

log using cex_veh_freq.log, replace
**************************************************
* Frequency of purchasing a vehicle (new or used *
**************************************************

gen Iveh = Inewveh+Iusedveh
replace Iveh = 1 if Iveh>1 & Iveh<.
su Iveh
di 1/r(mean)

log close

log using cex_table7.log, replace
***************************
* Table 7 and Footnote 25 *
***************************

su durable_exp non_durable_exp [w=finlwt21] if firstsharemw_bt==0
su durable_exp non_durable_exp [w=finlwt21] if firstsharemw_bt==1

log close

log using cex_tableA1.log, replace

************
* Table A1 *
************

gen unitcount = .
replace unitcount = 1 if firstsrvy==srvy

su tot_exp durable_exp non_durable_exp agehead firstsharemw_bt adults kids unitcount [w=finlwt21] if firstsharemw_bt==0
su tot_exp durable_exp non_durable_exp agehead firstsharemw_bt adults kids unitcount [w=finlwt21] if firstsharemw_bt>=0.2
su fincbtax [w=finlwt21] if firstsharemw_bt==0  & (srvy==firstsrvy | srvy==5)
su fincbtax [w=finlwt21] if firstsharemw_bt>=0.2  & (srvy==firstsrvy | srvy==5)

log close


log using cex_fig1.log, replace
************
* Figure 1 *
************

*De-mean variables to approximate fixed effect
foreach var of varlist tot_exp minwage q1 q2 q3 time time2 adults kids {
 by newid: egen _`var' = mean(`var')
 gen `var'_fe = `var'-_`var'
 drop _`var'
}

*Use version 10 because have trouble getting later versions to converge

*S>=.2
*sqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantiles(.1 .2 .3 .4 .5 .6 .7 .8 .9 .95 .98) 

 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.1) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.2) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.29) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.3) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.31) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.4) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.49) reps(200)
* bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.5) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.51) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.6) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.7) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.8) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.9) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.95) reps(200) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt>=0.2, quantile(.98) reps(200) 

*S=0
*sqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantiles(.1 .2 .3 .4 .5 .6 .7 .8 .9 .95 .98) 
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.1) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.2) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.3) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.4) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.49) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.5) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.51) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.6) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.7) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.8) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.9) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.95) reps(200)
 bsqreg tot_exp_fe minwage_fe q1_fe q2_fe q3_fe time_fe time2_fe adults_fe kids_fe if firstsharemw_bt==0, quantile(.98) reps(200)

log close

log using cex_fig2.log, replace
************
* Figure 2 *
************

*Figure 2b: Total Spending Response to a Change in the Minimum Wage
xtreg tot_exp mw9 mw6 mw3 minwage mw3ld mw6ld mw9ld q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)
lincom mw9ld+mw6ld
lincom mw9ld+mw6ld+mw3ld
lincom mw9ld+mw6ld+mw3ld+minwage
lincom mw9ld+mw6ld+mw3ld+minwage+mw3
lincom mw9ld+mw6ld+mw3ld+minwage+mw3+mw6
lincom mw9ld+mw6ld+mw3ld+minwage+mw3+mw6+mw9

xtreg non_durable_exp mw9 mw6 mw3 minwage mw3ld mw6ld mw9ld q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)
lincom mw9ld+mw6ld
lincom mw9ld+mw6ld+mw3ld
lincom mw9ld+mw6ld+mw3ld+minwage
lincom mw9ld+mw6ld+mw3ld+minwage+mw3
lincom mw9ld+mw6ld+mw3ld+minwage+mw3+mw6
lincom mw9ld+mw6ld+mw3ld+minwage+mw3+mw6+mw9

xtreg durable_exp mw9 mw6 mw3 minwage mw3ld mw6ld mw9ld q1-q3 y2-y27 adults kids if firstsharemw_bt>=0.2, fe cluster(newid)
lincom mw9ld+mw6ld
lincom mw9ld+mw6ld+mw3ld
lincom mw9ld+mw6ld+mw3ld+minwage
lincom mw9ld+mw6ld+mw3ld+minwage+mw3
lincom mw9ld+mw6ld+mw3ld+minwage+mw3+mw6
lincom mw9ld+mw6ld+mw3ld+minwage+mw3+mw6+mw9

log close


exit