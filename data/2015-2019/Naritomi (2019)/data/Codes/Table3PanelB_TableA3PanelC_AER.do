***********************************************************************************************************
* Table 3 Panel B, Table A3 Panel C
* DD reported expenses for firms in the VAT system in the whole period - firm level before vs. after policy
***********************************************************************************************************
clear all
set more off, perm

global MainDir "XX\Replication" /*replace XX with the main directory*/
cd "$MainDir\Data\

// Prepare data

* load firm-level data aggregated by firm and post (post=1 if after Oct.2007 and before Dec.2011; 0 if before Oct.2007 and after Jan.2004)
use DataVAT, clear
isid id_tx post

	* set global: p99.9 p99 p95 winsorization 
	global winsor 	p99_9 p99 p95      

	* Generate DD variable
	gen dd=post*treat //treatRW=1 if retail sector; treatRW=0 if wholesale sector

	* create pre-average weights based on revenue
	foreach w in $winsor{
		gen auxRev_all`w'__0=Rev_all`w' if post==0
		bys id_tx: egen scRev_all`w'__0=max(auxRev_all`w'__0)
	}

	* generate value added
	foreach w in $winsor{
	gen VA`w'=Rev_all`w'-Expen_all`w'
	}
	
	* create dummy for positive value added
	gen d_VA= 0
	replace d_VA= 1 if VAp99>0 
	replace d_VA= . if VAp99==. 
	
	* create log outcomes
	foreach w in $winsor{
	foreach y in Rev_all Expen_all VA{
	gen ln`y'`w'=ln(`y'`w')
	}
	}



// Prep for regressions

	* samples
	foreach y in Rev_all Expen_all {
	qui areg ln`y'p99 dd  i.post [aw=scRev_allp99__0], absorb(id_) vce(cluster cnae)
	cap gen lnsample_`y'=e(sample)
	}
	gen lnsampl_exp_rev=(lnsample_Rev_all==1&lnsample_Expen_all==1) //forces common sample for revenue and expenditures
	
	* define files for rgression output
	global Table3B	 	"$MainDir\Results\Table3B"	
	global TableA3C	 	"$MainDir\Results\TableA3C"	
	
		*create output file to add regression columns
		qui reg Rev_allp99 Rev_allp99
		outreg2 using ${Table3B}, nolabel bracket excel coefastr se nocons adjr2 replace 
		outreg2 using ${TableA3C}, nolabel bracket excel coefastr se nocons adjr2 replace 


// Table 3 Panel B
local c cnae
local w p99

* columns 1, 2 and 3
 foreach y in   Rev_all Expen_all VA{		
 qui areg ln`y'`w' dd  i.post [aw=scRev_all`w'__0] if lnsampl_exp_rev==1, absorb(id_) vce(cluster `c')
 outreg2  dd using ${Table3B}, nolabel bracket excel coefastr se nocons   append			
 }

* column 4
 local y d_VA
 qui areg `y' dd  i.post [aw=scRev_all`w'__0] if lnsampl_exp_rev==1, absorb(id_) vce(cluster `c')
 outreg2  dd using ${Table3B}, nolabel bracket excel coefastr se nocons   append	


		
// Table A3 Panel C

* Robustness of Table 3 Panel B colums 1, 2 and 3
foreach c in id_ cnae {
foreach y in  VA Rev_all Expen_all{
foreach w in $winsor{
 qui areg ln`y'`w' dd  i.post [aw=scRev_all`w'__0] if lnsampl_exp_rev==1, absorb(id_) vce(cluster `c')
 outreg2  dd using ${TableA3C}, nolabel bracket excel coefastr se nocons   append	
}
}
}

* Robustness of Table 3 Panel B colum 4
foreach c in id_ cnae {
local y d_VA
local w p99
 qui areg `y' dd  i.post [aw=scRev_all`w'__0] if lnsampl_exp_rev==1, absorb(id_) vce(cluster `c')
 outreg2  dd using ${TableA3C}, nolabel bracket excel coefastr se nocons   append	
}


