/*

This program generates the main results from "The Surprisingly Swift Decline of 
U.S. Manufacturing Employment" by Justin R. Pierce and Peter K. Schott

This program is organized according to first the tables and then the the figures in 
the order in which they appear in the paper

Datasets used in this paper are created in data_create.do

*/



clear all
set more off



*Table 1
	capture erase r1.txt
	use $interim/lbd_industry_regression_file, clear

	global OP s1999_post
	global UP lkl1990_post lsl1990_post
	global ODP contract_post dr_post dsub_post se1999_post atp_post
	global M sfw_mwt_sum_new
	global L mem 
	global N  ntr
	global W  emp1990
	global C cl(fam50)
	
	*col 0  
	reg lempfam501999 $OP [aw=$W], cl(fam50) robust
	outreg2 $OP using r1.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007
		local zzz = _b[s1999_post]	
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'  `zzz'"]
		drop t1
	}

	*col 1
	areg lempfam501999 $OP d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $OP using r1.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007
		local zzz = _b[s1999_post]	
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'  `zzz'"]
		drop t1
	}

	*col 2
	areg lempfam501999 $OP $UP d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $OP $UP using r1.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007
		local zzz = _b[s1999_post]	
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'  `zzz'"]
		drop t1
	}

	*col 3
	areg lempfam501999 $OP $UP $ODP $M $N $L d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $OP $UP $ODP $M $N $L using r1.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007
		local zzz = _b[s1999_post]	
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'  `zzz'"]
		drop t1
	}



*Table A.4 annual spec	
	capture erase ra4.txt
	use $interim/lbd_industry_regression_file, clear

	global O  d????s
	global U  d????lkl1990 d????lsl1990
	global OD d????con d????dr d????dsub d????se1999 d????atp 
	global M sfw_mwt_sum_new
	global L mem 
	global N  ntr
	global W  emp1990
	global C cl(fam50)
	
	*col 1
	areg lempfam501999 $O                 d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $O using ra4.txt, replace noaster nonote noparen dec(3)
	
	*col 2
	areg lempfam501999 $O $U              d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $O using ra4.txt, append noaster nonote noparen dec(3)
	
	*col 3
	areg lempfam501999 $O $U $OD $M $N $L d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $O using ra4.txt, append noaster nonote noparen dec(3)





*Table 2 robustness
	set matsize 500
	capture erase r2.txt
	use $interim/lbd_industry_regression_file, clear

	global OP s1999_post
	global UP lkl1990_post lsl1990_post
	global ODP contract_post dr_post dsub_post se1999_post atp_post
	global M sfw_mwt_sum_new
	global L mem 
	global N  ntr
	global GDP lrgdp_lkl1990 lrgdp_lsl1990
	global TREF yhat
	global W  emp1990
	global C cl(fam50)
	
	*iv with nntr (col 1)
	ivreg2 lempfam501999 $UP $ODP $M $N $L d???? _If* ($OP=nntr1999_post) [aw=$W], robust cl(fam50)
	outreg2 $OP $UP $ODP $M $N $L  using r2.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007		
		local zzz = _b[s1999_post]	
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'  `zzz'"]
		drop t1
	}
		
	*1990 gap (col 2)
	areg lempfam501999 s1990_post $UP $ODP $M $N $L d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $OP $UP $ODP $M $N $L using r2.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1990_post]*s1990
		sum t1 [aw=$W] if year==2007
		local zzz = _b[s1990_post]	
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'  `zzz'"]
		drop t1
	}

	*quadratic (col 3)
	areg lempfam501999 s1999_post s_sq_post $UP $ODP $M $N $L d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 s1999_post s_sq_post $UP $ODP $M $N $L using r2.txt, append noaster nonote noparen dec(3)
	noisily test s1999_post s_sq_post
	quietly {
		gen t1 = _b[s1999_post]*s1999 +_b[s_sq_post]*s1999^2
		sum t1 [aw=$W] if year==2007
		noisily display ["Weighted Avm.dog Implied loss in log points `r(mean)'"]
		drop t1
	}

	*best two-segment spline (see below for finding best) (col 4)
	local c1=.45
	 quietly {
		gen c1 = s1999<=`c1'
		gen c2 = s1999> `c1'
		gen a1 = post*(s1999<=`c1')
		gen a2 = post*(s1999> `c1')
		gen b1 = a1*post*s1999
		gen b2 = a2*post*s1999
		
		constraint define 1 a1 = 0
		constraint define 2 a2 = a1 + (b1-b2)*`c1'
		
		cnsreg lempfam501999 a1 b1 a2 b2 $UP $ODP $M $N $L d???? _If* [aw=$W], nocons c(1 2) vce(cl fam50)
		outreg2              a1 b1 a2 b2 $UP $ODP $M $N $L using r2.txt, append noaster nonote noparen dec(3)

		*get and store aic for display
		estat ic
		matrix aic=r(S)
		local ac = aic[1,5]

		gen t1 = _b[b1]*s1999*c1 + (_b[b1]*`c1'+_b[b2]*(s1999-`c1'))*c2
		sum t1 [aw=$W] if year==2007		
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'"]
		noisily display ["AIC `ac' knot `c1'"]
		drop c1-b2 t1
	}	

	*gdp (col 5)
	areg lempfam501999 $OP $UP $ODP $M $N $L $GDP d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $OP $UP $ODP $M $N $L using r2.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'"]
		drop t1
	}
		

	*trefler cyclical (col 6)
	areg lempfam501999 $OP $UP $ODP $M $N $L $TREF d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $OP $UP $ODP $M $N $L using r2.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'"]
		drop t1
	}


	*revealed NTR (col 7)
	areg lempfam501999 $OP $UP $ODP $M $L ta1y d???? [aw=$W], a(fam50) cl(fam50) robust
	outreg2 $OP $UP $ODP $M $L ta1y using r2.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999_post]*s1999
		sum t1 [aw=$W] if year==2007
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'"]
		drop t1
	}

*Table 3: unido

	see results_unido.do


*Table 4: imports

	capture erase r4.txt
	use $interim/true_trade_regs_20150922, clear

	drop if idx==1
	keep lmval lnf lnm lnp cg_post c_post g_post cg g c lxr lta1 hs8 country1 year hc ht ct mfa* dmfa* mval
	foreach x in dmfa1fr dmfa2fr dmfa3fr dmfa4fr {
		replace `x'=`x'/100
	}
	
	global DCG   cg_post
	
	*col 1
	reghdfe lmval  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r4.txt, append noaster nonote noparen dec(3)

	*col 2
	reghdfe lnf    $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r4.txt, append noaster nonote noparen dec(3)

	*col 3
	reghdfe lnm    $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r4.txt, append noaster nonote noparen dec(3)

	*col 4
	reghdfe lnp    $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r4.txt, append noaster nonote noparen dec(3)

	/*
	*econ sig
	use $interim/true_trade_regs_20150922 if idx~=1, clear
	keep lmval lnf lnm lnp cg_post c_post g_post cg g c lxr lta1 hs8 country1 year ///
             hc ht ct mfa* dmfa* mval
	keep if year>=2000
	foreach x in  nf nm np {
		gen `x' = exp(l`x')
	}
	des
	rename mval v
	keep v nf nm np c g hs8 country1 year
	reshape wide v nf nm np c g, i(hs8 country1) j(year)
	reshape long v nf nm np c g, i(hs8 country1) j(year)
	foreach x in c nf nm np g {
		egen t = mean(`x'), by(hs8 country1)
		replace `x'=t if `x'==.
		drop t
	}
	gen cg_post = c*g*(year>=2001)

	gen bv   = .415
	gen bnf  = .472
	gen bnm  = .517
	gen bnp  = .514

	quietly {
	 foreach x in v nf nm np {
		quietly {
			gen t`x' = b`x'*c*g 
			sum t`x' if year==2007 & c==1
			noisily display ["Avg Implied loss in log points `r(mean)'"]
		}
	 }
	}
	*/



*Table 5: Chinese microdata

	see results_chinesex.do 



*Table 6: imports (rp) 

	capture erase r6.txt
	use $interim/true_trade_regs_20150922_rp if rp==1, clear

	drop if idx==1
	keep lmval lnf lnm lnp cg_post c_post g_post cg g c lxr lta1 hs8 country1 year hc ht ct mfa* dmfa* mval
	foreach x in dmfa1fr dmfa2fr dmfa3fr dmfa4fr {
		replace `x'=`x'/100
	}
	
	global DCG   cg_post
	
	*col 1
	reghdfe lmval  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r6.txt, append noaster nonote noparen dec(3)

	*col 2
	reghdfe lnf    $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r6.txt, append noaster nonote noparen dec(3)

	*col 3
	reghdfe lnm    $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r6.txt, append noaster nonote noparen dec(3)

	*col 4
	reghdfe lnp    $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4, absorb(hc ht ct) vce(cluster hc) fast v(0)
	outreg2  $DCG lta1 dmfa1 dmfa2 dmfa3 dmfa4 using r6.txt, append noaster nonote noparen dec(3)

'	
	*econ sig
	use $interim/true_trade_regs_20150922_rp if rp==1 & idx==1, clear
	keep lmval lnf lnm lnp cg_post c_post g_post cg g c lxr lta1 hs8 country1 year hc ht ///
             ct mfa* dmfa* mval
	keep if year>=2000
	foreach x in  nf nm np {
		gen `x' = exp(l`x')
	}
	des
	rename mval v
	keep v nf nm np c g hs8 country1 year
	reshape wide v nf nm np c g, i(hs8 country1) j(year)
	reshape long v nf nm np c g, i(hs8 country1) j(year)
	foreach x in c nf nm np g {
		egen t = mean(`x'), by(hs8 country1)
		replace `x'=t if `x'==.
		drop t
	}
	gen cg_post = c*g*(year>=2001)

	gen bv   = .415
	gen bnf  = .472
	gen bnm  = .517
	gen bnp  = .514

	quietly {
	 foreach x in v nf nm np {
		quietly {
			gen t`x' = b`x'*c*g 
			sum t`x' if year==2007 & c==1
			noisily display ["Avg Implied loss in log points `r(mean)'"]
		}
	 }
	}
	

*Table 7: CM industry results

	capture erase r7.txt
	use $interim/cm_true_fam50, clear
	
	global OP s1999_post
	global UP lkl1992_post lsl1992_post
	global ODP contract_post dr_post dsub_post se1999_post atp_post
	global M sfw_mwt_sum_new
	global L mem 
	global N  ntr
	global W  te1992
	global C cl(fam50)

	*levels 
	foreach x in te oe pw ph rtae  {
		areg l`x' $OP $UP $ODP $L $M $N d???? [aw=$W], a(fam50) cl(fam50) robust
		outreg2 $OP $UP $ODP $L $M $N using r7.txt, append noaster nonote noparen dec(3)
		quietly {
			gen t1 = _b[s1999_post]*s1999
			sum t1 [aw=$W] if year==1997
			noisily display ["Implied loss `x' `r(mean)'"]
			drop t1
		}
		
	}
	
	*same, but for lkl as depvar, need to drop from covariate list
	foreach x in lkl {
		areg `x' $OP lsl1992_post $ODP $L $M $N d???? [aw=$W], a(fam50) cl(fam50) robust
		outreg2 $OP lsl1992_post $ODP $L $M $N using r7.txt, append noaster nonote noparen dec(3)
		quietly {
			gen t1 = _b[s1999_post]*s1999
			sum t1 [aw=$W] if year==1997
			noisily display ["Implied loss `x' `r(mean)'"]
			drop t1
		}
					
	}

	*same, but for lsl as depvar, need to drop from covariate list
	foreach x in lsl {
		areg `x' $OP lkl1992_post $ODP $L $M $N d???? [aw=$W], a(fam50) cl(fam50) robust
		outreg2 $OP lkl1992_post $ODP $L $M $N using r7.txt, append noaster nonote noparen dec(3)
		quietly {
			gen t1 = _b[s1999_post]*s1999
			sum t1 [aw=$W] if year==1997
			noisily display ["Implied loss `x' `r(mean)'"]
			drop t1
		}
					
	}
	

		



*Table 8: CM plant regs

	capture erase r8.txt
	use $interim/cm_true_plant, clear

	*keep constant industries as in fam50 regs
	merge m:1 fam50 using $interim/cm_constant
	keep if _merge==3
	drop _merge

	gen idx=1
	foreach x in lte loe lpw lph lrtae lkl lsl s1999_post s1999wm_post lklminyr_post lslminyr_post ///
	             contract_post dr_post dsub_post se1999_post atp_post sfw_mwt_sum_new mem ntr lage ///
		     ltfp_fhs wgap_offd31999wm_post iodown31999wm_post teminyr fam50 lte loe lpw lph ///
		     lrtae lkl lsl {
		replace idx=0 if `x'==.
	}	
	drop if idx==0
	
	egen minyr=min(year), by(lbdnum)
	egen maxyr=max(year), by(lbdnum)
	gen both=minyr<=1997 & maxyr>=2002
	tab both

	global OP s1999wm_post
	global UP lklminyr_post lslminyr_post
	global ODP contract_post dr_post dsub_post se1999_post atp_post
	global M sfw_mwt_sum_new
	global L mem 
	global N  ntr
	global P lage ltfp_fhs
	global W1  teminyr
	global C cl(fam50)

	foreach x in te oe pw ph rtae lkl lsl  {

		if "`x'"~="lsl" & "`x'"~="lkl" {
			areg l`x' $OP $UP $ODP $L $M $N $P d???? [aw=$W1] if both==1, a(lbdnum) cl(fam50) robust
			outreg2 $OP $UP $ODP $L $M $N $P using r8.txt, append noaster nonote noparen dec(3)
			quietly {
				gen t1 = _b[s1999wm_post]*s1999wm
				sum t1 [aw=$W1] if year==1997
				noisily display ["Implied loss `x' `r(mean)'"]
				drop t1
			}

		}

		if "`x'"=="lkl" {
			areg `x' $OP $ODP $L $M $N lslminyr_post $P d???? [aw=$W1] if both==1, a(lbdnum) cl(fam50) robust
			outreg2 $OP $ODP $L $M $N lslminyr_post $P using r8.txt, append noaster nonote noparen dec(3)
			quietly {
				gen t1 = _b[s1999wm_post]*s1999wm
				sum t1 [aw=$W1] if year==1997
				noisily display ["Implied loss `x' `r(mean)'"]
				drop t1
			}
			
		}
		if "`x'"=="lsl" {
			areg `x' $OP $ODP $L $M $N lklminyr_post $P d???? [aw=$W1] if both==1, a(lbdnum) cl(fam50) robust
			outreg2 $OP $ODP $L $M $N lklminyr_post $P using r8.txt, append noaster nonote noparen dec(3)
			quietly {
				gen t1 = _b[s1999wm_post]*s1999wm
				sum t1 [aw=$W1] if year==1997
				noisily display ["Implied loss `x' `r(mean)'"]
				drop t1
			}			
		}
	}
	
	




*Table 9: LBD plant regs

	capture erase r9.txt 

	/*
	*create interim plant-level gap dataset
	use $interim/pgap, clear
	keep lbdnum year *wm
	keep if year==1997
	save $interim/pgap_for_lbd, replace

	*merge in plant-level gap data
	use $interim/lbd_plant_regression_file, clear
	merge m:1 lbdnum using $interim/pgap_for_lbd, keepusing(s1999wm wgap_offd31999 iodown31999wm)
	drop if _merge==2
	drop _merge

	*generate "post" interactions
	foreach z in s1999wm wgap_offd31999wm iodown31999wm {
		gen `z'_post=`z'*post
	}

	save $interim/lbd_plant_regression_file_with_gap, replace
	*/
	
	use $interim/io_bbg_01_true_9007_20150605, clear
	keep if con50==1
	keep if year>=1990 & year<=2007
	capture drop i
	gen i = 1
	foreach x in s1999 nntr1999 ntr contract dr dsub se1999 sfw_mwt_sum_new lkl lsl mem {
		replace i=0 if `x'==.
	}
	egen ti = total(i), by(fam50)
	tab ti
	collapse (mean) ti, by(fam50)
	tab ti
	keep if ti==18
	drop ti
	gen check_true=1
	save $interim/check_true, replace	
		
	use  $interim/lbd_plant_regression_file_with_gap, clear
	merge m:1 fam50 using $interim/check_true
	keep if check_true==1
	drop if _merge==2
	drop _merge
	drop check_true

	gen idx=0
	foreach x in lemp death s1999_post lklminyr_post lslminyr_post contract_post ///
	             dr_post dsub_post se1999_post atp_post sfw_mwt_sum_new wgap_offd31999_post ///
		     iodown31999_post mem ntr empminyr fam50 {
		replace idx=1 if `x'==.
	}
	drop if idx==1

	global OP s1999wm_post
	global UP lklminyr_post lslminyr_post
	global ODP contract_post dr_post dsub_post se1999_post atp_post
	global M sfw_mwt_sum_new
	global IO wgap_offd31999wm_post iodown31999wm_post
	global L mem 
	global N  ntr
	global W  empminyr
	global C cl(fam50)

	*tailor the regs to the sample
	drop d1990

	gen one=1
	egen pcnt=total(one), by(lbdnum)
	tab pcnt

	*employment
	areg lemp $OP $UP $ODP $M $N $L d1991-d2007 [aw=$W] if pcnt==18, a(lbdnum) cl(fam50) robust
	outreg2 $OP $UP $ODP $M $N $L using r9.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1 = _b[s1999wm_post]*s1999wm
		sum t1 [aw=$W] if year==2007		
		noisily display ["Weighted Avg Implied loss in log points `r(mean)'"]
		drop t1
	}

	*employment + IO
	areg lemp $OP $IO $UP $ODP $M $N $L d1991-d2007 [aw=$W] if pcnt==18, a(lbdnum) cl(fam50) robust
	outreg2 $OP $IO $UP $ODP $M $N $L using r9.txt, append noaster nonote noparen dec(3)
	quietly {
		gen t1  = _b[s1999wm_post]*s1999wm + _b[wgap_offd31999wm_post]*wgap_offd31999wm + _b[iodown31999wm_post]*iodown31999wm
		gen t1o = _b[s1999wm_post]*s1999wm                   
		gen t1u = _b[wgap_offd31999wm_post]*wgap_offd31999wm 
		gen t1d = _b[iodown31999wm_post]*iodown31999wm       
		sum t1 if year==2000
		noisily display ["Weighted Avg Implied loss in log points tot loss `r(mean)'"]
		sum t1o if year==2000
		noisily display ["Weighted Avg Implied loss in log points own loss  `r(mean)'"]
		sum t1u if year==2000
		noisily display ["Weighted Avg Implied loss in log points up loss  `r(mean)'"]
		sum t1d if year==2000
		noisily display ["Weighted Avg Implied loss in log points down loss  `r(mean)'"]
		drop t1-t1d
	}

	gen both=minyr<2001 & maxyr>=2001

	*death
	areg death $OP $UP $ODP $M $N $L d1991-d2007 [aw=$W] if both==1, a(lbdnum) cl(fam50) robust
	outreg2 $OP $UP $ODP $M $N $L using r9.txt, append noaster nonote noparen dec(3)

	*death + io
	areg death $OP $IO $UP $ODP $M $N $L d1991-d2007 [aw=$W] if both==1, a(lbdnum) cl(fam50) robust
	outreg2 $OP $IO $UP $ODP $M $N $L using r9.txt, append noaster nonote noparen dec(3)

	
*Table A.1

		see results_public.do
	
	
*Table A.2 (using census sample; table in paper is from public sample)
	capture erase ra2.txt 
	use $interim/lbd_industry_regression_file, clear
	foreach x in lkl1990 lsl1990 contract dr dsub se1999 sfw_mwt_sum_new mem atp ntr1999 nntr1999 {
		reg s1999 `x' if year==2007
		outreg2 using ra2.txt, append noaster nonote noparen dec(3)
	}
	
*Table A.3

		see results_china_tfp.do

*Figure 1: 

		see results_public.do
			
*Figure 2: NTR gap
	use $interim/lbd_industry_regression_file, clear
	kdensity s1999 if year==1999 & con==1

*Figure 3:

		Manufacturing employment and real value added from BEA website.
		
*FIgure 4:

		Graphical representation of table A.4 results generated above.
	
*Figure A.1 constant manuf employment
	use $interim/lbd_industry_regression_file, clear
	table year, c(sum empfam501999) f(%18.0fc)





