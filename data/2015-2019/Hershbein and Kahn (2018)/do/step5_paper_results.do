
**make confidence intervals 95%
local ci = 1.96
*local ci = 1.645
local ci_label = "95%"
*local ci_label = "90%"

*******************************************************************************
**Table 1: Summary Statistics
********************************************************************************
*{{{
use "$data_output/BG_hasfirm_msa_year", clear

gen hasskill = 1- share_Mskills
gen temp = hasskill if year==2007
bysort msa: egen mtemp = mean(temp)
gen chhasskill = hasskill - mtemp
assert chhasskill!=.
drop temp mtemp
mata: sumstats = J(26,3,.)
local row = 1
foreach var in ed share12 share16 ed_more yed exp exp_low share3_5 exp_more yexp hasskill cog comp_all {
	sum `var' [aw=weight] if year==2007
	local mean1 = r(mean)
	local sd1 = r(sd)
	sum `var' [aw=weight] if year>2007
	local mean2 = r(mean)
	local sd2 = r(sd)
	reg ch`var' [aw=weight] if year>2007
	local diff = _b[_cons]
	local se = _se[_cons]
	mata: sumstats[`row',.] = `mean1', `mean2', `diff'
	local row = `row' + 1
	mata: sumstats[`row',.] = `sd1', `sd2', `se'
	local row = `row' + 1
}
mata: sumstats

sum M_ACS if year!=2007 [aw=weight]



****counts of postings/obs
use "$data_output/BG_hasfirm_msa_year", clear
egen helper = group(msa)
display "number of unique MSAs"
sum helper
display "posts per MSA-year"
sum npostings
use "$data_output/BG_hasfirm_soc_msa_year", clear
egen helper = group(soc)
display "number of unique SOCs"
sum helper
display "posts per occ-MSA-year"
sum npostings
use "$data_output/BG_hasfirm_employer_msa_year", clear
egen helper = group(emp_nospace)
display "number of unique firms"
sum helper
display "posts per firm-MSA-year"
sum npostings

*}}}

*******************************************************************************
**1. Figure 1: Graph of labor market shocks at MSA-year level
**	a. unemps and employment from LAUS
**	b. CPS epops by ed
** + accompanying Table C1 columns 1-4
********************************************************************************
*{{{
*******************************************************************************
**1a. Unemployment rates and employment
********************************************************************************
*{{{
***unemployment rates
use "$data_output/msa_unemps2000_2015", clear
collapse unemp_msa_nsa statemsa, by(msa year)
ren unemp_msa_nsa unemp
tempfile unemp
save `unemp', replace
***bring in MSA employment
use "$data_output/msa_emps1999_2015", clear
collapse emp_total, by(msa year)
tsset msa year, yearly
gen empch_total = log(emp_total) - log(l.emp_total)
tempfile emp
save `emp', replace

**only merging in BG data to get weight ACS* M_ACS and shock9010
use "$data_output/BG_hasfirm_msa_year", clear

merge 1:1 msa year using `unemp'
assert _merge!=1
*_merge=2 in earlier years and for micro areas
bysort msa: egen innit = mean(_merge)
keep if innit>2
drop _merge innit
egen helper = nvals(msa)
assert helper==381
drop helper

merge 1:1 msa year using `emp'
assert _merge!=1
drop if _merge==2

replace unemp = unemp/100

***project all the msa-level vars onto all obs, including the new years brought in (not in BG)
foreach var of varlist weight ACS* M_ACS shock9010 {
	bysort msa: egen temp = mean(`var')
	replace `var' = temp if `var'==.
	drop temp
}
drop shock90102*
foreach year of numlist 2000/2015 {
	gen shock9010`year' = shock9010*(year==`year')
}	

**get MSA-level change from 2007 for unemp and emp growth
foreach var in unemp empch_total {
	gen temp = `var' if year==2007
	bysort msa: egen mtemp = mean(temp)
	gen ch`var' = `var' - mtemp
	drop temp mtemp
}

assert year>=2000 & year<=2015

capture erase "$tables/COR_fig1.txt"
capture erase "$tables/COR_fig1.xml"

foreach stem in  empch_total  unemp {
	preserve
	***get main effect
	reg ch`stem' shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015  i.year [aw=weight] if year!=2007 ,  cluster(msa) 
	outreg2 shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 using "$tables/COR_fig1", append stats(coef, se) excel  
	matrix Tcoeffs = e(b)
	matrix Tses = e(V)
	mata: coeffs = st_matrix("Tcoeffs")'
	mata: ses = diagonal(st_matrix("Tses"))

	mata: coeffs_full = coeffs[1..15]
	mata: ses_full = ses[1..15]:^.5
		
	clear
	getmata coeffs_full ses_full 
	gen year = 1999 + _n if _n<=7
	replace year = 2000 + _n if _n>=8

	gen ci_plus = coeffs_full + `ci'*ses_full
	gen ci_minus = coeffs_full - `ci'*ses_full
		
	local obs = _N
	local new = `obs' + 1
	set obs `new'
	replace year = 2007 in `new'
	foreach var of varlist coeffs_full ci_plus ci_minus {
		replace `var' = 0 if year==2007
	}
	sort year

	if "`stem'" == "unemp" {
		local title = "Unemployment Rate"
	}
	if "`stem'" == "empch_total" {
		local title = "Employment Growth Rate"
	}

	***full effect
	twoway (line coeffs_full year, lcolor(navy)) (scatter coeffs_full year, mcolor(navy)) (rcap ci_plus ci_minus year, lcolor(navy) lpattern(dash) lwidth(vvthin)) , xtitle("") ytitle("") title("`title'") saving("$graphs/g`stem'", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white)
		
restore
}
*}}}

*******************************************************************************
**1b. Epops from CPS
********************************************************************************
*{{{
use "$data_output/workingCPS", replace
assert year<=2015 & year>=2000


**get MSA change from 2007
foreach var of varlist epop_low epop_high  {
	gen temp = `var' if year==2007
	bysort msa: egen mtemp = mean(temp)
	gen ch`var' = `var' - mtemp
	drop temp mtemp
}

foreach year of numlist 2000/2015 {
	gen shock9010`year' = shock9010*(year==`year')
}

bysort msa: egen Nyear = nvals(year)
gen has16 = (Nyear==16)
tab has16 if chepop_low!=.
tab has16 if chepop_low!=. [aw=weight]


foreach stem of varlist epop_low epop_high {
	preserve
	***get main effect
	reg ch`stem' shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 i.year  [aw=weight] if year!=2007 ,  cluster(msa) 
	outreg2 shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 using "$tables/COR_fig1", append stats(coef, se) excel  
	matrix Tcoeffs = e(b)
	matrix Tses = e(V)
	mata: coeffs = st_matrix("Tcoeffs")'
	mata: ses = diagonal(st_matrix("Tses"))

	mata: coeffs_full = coeffs[1..15]
	mata: ses_full = ses[1..15]:^.5
		
	clear
	getmata coeffs_full ses_full 
	gen year = 1999 + _n if _n<=7
	replace year = 2000 + _n if _n>=8

	gen ci_plus = coeffs_full + `ci'*ses_full
	gen ci_minus = coeffs_full - `ci'*ses_full
		
	local obs = _N
	local new = `obs' + 1
	set obs `new'
	replace year = 2007 in `new'
	foreach var of varlist coeffs_full ci_plus ci_minus {
		replace `var' = 0 if year==2007
	}
	sort year
	if "`stem'" == "epop_low" {
		local title = "Epop HS or Less"
	}
	if "`stem'" == "epop_high" {
		local title = "Epop Some College or More"
	}

	***full effect
	twoway (line coeffs_full year, lcolor(navy)) (scatter coeffs_full year, mcolor(navy)) (rcap ci_plus ci_minus year, lcolor(navy) lpattern(dash) lwidth(vvthin)) , xtitle("") ytitle("") title("`title'") saving("$graphs/g`stem'", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white) ylabel(-.05 -.02 0 .02 .05)
		
restore
}



*}}}

*******************************************************************************
**Combine graphs
********************************************************************************
graph combine "$graphs/gempch_total"  "$graphs/gunemp" "$graphs/gepop_high" "$graphs/gepop_low"  , l1title("Coefficient") b1title("Year") graphregion(color(white)) note("We regress the MSA-level change in local labor market variables from 2007 on an exhaustive set of MSA employment shock-by-year" "interactions, controlling for  year fixed effects (see equation 1). Graph plots the coefficients on Bartik shock*year, as well as `ci_label' CI bars."      "Unemployment and employment growth rates are from the BLS LAUS. Employment-to-population ratios (Epops) are author calculations" "based on the CPS.", size(vsmall))
graph export "$graphs/figure1.pdf", as(pdf) replace
*}}}

****************************************************************************
**FIGURE 2: MSA-level BG analysis
**** + accompanying Table C1 columns 5-8
****************************************************************************
*{{{
use "$data_output/BG_hasfirm_msa_year", clear

capture erase "$tables/COR_fig2.txt"
capture erase "$tables/COR_fig2.xml"

***main graphs
foreach stem in ed exp cog comp_all  {
	preserve
	**base reg	
	reg ch`stem' shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 i.year ACS* M_ACS  [aw=weight] if year!=2007,  cluster(msa)
	outreg2 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 using "$tables/COR_fig2", append stats(coef, se) excel  
	matrix Tcoeffs = e(b)
	matrix Tses = e(V)
	mata: coeffs = st_matrix("Tcoeffs")'
	mata: ses = diagonal(st_matrix("Tses"))
	mata: coeffs = coeffs[1..6]
	mata: ses = ses[1..6]:^.5
	clear
	getmata coeffs ses
	gen year = 2009+_n
	gen ci_plus = coeffs + `ci'*ses
	gen ci_minus = coeffs - `ci'*ses
	
	local obs = _N
	local new = `obs' + 1
	set obs `new'
	replace year = 2007 in `new'
	replace coeff = 0 if year==2007
	sort year
 	
	**get graph title for each dep var
	if "`stem'" =="ed" {
		local title = "Education Requirement"
	}
	if "`stem'" =="exp" {
		local title = "Experience Requirement"
	}
	if "`stem'" =="cog" {
		local title = "Cognitive Skill Requirement"
	}
	if "`stem'" =="comp_all" {
		local title = "Computer Skill Requirement"
	}

	twoway (scatter coeffs year, mcolor(navy)) (line coeffs year, lcolor(navy)) (rcap ci_minus ci_plus year, lcolor(navy) lpattern(dash) lwidth(vvthin)), xtitle("") ytitle("") title("`title'") saving("$graphs/g`stem'", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white) xlabel(2007 2009 2011 2013 2015) 
	restore
	
	local counter = `counter' + 1
}
***main results graph
graph combine "$graphs/ged.gph" "$graphs/gexp.gph" "$graphs/gcog.gph"  "$graphs/gcomp_all.gph", l1title(Coefficient) b1title(Year)  note("We regress the MSA-level change in BG skill requirements from 2007 on an exhaustive set of MSA employment shock-by-year interactions," "controlling for year fixed effects and MSA characteristics (see equation 1). Graph plots the coefficients on Bartik shock*year and `ci_label' CIs.", size(vsmall)) graphregion(color(white))  
graph export "$graphs/figure2.pdf", as(pdf) replace
*}}}

********************************************************************************
**MSA examples used in text around fig 2 discussion
******************************************************************************
*{{{
use "$data_output/BG_hasfirm_msa_year", clear
**keep only big MSAs
keep if lf2006>200000

keep shock9010 ed ched exp chexp cog chcog comp_all chcomp_all  msa year
reshape wide ed ched exp chexp cog chcog comp_all chcomp_all , i(msa) j(year)

gen msaname = ""
replace msaname = 	"Akron, OH"	 if msa==	10420
replace msaname = 	"Albany-Schenectady-Troy, NY"	 if msa==	10580
replace msaname = 	"Albuquerque, NM"	 if msa==	10740
replace msaname = 	"Alexandria, LA"	 if msa==	10780
replace msaname = 	"Allentown-Bethlehem-Easton, PA-NJ"	 if msa==	10900
replace msaname = 	"Altoona, PA"	 if msa==	11020
replace msaname = 	"Amarillo, TX"	 if msa==	11100
replace msaname = 	"Anchorage, AK"	 if msa==	11260
replace msaname = 	"Ann Arbor, MI"	 if msa==	11460
replace msaname = 	"Anniston-Oxford-Jacksonville, AL"	 if msa==	11500
replace msaname = 	"Asheville, NC"	 if msa==	11700
replace msaname = 	"Athens-Clarke County, GA"	 if msa==	12020
replace msaname = 	"Atlanta-Sandy Springs-Roswell, GA"	 if msa==	12060
replace msaname = 	"Atlantic City-Hammonton, NJ"	 if msa==	12100
replace msaname = 	"Auburn-Opelika, AL"	 if msa==	12220
replace msaname = 	"Augusta-Richmond County, GA-SC"	 if msa==	12260
replace msaname = 	"Austin-Round Rock, TX"	 if msa==	12420
replace msaname = 	"Bakersfield, CA"	 if msa==	12540
replace msaname = 	"Baltimore-Columbia-Towson, MD"	 if msa==	12580
replace msaname = 	"Bangor, ME"	 if msa==	12620
replace msaname = 	"Barnstable Town, MA"	 if msa==	12700
replace msaname = 	"Baton Rouge, LA"	 if msa==	12940
replace msaname = 	"Battle Creek, MI"	 if msa==	12980
replace msaname = 	"Beaumont-Port Arthur, TX"	 if msa==	13140
replace msaname = 	"Bellingham, WA"	 if msa==	13380
replace msaname = 	"Bend-Redmond, OR"	 if msa==	13460
replace msaname = 	"Billings, MT"	 if msa==	13740
replace msaname = 	"Binghamton, NY"	 if msa==	13780
replace msaname = 	"Birmingham-Hoover, AL"	 if msa==	13820
replace msaname = 	"Bismarck, ND"	 if msa==	13900
replace msaname = 	"Blacksburg-Christiansburg-Radford, VA"	 if msa==	13980
replace msaname = 	"Bloomington, IL"	 if msa==	14010
replace msaname = 	"Bloomington, IN"	 if msa==	14020
replace msaname = 	"Boise City, ID"	 if msa==	14260
replace msaname = 	"Boston-Cambridge-Newton, MA-NH"	 if msa==	14460
replace msaname = 	"Bremerton-Silverdale, WA"	 if msa==	14740
replace msaname = 	"Bridgeport-Stamford-Norwalk, CT"	 if msa==	14860
replace msaname = 	"Brownsville-Harlingen, TX"	 if msa==	15180
replace msaname = 	"Buffalo-Cheektowaga-Niagara Falls, NY"	 if msa==	15380
replace msaname = 	"Burlington, NC"	 if msa==	15500
replace msaname = 	"Burlington-South Burlington, VT"	 if msa==	15540
replace msaname = 	"Canton-Massillon, OH"	 if msa==	15940
replace msaname = 	"Cape Coral-Fort Myers, FL"	 if msa==	15980
replace msaname = 	"Champaign-Urbana, IL"	 if msa==	16580
replace msaname = 	"Charleston, WV"	 if msa==	16620
replace msaname = 	"Charleston-North Charleston, SC"	 if msa==	16700
replace msaname = 	"Charlotte-Concord-Gastonia, NC-SC"	 if msa==	16740
replace msaname = 	"Charlottesville, VA"	 if msa==	16820
replace msaname = 	"Chattanooga, TN-GA"	 if msa==	16860
replace msaname = 	"Chicago-Naperville-Elgin, IL-IN-WI"	 if msa==	16980
replace msaname = 	"Chico, CA"	 if msa==	17020
replace msaname = 	"Cincinnati, OH-KY-IN"	 if msa==	17140
replace msaname = 	"Clarksville, TN-KY"	 if msa==	17300
replace msaname = 	"Cleveland-Elyria, OH"	 if msa==	17460
replace msaname = 	"Coeur dAlene, ID"	 if msa==	17660
replace msaname = 	"College Station-Bryan, TX"	 if msa==	17780
replace msaname = 	"Colorado Springs, CO"	 if msa==	17820
replace msaname = 	"Columbia, MO"	 if msa==	17860
replace msaname = 	"Columbia, SC"	 if msa==	17900
replace msaname = 	"Columbus, OH"	 if msa==	18140
replace msaname = 	"Corpus Christi, TX"	 if msa==	18580
replace msaname = 	"Dallas-Fort Worth-Arlington, TX"	 if msa==	19100
replace msaname = 	"Daphne-Fairhope-Foley, AL"	 if msa==	19300
replace msaname = 	"Davenport-Moline-Rock Island, IA-IL"	 if msa==	19340
replace msaname = 	"Dayton, OH"	 if msa==	19380
replace msaname = 	"Decatur, AL"	 if msa==	19460
replace msaname = 	"Decatur, IL"	 if msa==	19500
replace msaname = 	"Deltona-Daytona Beach-Ormond Beach, FL"	 if msa==	19660
replace msaname = 	"Denver-Aurora-Lakewood, CO"	 if msa==	19740
replace msaname = 	"Des Moines-West Des Moines, IA"	 if msa==	19780
replace msaname = 	"Detroit-Warren-Dearborn, MI"	 if msa==	19820
replace msaname = 	"Dover, DE"	 if msa==	20100
replace msaname = 	"Durham-Chapel Hill, NC"	 if msa==	20500
replace msaname = 	"East Stroudsburg, PA"	 if msa==	20700
replace msaname = 	"Eau Claire, WI"	 if msa==	20740
replace msaname = 	"El Centro, CA"	 if msa==	20940
replace msaname = 	"Elizabethtown-Fort Knox, KY"	 if msa==	21060
replace msaname = 	"Elkhart-Goshen, IN"	 if msa==	21140
replace msaname = 	"El Paso, TX"	 if msa==	21340
replace msaname = 	"Erie, PA"	 if msa==	21500
replace msaname = 	"Eugene, OR"	 if msa==	21660
replace msaname = 	"Evansville, IN-KY"	 if msa==	21780
replace msaname = 	"Farmington, NM"	 if msa==	22140
replace msaname = 	"Fayetteville, NC"	 if msa==	22180
replace msaname = 	"Fayetteville-Springdale-Rogers, AR-MO"	 if msa==	22220
replace msaname = 	"Flagstaff, AZ"	 if msa==	22380
replace msaname = 	"Flint, MI"	 if msa==	22420
replace msaname = 	"Florence, SC"	 if msa==	22500
replace msaname = 	"Florence-Muscle Shoals, AL"	 if msa==	22520
replace msaname = 	"Fort Collins, CO"	 if msa==	22660
replace msaname = 	"Fort Wayne, IN"	 if msa==	23060
replace msaname = 	"Fresno, CA"	 if msa==	23420
replace msaname = 	"Gadsden, AL"	 if msa==	23460
replace msaname = 	"Gainesville, FL"	 if msa==	23540
replace msaname = 	"Gainesville, GA"	 if msa==	23580
replace msaname = 	"Glens Falls, NY"	 if msa==	24020
replace msaname = 	"Goldsboro, NC"	 if msa==	24140
replace msaname = 	"Grand Junction, CO"	 if msa==	24300
replace msaname = 	"Grand Rapids-Wyoming, MI"	 if msa==	24340
replace msaname = 	"Greeley, CO"	 if msa==	24540
replace msaname = 	"Greensboro-High Point, NC"	 if msa==	24660
replace msaname = 	"Greenville, NC"	 if msa==	24780
replace msaname = 	"Greenville-Anderson-Mauldin, SC"	 if msa==	24860
replace msaname = 	"Gulfport-Biloxi-Pascagoula, MS"	 if msa==	25060
replace msaname = 	"Hammond, LA"	 if msa==	25220
replace msaname = 	"Hanford-Corcoran, CA"	 if msa==	25260
replace msaname = 	"Harrisburg-Carlisle, PA"	 if msa==	25420
replace msaname = 	"Harrisonburg, VA"	 if msa==	25500
replace msaname = 	"Hartford-West Hartford-East Hartford, CT"	 if msa==	25540
replace msaname = 	"Hattiesburg, MS"	 if msa==	25620
replace msaname = 	"Hickory-Lenoir-Morganton, NC"	 if msa==	25860
replace msaname = 	"Hilton Head Island-Bluffton-Beaufort, SC"	 if msa==	25940
replace msaname = 	"Homosassa Springs, FL"	 if msa==	26140
replace msaname = 	"Houma-Thibodaux, LA"	 if msa==	26380
replace msaname = 	"Houston-The Woodlands-Sugar Land, TX"	 if msa==	26420
replace msaname = 	"Huntsville, AL"	 if msa==	26620
replace msaname = 	"Indianapolis-Carmel-Anderson, IN"	 if msa==	26900
replace msaname = 	"Iowa City, IA"	 if msa==	26980
replace msaname = 	"Ithaca, NY"	 if msa==	27060
replace msaname = 	"Jackson, MI"	 if msa==	27100
replace msaname = 	"Jackson, MS"	 if msa==	27140
replace msaname = 	"Jackson, TN"	 if msa==	27180
replace msaname = 	"Jacksonville, FL"	 if msa==	27260
replace msaname = 	"Jacksonville, NC"	 if msa==	27340
replace msaname = 	"Janesville-Beloit, WI"	 if msa==	27500
replace msaname = 	"Jefferson City, MO"	 if msa==	27620
replace msaname = 	"Johnstown, PA"	 if msa==	27780
replace msaname = 	"Joplin, MO"	 if msa==	27900
replace msaname = 	"Kalamazoo-Portage, MI"	 if msa==	28020
replace msaname = 	"Kankakee, IL"	 if msa==	28100
replace msaname = 	"Kansas City, MO-KS"	 if msa==	28140
replace msaname = 	"Kennewick-Richland, WA"	 if msa==	28420
replace msaname = 	"Killeen-Temple, TX"	 if msa==	28660
replace msaname = 	"Kingsport-Bristol-Bristol, TN-VA"	 if msa==	28700
replace msaname = 	"Knoxville, TN"	 if msa==	28940
replace msaname = 	"La Crosse-Onalaska, WI-MN"	 if msa==	29100
replace msaname = 	"Lafayette, LA"	 if msa==	29180
replace msaname = 	"Lafayette-West Lafayette, IN"	 if msa==	29200
replace msaname = 	"Lake Charles, LA"	 if msa==	29340
replace msaname = 	"Lake Havasu City-Kingman, AZ"	 if msa==	29420
replace msaname = 	"Lakeland-Winter Haven, FL"	 if msa==	29460
replace msaname = 	"Lancaster, PA"	 if msa==	29540
replace msaname = 	"Lansing-East Lansing, MI"	 if msa==	29620
replace msaname = 	"Laredo, TX"	 if msa==	29700
replace msaname = 	"Las Cruces, NM"	 if msa==	29740
replace msaname = 	"Las Vegas-Henderson-Paradise, NV"	 if msa==	29820
replace msaname = 	"Lawrence, KS"	 if msa==	29940
replace msaname = 	"Lebanon, PA"	 if msa==	30140
replace msaname = 	"Lewiston-Auburn, ME"	 if msa==	30340
replace msaname = 	"Lima, OH"	 if msa==	30620
replace msaname = 	"Lincoln, NE"	 if msa==	30700
replace msaname = 	"Little Rock-North Little Rock-Conway, AR"	 if msa==	30780
replace msaname = 	"Los Angeles-Long Beach-Anaheim, CA"	 if msa==	31080
replace msaname = 	"Louisville/Jefferson County, KY-IN"	 if msa==	31140
replace msaname = 	"Lubbock, TX"	 if msa==	31180
replace msaname = 	"Lynchburg, VA"	 if msa==	31340
replace msaname = 	"Madera, CA"	 if msa==	31460
replace msaname = 	"Manchester-Nashua, NH"	 if msa==	31700
replace msaname = 	"Mansfield, OH"	 if msa==	31900
replace msaname = 	"Mayagüez, PR"	 if msa==	32420
replace msaname = 	"McAllen-Edinburg-Mission, TX"	 if msa==	32580
replace msaname = 	"Medford, OR"	 if msa==	32780
replace msaname = 	"Memphis, TN-MS-AR"	 if msa==	32820
replace msaname = 	"Merced, CA"	 if msa==	32900
replace msaname = 	"Miami-Fort Lauderdale-West Palm Beach, FL"	 if msa==	33100
replace msaname = 	"Michigan City-La Porte, IN"	 if msa==	33140
replace msaname = 	"Midland, TX"	 if msa==	33260
replace msaname = 	"Milwaukee-Waukesha-West Allis, WI"	 if msa==	33340
replace msaname = 	"Minneapolis-St. Paul-Bloomington, MN-WI"	 if msa==	33460
replace msaname = 	"Mobile, AL"	 if msa==	33660
replace msaname = 	"Modesto, CA"	 if msa==	33700
replace msaname = 	"Monroe, LA"	 if msa==	33740
replace msaname = 	"Monroe, MI"	 if msa==	33780
replace msaname = 	"Montgomery, AL"	 if msa==	33860
replace msaname = 	"Morgantown, WV"	 if msa==	34060
replace msaname = 	"Muncie, IN"	 if msa==	34620
replace msaname = 	"Muskegon, MI"	 if msa==	34740
replace msaname = 	"Myrtle Beach-Conway-North Myrtle Beach, SC-NC"	 if msa==	34820
replace msaname = 	"Napa, CA"	 if msa==	34900
replace msaname = 	"Naples-Immokalee-Marco Island, FL"	 if msa==	34940
replace msaname = 	"Nashville-Davidson--Murfreesboro--Franklin, TN"	 if msa==	34980
replace msaname = 	"New Haven-Milford, CT"	 if msa==	35300
replace msaname = 	"New Orleans-Metairie, LA"	 if msa==	35380
replace msaname = 	"New York-Newark-Jersey City, NY-NJ-PA"	 if msa==	35620
replace msaname = 	"Niles-Benton Harbor, MI"	 if msa==	35660
replace msaname = 	"North Port-Sarasota-Bradenton, FL"	 if msa==	35840
replace msaname = 	"Norwich-New London, CT"	 if msa==	35980
replace msaname = 	"Ocala, FL"	 if msa==	36100
replace msaname = 	"Ocean City, NJ"	 if msa==	36140
replace msaname = 	"Odessa, TX"	 if msa==	36220
replace msaname = 	"Ogden-Clearfield, UT"	 if msa==	36260
replace msaname = 	"Oklahoma City, OK"	 if msa==	36420
replace msaname = 	"Olympia-Tumwater, WA"	 if msa==	36500
replace msaname = 	"Omaha-Council Bluffs, NE-IA"	 if msa==	36540
replace msaname = 	"Orlando-Kissimmee-Sanford, FL"	 if msa==	36740
replace msaname = 	"Oshkosh-Neenah, WI"	 if msa==	36780
replace msaname = 	"Owensboro, KY"	 if msa==	36980
replace msaname = 	"Oxnard-Thousand Oaks-Ventura, CA"	 if msa==	37100
replace msaname = 	"Palm Bay-Melbourne-Titusville, FL"	 if msa==	37340
replace msaname = 	"Panama City, FL"	 if msa==	37460
replace msaname = 	"Parkersburg-Vienna, WV"	 if msa==	37620
replace msaname = 	"Pensacola-Ferry Pass-Brent, FL"	 if msa==	37860
replace msaname = 	"Peoria, IL"	 if msa==	37900
replace msaname = 	"Philadelphia-Camden-Wilmington, PA-NJ-DE-MD"	 if msa==	37980
replace msaname = 	"Phoenix-Mesa-Scottsdale, AZ"	 if msa==	38060
replace msaname = 	"Pittsburgh, PA"	 if msa==	38300
replace msaname = 	"Pittsfield, MA"	 if msa==	38340
replace msaname = 	"Ponce, PR"	 if msa==	38660
replace msaname = 	"Portland-South Portland, ME"	 if msa==	38860
replace msaname = 	"Portland-Vancouver-Hillsboro, OR-WA"	 if msa==	38900
replace msaname = 	"Port St. Lucie, FL"	 if msa==	38940
replace msaname = 	"Prescott, AZ"	 if msa==	39140
replace msaname = 	"Providence-Warwick, RI-MA"	 if msa==	39300
replace msaname = 	"Provo-Orem, UT"	 if msa==	39340
replace msaname = 	"Pueblo, CO"	 if msa==	39380
replace msaname = 	"Punta Gorda, FL"	 if msa==	39460
replace msaname = 	"Racine, WI"	 if msa==	39540
replace msaname = 	"Raleigh, NC"	 if msa==	39580
replace msaname = 	"Reading, PA"	 if msa==	39740
replace msaname = 	"Redding, CA"	 if msa==	39820
replace msaname = 	"Reno, NV"	 if msa==	39900
replace msaname = 	"Richmond, VA"	 if msa==	40060
replace msaname = 	"Riverside-San Bernardino-Ontario, CA"	 if msa==	40140
replace msaname = 	"Roanoke, VA"	 if msa==	40220
replace msaname = 	"Rochester, NY"	 if msa==	40380
replace msaname = 	"Rockford, IL"	 if msa==	40420
replace msaname = 	"Rocky Mount, NC"	 if msa==	40580
replace msaname = 	"Sacramento--Roseville--Arden-Arcade, CA"	 if msa==	40900
replace msaname = 	"Saginaw, MI"	 if msa==	40980
replace msaname = 	"St. Cloud, MN"	 if msa==	41060
replace msaname = 	"St. George, UT"	 if msa==	41100
replace msaname = 	"St. Joseph, MO-KS"	 if msa==	41140
replace msaname = 	"St. Louis, MO-IL"	 if msa==	41180
replace msaname = 	"Salinas, CA"	 if msa==	41500
replace msaname = 	"Salisbury, MD-DE"	 if msa==	41540
replace msaname = 	"Salt Lake City, UT"	 if msa==	41620
replace msaname = 	"San Angelo, TX"	 if msa==	41660
replace msaname = 	"San Antonio-New Braunfels, TX"	 if msa==	41700
replace msaname = 	"San Diego-Carlsbad, CA"	 if msa==	41740
replace msaname = 	"San Francisco-Oakland-Hayward, CA"	 if msa==	41860
replace msaname = 	"San Germán, PR"	 if msa==	41900
replace msaname = 	"San Jose-Sunnyvale-Santa Clara, CA"	 if msa==	41940
replace msaname = 	"San Juan-Carolina-Caguas, PR"	 if msa==	41980
replace msaname = 	"San Luis Obispo-Paso Robles-Arroyo Grande, CA"	 if msa==	42020
replace msaname = 	"Santa Cruz-Watsonville, CA"	 if msa==	42100
replace msaname = 	"Santa Fe, NM"	 if msa==	42140
replace msaname = 	"Santa Maria-Santa Barbara, CA"	 if msa==	42200
replace msaname = 	"Santa Rosa, CA"	 if msa==	42220
replace msaname = 	"Scranton--Wilkes-Barre--Hazleton, PA"	 if msa==	42540
replace msaname = 	"Seattle-Tacoma-Bellevue, WA"	 if msa==	42660
replace msaname = 	"Sebastian-Vero Beach, FL"	 if msa==	42680
replace msaname = 	"Sheboygan, WI"	 if msa==	43100
replace msaname = 	"Shreveport-Bossier City, LA"	 if msa==	43340
replace msaname = 	"Spartanburg, SC"	 if msa==	43900
replace msaname = 	"Spokane-Spokane Valley, WA"	 if msa==	44060
replace msaname = 	"Springfield, IL"	 if msa==	44100
replace msaname = 	"Springfield, MA"	 if msa==	44140
replace msaname = 	"Springfield, MO"	 if msa==	44180
replace msaname = 	"Springfield, OH"	 if msa==	44220
replace msaname = 	"State College, PA"	 if msa==	44300
replace msaname = 	"Stockton-Lodi, CA"	 if msa==	44700
replace msaname = 	"Sumter, SC"	 if msa==	44940
replace msaname = 	"Syracuse, NY"	 if msa==	45060
replace msaname = 	"Tallahassee, FL"	 if msa==	45220
replace msaname = 	"Tampa-St. Petersburg-Clearwater, FL"	 if msa==	45300
replace msaname = 	"Terre Haute, IN"	 if msa==	45460
replace msaname = 	"Toledo, OH"	 if msa==	45780
replace msaname = 	"Topeka, KS"	 if msa==	45820
replace msaname = 	"Trenton, NJ"	 if msa==	45940
replace msaname = 	"Tucson, AZ"	 if msa==	46060
replace msaname = 	"Tuscaloosa, AL"	 if msa==	46220
replace msaname = 	"Tyler, TX"	 if msa==	46340
replace msaname = 	"Urban Honolulu, HI"	 if msa==	46520
replace msaname = 	"Utica-Rome, NY"	 if msa==	46540
replace msaname = 	"Valdosta, GA"	 if msa==	46660
replace msaname = 	"Vallejo-Fairfield, CA"	 if msa==	46700
replace msaname = 	"Vineland-Bridgeton, NJ"	 if msa==	47220
replace msaname = 	"Virginia Beach-Norfolk-Newport News, VA-NC"	 if msa==	47260
replace msaname = 	"Visalia-Porterville, CA"	 if msa==	47300
replace msaname = 	"Waco, TX"	 if msa==	47380
replace msaname = 	"Washington-Arlington-Alexandria, DC-VA-MD-WV"	 if msa==	47900
replace msaname = 	"Wausau, WI"	 if msa==	48140
replace msaname = 	"Wenatchee, WA"	 if msa==	48300
replace msaname = 	"Wichita, KS"	 if msa==	48620
replace msaname = 	"Wichita Falls, TX"	 if msa==	48660
replace msaname = 	"Williamsport, PA"	 if msa==	48700
replace msaname = 	"Wilmington, NC"	 if msa==	48900
replace msaname = 	"Winston-Salem, NC"	 if msa==	49180
replace msaname = 	"Worcester, MA-CT"	 if msa==	49340
replace msaname = 	"Yakima, WA"	 if msa==	49420
replace msaname = 	"York-Hanover, PA"	 if msa==	49620
replace msaname = 	"Youngstown-Warren-Boardman, OH-PA"	 if msa==	49660
replace msaname = 	"Yuba City, CA"	 if msa==	49700
replace msaname = 	"Yuma, AZ"	 if msa==	49740
replace msaname = 	"Augusta-Waterville, ME"	 if msa==	70600
replace msaname = 	"Bangor, ME"	 if msa==	70750
replace msaname = 	"Barnstable Town, MA"	 if msa==	70900
replace msaname = 	"Barre, VT"	 if msa==	71050
replace msaname = 	"Bennington, VT"	 if msa==	71350
replace msaname = 	"Berlin, NH-VT"	 if msa==	71500
replace msaname = 	"Berlin, NH-VT"	 if msa==	71500
replace msaname = 	"Boston-Cambridge-Quincy, MA-NH"	 if msa==	71650
replace msaname = 	"Bridgeport-Stamford-Norwalk, CT"	 if msa==	71950
replace msaname = 	"Burlington-South Burlington, VT"	 if msa==	72400
replace msaname = 	"Claremont, NH"	 if msa==	72500
replace msaname = 	"Concord, NH"	 if msa==	72700
replace msaname = 	"Hartford-West Hartford-East Hartford, CT"	 if msa==	73450
replace msaname = 	"Keene, NH"	 if msa==	73750
replace msaname = 	"Laconia, NH"	 if msa==	73900
replace msaname = 	"Lebanon, NH-VT"	 if msa==	74350
replace msaname = 	"Lewiston-Auburn, ME"	 if msa==	74650
replace msaname = 	"Manchester-Nashua, NH"	 if msa==	74950
replace msaname = 	"New Haven-Milford, CT"	 if msa==	75700
replace msaname = 	"Norwich-New London, CT"	 if msa==	76450
replace msaname = 	"Pittsfield, MA"	 if msa==	76600
replace msaname = 	"Portland-South Portland-Biddeford, ME"	 if msa==	76750
replace msaname = 	"Providence-New Bedford-Fall River, RI-MA"	 if msa==	77200
replace msaname = 	"Rockland, ME"	 if msa==	77500
replace msaname = 	"Rutland, VT"	 if msa==	77650
replace msaname = 	"Springfield, MA"	 if msa==	78100
replace msaname = 	"Torrington, CT"	 if msa==	78400
replace msaname = 	"Willimantic, CT"	 if msa==	79300
replace msaname = 	"Worcester, MA"	 if msa==	79600

gsort -shock9010

list msa msaname shock9010 ed2007 ched2010 ched2015, sep(0)

display "Detroit -- 2007"
list ed2007 exp2007 cog2007 comp_all2007 if msa==19820
display "Pittsburgh -- 2007"
list ed2007 exp2007 cog2007 comp_all2007 if msa==38300

display "Detroit -- ch2010"
list ched2010 chexp2010 chcog2010 chcomp_all2010 if msa==19820
display "Pittsburgh -- ch2010"
list ched2010 chexp2010 chcog2010 chcomp_all2010 if msa==38300





*}}}

********************************************************************************
**Table 2: within occ regs
******************************************************************************
*{{{
use "$data_output/BG_hasfirm_soc_msa_year", clear

capture erase "$tables/table2.txt"
capture erase "$tables/table2.xml"

foreach stem in ed exp cog comp_all  {
	reg ch`stem' shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015  i.year ACS* M_ACS   [aw=weight] if year!=2007,  cluster(msa)
	outreg2 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 using "$tables/table2", append stats(coef, se) excel   
}
*}}}


********************************************************************************
**Figure 3: average skill requirement by 2007-2010 change quartile
******************************************************************************
*{{{
use "$data_output/BG_hasfirm_employer_msa_year", clear

collapse ed exp cog comp_all (rawsum) npostings [aw=npostings], by(emp_nospace year)

reshape wide npostings ed exp cog comp_all, i(emp_nospace) j(year)
gen inchangesample = (npostings2007>=5 & npostings2010>=5 & npostings2007!=. & npostings2010!=.)
keep if inchangesample==1
gen ave_post = (npostings2007 + npostings2010)/2
foreach var in ed exp cog comp_all {
	gen ch`var' = `var'2010 - `var'2007
	xtile Q`var' = ch`var' [aw=ave_post], nquantiles(4)
}
	
reshape long npostings ed exp cog comp_all, i(emp_nospace) j(year)
keep if npostings!=0 & npostings!=.

local counter = 1
foreach var in ed exp cog comp_all {
	preserve
	collapse `var' [aw=ave_post], by(Q`var' year)
	
	if `counter'==1 {
		local title = "Education Requirement"
	}
	if `counter'==2 {
		local title = "Experience Requirement"
	}
	if `counter'==3 {
		local title = "Cognitive Skill Requirement"
	}
	if `counter' ==4 {
		local title = "Computer Skill Requirement"
	}

	twoway (line `var' year if Q`var'==1, lcolor(navy*.3) lpattern(solid)) (scatter `var' year if Q`var'==1, mcolor(navy*.3) msymbol(S)) ///
	 (line `var' year if Q`var'==2, lcolor(navy*.6) lpattern(solid)) (scatter `var' year if Q`var'==2, mcolor(navy*.6) msymbol(T)) ///
	 (line `var' year if Q`var'==3, lcolor(navy*.8) lpattern(solid)) (scatter `var' year if Q`var'==3, mcolor(navy*.8) msymbol(D)) ///
	 (line `var' year if Q`var'==4, lcolor(navy) lpattern(solid)) (scatter `var' year if Q`var'==4, mcolor(navy) msymbol(O)) ///
	, title("`title'") xtitle("") ytitle("") legend(off) saving("$graphs/g`var'", replace) graphregion(color(white)) bgcolor(white) 
	restore
	local counter = `counter' + 1
}
*title("Skill Requirements by Year and 2007-2010 Change")
graph combine "$graphs/ged.gph" "$graphs/gexp.gph" "$graphs/gcog.gph" "$graphs/gcomp_all" , l1title("Average Requirement") b1title("Year") note("Graph plots average BG skill requirement by year and quartile of 2007-10 firm-level skill change. Circles, diamonds, triangles, and squares" "indicate skill change quartile from largest to smallest, respectively.", size(vsmall)) graphregion(color(white))
graph export "$graphs/figure3.pdf", as(pdf) replace
*}}}

**************************************************************************************
**Figure 4: MSA change in PC's per employee
**** + accompanying Table C1 column 9
*************************************************************************************
*{{{
use "$data_output/workingHH_msa_year", clear

capture erase "$tables/COR_fig4.txt"
capture erase "$tables/COR_fig4.xml"



**base reg	
reg chpc_norm_fill shock90102000 shock90102002 shock90102004 shock90102008 shock90102010 shock90102012 shock90102014 i.year ACS* M_ACS  [aw=weight] if year!=2006,  cluster(msa)
outreg2 shock90102000 shock90102002 shock90102004 shock90102008 shock90102010 shock90102012 shock90102014 using "$tables/COR_fig4", append stats(coef, se) excel  
matrix Tcoeffs = e(b)
matrix Tses = e(V)
mata: coeffs = st_matrix("Tcoeffs")'
mata: ses = diagonal(st_matrix("Tses"))
mata: coeffs_base = coeffs[1..7]
mata: ses_base = ses[1..7]:^.5

clear
getmata coeffs_base ses_base
gen year = 1998 + 2*_n if _n<=3
replace year = 2000 + 2*_n if _n>=4

gen ci_plus = coeffs + `ci'*ses_base
gen ci_minus = coeffs - `ci'*ses_base

local obs = _N
local new = `obs' + 1
set obs `new'
replace year = 2006 in `new'
replace coeffs_base = 0 if year==2006
replace ses_base = 0 if year==2006
replace ci_plus = 0 if year==2006
replace ci_minus = 0 if year==2006
sort year

twoway (scatter coeffs_base year, mcolor(navy)) (line coeffs_base year, lcolor(navy)) (rcap ci_minus ci_plus year, lcolor(navy) lpattern(dash) lwidth(vvthin)), xtitle("Year") ytitle("Coefficient")  legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white) xlabel(2000 2002 2004 2006 2008 2010 2012 2014) note("We regress the MSA-level change in IT investment from 2006 on an exhaustive set of MSA employment shock-by-year interactions," "controlling for year fixed effects and MSA characteristics (see equation 1). Graph plots the coefficients on Bartik shock*year," "as well as `ci_label' CI bars. MSA-year IT investment is the employment-weighted average of site-level PCs per pre-recession" "employment from Harte Hanks.", size(vsmall)) graphregion(color(white)) bgcolor(white) 
graph export "$graphs/figure4.pdf", as(pdf) replace
	
*}}}

**************************************************************************************
**Figure 5: firm-level capital change and firm-MSA upskilling
** + summary statistics on matching to HH and COMPUSTAT at firm level
** + Table C2
*************************************************************************************
*{{{
*****bring in both datasets to BG at the employer level and save working dataset
*{{{
use "$data_output/BG_hasfirm_employer_msa_year", clear
merge m:1 emp_nospace using "$HH/matchID_employer_allyrs2"
assert _merge!=2
drop _merge

**bring in HH
merge m:1 matchID using "$data_output/workingHH_firm"

drop if _merge==2
gen hasHH = (_merge==3)
drop _merge

**bring in Compustat
merge m:1 emp_nospace using  "$data_output/workingCOMP_firm"
assert _merge!=2
gen hasCOMP = (_merge==3)
drop _merge


save "$data_output/working_capital", replace

*}}}

****summary statistics on matching
*{{{
**clean in HH vars to merge below
use "$data_output/working_capital", clear
keep if chprepost_fill!=.
keep emp_nospace chprepost_fill match_type
duplicates drop
bysort emp_nospace: assert _n==_N
tempfile HHvars
save `HHvars', replace

use "$data_output/BG_hasfirm_employer_msa_year", clear
**how many firms match forwards and backwards?
gen temp = (year==2007)
bysort emp_nospace: egen has07 = mean(temp)
bysort emp_nospace: egen Nyrs = nvals(year)
gen innit = (has07>0 & Nyrs>=2)

display "fraction of obs by a firm that matches forwards and backwards"
tab innit 
display "weighted by postings"
tab innit [aw=npostings] 
display "with weights "
tab innit [aw=weight] 

display "fraction of firms that matches forwards and backwards"
bysort emp_nospace: gen counter = _n
tab innit if counter==1
display "weighted by postings"
tab innit [aw=npostings] if counter==1 
display "with weights "
tab innit [aw=weight] if counter==1

tab innit if year!=2007
display "weighted by postings"
tab innit [aw=npostings] if year!=2007
display "with weights "
tab innit [aw=weight] if year!=2007

display "fraction of firms that matches forwards and backwards"
tab innit if counter==1 & year!=2007
display "weighted by postings"
tab innit [aw=npostings] if counter==1  & year!=2007 
display "with weights "
tab innit [aw=weight] if counter==1  & year!=2007

display "condl on within emp-msa match"
tab innit if year!=2007 & ched!=.
display "weighted by postings"
tab innit [aw=npostings] if year!=2007 & ched!=.
display "with weights "
tab innit [aw=weight] if year!=2007 & ched!=.

keep if innit==1

***bring in variables used
merge m:1 emp_nospace using `HHvars'
**_merge will =2 but those obs do not have HH data
assert _merge!=2
drop _merge

gen has_chpc = (chprepost_fill!=.)
display "fraction with pre-post pc change measure"
tab has_chpc if year!=2007
display "weighted by postings"
tab has_chpc [aw=npostings] if year!=2007
display "with weights "
tab has_chpc [aw=weight] if year!=2007

display "by firm"
tab has_chpc if year!=2007 & counter==1
display "weighted by postings"
tab has_chpc [aw=npostings] if year!=2007 & counter==1
display "with weights "
tab has_chpc [aw=weight] if year!=2007 & counter==1


display "condl on within emp-msa match"
tab has_chpc if year!=2007 & ched!=.
display "weighted by postings"
tab has_chpc [aw=npostings] if year!=2007 & ched!=.
display "with weights "
tab has_chpc [aw=weight] if year!=2007 & ched!=.

***types of matches
**first exact
**second common
***third singular
**4. univ
***5. first10
display "type of match by firm"
tab match_type if counter==1 & year!=2007
display "type of match by ad"
tab match_type [aw=npostings] if year!=2007


**COMPUSTAT
use "$data_output/working_capital", clear
keep if comp_prepost_fill!=.
keep emp_nospace comp_prepost_fill COMPmatch_type
duplicates drop
bysort emp_nospace: assert _n==_N
tempfile COMPvars
save `COMPvars', replace

use "$data_output/BG_hasfirm_employer_msa_year", clear
**how many firms match forwards and backwards?
gen temp = (year==2007)
bysort emp_nospace: egen has07 = mean(temp)
bysort emp_nospace: egen Nyrs = nvals(year)
gen innit = (has07>0 & Nyrs>=2)

display "fraction of obs by a firm that matches forwards and backwards"
tab innit if year!=2007
display "weighted by postings"
tab innit [aw=npostings] if year!=2007
display "with weights "
tab innit [aw=weight] if year!=2007

display "condl on within emp-msa match"
tab innit if year!=2007 & ched!=.
display "weighted by postings"
tab innit [aw=npostings] if year!=2007 & ched!=.
display "with weights "
tab innit [aw=weight] if year!=2007 & ched!=.

bysort emp_nospace: gen counter = _n

keep if innit==1

***bring in variables used
merge m:1 emp_nospace using `COMPvars'
**_merge will =2 but those obs do not have HH data
drop if _merge==2
drop _merge

gen has_chcomp = (comp_prepost_fill!=.)
display "fraction with pre-post pc change measure"
tab has_chcomp if year!=2007
display "weighted by postings"
tab has_chcomp [aw=npostings] if year!=2007
display "with weights "
tab has_chcomp [aw=weight] if year!=2007

display "# firms"
tab has_chcomp if year!=2007 & counter==1
display "weighted by postings"
tab has_chcomp [aw=npostings] if year!=2007 & counter==1
display "with weights "
tab has_chcomp [aw=weight] if year!=2007 & counter==1

display "condl on within emp-msa match"
tab has_chcomp if year!=2007 & ched!=.
display "weighted by postings"
tab has_chcomp [aw=npostings] if year!=2007 & ched!=.
display "with weights "
tab has_chcomp [aw=weight] if year!=2007 & ched!=.

***types of matches
**first exact
**second fuzzy
***third Deming
display "type of match by firm"
tab COMPmatch_type if counter==1 & year!=2007
display "type of match by ad"
tab COMPmatch_type [aw=npostings] if year!=2007

*}}}

******************************************************************************
**Regs and figures
*****************************************************************************
*{{{
use "$data_output/working_capital", clear

ren comp_prepost_fill chcomp_prepost_fill

capture erase "$tables/COR_fig5.txt"
capture erase "$tables/COR_fig5.xml"


foreach HH in  HH_trim comp_prepost_fill {
	sum ch`HH' [aw=weight], d
	local p10 = r(p10)
	local p90 = r(p90)
	local diff = `p90'-`p10'
	display "90-10 differential, `p90'-`p10' =  `diff'"
	replace ch`HH' = ch`HH' - r(mean)
	sum ch`HH' [aw=weight], d

	foreach year of numlist 2010/2015 {
		gen LCAP`year' = shock9010`year'*ch`HH'

	}
	
	mata: ratio = J(6,4,.)	
	local column = 1
	foreach stem in ed exp cog comp_all {
		preserve
		
		if "`stem'"=="ed" {
			local title = "Education Requirement"
		}
		if "`stem'" =="exp" {
			local title = "Experience Requirement"
		}
		if "`stem'" =="cog" {
			local title = "Cognitive Skill Requirement"
		}
	
		if "`stem'" =="comp_all" {
			local title = "Computer Skill Requirement"
		}
		
		reg ch`stem' shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 LCAP* i.year ACS* M_ACS  [aw=weight] if year!=2007,  cluster(msa) 
		outreg2 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 LCAP* using "$tables/COR_fig5", append stats(coef, se) excel  
		mata: Lcoeffs=J(6,1,.)
		mata: Lses = J(6,1,.)
		local row = 1
		foreach year of numlist 2010/2015 {
			*90-10 diffl
			lincom (`p90' - `p10')*LCAP`year'
			local est = r(estimate)
			local se = r(se)
			mata: Lcoeffs[`row',1] = `est'
			mata: Lses[`row',1] = `se'
			
			lincom `p90'*LCAP`year' + shock9010`year'
			local est90 = r(estimate)
			lincom `p10'*LCAP`year' + shock9010`year'
			local est10 = r(estimate)
			local ratio = (`est90' - `est10')/`est10'
			mata: ratio[`row',`column'] = `ratio'
			
			local row = `row' + 1
		}
		
		
		clear
		getmata Lcoeffs Lses 
		gen year = 2009 + _n

		gen Lci_plus = Lcoeffs + `ci'*Lses
		gen Lci_minus = Lcoeffs - `ci'*Lses


		local obs = _N
		local new = `obs' + 1
		set obs `new'
		replace year = 2007 in `new'
		foreach fill of varlist L*   {
			replace `fill' = 0 if year==2007
		}
		sort year

		list
		
		twoway (line Lcoeffs year, lcolor(navy)) (scatter Lcoeffs year, mcolor(navy)) (rcap Lci_plus Lci_minus year, lcolor(navy) lpattern(dash) lwidth(vvthin)) , xtitle("") ytitle("") title("`title'") saving("$graphs/g`stem'", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white) xlabel(2007 2009 2011 2013 2015)
		
		restore
		
		local column = `column' + 1
		
	}
	
		display "(est90 - est10)/est10 for `HH'"
		mata: ratio


	if "`HH'"=="HH_trim" {
		graph combine "$graphs/ged.gph" "$graphs/gexp.gph" "$graphs/gcog.gph"  "$graphs/gcomp_all.gph",   graphregion(color(white))  note("We regress the firm-MSA-level change in BG skill requirements from 2007 on an exhaustive set of MSA employment shock-by-year interactions," "and triple interactions between the shock, year, and the firm-level capital change. We also control for year fixed effects and MSA characteristics" "(see equation 3). Graph plots the coefficients on the triple interactions, fitted to the 90-10 differential in firm capital change, and `ci_label' CI bars. The" "capital change variable is the firm level change in average PCs (Harte-Hanks) per pre-recession employment between 2010-14 and 2002-06.", size(vsmall)) graphregion(color(white))  title("")
		graph export "$graphs/figure5a.pdf", as(pdf) replace
	}
	if "`HH'"=="comp_prepost_fill" {
		graph combine "$graphs/ged.gph" "$graphs/gexp.gph" "$graphs/gcog.gph"  "$graphs/gcomp_all.gph",   graphregion(color(white)) note("See notes to sub-figure (a). The capital change variable is the ratio of firm-level average capital holdings (Compustat) in 2010-2014" "to holdings in 2002-2006.", size(vsmall)) title("")
		graph export "$graphs/figure5b.pdf", as(pdf) replace
	}
		
	drop  LCAP*

  
}
*}}}
      
*}}}

******************************************************************************
** Figure 6: differential upskilling by routine-cognitive and routine-manual
** + Table C3
** Figure 7: layoffs, employment, and wages by routine-cog and routine-man
** + Table C4, Table C1 columns 10-11
** Figure A5: main layoff and wage effects (across all occs)
*******************************************************************************
*{{{

**read in routineness measures, get quantiles
*{{{
*routineness measures made by brad
use "$data_output/onet_routine_harmonized_4d", clear
ren soc4 soc
keep soc AA_r_cog AA_r_man
foreach var of varlist AA_r_cog AA_r_man {
	foreach q in 4 {
		xtile V`var'`q'_unwt = `var', nq(`q')
	}
}
tempfile occs
save `occs', replace
*}}}

*******************************************************************************
**Figure 6: Main upskilling figure: by "top 4" interaction
** + Table C3
*******************************************************************************
*{{{
use "$data_output/BG_hasfirm_soc_msa_year", clear
merge m:1 soc using `occs'
assert _merge==3
drop _merge

**summary graph, both together
foreach year of numlist 2010/2015 {
	gen cog`year' = shock9010*(year==`year')*(VAA_r_cog4_unwt==4)
	gen man`year' = shock9010*(year==`year')*(VAA_r_man4_unwt==4)
}

capture erase "$tables/COR_fig6.txt"
capture erase "$tables/COR_fig6.xml"

foreach stem in ed exp cog comp_all {
	preserve
	if "`stem'"=="ed" {
		local title = "Education Requirement"
	}
	if "`stem'" =="exp" {
		local title = "Experience Requirement"
	}
	if "`stem'" =="cog" {
		local title = "Cognitive Skill Requirement"
	}
	if "`stem'" =="comp_all" {
		local title = "Computer Skill Requirement"
	}
	
	foreach type in cog man {
		reg ch`stem' shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 `type'2010 `type'2011 `type'2012 `type'2013 `type'2014 `type'2015 ACS* M_ACS i.year [aw=weight] if year!=2007,  cluster(msa) 
		outreg2 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 `type'2010 `type'2011 `type'2012 `type'2013 `type'2014 `type'2015  using "$tables/COR_fig6", append stats(coef, se) excel  
		matrix Tcoeffs = e(b)
		matrix Tses = e(V)
		mata: coeffs = st_matrix("Tcoeffs")'
		mata: ses = diagonal(st_matrix("Tses"))
			
		mata: coeffs_`type' = coeffs[7..12]
		mata: ses_`type' = ses[7..12]:^.5

	}
	clear
	getmata coeffs_cog ses_cog coeffs_man ses_man  
	gen year = 2009 + _n
	foreach type in cog man {
		gen ci_plus`type' = coeffs_`type' + `ci'*ses_`type'
		gen ci_minus`type' = coeffs_`type' - `ci'*ses_`type'
	}
	
	local obs = _N
	local new = `obs' + 1
	set obs `new'
	replace year = 2007 in `new'
	foreach var in coeffs_cog ci_pluscog ci_minuscog coeffs_man ci_plusman ci_minusman {
		replace `var' = 0 if year==2007
	}
	sort year

	twoway (line coeffs_cog year, lcolor(navy)) (scatter coeffs_cog year, mcolor(navy)) (rcap ci_pluscog ci_minuscog year, lcolor(navy) lpattern(dash) lwidth(vvthin)) (line coeffs_man year, lcolor(maroon)) (scatter coeffs_man year, mcolor(maroon) symbol(S)) (rcap ci_plusman ci_minusman year, lcolor(maroon) lpattern(dash) lwidth(vvthin)), xtitle("") ytitle("") title("`title'") saving("$graphs/g`stem'", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white) xlabel(2007 2009 2011 2013 2015)		

	restore
}

graph combine "$graphs/ged.gph" "$graphs/gexp.gph" "$graphs/gcog.gph"  "$graphs/gcomp_all.gph", l1title(Coefficient) b1title(Year)  graphregion(color(white)) note("Blue circles = routine-cognitive, maroon squares = routine-manual", size(medsmall)) caption("We regress the occupation-MSA-level change in BG skill requirements from 2007 on an exhaustive set of MSA employment shock-by-year" "interactions, and triple interactions between the shock, year, and whether the occupation is routine. We also control for year fixed effects and" "MSA characteristics (see equation 4). Graph plots the coefficients on the triple interactions, and `ci_label' CI bars. The routineness measures are" "whether the occupation is in the top quartile of routine-cognitive or routine-manual index scores based on Acemolgu and Autor (2011).", size(vsmall))
*title("Differential Upskilling for Routine Occupations") 
graph export "$graphs/figure6.pdf", as(pdf) replace


*}}}


******************************************************************************
** Figure 7. Invol separations (CPS), employment and wages (OES)
*******************************************************************************
*{{{

**CPS invol seps
*{{{
use "$data_output/workingCPS_layoffs", clear

capture erase "$tables/COR_fig7.txt"
capture erase "$tables/COR_fig7.xml"

***get overall effect
reg chinvsep shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015  i.year ACS* M_ACS [aw=weight] if year!=2007 ,  cluster(msa) 
matrix Tcoeffs = e(b)
matrix Tses = e(V)
mata: coeffs = st_matrix("Tcoeffs")'
mata: ses = diagonal(st_matrix("Tses"))

mata: coeffs4_main = coeffs[1..15]
mata: ses4_main = ses[1..15]:^.5

foreach type in cog man {
	reg chinvsep shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 `type'2000 `type'2001 `type'2002 `type'2003 `type'2004 `type'2005 `type'2006 `type'2008 `type'2009 `type'2010 `type'2011 `type'2012 `type'2013 `type'2014 `type'2015 i.year ACS* M_ACS [aw=weight] if year!=2007,  cluster(msa) 
	outreg2 shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 `type'2000 `type'2001 `type'2002 `type'2003 `type'2004 `type'2005 `type'2006 `type'2008 `type'2009 `type'2010 `type'2011 `type'2012 `type'2013 `type'2014 `type'2015   using "$tables/COR_fig7", append stats(coef, se) excel  
	matrix Tcoeffs = e(b)
	matrix Tses = e(V)
	mata: coeffs = st_matrix("Tcoeffs")'
	mata: ses = diagonal(st_matrix("Tses"))

	mata: coeffs4_`type' = coeffs[16..30]
	mata: ses4_`type' = ses[16..30]:^.5
		
}

clear
getmata coeffs4_cog coeffs4_man ses4_cog ses4_man coeffs4_main ses4_main
gen year = 1999 + _n if _n<=7
replace year = 2000 + _n if _n>=8

foreach type in cog man main {
	gen ci_plus`type' = coeffs4_`type' + `ci'*ses4_`type'
	gen ci_minus`type' = coeffs4_`type' - `ci'*ses4_`type'
}
	
local obs = _N
local new = `obs' + 1
set obs `new'
replace year = 2007 in `new'
foreach var of varlist *man *cog *main {
	replace `var' = 0 if year==2007
}
sort year

***main effect
twoway (line coeffs4_main year, lcolor(navy)) (scatter coeffs4_main year, mcolor(navy)) (rcap ci_plusmain ci_minusmain year, lcolor(navy) lpattern(dash) lwidth(vvthin)) , xtitle("") ytitle("") title("Involuntary Separations (CPS)") saving("$graphs/gCPSmain", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white)
***combine quartile effects like above
twoway (line coeffs4_cog year, lcolor(navy)) (scatter coeffs4_cog year, mcolor(navy)) (rcap ci_pluscog ci_minuscog year, lcolor(navy) lpattern(dash) lwidth(vvthin)) (line coeffs4_man year, lcolor(maroon)) (scatter coeffs4_man year, mcolor(maroon) msymbol(S)) (rcap ci_plusman ci_minusman year, lcolor(maroon) lpattern(dash) lwidth(vvthin)), xtitle("") ytitle("") title("Involuntary Separations (CPS)") saving("$graphs/gCPSrout", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white)		


*}}}

**OES wages and relative employment
**1. relative wages
*{{{
use "$data_output/workingOES", clear

**routine vars already merged in in step1
***top half/quartile/decile
foreach q of numlist 1/4 {
	foreach wt in unwt {
		foreach occ in cog man {
			gen emp`q'_`occ' = (VAA_r_`occ'4_`wt'==`q') 
	}
}
}

collapse emp* shock9010 lf2006 ACS* M_ACS (rawsum) tot_emp [aw=tot_emp], by(msa year)

gen weight = lf2006
foreach year of numlist 2000/2015 {
	gen shock9010`year' = shock9010*(year==`year')
}


foreach var of varlist emp4* {
	gen temp = `var' if year==2007
	bysort msa: egen mtemp = mean(temp)
	gen ch`var' = `var' - mtemp
	drop temp mtemp
}

bysort msa: egen Nyear = nvals(year)
gen has16 = (Nyear==16)
tab has16 if chemp4_cog!=.
tab has16 if chemp4_cog!=. [aw=weight]

foreach type in cog man {
	reg chemp4_`type' shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 ACS* M_ACS i.year [aw=weight] if year!=2007 ,  cluster(msa) 
	outreg2 shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015    using "$tables/COR_fig7", append stats(coef, se) excel
	matrix Tcoeffs = e(b)
	matrix Tses = e(V)
	mata: coeffs = st_matrix("Tcoeffs")'
	mata: ses = diagonal(st_matrix("Tses"))
	mata: coeffs_`type' = coeffs[1..15]
	mata: ses_`type' = ses[1..15]:^.5
}

clear
getmata coeffs_cog coeffs_man ses_cog ses_man
gen year = 1999 + _n if _n<=7
replace year = 2000 + _n if _n>=8
	
foreach type in cog man {
	gen ci_plus`type' = coeffs_`type' + `ci'*ses_`type'
	gen ci_minus`type' = coeffs_`type' - `ci'*ses_`type'
}

local obs = _N
local new = `obs' + 1
set obs `new'
replace year = 2007 in `new'
foreach var of varlist coeff* ses* ci_* {
	replace `var' = 0 if year==2007
}
sort year

twoway (line coeffs_cog year, lcolor(navy)) (scatter coeffs_cog year, mcolor(navy)) (rcap ci_pluscog ci_minuscog year, lcolor(navy) lpattern(dash) lwidth(vvthin)) (line coeffs_man year, lcolor(maroon)) (scatter coeffs_man year, mcolor(maroon) msymbol(S)) (rcap ci_plusman ci_minusman year, lcolor(maroon) lpattern(dash) lwidth(vvthin)), xtitle("") ytitle("") title("Relative Employment (OES)") saving("$graphs/gOES_emp4", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white)
*}}}			

**2. wage graphs in OES
*{{{
use "$data_output/workingOES", clear
ren wmedian w50

***top half/quartile/decile
foreach wage in w50 {
	gen l`wage' = log(`wage')
}

bysort msa year: egen tot = sum(tot_emp)
gen weight = lf2006*tot_emp/tot
drop tot

foreach var of varlist lw50 {
	gen temp = `var' if year==2007
	bysort msa soc: egen mtemp = mean(temp)
	gen ch`var' = `var' - mtemp
	drop temp mtemp
}

foreach year of numlist 2000/2015 {
	gen shock9010`year' = shock9010*(year==`year')
}

bysort msa: egen Nyear = nvals(year)
gen has16 = (Nyear==16)
tab has16 if chlw50!=.
tab has16 if chlw50!=. [aw=weight]

foreach year of numlist 2000/2015 {
	gen cog`year' = shock9010*(year==`year')*(VAA_r_cog4_unwt==4)
	gen man`year' = shock9010*(year==`year')*(VAA_r_man4_unwt==4)
}


***get main effect
reg chlw50 shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 ACS* M_ACS i.year [aw=weight] if year!=2007,  cluster(msa) 
matrix Tcoeffs = e(b)
matrix Tses = e(V)
mata: coeffs = st_matrix("Tcoeffs")'
mata: ses = diagonal(st_matrix("Tses"))

mata: coeffs4_main = coeffs[1..15]
mata: ses4_main = ses[1..15]:^.5
		
foreach type in cog man {
	reg chlw50 shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 `type'2000 `type'2001 `type'2002 `type'2003 `type'2004 `type'2005 `type'2006 `type'2008 `type'2009 `type'2010 `type'2011 `type'2012 `type'2013 `type'2014 `type'2015 i.year ACS* M_ACS [aw=weight] if year!=2007 ,  cluster(msa) 
	outreg2 shock90102000 shock90102001 shock90102002 shock90102003 shock90102004 shock90102005 shock90102006 shock90102008 shock90102009 shock90102010 shock90102011 shock90102012 shock90102013 shock90102014 shock90102015 `type'2000 `type'2001 `type'2002 `type'2003 `type'2004 `type'2005 `type'2006 `type'2008 `type'2009 `type'2010 `type'2011 `type'2012 `type'2013 `type'2014 `type'2015   using "$tables/COR_fig7", append stats(coef, se) excel
	matrix Tcoeffs = e(b)
	matrix Tses = e(V)
	mata: coeffs = st_matrix("Tcoeffs")'
	mata: ses = diagonal(st_matrix("Tses"))

	mata: coeffs4_`type' = coeffs[16..30]
	mata: ses4_`type' = ses[16..30]:^.5
			
}
clear
getmata coeffs4_cog coeffs4_man ses4_cog ses4_man coeffs4_main ses4_main  
gen year = 1999 + _n if _n<=7
replace year = 2000 + _n if _n>=8

		
foreach type in cog man main {
	gen ci_plus`type' = coeffs4_`type' + `ci'*ses4_`type'
	gen ci_minus`type' = coeffs4_`type' - `ci'*ses4_`type'
}
	
local obs = _N
local new = `obs' + 1
set obs `new'
replace year = 2007 in `new'
foreach var of varlist *man *cog *main {
	replace `var' = 0 if year==2007
}
sort year

***full effect
twoway (line coeffs4_main year, lcolor(navy)) (scatter coeffs4_main year, mcolor(navy)) (rcap ci_plusmain ci_minusmain year, lcolor(navy) lpattern(dash) lwidth(vvthin)) , xtitle("") ytitle("") title("Log Median Wage (OES)") saving("$graphs/gOESmain", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white)
		
***combine quartile effects like above
twoway (line coeffs4_cog year, lcolor(navy)) (scatter coeffs4_cog year, mcolor(navy)) (rcap ci_pluscog ci_minuscog year, lcolor(navy) lpattern(dash) lwidth(vvthin)) (line coeffs4_man year, lcolor(maroon)) (scatter coeffs4_man year, mcolor(maroon) msymbol(S)) (rcap ci_plusman ci_minusman year, lcolor(maroon) lpattern(dash) lwidth(vvthin)), xtitle("") ytitle("") title("Log Median Wage (OES)") saving("$graphs/gOESlw50", replace) legend(off) yline(0,lcolor(black)) graphregion(color(white)) bgcolor(white)		

*}}}

*******************************************************************************
**Combine figures
*******************************************************************************
graph combine "$graphs/gCPSrout" "$graphs/gOES_emp4" "$graphs/gOESlw50", l1title("Coefficient") b1title("Year") graphregion(color(white)) note("Blue circles = routine cognitive, maroon squares = routine manual", size(medsmall)) caption("Top left and bottom panels plot coefficients on the triple interactions of shock-year-routine (see equation 4 and figure 6). Top right plots" "coefficients on shock-by-year, where the dependent variable is the MSA change in the employment share of routine occupations (see" "equation 1). All regressions control for year fixed effects and MSA characteristics; we also include `ci_label' CI bars. The routineness measures" "are whether the occupation is in the top quartile of routine-cognitive or routine-manual index scores based on Acemolgu and Autor (2011).", size(vsmall))
*title("Differential Employment and Wage Effects for Routine Occupations") 
graph export "$graphs/figure7.pdf", as(pdf) replace

graph combine "$graphs/gCPSmain" "$graphs/gOESmain" , l1title("Coefficient") b1title("Year") graphregion(color(white))  note("We regress the MSA-level change in local labor market variables from 2007 on an exhaustive set of MSA employment shock-by-year" "interactions, controlling for  year fixed effects (see equation 1). Graph plots the coefficients on Bartik shock*year, as well as `ci_label' CI bars."      "Involuntary separations are author calculations based on the CPS. Log median wages obtained from Occupational Employment Statistics.", size(vsmall))
*title("Differential Employment and Wage Effects for Routine Occupations") 
graph export "$graphs/figureA5.pdf", as(pdf) replace



*}}}


*}}}


