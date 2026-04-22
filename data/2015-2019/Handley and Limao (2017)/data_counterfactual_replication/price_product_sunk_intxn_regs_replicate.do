
set more off


use  replication_maindata1,clear


 /*program to compute marginal effects*/
  capture program drop unc_margins
  program unc_margins, rclass
  
  args unccoeff unc_unwt unc_wt
  
  lincom `unc_unwt'*_b[`unccoeff']
  return scalar mfx_unwt = round(`r(estimate)',.01)

  
  lincom `unc_wt'*_b[`unccoeff']
  return scalar mfx_wt = round(`r(estimate)',.01)

    
  end	


  
  
qui reg dif_ln_imp_5  dif_advalorem_mfn_5 dif_ln_tcost_5 unc_pre if year==2005

sum unc_pre if e(sample), meanonly
local unc_unwt=round(`r(mean)',.01)


sum unc_pre [aw=w_g_num_05] if e(sample), meanonly
local unc_wt=round(`r(mean)',.01)



local outregfile1 table4.out
local outregfile2 table5.out

local replace replace
local psample " & pindex_sample==1"
	
*local samples `" " " " & max2max==0"  " & hi_sunk_t==0 " " & hi_sunk_t==1 " "'

local samples `" " " " & max2max==0"    "'

local restrict "UNCONSTRAINED"
	
	

xtset hs6 year


** Price Results for Table 4 & 5 **

foreach var in  ldif_ln_pindex_hs6_total {	
	
/*ADVALOREM*/


	local difX  dif_advalorem_mfn_`x' dif_ln_tcost_`x'
	
	
	/*** Trim 2.5% tails of price depvar ****/
	
	reg `var' unc_pre `difX'  /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r  
	
	
	unc_margins unc_pre `unc_unwt' `unc_wt'
	
	outreg2   `difX'  using `outregfile1',  `replace' /*
				*/cttop(`var', `year',  ,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons /*
				*/ addstat("mfx unwt", `r(mfx_unwt)', "mfx ideal wts", `r(mfx_wt)')
				

	
	
	reg `var' c.unc_pre#i.hi_sunk_t `difX' i.hi_sunk_t  /*
	*/ if year==2005  & trim_025tails==1 `sub' `psample', r  
	
	
	
	
	
	outreg2     using `outregfile2',  `replace' /*
				*/cttop(`var', `year',  ,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons /*
				*/
		
	local replace
		
		
	/*** now same with sections ****/
	
	areg `var' unc_pre `difX'  /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r  ab(section)
	
	unc_margins unc_pre `unc_unwt' `unc_wt'
	
	
	outreg2   `difX'  using `outregfile1',  `replace' /*
				*/cttop(`var', `year',  section FE,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons /*
				*/ addstat("mfx unwt", `r(mfx_unwt)', "mfx ideal wts", `r(mfx_wt)')
				
	
	areg `var' c.unc_pre#i.hi_sunk_t `difX' i.hi_sunk_t   /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r ab(section) 
	
	
	outreg2    using `outregfile2',  `replace' /*
				*/cttop(`var', `year',  section FE,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons 
	
	
	}	
	
	
	
preserve	
	
/*** Aggregation to hs4*****/



sort hs4 year

keep if year==2005 

*don't commingle hs6 with AVE and ad-valorem tariffs
*drop all AVE tariffs so mean is over statutory ad valorem lines

keep if dif_advalorem_mfn_5!=. 


set more off
collapse (mean) dif_ln_tcost_5 dif_advalorem_mfn_5  unc_pre    (first) ldif_ln_pindex_hs4* section, by(hs4 year)



*adjust hs4 measures from FOB to CIF/tariff basis
*unweighted just use replace
foreach var in ldif_ln_pindex_hs4  {

replace `var'_total=`var'_total+dif_advalorem_mfn_5+dif_ln_tcost_5 if `var'_total!=.

}



/***** RUN MAIN SET OF RESULTS AT HS4 FOR TABLE 4 *****/	


set more off
qui reg ldif_ln_pindex_hs4_total dif_ln_tcost_5 dif_advalorem_mfn_5  unc_pre if year==2005
gen pindex_sample=e(sample)



local pricevar ldif_ln_pindex_hs4_total

*full sample*

  reg `pricevar' dif_ln_tcost_5 dif_advalorem_mfn_5  unc_pre      if year==2005 & pindex_sample==1  ,robust

	unc_margins unc_pre `unc_unwt' `unc_wt'
	
	outreg2 using  `outregfile1' ,  `replace'   /*
			*/  cttop(HS4 `pricevar',  ,     ,robust SE,) bfmt(fc) coefastr level(95) se br  cons  /*
				*/ addstat("mfx unwt", `r(mfx_unwt)', "mfx ideal wts", `r(mfx_wt)')
			
	local replace

*section FE*

  areg `pricevar' dif_ln_tcost_5 dif_advalorem_mfn_5  unc_pre  if year==2005 & pindex_sample==1  ,robust ab(section)

	unc_margins unc_pre `unc_unwt' `unc_wt'
	
	outreg2 using  `outregfile1' ,  `replace'   /*
			*/ cttop(HS4 `pricevar',  ,section FE ,robust SE,)  bfmt(fc) coefastr level(95) se br  cons   /*
				*/ addstat("mfx unwt", `r(mfx_unwt)', "mfx ideal wts", `r(mfx_wt)')
	local replace


restore
	
	
	
	

*** Product variety results for tables 4 and 5 ***

foreach var in  dif_ln_num_prod_`x'{	
	
/*ADVALOREM*/


	local difX  dif_advalorem_mfn_`x' dif_ln_tcost_`x'
	
	
	/*** Trim 2.5% tails of price depvar ****/
	
	reg `var' unc_pre `difX'  /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r  
	
	outreg2   `difX'  using `outregfile1',  `replace' /*
				*/cttop(`var', `year',  ,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons 

	
	
	reg `var' c.unc_pre#i.hi_sunk_t `difX' i.hi_sunk_t  /*
	*/ if year==2005  & trim_025tails==1 `sub' `psample', r  
	
	outreg2     using `outregfile2',  `replace' /*
				*/cttop(`var', `year',  ,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons 
				
		local replace
		
		
	/*** now same with sections ****/
	
	areg `var' unc_pre `difX'  /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r  ab(section)
	
	outreg2   `difX'  using `outregfile1',  `replace' /*
				*/cttop(`var', `year',  section FE,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons 
				
	
	areg `var' c.unc_pre#i.hi_sunk_t `difX' i.hi_sunk_t   /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r ab(section) 
	
	
	outreg2   using `outregfile2',  `replace' sortvar(0.hi_sunk_t#unc_pre  1.hi_sunk_t#unc_pre `difX')/*
				*/cttop(`var', `year',  section FE,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons 
	
	
	
preserve
keep if max2max==0
	
	
	/*** Trim 2.5% tails of price depvar ****/
	
	reg `var' unc_pre `difX'  /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r  
	
	
	outreg2   `difX'  using `outregfile1',  `replace' /*
				*/cttop(`var', `year',  ,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons 

	areg `var' unc_pre `difX'  /*
		*/ if year==2005  & trim_025tails==1 `sub' `psample', r  ab(section)
	

	outreg2   `difX'  using `outregfile1',  `replace' /*
				*/cttop(`var', `year',  section FE,`sub',"PRICE trim 0.025 tails") bfmt(fc) coefastr level(95) se br  cons 
				
restore
	}	
	
	
	
	


	
exit


