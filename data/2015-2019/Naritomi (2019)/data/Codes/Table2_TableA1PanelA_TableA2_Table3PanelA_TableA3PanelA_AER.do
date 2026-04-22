*******************************************************************************
* Table 2, Table A1 Panel A, Table A2, Table 3 Panel A, Table A3 Panel A
* DD reported revenue and tax liabilities - firm level before vs. after policy
*******************************************************************************
clear all
set more off, perm

global MainDir "XX\Replication" /*replace XX with the main directory*/
cd "$MainDir\Data\



// Preparing the data

* load firm-level data aggregated by firm and post (post=1 if after Oct.2007 and before Dec.2011; 0 if before Oct.2007 and after Jan.2004)
use FirmData, clear 
isid id_tx post

	* set global: p99.9 p99 p95 winsorization 
	global winsor 	p99_9 p99 p95      

	* create pre-average weights based on revenue
	foreach w in $winsor{
		gen auxRev_all`w'__0=Rev_all`w' if post==0
		bys id_tx: egen scRev_all`w'__0=max(auxRev_all`w'__0)
	}

	* define DD
	gen dd=post*treatRW //treatRW=1 if retail sector; treatRW=0 if wholesale sector


	* taking logs
	foreach w in $winsor{
	foreach y in Rev_all Tax_all{
	gen ln`y'`w'=ln(`y'`w')
	}
	}
	
	* create binary outcome for taxes
	local x Tax_allp99
	gen d_`x'= 0
	replace d_`x'= 1 if `x'>0 
	replace d_`x'= . if `x'==. 

	* create flag for observations that are in the main regression (sample_main_reg)
	local w p99
	qui areg lnRev_all`w' dd  i.post [aw=scRev_all`w'__0], absorb(id_) vce(cluster cnae)
	gen sample_main_reg=e(sample)

	* define size (pre-treatment)

		* cutoff points for levels of revenue (comparing within bins of size - all firms)
		gen RBT=scRev_allp99__0 if scRev_all`w'__0>0
		
		* size polynomial
		forvalue x=2(1)3{
		gen RBT_`x'=RBT^`x'
		}
		
		* interact with DD
		foreach x in RBT RBT_2 RBT_3 {
			gen dd_w`x'=dd*`x'
		}

		* size dummy 
		gen low_size_R=0 if RBT!=.
		replace low_size_R=1 if RBT!=.&RBT<=p50RBT&treatRW==1
		gen high_size_R=0 if RBT!=.
		replace high_size_R=1 if RBT!=.&RBT>p50RBT&treatRW==1

	* define other dummies for heterogeneity
	
		* use foot traffic dummy (1 for above the median defined at the sector level) to split retail into two groups
		gen high_traffic_R=0
		replace high_traffic_R=1 if high_traffic==1&treatRW==1
		gen low_traffic_R=0
		replace low_traffic_R=1 if high_traffic!=1&treatRW==1


		* use number of different consumers dummy (1 for above the median defined at the sector level) to split retail into two groups
		gen high_ppl_R=0
		replace high_ppl_R=1 if high_ppl==1&treatRW==1
		gen low_ppl_R=0
		replace low_ppl_R=1 if high_ppl!=1&treatRW==1

		* use the value of transactions dummy (1 for above the median defined at the sector level) to split retail into two groups
		gen low_value_R=0
		replace low_value_R=1 if low_value==1&treatRW==1
		gen high_value_R=0
		replace high_value_R=1 if low_value!=1&treatRW==1


	* interact heterogeneity with DD
		foreach h in size traffic value ppl {
		foreach s in high_ low_ {
		gen dd_w`s'`h'_R=dd*`s'`h'_R
		}
		}
	
// Prep for regressions
	
global polsize 	dd_wRBT dd_wRBT_2 dd_wRBT_3 
global table2 	"$MainDir\Results\Table2"
global tableA1 	"$MainDir\Results\TableA1"
global tableA2 	"$MainDir\Results\TableA2"
global table3A 	"$MainDir\Results\table3A"
global tableA3A "$MainDir\Results\tableA3A"

	* create output file to add regression columns
	qui reg Rev_allp99 Rev_allp99 
	outreg2 using ${table2}, nolabel bracket excel coefastr se nocons adjr2 replace 
	outreg2 using ${tableA1}, nolabel bracket excel coefastr se nocons adjr2 replace 
	outreg2 using ${tableA2}, nolabel bracket excel coefastr se nocons adjr2 replace 
	outreg2 using ${table3A}, nolabel bracket excel coefastr se nocons adjr2 replace 
	outreg2 using ${tableA3A}, nolabel bracket excel coefastr se nocons adjr2 replace 


// Table 2 

local y Rev_all
local c cnae
local w p99

	* column 1
	qui areg ln`y'`w' dd  i.post [aw=scRev_all`w'__0], absorb(id_) vce(cluster `c')
	outreg2  dd using ${table2}, nolabel bracket excel coefastr se nocons adjr2  append	

	* column 2
	qui areg ln`y'`w' dd_whigh_size_R dd_wlow_size_R  i.post [aw=scRev_all`w'__0], absorb(id_) vce(cluster `c')
	outreg2  dd_whigh_size_R dd_wlow_size_R using ${table2}, nolabel bracket excel coefastr se nocons adjr2  append	

	* columns 3, 4, 5
	foreach h in ppl traffic value  {
		qui areg ln`y'`w'  dd_whigh_`h'_R dd_wlow_`h'_R ${polsize} i.post [aw=scRev_all`w'__0], absorb(id_) vce(cluster `c')
		outreg2 dd_whigh_`h'_R dd_wlow_`h'_R   using ${table2}, nolabel bracket excel coefastr se nocons adjr2  append
	}



// Table A1 Panel A

foreach w in $winsor{ // p99.9 p99 p95 winsorization 
foreach c in cnae id_ {  // clustering standard errors by sector (cnae) or firm (id_)
local y Rev_all

	* robustness of Table 2 column 1 
	qui areg ln`y'`w' dd  i.post [aw=scRev_all`w'__0], absorb(id_) vce(cluster `c')
	outreg2  dd using ${tableA1}, nolabel bracket excel coefastr se nocons adjr2  append	

}
}

// Table A2

foreach w in $winsor{ // p99.9 p99 p95 winsorization 
foreach c in cnae id_ {  // clustering standard errors by sector (cnae) or firm (id_)
local y Rev_all

	* robustness of Table 2 column 2
	qui areg ln`y'`w' dd_whigh_size_R dd_wlow_size_R i.post [aw=scRev_all`w'__0], absorb(id_) vce(cluster `c')
	outreg2  dd using ${tableA2}, nolabel bracket excel coefastr se nocons adjr2  append	

	* robustness of Table 2 columns 3, 4, 5
	foreach h in ppl traffic value  {
		qui areg ln`y'`w' dd_whigh_`h'_R dd_wlow_`h'_R ${polsize} i.post [aw=scRev_all`w'__0], absorb(id_) vce(cluster `c')
		outreg2 dd_whigh_`h'_R dd_wlow_`h'_R   using ${tableA2}, nolabel bracket excel coefastr se nocons adjr2  append
	}

}
}

// Table 3 Panel A
	
local c cnae
local w p99

 * column 1
 qui areg lnRev_all`w' dd i.post [aw=scRev_all`w'__0] if sample_main_reg==1&ST_1!=1, absorb(id_) vce(cluster cnae)
 outreg2  dd using ${table3A}, nolabel bracket excel coefastr se nocons adjr2  append	

 * column 2
 qui areg lnTax_all`w' dd  i.post [aw=scRev_all`w'__0] if sample_main_reg==1&ST_1!=1, absorb(id_) vce(cluster cnae)
 outreg2  dd using ${table3A}, nolabel bracket excel coefastr se nocons adjr2  append	
 
 * column 3
 qui areg d_Tax_all dd  i.post [aw=scRev_all`w'__0] if sample_main_reg==1&ST_1!=1, absorb(id_) vce(cluster cnae)
 outreg2  dd using ${table3A}, nolabel bracket excel coefastr se nocons adjr2  append	


// Table A3 Panel A

foreach c in cnae id_ {  // clustering standard errors by sector (cnae) or firm (id_)
 
 * robustness of Table 3 Panel A Columns 1 and 2
 foreach w in $winsor{ // p99.9 p99 p95 winsorization 
 qui areg lnRev_all`w' dd  i.post [aw=scRev_all`w'__0] if sample_main_reg==1&ST_1!=1, absorb(id_) vce(cluster `c')
 outreg2  dd using ${tableA3A}, nolabel bracket excel coefastr se nocons adjr2  append	

 qui areg lnTax_all`w' dd  i.post [aw=scRev_all`w'__0] if sample_main_reg==1&ST_1!=1, absorb(id_) vce(cluster `c')
 outreg2  dd using ${tableA3A}, nolabel bracket excel coefastr se nocons adjr2  append	

 }

 * robustness of Table 3 Panel A Column 3
 local w p99
 qui areg d_Tax_all dd  i.post [aw=scRev_all`w'__0] if sample_main_reg==1&ST_1!=1, absorb(id_) vce(cluster `c')
 outreg2  dd using ${tableA3A}, nolabel bracket excel coefastr se nocons adjr2  append	
 
} 
 


