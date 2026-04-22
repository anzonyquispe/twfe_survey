/* Clean Electricity Variables.do */
* Created by Hunt, 3-29-2013
* Note: qelecprod needs to be cleaned after panelgroup variable is created.


/* Clean electricity variables */
* replace qelecsold = . if qelecsold>qelecprod // No: sold and produced (for own generation) are separately recorded, and you can sell more than you produce for yourself. The schedules seem to imply that prod is produced for own consumption.

/* Electricity sales */
gen ElecSalesPrice = velecsold_defl/qelecsold
replace ElecSalesPrice=. if velecsold_defl==0
gen ElecSalesPrice_flag = cond(ElecSalesPrice< Rs_kWh*0.02|ElecSalesPrice> Rs_kWh*50&ElecSalesPrice!=.,1,0)

** Make missing if far outside the normal range. 
	* Note: Hunt inspected these on 3-29-2013, and there are some values of ElecSalesPrice that are between 10 and 100 x the median that might actually be correct - could be peak electricity sales, etc.
replace velecsold_defl = . if ElecSalesPrice_flag
replace velecsold_nominal = . if ElecSalesPrice_flag


** Get ElecSold variable
	* Use qelecsold if it is non-zero and non-missing. If not, use velecsold and deflate by median price. (In some years, velecsold is recorded, but not a qelecsold.)
gen ElecSold = qelecsold
replace ElecSold = velecsold_defl/Rs_kWh if qelecsold==0|qelecsold==.
replace ElecSold = . if ElecSalesPrice_flag // This makes ElecSold missing if the price triggers the price flag


** This flags some observations that might be legit for qeleccons, where a plant purchases electricity and then resells some of it.
	* So we keep qeleccons here. 
	* However, we want to define qelecprod as qelecprod for sale. So we make this missing.
gen qeleccons_test = qelecprod+qelecpur
gen flag = cond(qeleccons_test/qeleccons>1.1|qeleccons_test/qeleccons<0.9,1,0)
replace flag = 0 if (qeleccons==0&qeleccons_test==0)|(abs(qeleccons)<1000|abs(qeleccons_test)<1000)
replace qelecprod=. if flag==1
drop flag qeleccons_test 




/* Electricity Purchases */
** Check implied electricity purchase price
gen ElecPurchPrice = velecpur_defl/qelecpur
replace ElecPurchPrice=. if velecpur_defl==0
gen ElecPurchPrice_flag = cond(ElecPurchPrice!=.&(ElecPurchPrice< Rs_kWh*0.02|ElecPurchPrice> Rs_kWh*50),1,0)
replace qelecpur = qelecpur/1000 if ElecPurchPrice_flag==1 & ElecPurchPrice>=0.002&ElecPurchPrice<=0.02
** Replace all variables as missing for the observations that are flagged. 
	* This could be done more intelligently to drop only the problem variable, but there are only 16 observations, and in some cases both are wrong anyway.
foreach var in qelecpur velecpur_defl velecpur_nominal {
	replace `var' = . if ElecPurchPrice_flag
}

drop ElecPurchPrice ElecPurchPrice_flag
gen ElecPurchPrice = velecpur_defl/qelecpur
replace ElecPurchPrice=. if velecpur_defl==0


/* Electricity Production */
* Notes: In 1997 and earlier, many more plants report zero self-generation. 
	* This is somewhat more concentrated among plants that do not appear in the sample after 1997, and these plants are smaller.
	* But about 20% of the plants that appear after 1998 (and report self-generation 100% of the time) report zero self-generation before 1998.
	* Hopefully this is addressed using year fixed effects and robustness checks for 1998 and later only.
	* However, there are many zeros in 1997 that are surrounded by non-zero entries. Go ahead and make these missing.
		* The second line makes qelecprod missing if the panelgroup disappears after 1997, but it is zero in 1997 but not for the two years before.
		
sort panelgroup year

	** Because qelecprod is erroneously zero here, qeleccons will also be underestimated, because it is the sum of purchased and produced.
		* Replace qeleccons = . if this problem occurs and if SGS > 0.05
		* qeleccons needs to be replaced before qelecprod given that this code here relies on qelecprod.
	gen SGStemp = qelecprod/qeleccons
	replace qeleccons = . if l.SGStemp>0.05&l.SGStemp!=.&f.SGStemp>0.05&f.SGStemp!=.   & qelecprod==0 & l.qelecprod!=0&l.qelecprod!=.&f.qelecprod!=0&f.qelecprod!=.  & year==1997 
	replace qeleccons = . if l.SGStemp>0.05&l.SGStemp!=.&l2.SGStemp>0.05&l2.SGStemp!=. & qelecprod==0 & l.qelecprod!=0&l.qelecprod!=.&l2.qelecprod!=0&l2.qelecprod!=.& year==1997
	drop SGStemp
	
foreach var in qelecprod  { 
	replace `var' = . if qelecprod==0 & l.qelecprod!=0&l.qelecprod!=.&f.qelecprod!=0&f.qelecprod!=. & year==1997
	replace `var' = . if qelecprod==0 & l.qelecprod!=0&l.qelecprod!=.& l2.qelecprod!=0&l2.qelecprod!=.& year==1997
}



/* Generate logs */
** Get Natural Logs
foreach var in qelecprod qelecpur qelecsold velecsold_defl {
	gen ln`var' = cond(`var'!=., ln(max(`var',0)+1),.) // Note: conceptually we do want to have negative shortages as zero - it is not meaningful to have a negative shortage, as all of demand is being met.
}

