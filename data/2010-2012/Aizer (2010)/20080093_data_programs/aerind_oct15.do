
clear
use dataall03_aer.dta
*log using aerind_oct15.log,replace
cap drop _merge
sort fips race year
merge fips race year using bartik03_industry.dta
tab _merge

gen lfemwage=ln(femwageind)
gen lmalewage=ln(malewageind)
label var lfemwage "Ln (female wage)"
label var lmalewage "Ln (male wage)"

cap drop ratiow_hs difw_hs
gen ratiow_hs=femwageind/malewageind
label var ratiow_hs "Female/male wage - industry"
gen difw_hs=malewageind-femwageind
label var difw_hs "Male-female wage"

do oct9globals.do

drop if lfass==. | laglfass==.

/* means*/

table year [w=$w] $if, c (mean fass_r mean mass_r mean marr_r mean fmv_r)
table year [w=$w] $if, c (mean fassault mean massault mean marr mean fmv)

table year [w=$w] $if, c (mean ratiow_hs mean ratiow_ind mean difw_hs)
summ ratiow_hs [w=$w], detail
table year [w=$w] if fempop>=10000, c (mean ratiow_hs mean ratiow_ind mean difw_hs)

label var lfass "Ln(female assaults)"


global wage "ratiow_hs"

global other "laglfass lmass lfnainj lfempop"

xi: areg lfass $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table.out,append $o

global other "laglmarr lmalepop lmass"
xi: areg lmarr $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
*outreg $wage using $table.out,append $o

global other "lagldrug ltotpop"
xi: areg ldrug $wage $race $other $controls [w=$w] $if, a ($fe) cluster ($cl)
outreg $wage using $table.out,append $o

