* define the location of the main folder on your computer
global mypath "X:\EthnicFavouritism\AER-FINAL\replication\TABLES\TABLE-6\data-preparation-table-6"


**********************************************
*** EASTERLY-LEVINE DATA SET (1960S-1980S) ***
**********************************************

* 1. We use the Easterly-Levine for the decade 1960s, 1970s and 1980s *
use "$mypath\ELF_ORIGNAL.dta", clear
* we change the year variable to be in a XXXX format
replace year=1960 if year==60
replace year=1970 if year==70
replace year=1980 if year==80
* we change the country codes that changed between the 1960s-1980s and the 1990s-2000s *
replace code="CZE" if code=="CSK"
replace code="TWN" if code=="OAN"
replace code="ROU" if code=="ROM"
replace code="BFA" if code=="HVO"
replace code="GER" if code=="DEU"
* we drop the countries with no ELF measure *
drop if ELF==.
sort code year
save "$mypath\ELF_clean.dta", replace
* this creates a version of the Easterly-Levine data set (1960s-1980s) that is ready for our purpose *

*** 2. APPEND THE DATA FOR THE SUBSEQUENT DECADES, 1990s AND 2000s ***
* Bring in income data from the Penn World Tables data set *
* Append with the following two decades - 1990s and 2000s data to the Easterly-Levine data set *
clear
use "$mypath\pwt.dta"
keep if year == 1990 | year == 1999 | year == 2000 | year == 2009 
rename country_isocode code
gen period=.
replace period=4 if year == 1990 
replace period=4 if year == 1999 
replace period=5 if year == 2000 
replace period=5 if year == 2009 
sort code year period
* Compute growth rates
drop rgdpl2 rgdpch
* We do not use these GDP measures, we only use rgdpl
* rgdpl: Real GDP per capita (Constant Prices: Laspeyres), derived from growth rates of c, g, i 
gen ln_rgdpl=ln(rgdpl)
gen ln_rgdpl_sq=(ln_rgdpl*ln_rgdpl) 
bysort code period: gen g1=(rgdpl[_n]/rgdpl[_n-1])
gen g2=ln(g1)
gen g=g2/10
drop g1 g2
by code period: replace g=g[_n+1] if g[_n]==.
rename g growth_pwt
drop if year==1999 | year==2009
drop period
sort code year
* We then make our data set consistent with the ELF data set ***
drop rgdpl
gen ssa=.
gen latinca=.
gen ELF60=.
gen DUM60=0
gen DUM70=0
gen DUM80=0
gen DUM90=1 if year==1990
replace DUM90=0 if year!=1990
gen DUM2000=.
replace DUM2000=0 if year!=2000
replace DUM2000=1 if year==2000
rename ln_rgdpl lrgdp
rename ln_rgdpl_sq lrgdpsq
rename growth_pwt gyp
sort code year
save "$mypath\pwt_clean_gdp.dta", replace
* this creates a version of the Easterly-Levine data set (1990s-2000s) with the addition of the subsequent decades *

*** 3. WE COMBINE THE TWO DATA SETS (1960s-1980s and 1990s-2000s)
clear
use "$mypath\ELF_clean.dta"
append using "$mypath\pwt_clean_gdp.dta"
sort code year
bys code: egen N= count(_N)
* Check that all the countries have 5 observations: 1960s, 1970s, 1980s, 1990s, 2000s 
drop if N==2
drop N
* Check year dummies are correctly defined for all observations
replace DUM60=1 if year==1960
replace DUM60=0 if year!=1960
replace DUM70=1 if year==1970
replace DUM70=0 if year!=1970
replace DUM80=1 if year==1980
replace DUM80=0 if year!=1980
replace DUM90=1 if year==1990
replace DUM90=0 if year!=1990
replace DUM2000=1 if year==2000
replace DUM2000=0 if year!=2000
order obs code country year ssa latinca DUM60 DUM70 DUM80 DUM90 DUM2000 ELF60 gyp lrgdp lrgdpsq lschool
* Check continent dummies are correctly defined for all observations
by code: egen X_ssa=mean(ssa)
replace ssa=1 if X_ssa==1
replace X_ssa=0 if X_ssa==.
by code: egen X_latinca=mean(latinca)
replace latinca=1 if X_latinca==1
replace X_latinca=0 if X_latinca==.
drop ssa latinca
rename X_ssa ssa
rename X_latinca latinca
* Check index of ethnolinguistic fragmentation is correclty defined for all observations
by code: egen X_ELF60=mean(ELF60)
drop ELF60
rename X_ELF60 ELF60
sort code year
save "$mypath\ELF_clean_full.dta", replace

** 4. THE SCHOOLING VARIABLE **
* Bring in the schooling data from Barro and Lee **
clear
use "$mypath\BL(2010)_MF1599_v1.2.dta"
keep BLcode country year yr_sch WBcode region_code region_code
drop if year==1950
drop if year ==1955
sort country year
gen yr = 1960 if year==1960
replace yr = 1970 if year==1970
replace yr = 1980 if year==1980
replace yr = 1990 if year==1990
replace yr = 2000 if year==2000
replace yr = 2010 if year==2010
replace year=1960 if year ==1965
replace year=1970 if year ==1975
replace year=1980 if year ==1985
replace year=1990 if year ==1995
replace year=2000 if year ==2005
bys country year: egen av_yr_sch=mean(yr_sch)
drop if yr==.
drop yr_sch yr
drop region_code BLcode
gen ln_av_yr_sch_one= ln(av_yr_sch+1)
rename WBcode code
sort code year
** 146 countries - 6 years: 1960, 1970, 1980, 1990, 2000, 2010 **
drop av_yr_sch
** we only want to append to the main data set the observations for the 1990s and 2000s **
** NOTE: we cannot use 2010 because that is the beginning of the decade and all our variables are averages for the decade **
keep if year ==1990 |year ==2000
sort code year
save "$mypath\education.dta", replace

clear
use "$mypath\BL(2010)_MF1599_v1.2.dta"
keep BLcode country year yr_sch WBcode region_code region_code
drop if year==1950
drop if year ==1955
sort country year
gen yr = 1960 if year==1960
replace yr = 1970 if year==1970
replace yr = 1980 if year==1980
replace yr = 1990 if year==1990
replace yr = 2000 if year==2000
replace yr = 2010 if year==2010
replace year=1960 if year ==1965
replace year=1970 if year ==1975
replace year=1980 if year ==1985
replace year=1990 if year ==1995
replace year=2000 if year ==2005
bys country year: egen av_yr_sch=mean(yr_sch)
drop if yr==.
drop yr_sch yr
drop region_code BLcode
gen ln_av_yr_sch_one= ln(av_yr_sch+1)
rename WBcode code
sort code year
** 146 countries - 6 years: 1960, 1970, 1980, 1990, 2000, 2010 **
drop av_yr_sch
** we only want to append to the main data set the observations for the 1990s and 2000s **
** We cannot use 2010 because that is the beginning of the decade and all our variables are averages for the decade **
keep if year ==1960 | year == 1970 | year == 1980
sort code year
save "$mypath\education_gaps.dta", replace

* merge the schooling data set with the main data set *
use "$mypath\ELF_clean_full.dta", clear
merge code year using "$mypath\education.dta"
drop if _m==2
replace lschool = ln_av_yr_sch_one if _m==3
codebook lschool
codebook lschool if year == 1990
codebook lschool if year == 2000
* missing observations before 1990
drop _m 
drop ln_av_yr_sch_one
sort code year
save "$mypath\ELF_clean_full.dta", replace

** CREATE THE DEMOCRACY VARIABLE **
clear
insheet using "$mypath\p4v2011_all.csv", delimiter(",")
keep if year >= 1960 & year <= 2000
gen decade = "1960" if year >= 1960 & year <= 1969
replace decade = "1970" if year >= 1970 & year <= 1979
replace decade = "1980" if year >= 1980 & year <= 1989
replace decade = "1990" if year >= 1990 & year <= 1999
replace decade = "2000" if year >= 2000 & year <= 2009
sum polity2, d
codebook polity2 
* 51 on 5787
replace country = "Yemen" if country == "Yemen North"
replace country = "Yemen" if country == "Yemen South"
collapse (mean) polity2, by(country decade)
gen auto = (polity2 <= -6)
gen nonauto = 1-auto
gen ano = (polity2 >=-5 & polity2 < 5)
gen demo = (polity2 >= 5)
ren decade year
replace country = lower(country)
destring year, replace
replace country = "congo, rep." if country == "congo brazzaville"
replace country = "congo, dem. rep." if country == "congo kinshasa"
replace country = "cote d'ivoire" if country == "ivory coast"
replace country = "dominican republic" if country == "dominican rep"
replace country = "germany, west" if country == "germany west"
replace country = "korea, republic of" if country == "korea south"
replace country = "myanmar" if country == "myanmar (burma)"
replace country = "syrian arab republic" if country == "syria"
replace country = "taiwan, china" if country == "taiwan"
replace country = "trinidad and tobago" if country == "trinidad"
replace country = "yemen, republic of" if country == "yemen"
replace country = "gambia, the" if country == "gambia"
sort country year
save "$mypath\democracy_ELF.dta", replace

* we merge the democracy data set with the main data set *
use "$mypath\ELF_clean_full.dta", clear
* we convert the "country" variable to lower case in order to have an unique country name
replace country = lower(country)
replace country = "congo, republic of" if country == "congo"
replace country = "congo, dem. rep." if country == "zaire"
replace country = "cote d'ivoire" if country == "cote d`ivoire"
replace country = "congo, rep." if country == "congo, republic of"
replace country = "trinidad and tobago" if country == "trinidad &tobago"
replace country = "taiwan, china" if country == "taiwan"
replace country = "syrian arab republic" if country == "syria"
replace country = "yemen, republic of" if country == "yemen"
sort country year
merge country year using "$mypath\democracy_ELF"
tab _m
tab country if _m == 1
*tab country if _m == 2
drop if _m == 2
drop _m
gen POLELF = ELF*polity2
codebook polity2 
* 29 missing
* we create the democracy variable "nonauto" 
* it is equal to one if the country is not autocratic on average in decade t
drop auto nonauto
gen auto = (polity2 <= -6)
replace auto = . if polity2 == .
gen nonauto = 1-auto if polity2 != .
* we create a post-1990 dummy
gen POST90=1 if year>=1990
replace POST90=0 if year <1990
save "$mypath\cross_country.dta", replace


* Drop the variables that we do not use and label the variables we use *
use "$mypath\cross_country.dta", clear
drop obs DUM*
label var code "Country Code"
label var country "Country"
label var year "Decade"
label var gyp "Growth of Per Capita Real GDP [c,t]"
label var ssa "Indicator Variable for Sub-Saharan Africa"
label var latinca "Indicator Variable for Latin America and the Caribbean"
label var lrgdp "Log of Initial Income"
label var lrgdpsq "(Log of Initial Income) Squared"
label var ELF "Index of Ethnolinguistic Fractionalization of Country c in 1960: Ethnic [c,1960]"
ren nonauto democ
label var democ "Indicator variable if Country c is not an Autocracy in Decade t: Democracy [c,t]"
label var lschool "Log of Schooling"
keep code country year gyp ssa latinca lrgdp lrgdpsq ELF democ lschool
save "$mypath\table-6.dta", replace

****************************************************
*** TO CREATE TABLE 6 PLEASE REFER TO TABLE-6.DO ***
****************************************************
