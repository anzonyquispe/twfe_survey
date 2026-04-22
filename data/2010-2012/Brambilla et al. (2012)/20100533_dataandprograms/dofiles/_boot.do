* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

* This file is a subrutine for bootstrap replications. It does not run on its own.
* It is used in the preparation of Tables 5 to 12.

* -- Seed
local s=1

* -- Run regression to get coefficients and number of observations
use maindata, clear
global regression = "xi: xtivreg $dependent ($var1 = $instruments) $var2 $var3, fe i(firmid)"
$regression
mat define coef=e(b)
local Nobs=e(N)
local Ngobs=e(N_g)

* -- Define matrix A to display final results
* We keep coefficients on main variables only (i.e. drop year effects and their interactions)
global var="$var1"+" "+"$var2"
local nvar=1
foreach h of varlist $var {
	local nvar=`nvar'+1
	}
local nvar=`nvar'-1
matrix define coef=coef[1,1..`nvar']

* -- Run bootstrap replications
* Save replication results in matrix B where #cols=#main variables and #rows=#replications
matrix define sdev=coef
set seed `s'
forvalues i=1(1)$r {
	* First draw random sample of firm names
	use tempg, clear
	bsample
	sort firmid
	* Then get all years of data for the selected firms
	merge firmid using maindata
	keep if _merge==3
	drop _merge
	* Run regression and store results in matrix B
	qui $regression
	matrix define B=e(b)
	matrix sdev=sdev \ B[1,1..`nvar']
	if `i'==1 {
	  matrix define sdev=sdev[2,1..`nvar']
	  }
	}

* -- Compute standard errors with interquantile range
drop _all
svmat sdev
collapse (iqr) _all
mkmat _all, matrix(iqr)
matrix sdiqr = iqr/1.34
matrix colnames sdiqr = $var

* -- Put in convenient format for display
matrix A = coef \ sdiqr
matrix B = A'
matrix colnames B = Bcoef Bsdiqr
drop _all
svmat B, names(col)
gen str20 variable=""
local count=1
foreach p of global var1 {
	replace variable = "`p'" in `count'
	local count=`count'+1
	}
foreach p of global var2 {
	replace variable = "`p'" in `count'
	local count=`count'+1
	}
reshape long B, i(variable) j(stat) string
format B %9.3f
rename B value

* -- Add number of observations
sum value
local a=2*`nvar'+1
local b=`a'+1
set obs `b'
replace variable="z_Observations" in `a'
replace value=`Nobs' in `a'
replace variable="z_Firms" in `b'
replace value=`Ngobs' in `b'

* - Generate stars
gen v1=value
replace v1=0 if stat~="coef"
bys variable: egen v2=sum(v1)
gen v3=value
replace v3=0 if stat~="sdiqr"
bys variable: egen v4=sum(v3)
gen v5=abs(v2/v4)
gen stars=0
replace stars=1 if stat=="coef" & (v5>=1.6448536)
replace stars=2 if stat=="coef" & (v5>=1.959964)
replace stars=3 if stat=="coef" & (v5>=2.5758293)
gen str3 stars1=""
replace stars1="*" if stars==1
replace stars1="**" if stars==2
replace stars1="***" if stars==3
gen str20 value1=string(value, "%9.3f")+stars1
gen str20 value2=string(value, "%9.0f")
replace value1=value2 if variable=="z_Observations" | variable=="z_Firms"
replace value1="["+value1+"]" if stat=="sdiqr"
drop value v1-v5 stars stars1 value2

* -- Clean
rename value1 $dependent$regnumber
compress
sort variable stat

* -- Save
if $regnumber==1 {
	save chart, replace
	}
if $regnumber>1 {
	save tempchart, replace
	use chart, clear
	merge variable stat using tempchart
	drop _merge
	sort variable stat
	save chart, replace
	}
global regnumber=$regnumber+1
capture erase tempchart.dta

* -- Clean
replace variable="" if stat=="sdiqr"
drop stat
