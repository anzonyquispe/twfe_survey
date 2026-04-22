*******************
* Table 1
* Descriptive Stats  
*******************
clear all
set more off, perm

global MainDir "XX\Replication" /*replace XX with the main directory*/
cd "$MainDir\Data\"


///////////////////////////
// First panel: Firm sample
///////////////////////////

capture log close
log using "$MainDir\Results\Table1_firm_sample", replace
set more off 

	*** Use panel data by firm
	use MainData_reprev.dta, clear

	 // Put reported revenue value in USD: divided by 2 to get to dollar values in Jan.2007
	 gen USDcpRev_allp99=cpRev_allp99/2

	 
	 // Cleaning values of data from the program (number of receipts asked by consumers - NumRec, number of different consumers - NumCons) aggregated by firm-month 
	 		* all values should be missing for the NFP program before Jan. 2009; and all missing should be replace by zero after Jan. 2009 as they indicate that no receipt was issued as part of the program
			* NB: the NFP program stated in Oct. 2007 but the data available to this project from the program only begins in Jan. 2009 

		foreach y in NumRec NumCons{
		replace `y'=0 if `y'==. & date_taxref_n>=tm(2009m1) 
		replace `y'=. if `y'==0 & date_taxref_n<tm(2009m1)
		}
		
	// Generate descriptive stats for reported revenue (constant prices 2010)	 
		* descriptive stats of reported revenue for retail and wholesale firms that are in the regression analysis (sample_main_reg_all==1)
	 
		sum USDcpRev_allp99 NumRec NumCons 	if sample_main_reg_all==1 &  treatRW==1 // retail
		sum USDcpRev_allp99 				if sample_main_reg_all==1 &  treatRW==0 // wholesale
	 
log close

////////////////////////////////
// Second panel: Consumer sample
////////////////////////////////


capture log close
log using "$MainDir\Results\Table1_consumer_sample", replace
set more off 

	* Load lottery data
	use Lottery_all, clear
	keep if date_taxref_n<=617&date_taxref_n>=593 //restrict to the lotteries used in the analysis (from June 2009 - June 2011)

	* Ensure common support and exclude outliers in terms of quantity of lottery tickets (qtdebilhetes)
	drop if qtdebilhetes>40 // 40 lottery tickets is the min p99 value held by the control group in a lottery draw

	* Merge it with receipts data for a monthly balanced panel of consumers (iddest: masked consumer id) from Jan 2009 to December 2011
	merge  1:1 iddest date_taxref_n using "ConsDF_bal_lot" //panel data with consumer participation in the program
	drop if _merge==1
	drop _merge

	* The total prize value (sumprize) should be zero when there is a non-missing quantity of lottery tickets (no lottery wins)
	replace sumprize=0 if sumprize==.&qtde!=. 

	* Put values in USD: divided by 2 to get to dollar values in Jan.2007
	 gen USDRebatep99=Rebatep99/2 // tax rebate
	 gen USDValueRecp99=ValueRecp99/2 // total value of receipts
	 gen USDsumprize=sumprize/2 // total prize value
	 
	* Descriptive stats for consumer sample
	count
	sum NumRecp99 NumBusinessp99 USDReb USDValue qtdebilhetes USDsumprize

log close




















