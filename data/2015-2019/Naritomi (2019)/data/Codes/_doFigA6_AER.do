**********************************************************************
* Building the data for Event Study around lottery wins - past winners  
* Figure A6a and A6b
**********************************************************************

cd "$MainDir\Data\"

//////////////
// Figure A6a
//////////////

use  "Lottery_all.dta", clear

* generate winner dummy
gen win=1 if nprize!=.
replace win=0 if nprize==.


* count the number of times someone won the lottery before
sort  iddest date_taxref_n
gen totalwin=win
bys iddest: replace totalwin=totalwin+totalwin[_n-1] if _n!=1

	* restric attention to winners of prize size l
	gen sample_treat= 1 if win==1&totalwin>=2&sumprize==10			//have won at least once in the past and won R$10
	gen sample_ctrl= 1  if win==0&totalwin>=1						//have won at least once in the past did not win	
					
	keep if sample_treat==1 | sample_ctrl==1 

	global file PastWinSample
	*Create DFL weights for 10-reais (5-dollar) wins for past winners
	do "$MainDir\Codes\_doFigA6_dataprep_AER.do"
	*raw data graph and coefficient
	do "$MainDir\Codes\_doFigA6_analysis_AER.do"
	
	

/////////////
// Figure A6b
/////////////

use  "Lottery_all.dta", clear

* generate winner dummy
gen win=1 if nprize!=.
replace win=0 if nprize==.

	* restric attention to winners of prize size l
	gen sample_treat= 1 if win==1&sumprize==20
	gen sample_ctrl= 1 if win==1&sumprize==10
	
	keep if sample_treat==1 | sample_ctrl==1 

	global file _10vs20
	*Create DFL weights for 10-reais (5-dollar) wins vs 20-reais (10-dollar) wins 
	do "$MainDir\Codes\_doFigA6_dataprep_AER.do"
	*raw data graph and coefficient
	do "$MainDir\Codes\_doFigA6_analysis_AER.do"
	
