
capture drop zz* _merge tempdflorigwgt
	
	use ${file}2, clear	
	set more off
	keep if ${dflbyvar}==${lottery}
	rename ${dflorigwgt} zzbasegroupval
	sort $dflvarlist
	save ${file}3, replace
	
	use ${file}2, clear
	keep if ${dflbyvarbasegroup}==${lottery}
	sort $dflvarlist
	
	merge m:1 ${dflvarlist} using ${file}3
	drop _merge
	gen zzfactor = zzbasegroupval/$dflorigwgt
		if $balanceacrossdflbyvar!=1 {
		 bys $dflbyvar: egen zzdflbyvarsum = sum($dflorigwgt)
		 quietly sum $dflorigwgt if $dflbyvar==${lottery}
		 replace zzfactor = zzfactor*(zzdflbyvarsum/r(sum))
		}
	replace zzfactor=0 if zzfactor==.
	drop $dflorigwgt
	sort $dflvarlist $dflbyvar
	
	merge 1:m ${dflvarlist} ${dflbyvar} using ${file}
	drop if _merge==2
	gen dfl = zzfactor*$dflorigwgt
	drop zz* _merge
	drop one
	save ${file}${lottery}, replace
