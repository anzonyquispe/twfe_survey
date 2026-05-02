

clear all
	
	
set more off

use replication_maindata1, clear

local year=2005	
local x=5

	
	local outregfile table6.out
	local replace replace 

	
	xtset hs6 year
	
	

***non-linear***

gen lag_imports00=L5.imports
	keep if year==2005

	
	*since much depends on the transport cost, which pins down k 
	*and k shows up in all other coefficients we need to make sure that k is not
	*biased by outliers in transport costs, particularly given that the latter
	*are sometimes measured with error**
	
	qui reg dif_ln_imp_5  dif_ln_tcost_5 dif_advalorem_mfn_5 rat_2000 if year==2005 
	
	egen p25=pctile(dif_ln_tcost_5)  if e(sample), p(25)
	egen p75=pctile(dif_ln_tcost_5)  if e(sample), p(75)
	gen double inner=p25-3*(p75-p25)
	gen double outer =p75+3*(p75-p25)
	
	*confirm
	sum inner outer

	
	*scalar
	sum inner 
	scalar inner=r(mean)
	sum outer
	scalar outer=r(mean)
	
local replace replace	
	

		*no section, restrict sigma=3*
		constraint 1 dif_ln_tcost_5*3/2= dif_advalorem_mfn_5

/* col 1*/	

reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5 if  dif_ln_tcost_5>inner & dif_ln_tcost_5<outer  & year==2005,r 


/*** get share of total trade on NLS sample****/
capture drop regsamp
gen regsamp=e(sample)
	
	di "share of total trade 2005 on nls regression sample"
	sum regsamp [aw=imports] if year==2005
	local totsh2005=r(mean)
	
	di "share of total trade 2000 on nls regression sample"
	sum regsamp [aw=lag_imports00] if year==2005
	local totsh2000=r(mean)
	
	di "share of total growth in nls sample is share of total trade: "`totsh2005'


test 1.5*_b[dif_ln_tcost]=_b[dif_advalorem_mfn_5]
local restrictp=r(p)


cnsreg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5 if  dif_ln_tcost_5>inner & dif_ln_tcost_5<outer  & year==2005,r constraint(1)


outreg2   dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5  using `outregfile', nolabel `replace' /*
				*/cttop(OLS, `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Test TC/Tar Restriction",`restrictp')

local replace


		*confirm that we can't reject sigma=3*
				nl (dif_ln_imp_5 = {alpha=1} - (({k=3}-({sigma=3}-1))/({sigma=3}-1))*ln(1+{gamma=1}*rat_2000^({sigma=3}))  -{k=3}*dif_ln_tcost_5  -{k=3}*({sigma=3}/({sigma=3}-1))*dif_advalorem_mfn_5   ) if dif_ln_tcost_5>inner & dif_ln_tcost_5<outer , vce(r)
	
				**derive the equivalent of the beta_gamma coefficient we estimate in baseline and show it is significant and approximately the same**
				nlcom ((_b[/k]-_b[/sigma]+1)/(_b[/sigma]-1))*_b[/gamma]
			
				*tariff coefficient*
				nlcom (_b[/k]*_b[/sigma]/(_b[/sigma]-1))
		
	
				
				
/*col 2 stat at bottom*/
test _b[/sigma]=3
local sigmapval=r(p) 


*test cross-restriction in flexible coeffs on tariff and tcost*
				nl (dif_ln_imp_5 = {alpha=1} - ({bt}-{k}-1)*ln(1+{gamma=.1}*rat_2000^(3))  -{k=3}*dif_ln_tcost_5  -{bt=6}*dif_advalorem_mfn_5  ) if dif_ln_tcost_5>inner & dif_ln_tcost_5<outer , vce(r)


*check leading coeff
lincom _b[/bt]-_b[/k]-1

*test ratio when sigma=3
testnl _b[/bt]/_b[/k]=1.5
test 1.5*_b[/k]=_b[/bt]
local restrictp=r(p)


/* col 2*/		

nl (dif_ln_imp_5 = {alpha=1} - (({k=3}-(3-1))/(3-1))*ln(1+{gamma=1}*rat_2000^(3))  -{k=3}*dif_ln_tcost_5  -{k=3}*(3/(3-1))*dif_advalorem_mfn_5   ) if dif_ln_tcost_5>inner & dif_ln_tcost_5<outer , vce(r) variables(rat_2000 dif_ln_tcost_5 dif_advalorem_mfn_5)

	

				**derive the equivalent of the beta_gamma coefficient we estimate in baseline and use to calculate impact on exports and show it is significant and approximately the same**
				nlcom ((_b[/k]-3+1)/(3-1))*_b[/gamma]
				matrix bmat=r(b)
				local unc_lin=bmat[1,1]
				matrix bvar=r(V)
				local unc_lin_se=bvar[1,1]^.5
			
				*tariff coefficient*
				nlcom -((_b[/k])*3/(3-1))
				matrix bmat=r(b)
				local tar_lin=bmat[1,1]
				matrix bvar=r(V)
				local tar_lin_se=bvar[1,1]^.5

				*transport cost coefficient*
				nlcom -(_b[/k])
				matrix bmat=r(b)
				local tc_lin=bmat[1,1]
				matrix bvar=r(V)
				local tc_lin_se=bvar[1,1]^.5
				
				
				
				
outreg2    using `outregfile', nolabel `replace' /*
				*/cttop(NLS, `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Unc Coeff", `unc_lin', "Unc SE", `unc_lin_se', "Tariff Coeff", `tar_lin', "Tariff SE", `tar_lin_se',"TC Coeff", `tc_lin', "TC SE", `tc_lin_se', "Test unrestrict sigma=3 p-value",`sigmapval',"Test TC/Tar Restriction",`restrictp')
				


	
		*section dummies, restricted sigma=3*

/*col 3*/		


xi: reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5 i.section if  dif_ln_tcost_5>inner & dif_ln_tcost_5<outer  & year==2005,r 

test 1.5*_b[dif_ln_tcost]=_b[dif_advalorem_mfn_5]
local restrictp=r(p)


xi: cnsreg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5 i.section if  dif_ln_tcost_5>inner & dif_ln_tcost_5<outer  & year==2005,r constraint(1)


outreg2    using `outregfile', nolabel `replace' keep(dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5 )/*
				*/cttop(OLS, `year', sigma=`s', sections) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Test TC/Tar Restriction",`restrictp')
				
	


		*section dummies, unrestricted sigma*
		nl (dif_ln_imp_5 = {alpha=1} - (({k=3}-({sigma=3}-1))/({sigma=3}-1))*ln(1+{gamma=1}*rat_2000^({sigma=3}))  -{k=3}*dif_ln_tcost_5  -{k=3}*({sigma=3}/({sigma=3}-1))*dif_advalorem_mfn_5   +{i2}*_Isection_2 +{i3}*_Isection_3 +{i4}*_Isection_4 +{i5}*_Isection_5 +{i6}*_Isection_6 +{i7}*_Isection_7 +{i8}*_Isection_8 +{i9}*_Isection_9 +{i10}*_Isection_10 +{i11}*_Isection_11 +{i12}*_Isection_12 +{i13}*_Isection_13 +{i14}*_Isection_14 +{i15}*_Isection_15 +{i16}*_Isection_16 +{i17}*_Isection_17 +{i18}*_Isection_18 +{i19}*_Isection_19 +{i20}*_Isection_20 +{i21}*_Isection_21   ) if dif_ln_tcost_5>inner & dif_ln_tcost_5<outer , vce(r)
	
				nlcom ((_b[/k]-_b[/sigma]+1)/(_b[/sigma]-1))*_b[/gamma]
			
				*tariff coefficient*
				nlcom (_b[/k]*_b[/sigma]/(_b[/sigma]-1))
		
		
/*col 4 stat at bottom*/	
test _b[/sigma]=3
local sigmapval=r(p) 


nl (dif_ln_imp_5 = {alpha=1} - ({bt}-{k}-1)*ln(1+{gamma=.1}*rat_2000^(3))  -{k=3}*dif_ln_tcost_5  -{bt=6}*dif_advalorem_mfn_5  +{i2}*_Isection_2 +{i3}*_Isection_3 +{i4}*_Isection_4 +{i5}*_Isection_5 +{i6}*_Isection_6 +{i7}*_Isection_7 +{i8}*_Isection_8 +{i9}*_Isection_9 +{i10}*_Isection_10 +{i11}*_Isection_11 +{i12}*_Isection_12 +{i13}*_Isection_13 +{i14}*_Isection_14 +{i15}*_Isection_15 +{i16}*_Isection_16 +{i17}*_Isection_17 +{i18}*_Isection_18 +{i19}*_Isection_19 +{i20}*_Isection_20 +{i21}*_Isection_21  ) if dif_ln_tcost_5>inner & dif_ln_tcost_5<outer , vce(r)


*check leading coeff
lincom _b[/bt]-_b[/k]-1

*test ratio when sigma=3
testnl _b[/bt]/_b[/k]=1.5
test 1.5*_b[/k]=_b[/bt]
local restrictp=r(p)


*sections, restricted sigma*
nl (dif_ln_imp_5 = {alpha=1} - (({k=3}-(3-1))/(3-1))*ln(1+{gamma=1}*rat_2000^(3))  -{k=3}*dif_ln_tcost_5  -{k=3}*(3/(3-1))*dif_advalorem_mfn_5  +{i2}*_Isection_2 +{i3}*_Isection_3 +{i4}*_Isection_4 +{i5}*_Isection_5 +{i6}*_Isection_6 +{i7}*_Isection_7 +{i8}*_Isection_8 +{i9}*_Isection_9 +{i10}*_Isection_10 +{i11}*_Isection_11 +{i12}*_Isection_12 +{i13}*_Isection_13 +{i14}*_Isection_14 +{i15}*_Isection_15 +{i16}*_Isection_16 +{i17}*_Isection_17 +{i18}*_Isection_18 +{i19}*_Isection_19 +{i20}*_Isection_20 +{i21}*_Isection_21   ) if dif_ln_tcost_5>inner & dif_ln_tcost_5<outer , vce(r) variables(dif_advalorem_mfn_5 dif_ln_tcost_5 rat_2000)

	**derive the equivalent of the beta_gamma coefficient we estimate in baseline and use to calculate impact on exports and show it is significant and approximately the same**
				nlcom ((_b[/k]-3+1)/(3-1))*_b[/gamma]
				matrix bmat=r(b)
				local unc_lin=bmat[1,1]
				matrix bvar=r(V)
				local unc_lin_se=bvar[1,1]^.5
			
				*tariff coefficient*
				nlcom -((_b[/k])*3/(3-1))
				matrix bmat=r(b)
				local tar_lin=bmat[1,1]
				matrix bvar=r(V)
				local tar_lin_se=bvar[1,1]^.5

				*transport cost coefficient*
				nlcom -(_b[/k])
				matrix bmat=r(b)
				local tc_lin=bmat[1,1]
				matrix bvar=r(V)
				local tc_lin_se=bvar[1,1]^.5
				
			
		
		
outreg2     using `outregfile', nolabel `replace' /*
				*/cttop(NLS, `year', sigma=`s',sections) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Unc Coeff", `unc_lin', "Unc SE", `unc_lin_se', "Tariff Coeff", `tar_lin', "Tariff SE", `tar_lin_se',"TC Coeff", `tc_lin', "TC SE", `tc_lin_se', "Test unrestrict sigma=3 p-value",`sigmapval', "Test TC/Tar Restriction", `restrictp')


*reformat output*
import delimited table6.out, clear 
keep v1-v3 v6-v7

*reorder vars

order v1 v3 v2 v7 v6

*renumber columns
replace v6="(4)" if v6=="(5)" 
replace v7="(3)" if v7=="(6)" 
replace v3="(1)" if v3=="(2)"
replace v2="(2)" if v2=="(1)"

export delimited using "table6.out", delimiter(tab) novarnames replace

exit
				
	
