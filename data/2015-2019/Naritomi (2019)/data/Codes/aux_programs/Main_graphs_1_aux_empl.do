gen b=.
gen s=.
	forvalue y=2004(1)2005{
	replace b= _b[dd`y'_${treatdata}] if d`y'==1
	replace s= _se[dd`y'_${treatdata}] if d`y'==1
	}

	local y 2006
	replace b= 0 if d`y'==1
	replace s= 0 if d`y'==1

	*-1 as reference
	forvalue y=2007(1)2011{
	replace b= _b[dd`y'_${treatdata}] if d`y'==1
	replace s= _se[dd`y'_${treatdata}] if d`y'==1
	}	
	
gen up=b+1.96*s
gen low=b-1.96*s


 		#delimit ; 
		twoway || scatter  b time if tagg==1,  mcolor(black) msize(vsmall) lpattern(solid) lcolor(black) lwidth(thin) 
		|| rcap  up low  time  if tagg==1,  lcolor(black) mcolor(black) msize(vsmall) lpattern(solid) lcolor(black) lwidth(thin) msymbol(D)
		xtitle("", size(medium)) ytitle("Difference in ${outcomegr}", size(medium)) 
		legend(off) xline(2007, lpattern(dash) lwidth(thin) lcolor(red)) 
		xlabel(2004[1]2011,labsize(small) valuelabel angle(vert)) 
		ylabel(${yl},labsize(small) )
		graphregion(color(white)) saving(temp/gr_1_${outcomegr}, replace)
		;
		#delimit cr	
		graph export "temp\gr_1_${outcomegr}.pdf", as(pdf) replace
		
drop b s up low	

