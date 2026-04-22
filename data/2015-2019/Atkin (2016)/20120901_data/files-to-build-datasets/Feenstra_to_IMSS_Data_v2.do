

set more off

/**

foreach n in 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 {

use C:\Scratch\Feenstra\wtf`n'.dta, clear

keep if exporter=="Mexico" & importer=="World"

save C:\Scratch\Feenstra\Mexwtf`n'.dta, replace

}


use C:\Scratch\Feenstra\Mexwtf84.dta

foreach n in  85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 {


append using  C:\Scratch\Feenstra\Mexwtf`n'.dta

}


gen sitc3=substr(sitc4,1,3)
egen valuesitc=total(value), by(sitc3 year) 

egen tagsitc3=tag(sitc3 year)
keep if tagsitc3==1

keep sitc3 valuesitc year

save "C:\Work\Mexico\Trade Production and Protection\Update\Feenstra_Mex_trade.dta", replace



*get total workers in IMSS
use muncenso year emp00* using "C:\Data\Mexico\mexico_ss_Stata\newindcen90_simpleMerge_skill.dta", clear
reshape long emp00 , i(year muncenso) j(imms2cen90)

egen totemp00=total(emp00), by(year imms2cen90)
egen tag=tag(year imms2cen90)
keep if tag==1
drop tag muncenso emp00
save "C:\Scratch\trashbit.dta", replace

**/



clear

use "C:\Work\Mexico\Trade Production and Protection\Update\sic_rev2_3digit_to_immsgrupo.dta"

gen sitc3=substr( sitc2commoditycode,4,3)

keep sitc3 newimss_grupo?

reshape long newimss_grupo, i(sitc3) j(mult)
drop if  newimss_grupo==.
rename newimss_grupo grupo

sort grupo 
merge grupo using "C:\Work\Mexico\IMSS_Hcode_David_imss2cen90.dta", _merge(_mergehcode) nokeep keep(imms2cen90 hcode_name imss_name)

format imss_name hcode_name  %-60s


egen reps=count(grupo), by(sitc3)

gen id=_n

expand 17

egen year=seq(),by(id)
replace year=year+1983

merge m:1 sitc3 year using "C:\Work\Mexico\Trade Production and Protection\Update\Feenstra_Mex_trade.dta", generate(merge1)
*this is mexican trade from Feentras website

*divinding by number of occurance of sitc
replace valuesitc=valuesitc/reps



egen count=count(valuesitc), by(id)
mvencode valuesitc if count>0 & count<=17, mv(0)

egen exportvalue=total(valuesitc) , by(year year imms2cen90)

egen tagimss=tag(year imms2cen90)

keep if tagimss==1
drop if imms2cen90==.

sort imms2cen90 year
keep exportvalue imms2cen90 year imms2cen90 hcode_name imss_name



gen US_cpi_annual_average=.
*from ftp://ftp.bls.gov/pub/special.requests/cpi/cpiai.txt


replace US_cpi_annual_average=103.9 if year==1984
replace US_cpi_annual_average=107.6 if year==1985	
replace US_cpi_annual_average=109.6 if year==1986
replace US_cpi_annual_average=113.6 if year==1987
replace US_cpi_annual_average=118.3 if year==1988
replace US_cpi_annual_average=124 if year==1989
replace US_cpi_annual_average=130.7 if year==1990	
replace US_cpi_annual_average=136.2 if year==1991
replace US_cpi_annual_average=140.3 if year==1992
replace US_cpi_annual_average=144.5 if year==1993
replace US_cpi_annual_average=148.2 if year==1994
replace US_cpi_annual_average=152.4 if year==1995	
replace US_cpi_annual_average=156.9 if year==1996
replace US_cpi_annual_average=160.5 if year==1997
replace US_cpi_annual_average=163 if year==1998
replace US_cpi_annual_average=166.6 if year==1999
replace US_cpi_annual_average=172.2 if year==2000

gen US_cpi_1985=US_cpi_annual_average/107.6
gen rexport=exportvalue/US_cpi_1985


merge 1:1 imms2cen90 year using "C:\Scratch\trashbit.dta" , generate(merge2)

gen rexport_pw=rexport/totemp00
mvencode rexport_pw rexport if year>1984, mv(0) override
mvencode rexport if year>=1984, mv(0) override



xtset imms2cen90 year
gen deltarexportpct=(rexport-l.rexport)/(l.rexport)
gen deltarexport_dw=(rexport-l.rexport)/(l.totemp00)

gen deltarexport_pw=rexport_pw-l.rexport_pw
gen deltarexportpct_pw=(rexport_pw-l.rexport_pw)/(l.rexport_pw)

gen delta13rexport_pw=rexport_pw-l13.rexport_pw if year==1999
gen delta13rexport_dw=(rexport_pw-l13.rexport_pw)/(l13.totemp00)
gen delta13rexportpct_pw=(rexport_pw-l13.rexport_pw)/(l13.rexport_pw) if year==1999


gen delta10rexport_pw=rexport_pw-l10.rexport_pw if year==1999
gen delta10rexport_dw=(rexport_pw-l10.rexport_pw)/(l10.totemp00) if year==1999
gen delta10rexportpct_pw=(rexport_pw-l10.rexport_pw)/(l10.rexport_pw) if year==1999



foreach var of varlist  delta??rexport* {
egen X`var'=max(`var'), by(imms2cen90)
drop `var'
rename X`var' `var'
}


mvencode *pct* , mv(0) override 




save "C:\Work\Mexico\Trade Production and Protection\Update\Feenstra__by_imsss_v2", replace

drop rexport

*now replace 337 and 210 by the largest export groups since these guys are off the hizzle (oil!)
*********

foreach var of varlist  rexport_pw delta??rexport_pw  deltarexport_dw delta??rexport_dw {
winsor(`var'), generate(win`var') p(.05) 

gen temp`var'=`var'
replace `var'=. if imms2cen90==337 | imms2cen90==210
egen X1`var'=min(`var'), by(year)
egen X2`var'=max(`var'), by(year)
replace `var'=X1`var' if (imms2cen90==337 | imms2cen90==210) & temp`var'<X1`var'
replace `var'=X2`var' if (imms2cen90==337 | imms2cen90==210) & temp`var'>X2`var'
drop X1`var' X2`var' temp`var'
}

foreach var of varlist rexport* deltarexport* {
egen `var'mean=mean(`var'), by(imms2cen90)
}



ds *rexport*

local lister "`r(varlist)'"

renvars `lister', postfix(_)


 

foreach var of varlist rexport* delta* {
xtile quart =  `var' , n(4)
gen fq4`var'=(quart==4) if quart!=.
drop quart
xtile quart =  `var' if `var'!=0, n(4)
gen fqm4`var'=(quart==4) if `var'!=.
gen fqm2`var'=(quart>=3) if `var'!=.
drop quart
}






d *rexport*, f
pause on
pause here 

keep *rexport* imms2cen90 year




ds *rexport*
reshape wide  `r(varlist)' , i(year) j(imms2cen90)

renpfix windelta fwindelta
renpfix delta fdelta
renpfix rexport frexport
renpfix winrexport fwinrexport

save "C:\Work\Mexico\Trade Production and Protection\Update\Wide_Feenstra_by_imsss_v2", replace


*calculate per workler by merging in the number of workers...













