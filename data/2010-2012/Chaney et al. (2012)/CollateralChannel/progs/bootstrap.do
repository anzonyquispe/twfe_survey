clear mata
clear matrix
clear
set more 1
set mem 1500m
set mat 800
cap log close

/**************************************************************************************************************/
/********************************************   PROGRAMS 	      *****************************************/
/**************************************************************************************************************/




****************************************************************************
*************** building IV data *******************************************
****************************************************************************


***data on mortgage rate & inflation by quarter
insheet using "../data/interest.txt", names tab clear
replace inflation=subinstr(inflation,",",".",.) 
destring inflation, replace
replace mortgage=subinstr(mortgage,",",".",.)
destring mortgage, replace
gen year=real(substr(date,1,4))
gen month=real(substr(date,6,2))
drop date
gen quarter=1+(month>3)+(month>6)+(month>9)

***data collapsed at the year level
collapse (mean) mortgage inflation,by(year )
sort year 
***save in temporary file temp.
save "../output/temp", replace 


***data on housing prices & housing supply restriction at the MSA level

insheet using "../data/housing_data_MSA.txt", tab names clear

***correct the msacode for big cities (div code for CBSA code)
replace msacode	=	14460 if msacode==	14484
replace msacode	=	14460 if msacode==	15764
replace msacode	=	37980 if msacode==	15804
replace msacode	=	16980 if msacode==	16974
replace msacode	=	19100 if msacode==	19124
replace msacode	=	19820 if msacode==	19804
replace msacode	=	19100 if msacode==	23104
replace msacode	=	31100 if msacode==	31084
replace msacode	=	33100 if msacode==	33124
replace msacode	=	35620 if msacode==	35084
replace msacode	=	35620 if msacode==	35644
replace msacode	=	41860 if msacode==	36084
replace msacode	=	37980 if msacode==	37964
replace msacode	=	41860 if msacode==	41884
replace msacode	=	31100 if msacode==	42044
replace msacode	=	42660 if msacode==	42644
replace msacode	=	42660 if msacode==	45104
replace msacode	=	47900 if msacode==	47894
replace msacode	=	33100 if msacode==	48424

***index_msa is originally in string because of missing data
destring index_msa, force replace

***data collapsed at the year MSA level (initially by quarter)
collapse (mean) index_msa msacode, by(msa year)

sort msacode year
save "../output/temp2", replace

*****elasticity is a dataset with msa-level elasticities coming from saez
use "../data/elasticity", replace
sort msacode
merge 1:n msacode using "../output/temp2"
drop if _merge==1
drop _merge
drop if msacode==.
sort msacode year
save "../output/temp2", replace

***commercial_price_data gives commercial real estate prices at the msa levels, for some MSAs. Comes from Mayer (industrial analytics).
insheet using "../not for diffusion/commercial_price_data.txt", names tab clear
collapse (mean) offprice indprice, by(msacode year)
sort msacode year
merge 1:n msacode year using "../output/temp2"
drop if _merge==1
drop _merge
sort msacode year
save "../output/temp2",replace


***merge with data on mortgage rates & inflation
sort year
merge m:1 year using "../output/temp"
drop if _m==2
drop _m

***we normalize office and MSA prices to be 1 in 2006
cap drop var1 
cap drop var2
gen var1=offprice if year==2006
egen var2=max(var1),by(msacode)
replace offprice=offprice/var2

cap drop var1 
cap drop var2
gen var1=index_msa if year==2006
egen var2=max(var1),by(msacode)
replace index_msa =index_msa /var2

***create real estate price growth rates for summary statistics
sort msa year
quietly by msa: gen g_indmsa=(index_msa-index_msa[_n-1])/index_msa[_n-1]
clean g_indmsa

quietly by msa: gen g_offprice=(offprice-offprice[_n-1])/offprice[_n-1]
clean g_offprice

***only interested in predicting price from 1993 on (to match COMPUSTAT sample)
keep if year>=1993

*** 30 years mortgage rates are adjusted for inflation
replace mortgage=mortgage-inflation

****create first instrument (inter) and predict prices (MSA and office)
cap drop inter
gen inter=elasticity*mortgage
clean inter

sort msacode year
save "../output/temp", replace


cap program drop myboot
program define myboot, rclass
use "../output/temp", clear
bsample , cl(msacode)
xi: areg offprice inter  mortgage i.year,a(msa) cl(msa)
predict offprice_p1,xbd
duplicates drop msacode year, force
keep msacode year offprice_p1
sort msacode year
save "../output/local",replace
use msacode ppem year inv RE_ft_off offprice cash qm ageq assetq roaq state sic2 yr* gvkey id2 using "../output/dataset_final" ,clear
sort msacode year
merge m:1 msacode year using "../output/local"
drop if _m==2
drop _m
sort gvkey year
quietly by gvkey: gen RE_value_off_p1=(RE_ft_off[1]*offprice[1]/offprice_p1[1])*offprice_p1/ppem
clean RE_value_off_p1
save "../output/local", replace
bsample , cl(id2)

xi: areg inv RE_value_off_p1 offprice_p1 cash qm i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)

matrix coeff=e(b)
return scalar coeff1=coeff[1,1]
return scalar coeff2=coeff[1,2]
return scalar coeff3=coeff[1,3]
return scalar coeff4=coeff[1,4]
end

log using "../output/reg.log", append

**********************************************************************
*****BOOTSTRAP FOR REGRESSION WITH RE_VALUE *************************
**********************************************************************

simulate coeff1=coeff[1,1] coeff2=coeff[1,2] coeff3=coeff[1,3] coeff4=coeff[1,4], reps(500) : myboot
sum coeff1,d
sum coeff2,d
sum coeff3,d
sum coeff4,d

log close


cap program drop myboot
program define myboot, rclass
use "../output/temp", clear
bsample , cl(msacode)
xi: areg offprice inter  mortgage i.year,a(msa) cl(msa)
predict offprice_p1,xbd
duplicates drop msacode year, force
keep msacode year offprice_p1
sort msacode year
save "../output/local",replace
use msacode year REAL_ESTATE0 inv offprice cash qm ageq assetq roaq state sic2 yr* gvkey id2 using "../output/dataset_final" ,clear
sort msacode year
merge m:1 msacode year using "../output/local"
drop if _m==2
drop _m

save "../output/local", replace
bsample , cl(id2)

cap drop dum
gen dum=REAL_ESTATE0*offprice_p1
xi: areg inv dum  offprice_p1 cash qm  i.ageq*offprice_p1 REAL_ESTATE0 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)

matrix coeff=e(b)
return scalar coeff1=coeff[1,1]
return scalar coeff2=coeff[1,2]
return scalar coeff3=coeff[1,3]
return scalar coeff4=coeff[1,4]
end


log using "../output/reg.log", append

**********************************************************************
*****BOOTSTRAP FOR REGRESSION WITH RE DUMMY* *************************
**********************************************************************

simulate coeff1=coeff[1,1] coeff2=coeff[1,2] coeff3=coeff[1,3] coeff4=coeff[1,4], reps(500) : myboot
sum coeff1,d
sum coeff2,d
sum coeff3,d
sum coeff4,d


log close

cap program drop myboot
program define myboot, rclass
use "../output/temp", clear
bsample , cl(msacode)
xi: areg offprice inter  mortgage i.year ,a(msa) cl(msa)
predict offprice_p1,xbd
duplicates drop msacode year, force
keep msacode year offprice_p1
sort msacode year
save "../output/local",replace
use msacode year REAL_ESTATE0 inv offprice cash qm ageq assetq roaq state sic2 yr* gvkey id2 using "../output/unbalanced" ,clear
sort msacode year
merge m:1 msacode year using "../output/local"
drop if _m==2
drop _m
save "../output/local", replace
bsample , cl(id2)

cap drop dum
gen dum=REAL_ESTATE0*offprice_p1
xi: areg inv dum  offprice_p1 cash qm  i.ageq*offprice_p1 REAL_ESTATE0 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)

matrix coeff=e(b)
return scalar coeff1=coeff[1,1]
return scalar coeff2=coeff[1,2]
return scalar coeff3=coeff[1,3]
return scalar coeff4=coeff[1,4]
end

log using "../output/reg.log", append
*************************************************************************************
*****BOOTSTRAP FOR REGRESSION WITH dummy variable using unbalanced sample************
*************************************************************************************

simulate coeff1=coeff[1,1] coeff2=coeff[1,2] coeff3=coeff[1,3] coeff4=coeff[1,4], reps(500) : myboot
sum coeff1,d
sum coeff2,d
sum coeff3,d
sum coeff4,d

log close


cap program drop myboot
program define myboot, rclass
use "../output/temp", clear
bsample , cl(msacode)
xi: areg offprice inter  mortgage i.year,a(msa) cl(msa)
predict offprice_p1, xbd
duplicates drop msacode year, force
keep msacode year offprice_p1
sort msacode year
save "../output/local",replace
use msacode year owner_10k inv offprice cash qm ageq assetq roaq state sic2 yr* gvkey id using "../output/msaownership" ,clear
sort msacode year
merge m:1 msacode year using "../output/local"
drop if _m==2
drop _m
save "../output/local", replace
bsample , cl(id)

cap drop dum
gen dum=owner_10k*offprice_p1
xi: areg inv dum  offprice_p1 cash qm  i.ageq*offprice_p1 owner_10k i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id)

matrix coeff=e(b)
return scalar coeff1=coeff[1,1]
return scalar coeff2=coeff[1,2]
return scalar coeff3=coeff[1,3]
return scalar coeff4=coeff[1,4]
end

log using "../output/reg.log", append
*************************************************************************************
*****BOOTSTRAP FOR REGRESSION WITH dummy variable using 10k info************
*************************************************************************************

simulate coeff1=coeff[1,1] coeff2=coeff[1,2] coeff3=coeff[1,3] coeff4=coeff[1,4], reps(500) : myboot
sum coeff1,d
sum coeff2,d
sum coeff3,d
sum coeff4,d

log close


cap program drop myboot
program define myboot, rclass
use "../output/temp", clear
bsample , cl(msacode)
xi: areg offprice inter  mortgage i.year,a(msa) cl(msa)
predict offprice_p1,xbd
duplicates drop msacode year, force
keep msacode year offprice_p1
sort msacode year
save "../output/local",replace
use largemsa year msacode ppem year inv inv2 inv3 inv_adj RE_ft_off offprice cash qm ageq assetq roaq state sic2 yr* gvkey id2 using "../output/dataset_final" ,clear
sort msacode year
merge m:1 msacode year using "../output/local"
drop if _m==2
drop _m

sort gvkey year
quietly by gvkey: gen RE_value_off_p1=(RE_ft_off[1]*offprice[1]/offprice_p1[1])*offprice_p1/ppem
clean RE_value_off_p1

save "../output/local", replace
bsample , cl(id2)

xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr* if year<=1999, a(gvkey) cl(id2)
matrix coeffA=e(b)

xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr* if year>=2000, a(gvkey) cl(id2)
matrix coeffB=e(b)

xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr* if largemsa==1&assetq~=4, a(gvkey) cl(id2)
matrix coeffC=e(b)

xi: areg inv2 RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
matrix coeffD=e(b)

xi: areg inv3 RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
matrix coeffE=e(b)

xi: areg inv_adj RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
matrix coeffF=e(b)

return scalar coeffA1=coeffA[1,1]
return scalar coeffA2=coeffA[1,2]
return scalar coeffA3=coeffA[1,3]
return scalar coeffA4=coeffA[1,4]

return scalar coeffB1=coeffB[1,1]
return scalar coeffB2=coeffB[1,2]
return scalar coeffB3=coeffB[1,3]
return scalar coeffB4=coeffB[1,4]

return scalar coeffC1=coeffC[1,1]
return scalar coeffC2=coeffC[1,2]
return scalar coeffC3=coeffC[1,3]
return scalar coeffC4=coeffC[1,4]

return scalar coeffD1=coeffD[1,1]
return scalar coeffD2=coeffD[1,2]
return scalar coeffD3=coeffD[1,3]
return scalar coeffD4=coeffD[1,4]

return scalar coeffE1=coeffE[1,1]
return scalar coeffE2=coeffE[1,2]
return scalar coeffE3=coeffE[1,3]
return scalar coeffE4=coeffE[1,4]

return scalar coeffF1=coeffF[1,1]
return scalar coeffF2=coeffF[1,2]
return scalar coeffF3=coeffF[1,3]
return scalar coeffF4=coeffF[1,4]
end

log using "../output/reg.log", append
*************************************************************************************
*****BOOTSTRAP FOR ROBUSTNESS CHECK REGRESSIONS							************
*************************************************************************************

simulate coeffA1=coeffA[1,1] coeffA2=coeffA[1,2] coeffA3=coeffA[1,3] coeffA4=coeffA[1,4] coeffB1=coeffB[1,1] coeffB2=coeffB[1,2] coeffB3=coeffB[1,3] coeffB4=coeffB[1,4] coeffC1=coeffC[1,1] coeffC2=coeffC[1,2] coeffC3=coeffC[1,3] coeffC4=coeffC[1,4] coeffD1=coeffD[1,1] coeffD2=coeffD[1,2] coeffD3=coeffD[1,3] coeffD4=coeffD[1,4] coeffE1=coeffE[1,1] coeffE2=coeffE[1,2] coeffE3=coeffE[1,3] coeffE4=coeffE[1,4] coeffF1=coeffF[1,1] coeffF2=coeffF[1,2] coeffF3=coeffF[1,3] coeffF4=coeffF[1,4], reps(500) : myboot
sum coeffA1,d
sum coeffA2,d
sum coeffA3,d
sum coeffA4,d

sum coeffB1,d
sum coeffB2,d
sum coeffB3,d
sum coeffB4,d

sum coeffC1,d
sum coeffC2,d
sum coeffC3,d
sum coeffC4,d

sum coeffD1,d
sum coeffD2,d
sum coeffD3,d
sum coeffD4,d

sum coeffE1,d
sum coeffE2,d
sum coeffE3,d
sum coeffE4,d

sum coeffF1,d
sum coeffF2,d
sum coeffF3,d
sum coeffF4,d


log close


cap program drop myboot
program define myboot, rclass
use "../output/temp", clear
bsample , cl(msacode)
xi: areg offprice inter  mortgage i.year,a(msa) cl(msa)
predict offprice_p1,xbd
duplicates drop msacode year, force
keep msacode year offprice_p1
sort msacode year
save "../output/local",replace
use msacode ppem year inv deltaltdebt ltdebt_issuance ltdebt_reduction net_debt st_issuance RE_ft_off offprice cash qm ageq assetq roaq state sic2 yr* gvkey id2 using "../output/dataset_final" ,clear
sort msacode year
merge m:1 msacode year using "../output/local"
drop if _m==2
drop _m

sort gvkey year
quietly by gvkey: gen RE_value_off_p1=(RE_ft_off[1]*offprice[1]/offprice_p1[1])*offprice_p1/ppem
clean RE_value_off_p1

save "../output/local", replace
bsample , cl(id2)
xi: areg ltdebt_issuance RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id)
matrix coeffA=e(b)
xi: areg ltdebt_reduction RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id)
matrix coeffB=e(b)
xi: areg net_debt RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice i.sic2*offprice_p1  yr*, a(gvkey) cl(id)
matrix coeffC=e(b)
xi: areg deltaltdebt RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id)
matrix coeffD=e(b)
xi: areg st_issuance RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id)
matrix coeffE=e(b)


return scalar coeffA1=coeffA[1,1]
return scalar coeffA2=coeffA[1,2]
return scalar coeffA3=coeffA[1,3]
return scalar coeffA4=coeffA[1,4]

return scalar coeffB1=coeffB[1,1]
return scalar coeffB2=coeffB[1,2]
return scalar coeffB3=coeffB[1,3]
return scalar coeffB4=coeffB[1,4]

return scalar coeffC1=coeffC[1,1]
return scalar coeffC2=coeffC[1,2]
return scalar coeffC3=coeffC[1,3]
return scalar coeffC4=coeffC[1,4]

return scalar coeffD1=coeffD[1,1]
return scalar coeffD2=coeffD[1,2]
return scalar coeffD3=coeffD[1,3]
return scalar coeffD4=coeffD[1,4]

return scalar coeffE1=coeffE[1,1]
return scalar coeffE2=coeffE[1,2]
return scalar coeffE3=coeffE[1,3]
return scalar coeffE4=coeffE[1,4]

end

log using "../output/reg.log", append

*************************************************************************************
*****BOOTSTRAP FOR ROBUSTNESS CAPITAL STRUCTURE REGRESSIONS	**			************
*************************************************************************************

simulate coeffA1=coeffA[1,1] coeffA2=coeffA[1,2] coeffA3=coeffA[1,3] coeffA4=coeffA[1,4] coeffB1=coeffB[1,1] coeffB2=coeffB[1,2] coeffB3=coeffB[1,3] coeffB4=coeffB[1,4] coeffC1=coeffC[1,1] coeffC2=coeffC[1,2] coeffC3=coeffC[1,3] coeffC4=coeffC[1,4] coeffD1=coeffD[1,1] coeffD2=coeffD[1,2] coeffD3=coeffD[1,3] coeffD4=coeffD[1,4] coeffE1=coeffE[1,1] coeffE2=coeffE[1,2] coeffE3=coeffE[1,3] coeffE4=coeffE[1,4] , reps(500) : myboot
sum coeffA1,d
sum coeffA2,d
sum coeffA3,d
sum coeffA4,d

sum coeffB1,d
sum coeffB2,d
sum coeffB3,d
sum coeffB4,d

sum coeffC1,d
sum coeffC2,d
sum coeffC3,d
sum coeffC4,d

sum coeffD1,d
sum coeffD2,d
sum coeffD3,d
sum coeffD4,d

sum coeffE1,d
sum coeffE2,d
sum coeffE3,d
sum coeffE4,d
log close



cap program drop myboot
program define myboot, rclass
use "../output/temp", clear
bsample , cl(msacode)
xi: areg offprice inter  mortgage i.year,a(msa) cl(msa)
predict offprice_p1,xbd
duplicates drop msacode year, force
keep msacode year offprice_p1
sort msacode year
save "../output/local",replace
use constraint* p_cont* p_const* ident* msacode ppem year inv RE_ft_off offprice cash qm ageq assetq roaq state sic2 yr* gvkey id2 using "../output/dataset_final" ,clear
sort msacode year
merge m:1 msacode year using "../output/local"
drop if _m==2
drop _m

sort gvkey year
quietly by gvkey: gen RE_value_off_p1=(RE_ft_off[1]*offprice[1]/offprice_p1[1])*offprice_p1/ppem
clean RE_value_off_p1

save "../output/local", replace
bsample , cl(id2)
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint1==1, a(gvkey) cl(id2)
matrix coeffA=e(b)
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint1==0, a(gvkey) cl(id2)
matrix coeffB=e(b)
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint2==1, a(gvkey) cl(id2)
matrix coeffC=e(b)
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint2==0, a(gvkey) cl(id2)
matrix coeffD=e(b)
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint3==1, a(gvkey) cl(id2)
matrix coeffE=e(b)
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint3==0, a(gvkey) cl(id2)
matrix coeffF=e(b)
renpfix p_const1_cont3 CO1
renpfix p_const2_cont3 CO2
renpfix p_const3_cont3 CO3

cap drop inter
gen inter=constraint1*RE_value_off_p1
xi: areg inv inter i.constraint1 RE_value_off_p1 i.constraint1*offprice_p1 i.constraint1*cash i.constraint1*qm   p_cont3_qage* p_cont3_qasset* p_cont3_qroa* p_cont3_ind* p_cont3_st* CO1*  yr*, a(ident1) cl(id2)
matrix coeffG=e(b)
cap drop inter
gen inter=constraint2*RE_value_off_p1
xi: areg inv inter i.constraint2 RE_value_off_p1 i.constraint2*offprice_p1 i.constraint2*cash i.constraint2*qm   p_cont3_qage* p_cont3_qasset* p_cont3_qroa* p_cont3_ind* p_cont3_st* CO2*  yr*, a(ident2) cl(id2)
matrix coeffH=e(b)
cap drop inter
gen inter=constraint3*RE_value_off_p1
xi: areg inv inter constraint3 RE_value_off_p1 i.constraint3*offprice_p1 i.constraint3*cash i.constraint3*qm   p_cont3_qage* p_cont3_qasset* p_cont3_qroa* p_cont3_ind* p_cont3_st* CO3*  yr*, a(ident3) cl(id2)
matrix coeffI=e(b)

return scalar coeffA1=coeffA[1,1]
return scalar coeffA2=coeffA[1,2]
return scalar coeffA3=coeffA[1,3]
return scalar coeffA4=coeffA[1,4]

return scalar coeffB1=coeffB[1,1]
return scalar coeffB2=coeffB[1,2]
return scalar coeffB3=coeffB[1,3]
return scalar coeffB4=coeffB[1,4]

return scalar coeffC1=coeffC[1,1]
return scalar coeffC2=coeffC[1,2]
return scalar coeffC3=coeffC[1,3]
return scalar coeffC4=coeffC[1,4]

return scalar coeffD1=coeffD[1,1]
return scalar coeffD2=coeffD[1,2]
return scalar coeffD3=coeffD[1,3]
return scalar coeffD4=coeffD[1,4]

return scalar coeffE1=coeffE[1,1]
return scalar coeffE2=coeffE[1,2]
return scalar coeffE3=coeffE[1,3]
return scalar coeffE4=coeffE[1,4]

return scalar coeffF1=coeffF[1,1]
return scalar coeffF2=coeffF[1,2]
return scalar coeffF3=coeffF[1,3]
return scalar coeffF4=coeffF[1,4]

return scalar coeffG1=coeffG[1,1]
return scalar coeffH1=coeffH[1,1]
return scalar coeffI1=coeffI[1,1]
end

log using "../output/reg.log", append
*************************************************************************************
*****BOOTSTRAP FOR ROBUSTNESS CAPITAL CONSTRAINED/UNCONSTRAINED REGRESSIONS	*********
*************************************************************************************

simulate coeffA1=coeffA[1,1] coeffA2=coeffA[1,2] coeffA3=coeffA[1,3] coeffA4=coeffA[1,4] coeffB1=coeffB[1,1] coeffB2=coeffB[1,2] coeffB3=coeffB[1,3] coeffB4=coeffB[1,4] coeffC1=coeffC[1,1] coeffC2=coeffC[1,2] coeffC3=coeffC[1,3] coeffC4=coeffC[1,4] coeffD1=coeffD[1,1] coeffD2=coeffD[1,2] coeffD3=coeffD[1,3] coeffD4=coeffD[1,4] coeffE1=coeffE[1,1] coeffE2=coeffE[1,2] coeffE3=coeffE[1,3] coeffE4=coeffF[1,4] coeffF1=coeffF[1,1] coeffF2=coeffF[1,2] coeffF3=coeffF[1,3] coeffF4=coeffF[1,4] coeffG1=coeffG[1,1] coeffH1=coeffH[1,1] coeffI1=coeffI[1,1], reps(500) : myboot
sum coeffA1,d
sum coeffA2,d
sum coeffA3,d
sum coeffA4,d

sum coeffB1,d
sum coeffB2,d
sum coeffB3,d
sum coeffB4,d

sum coeffC1,d
sum coeffC2,d
sum coeffC3,d
sum coeffC4,d

sum coeffD1,d
sum coeffD2,d
sum coeffD3,d
sum coeffD4,d

sum coeffE1,d
sum coeffE2,d
sum coeffE3,d
sum coeffE4,d

sum coeffF1,d
sum coeffF2,d
sum coeffF3,d
sum coeffF4,d

sum coeffG1,d
sum coeffH1,d
sum coeffI1,d

log close


erase "../output/temp.dta"
erase "../output/local.dta"
erase "../output/temp2.dta"

