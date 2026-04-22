clear
set more off 

capture program drop makestars
program define makestars, rclass
	syntax , Pointest(real) PVal(real) [bdec(integer 3)]
	**** Formats the coefficient with stars
	****

	local fullfloat = `bdec' + 1
	
	local outstr = string(`pointest',"%`fullfloat'.`bdec'f")
	
	if `pval' <= 0.01 {
		local outstr = "`outstr'" + "***"
	}
	else if `pval' <= 0.05 {
		local outstr = "`outstr'" + "**"
	}
	else if `pval' <= 0.1 {
		local outstr = "`outstr'" + "*"
	}	
		
	return local coeff = "`outstr'"
		
end

use table1, clear

***---Create table structure

g rowtitle = ""
for num 1/10: g outcolX = ""
g indexnum = _n


*Political characteristics
replace rowtitle = "Mun. taxes per capita (2005)" if indexnum == 6
replace rowtitle = "Turnout" if indexnum == 7
replace rowtitle = "PAN incumbent" if indexnum == 8
replace rowtitle = "PRD incumbent" if indexnum == 9
replace rowtitle = "\% alternations (1976-2006)" if indexnum == 10
replace rowtitle = "PRI never lost  (1976-2006)" if indexnum == 11


*Demographic characteristics
replace rowtitle = "Population (2005)" if indexnum == 12
replace rowtitle = "Population density (2005)" if indexnum == 13
replace rowtitle = "Migrants per capita (2005)" if indexnum == 14


*Economic characteristics
replace rowtitle = "Income per capita (2005)" if indexnum == 15
replace rowtitle = "Malnutrition (2005)" if indexnum == 16
replace rowtitle = "Mean years schooling (2005)" if indexnum == 17
replace rowtitle = "Infant mortality (2005)" if indexnum == 18
replace rowtitle = "HH w/o access to sewage (2005)" if indexnum == 19
replace rowtitle = "HH w/o access to water (2005)" if indexnum == 20
replace rowtitle = "Marginality index (2005)" if indexnum == 21


*Road network characteristics
replace rowtitle = "Detour length (km)" if indexnum == 22
replace rowtitle = "Road density ($km$/$km^2$)" if indexnum == 23
replace rowtitle = "Distance U.S. (km)" if indexnum == 24


*Geographic characteristics
replace rowtitle = "Elevation (m)" if indexnum == 25
replace rowtitle = "Slope (degrees)" if indexnum == 26
replace rowtitle = "Surface area ($km^2$)" if indexnum == 27
replace rowtitle = "Average min. temperature, C" if indexnum == 28
replace rowtitle = "Average max. temperature, C" if indexnum == 29
replace rowtitle = "Average precipitation, cm" if indexnum ==30

replace rowtitle = "\textbf{Observations}" if indexnum == 31


local i=5

foreach X in taxpc turnout lPAN lPRD alter priNlose pop popdens migpc ypc malnut ed infantMort noDrainage noWater marginal detour roaddens distUS elev  slope sarea Tmin Tmax precip {
 
	local i=`i'+1
	di "`X'"

	*Mean PAN win
	local colnum = 1
	summ `X' if (PANwin==1 & abs(spread)<.05)
	replace outcol`colnum' = string(r(mean),"%4.2f") if indexnum == `i'

	*Mean PAN loss
	local colnum = 2
	summ `X' if (PANwin==0 & abs(spread)<.05)
	replace outcol`colnum' = string(r(mean),"%4.2f") if indexnum == `i'

	*t stat on the difference
	local colnum = 3
	reg `X' PANwin if abs(spread)<.05, robust
	local tval = (_b[PANwin]/_se[PANwin])	
	di `tval'
	local pval = 2*ttail(e(df_r),abs(`tval'))
	di `pval'
	makestars, pointest(`tval') pval(`pval') bdec(2)
	di "`r(coeff)'"
	capture	replace outcol`colnum' = "'(" + string(`r(coeff)',"%4.2f") + ")" if indexnum == `i'		
	if _rc!=0 {
		replace outcol`colnum' = "'(" +r(coeff)+ ")" if indexnum == `i'
	}
	
	
	*Local linear regression
	reg `X' PANwin spread spreadPW spread2 spreadPW2 if abs(spread)<.05, robust
	local colnum = 5
	local tval = (_b[PANwin]/_se[PANwin])	
	local pval = 2*ttail(e(df_r),abs(`tval'))
	replace outcol`colnum' = "'(" + string(`tval',"%4.2f") + ")" if indexnum == `i'	
	local pe = _b[PANwin]
	local pval = `pval'
	makestars,pointest(`pe') pval(`pval') bdec(2)
	local colnum = 4
	replace outcol`colnum' = r(coeff) if indexnum == `i'
}

* Get observation counts

local colnum = 1
summ taxpc if (PANwin==1 & abs(spread)<.05)
replace outcol`colnum' = string(r(N),"%4.0f") if indexnum == 31
local colnum = 2
summ taxpc if (PANwin==0 & abs(spread)<.05)
replace outcol`colnum' = string(r(N),"%4.0f") if indexnum == 31 
local colnum = 4
reg Tmax PANwin spread spreadPW if abs(spread)<.05, robust
replace outcol`colnum' = string(e(N),"%4.0f") if indexnum == 31 

keep id_m rowtitle outcol* indexnum

********************************
********************************
***--average in bordering muns
********************************
********************************

merge 1:1 id_m using table1_neighbor

sort indexnum

local i=5

foreach X in taxpc turnout lPAN lPRD alter priNlose pop popdens migpc ypc malnut ed infantMort noDrainage noWater marginal detour roaddens distUS elev  slope sarea Tmin Tmax precip {
	local i=`i'+1
	di "`X'"
	
	
	*Local linear regression
	reg `X' PANwin spread spreadPW spread2 spreadPW2 if abs(spread)<.05, robust
	local colnum = 7
	local tval = (_b[PANwin]/_se[PANwin])	
	local pval = 2*ttail(e(df_r),abs(`tval'))
	replace outcol`colnum' = "'(" + string(`tval',"%4.2f") + ")" if indexnum == `i'	
	local pe = _b[PANwin]
	local pval = `pval'
	makestars,pointest(`pe') pval(`pval') bdec(2)
	local colnum = 6
	replace outcol`colnum' = r(coeff) if indexnum == `i'

}
	
local colnum = 6
reg Tmax PANwin spread spreadPW spread2 spreadPW2 if abs(spread)<.05, robust
replace outcol`colnum' = string(e(N),"%4.0f") if indexnum == 31 	

keep if (indexnum>=5 & indexnum<=31)
outsheet rowtitle outcol1 outcol2 outcol3 outcol4 outcol5 outcol6 outcol7 using table1.out, replace noquote 
	

	