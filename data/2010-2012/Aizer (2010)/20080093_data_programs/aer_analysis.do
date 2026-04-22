
/* final analysis file*/

cap log close
log using aer_analysis.log,replace


use ~/dvupdate/dataall03_aer.dta
cap drop _merge
sort fips year race
merge fips year race using ~/census/bartik03_aer.dta
tab _merge

gen lfemwage=ln(femwage_hs)
gen lmalewage=ln(malewage_hs)
label var lfemwage "Ln (female wage)"
label var lmalewage "Ln (male wage)"

gen ldifw_hs=ln(difw_hs)
label var ldifw_hs "Ln(male-female wage)"

do oct9globals.do

label var lfass "Ln(female assaults)"
summ fnainj fmv
gen lfnainj2=ln(fnainj-fmv)
label var lfnainj2 "Ln(female non assault injuries - excludes MV)"

summ nonint nonint_r
replace nonint_r=nonint*100000/(fempop+malepop)
label var nonint_r "Non intimate homicides per 100,000"
summ nonint nonint_r

gen iph=(fdv+mdv)*100000/(fempop+malepop)

/* means*/

table year [w=$w] $if & year==1990 | year==2003, c (mean fass_r mean mass_r mean marr_r mean fmv_r mean drug_r)
table year [w=$w] $if & year==1990 | year==2003, c (mean fass_r mean iph mean nonint_r)

gen yr2003=year==2003
xi: areg fass_r yr2003 if (year==1990 | year==2003) [w=$w], a (fips)
xi: areg fass_r fnainj_r yr2003 if (year==1990 | year==2003) [w=$w], a (fips)


/* table 2 */

drop if lfass==. | laglfass==.

global wage "ratiow_hs"
global table "table2.out"

global other "lfempop"
xi: areg lfass $wage  black white hisp $controls $other [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table,replace $o

global other "lmass lfnainj lfempop"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table,append $o

global other "laglfass lmass lfnainj lfempop"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table,append $o

global other "lagldrug ltotpop"
xi: areg ldrug $wage $race $other $controls [w=$w] $if & year>=1992, a ($fe) cluster ($cl)
outreg $wage $race $other using $table,append $o

global other "laglmass lmalepop lmnainj lfass"
xi: areg lmass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage $race $other using $table,append $o


/* linear difference in wages*/

global wage "difw_hs"
global table "table2b.out"

global other "lfempop"
xi: areg lfass $wage  black white hisp $controls $other [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table,replace $o

global other "lmass lfnainj lfempop"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table,append $o

global other "laglfass lmass lfnainj lfempop"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table,append $o

global other "lagldrug ltotpop"
xi: areg ldrug $wage $race $other $controls [w=$w] $if & year>=1992, a ($fe) cluster ($cl)
outreg $wage $race $other using $table,append $o

global other "laglmass lmalepop lmnainj lfass"
xi: areg lmass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage $race $other using $table,append $o



/* table 4 separate wages*/

global wage "$sep"
global table "table4"

global other "laglfass lfempop lmalepop"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
test lfemwage=-lmalewage

global other "laglfass lmass"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table.out,replace $o
test lfemwage=-lmalewage



/* table 3 add  full set of controls, different ouctomes*/

global wage "ratiow_hs"

gen lclinic=ln(num)
label var lclinic "Ln(primary care clinics)"

global other "laglfass lmass lfnainj incar_r limmig lfemstudent lmalestudent lfempop lclinic"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage $race $other using table3.out,replace $o


/* see if removing lagged dependent variables matters*/

global other "lmass lfnainj incar_r limmig lfemstudent lmalestudent lfempop lclinic"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)


/* see if rates, not natural logs, for controls matters*/

cap drop lagfass_r
sort fips race year
by fips race: gen lagfass_r=fass_r[_n-1]
by fips race: gen lagfass_inj=fass_inj[_n-1]
label var lagfass_r "Lag dependent variable"
label var lagfass_inj "Lag dependent variable"

cap drop immig_r
gen immig_r=immigration*10000/(fempop +malepop)
cap drop femstud_r
gen femstud_r=femstudent*10000/fempop
cap drop malestud_r
gen malestud_r=malestudent*10000/malepop
gen clinic_r=num*10000/fempop
label var clinic_r "clinics per 10000 females"
label var immig_r "immigrants per 10000 individuals"
label var malestud_r "Male students per 10000 males"
label var femstud_r "Female students per 10000 females"
replace lnonint=0
label var nonint_r "Non intimate homicides per 10000"

global other "laglfass fnainj_r mass_r incar_r immig_r femstud_r malestud_r clinic_r nonint_r"
xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)


replace lnonint=ln(nonint)


/* iv for wage ratio using wage growth*/

cap drop _merge
sort fips year race
merge fips year race using ~/census/bartik03_aeriv.dta
tab _merge
keep if _merge==3
drop _merge

global other "laglfass lfnainj lmass lfempop lmalepop"

table year [w=fempop] if fempop>=10000, c (mean ratiowcty mean $wage mean ratioemp mean lratioemp)
global w "fempop"

gen lfememp=ln(fememp_hs)
gen lmaleemp=ln(maleemp_hs)

xi: ivreg lfass (ratiowcty=lfememp lmaleemp) $race $other $controls i.fips [w=$w] $if, first cluster ($cl)
outreg ratiowcty using $table.out,append $o


/* industry wages table 4*/

clear
do aerind_oct15.do


/* add weekend column to table 2*/

clear
do weekend.do


