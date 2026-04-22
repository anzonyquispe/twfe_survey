gen b=.
gen s=.

	forvalue y=1/8{
	replace b= _b[dd`y'_${treatdata}] if post`y'==1
	replace s= _se[dd`y'_${treatdata}] if post`y'==1
	}
	forvalue y=0/8{
	replace b= _b[dd_`y'_${treatdata}] if post_`y'==1
	replace s= _se[dd_`y'_${treatdata}] if post_`y'==1
	}	
	
gen up=b+1.96*s
gen low=b-1.96*s


 		#delimit ; 
		twoway || scatter  b time if tagg==1,  mcolor(black) msize(vsmall) lpattern(solid) lcolor(black) lwidth(thin) 
		|| rcap  up low  time  if tagg==1,  lcolor(black) mcolor(black) msize(vsmall) lpattern(solid) lcolor(black) lwidth(thin) msymbol(D)
		xtitle("", size(medium)) ytitle("Difference in ${outcomegr}", size(medium)) 
		legend(off) xline(0, lpattern(dash) lwidth(thin) lcolor(red) )  
		xlabel(-8[1]8,labsize(small) valuelabel angle(vert)) 
		ylabel(,labsize(small) )
		graphregion(color(white)) saving(temp/gr_${outcomegr}, replace)
		;
		#delimit cr	
		graph export "temp/gr_${outcomegr}.pdf", as(pdf) replace
		

drop b s up low	

