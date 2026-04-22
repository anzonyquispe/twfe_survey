clear all
set more off
set matsize 6000
set mem 500m
capture log close
capture clear

/*
***********************************************************************************
***********************************************************************************
																				

This do file uses data from 
	(1) ICPSR Great Plains Population and Environmental Data: Agricultural Data (county-level) (Gutmann 2005)
	(2) ICPSR Historical, Demographic, Economic, and Social Data: US, 1790-2000 (county-level) (Haines 2005)
	(3) New Deal Spending Data from the Office of Government Reports (county-level) (Fishback et al. 2005)
	(4) Erosion data from maps from the Soil Conservation Service 
	
to create a county-level panel dataset (i.e. unit of observation = county-year pair) of all 1910 counties: "DustBowl_All_base1910.dta" 
	
	
***********************************************************************************
***********************************************************************************
*/

*set directory to current folder, which contains all of the needed data
*cd "  "

*set log
log using Generate_DustBowl.log, replace

*declare temporary datasets
tempfile /*plains variables, alphabetically, then together*/ plains_o_z plains_f_m plains_a_e plains /*plains yearly datasets - 18 total - one per year*/ plains_1910 plains_1920 plains_1925 plains_1930 plains_1935 plains_1940 plains_1945 plains_1950 plains_1954 plains_1959 plains_1964 plains_1969 plains_1974 plains_1978 plains_1982 plains_1987 plains_1992 plains_1997 /*icpsr yearly datasets - 17 years covered - no 1935*/ icpsr_1910_1 icpsr_1910 icpsr_1920 icpsr_1930 icpsr_1930_1 new_deal_spending icpsr_1940 icpsr_1940_1 icpsr_1945 icpsr_1950 icpsr_1950_1 icpsr_1954 icpsr_1959 icpsr_1964 icpsr_1969 icpsr_1974 icpsr_1978 icpsr_1978_1 icpsr_1982 icpsr_1982_1 icpsr_1987 icpsr_1987_1 icpsr_1992 icpsr_1992_1 icpsr_1992_2 icpsr_1997 /*merged plains and icprs yearly datasets - 16 total- no 1925 or 1935*/ 1910 1920 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 /*stacked, uncleaned yearly datasets*/ uncleaned pre_landvalue farmval_temp DustBowl_clean /*yearly cleaned datasets - 18 total - one per year*/ DustBowl_clean_1910 DustBowl_clean_1920 DustBowl_clean_1925 DustBowl_clean_1930 DustBowl_clean_1935 DustBowl_clean_1940 DustBowl_clean_1945 DustBowl_clean_1950 DustBowl_clean_1954 DustBowl_clean_1959 DustBowl_clean_1964 DustBowl_clean_1969 DustBowl_clean_1974 DustBowl_clean_1978 DustBowl_clean_1982 DustBowl_clean_1987 DustBowl_clean_1992 DustBowl_clean_1997 /*census boundary base datasets - we use only 1910 for this analysis*/ DustBowl_base1910 /*cleaned datasets with 1910 boundary year base - they cover all 18 of our observation years*/ DustBowl_clean_19201910 DustBowl_clean_19251910_1 DustBowl_clean_19251910_2 DustBowl_clean_19301910 DustBowl_clean_19351910_1 DustBowl_clean_19351910_2 DustBowl_clean_19401910 DustBowl_clean_19451910_1 DustBowl_clean_19451910_2 DustBowl_clean_19501910 DustBowl_clean_19541910_1 DustBowl_clean_19541910_2 DustBowl_clean_19591910_1 DustBowl_clean_19591910_2 DustBowl_clean_19641910_1 DustBowl_clean_19641910_2 DustBowl_clean_19691910_1 DustBowl_clean_19691910_2 DustBowl_clean_19741910_1 DustBowl_clean_19741910_2 DustBowl_clean_19781910_1 DustBowl_clean_19781910_2 DustBowl_clean_19821910_1 DustBowl_clean_19821910_2 DustBowl_clean_19871910_1 DustBowl_clean_19871910_2 DustBowl_clean_19921910_1 DustBowl_clean_19921910_2 DustBowl_clean_19971910_1 DustBowl_clean_19971910_2 /*GIS Maps*/ woodland_map_1910 centroid_map_1910 erosion_map_1910


***************************************************************************************************
***		Great Plains Population and Environment Database Extract, which contains				***
***		data on agricultural variables at the county level for different years 					***
***		Note: unit of obs = county-year pairs													***
***************************************************************************************************

*** Bring in data (from 3 separate extract files) and create a single panel dataset ***

*Import Extract Files
	/*Extract File 1*/
		/*bring in data*/
		insheet using hor2678.txt, comma
		/*sort by unique ID: concatenated fips and year*/
		sort unyear
		/*save as temporary dataset*/
		save `plains_o_z', replace
		clear

	/*Extract File 2*/
		/*bring in data*/
		insheet using hor4922.txt, comma
		/*sort by unique ID: concatenated fips and year*/
		sort unyear
		/*save as temporary dataset*/
		save `plains_f_m', replace
		clear

	/*Extract File 3*/	
		/*bring in data*/
		insheet using hor6429.txt, comma
		/*sort by unique ID: concatenated fips and year*/
		sort unyear
		/*save as temporary dataset*/
		save `plains_a_e', replace
		clear
	
*Combine 3 extract files into a single file by merging based on unique ID (county-year)
use `plains_a_e'
sort unyear
merge 1:1 unyear using `plains_f_m'
drop _merge
sort unyear
merge 1:1 unyear using `plains_o_z'

*clean data
	/*drop merge variable and missing code flags*/
	drop _merge miss*
	/*fix year values*/
	replace year="1969" if year=="1969a"
	replace year="1974" if year=="1974a"
	drop if year=="1969c" | year=="1974c"
	destring year, replace
	save `plains', replace
	clear

*create a separate county-level dataset for each year of data
foreach y in 1910 1920 1925 1930 1935 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
	use `plains'
	keep if year==`y'
	rename unfips fips
	sort fips
	save `plains_`y'', replace
	clear
}


***************************************************************************************************
***		Build individual year county-level datasets using (1) ICPSR data, which contains 		***
***		population and farm value data at the county level (all obs	with level==1 [this 		***
***		signifies that the observation is a county observation] and (2) New Deal Spending 		***
***		dataset for 1930 (also county-level). 													***
***		We'll save each year as its own .dta file , so the unit of obs for each year will be 	***
***		the county. 																			***
***************************************************************************************************


*** 1910 ***
	/*bring in first datafile*/
	use 02896-0022-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables needed*/
	keep state county name totpop urb910 cropval farms farmown1 farmown2 farmman acresman farmten acresten favalman favalten acresown farmown area fips 
	/*create total farm acres for the county*/
	gen acres = acresown /*acres in owner-operated farms*/ + acresman /*acres in manager-operated farms*/ +	acresten /*acres in tenant farms*/
	/*rename variables so they correspond to names in future years*/
	rename farmown1 farmfown /*number of farms consisting of fully owned land only*/
	rename farmown2 farmpown /*number of farms consisting of partially owned (i.e. owned and hired) land*/
	rename acresman acman /*acres in manager-operated farms*/
	rename acresten acten /*acres in tenant farms*/
	rename urb910 urban /*urban population in 1910*/
	sort fips /*unique county ID (county & state)*/
	drop if fips==.
	save `icpsr_1910_1', replace
	clear
	
	/*bring in 2nd data file*/
	use 02896-0085-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables needed*/
	keep fips farmval farmbui farmequi livstock dairyrec pouprrec animrec hwaxval woolval livslval
	/*sort by fips so that we can merge with the first 1910 county datafile*/
	sort fips
	drop if fips==.
	/*merge with first 1910 datafile*/
	merge 1:1 fips using `icpsr_1910_1'
	drop _merge
	/*create year variable*/
	gen year=1910
	/*sort to prepare appending with other years to create full panel*/
	sort fips
	save `icpsr_1910', replace
	clear

	
*** 1920 ***
	/*bring in datafile*/
	use 02896-0024-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep state county name totpop urb920 mfgestab mfgavear mfgwages mfgrms mfgout mfgvalad cropval farms acres landval farmbui farmequi farmown1 farmown2 farmman acresman farmten acresten favalten acresown acwoods farmval livstock farmown area areaac fips
	/*rename variables so that they correspond to names in future years*/
	rename farmown1 farmfown
	rename farmown2 farmpown
	rename acresman acman
	rename acresten acten
	rename urb920 urban
	/*create year variable*/
	gen year=1920
	/*sort and save for appending with rest of panel*/
	sort fips
	drop if fips==.
	save `icpsr_1920', replace
	clear


*** 1930 ***
	/*bring in datafile*/
	use 02896-0026-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep state county name totpop urb930 urbfarm rurfarm mfgestab mfgavear mfgwages mfgrms mfgout mfgvalad gainwrk totunemp munemp funemp tolayoff mlayoff flayoff retsales cropval farms acres accrop acharves landval farmbui farmequi farmfown acfown farmpown acpown farmman acman farmten acten hacten favalten eqvalten acfailur acidle acpastur acwoods acoth area areaac fips
	/*rename variables so that they correspond to names in all years*/
	rename urb930 urban
	/*create year variable*/
	gen year=1930
	/*sort and save to prepare for merge with special county-level New Deal spending dataset*/
	sort state county
	save `icpsr_1930_1', replace
	clear

	/*Bring in county-level New Deal spending dataset*/
	insheet using new_deal_spending.txt, tab
	/*drop observations that are combinations of counties (i.e. not a unique county)*/
	drop if ndmtcode!=county
	/*create population in 1930 variable*/
	gen pop30 = round(pop30t*1000)
	/*convert per-capita variables into county-level totals*/
	foreach var of varlist pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*pop30
	}
	/*drop un-needed variables and variables whose value we'll get from other sources: (1) name of county, (2) 1930 population, (3) state*/
	drop ndmtcode name stateabl pop30t pop30
	/*sort and save to prepare with merge with other 1930 data*/
	sort state county
	save `new_deal_spending', replace

	/*merge 1930 ICPRS data with New Deal Spending data*/
	use `icpsr_1930_1'
	merge 1:1 state county using `new_deal_spending'
	/*drop if the county is not in the ICPRS dataset*/
	drop if _merge==2
	drop _merge
	
	/*sort and save for appending onto panel*/
	sort fips
	drop if fips==.
	save `icpsr_1930', replace
	clear
	

*** 1940 ***
	/*bring in ICPRS datafile 1*/
	use 02896-0032-Data.dta
	/*keep county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep state county name totpop urb940 urbfarm rurfarm mfgestab mfgavear mfgwages mfgrms mfgout mfgvalad m14emp f14emp m14seek f14seek m14emerg f14emerg retsales cropval farms acfarms hacfarms farmval buildval equipval farmfown acfown farmpown acpown farmman acman farmten acten hacten favalten eqvalten area areaac fips
	/*standardize variable names to match across years*/
	rename acfarms acres /*total farm acreage in 1940*/
	rename hacfarms acharves /*harvested farm acreage in 1940*/
	rename buildval farmbui /*value of farm buildings of all farms, 1940*/
	rename equipval farmequi /*value of farm implements and machinery on all farms, 1940*/
	rename urb940 urban
	/*sort and save for (1) merging with second 1940 data and (2) appending onto panel*/
	sort fips
	drop if fips==.
	save `icpsr_1940_1', replace
	clear

	/*bring in ICPRS datafile 2*/
	use 02896-0070-Data.dta
	/*keep only county-level observations*/
	keep if level==1
	/*keep and rename only the variables we need*/
	keep fips var58 var59 var60
	rename var58 fprodval /*value of farm products sold, traded, or used by farm household ($000s), 1939*/
	replace fprodval = fprodval*1000
	rename var59 livestock_percent /*percent of value of farm products from livestock products, 1939*/
	rename var60 crop_percent /*percent of value of farm products from crops, 1939*/
	/*sort and merge with 1940 ICPRS datafile 1*/
	sort fips
	merge 1:1 fips using `icpsr_1940_1'
	drop _merge
	/*create year variable*/
	gen year=1940
	/*sort and save for appending onto panel*/
	sort fips
	drop if fips==.
	save `icpsr_1940', replace
	clear


*** 1945 ***
	/*bring in datafile*/
	use 02896-0071-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep variables we want*/
	keep fips var75 var76 var77 var78 var71 var74 var69 var68 var70 var71 var73 var2 var34 var35 var36 var37
	/*rename variables to more descriptive, intuitive names*/
	rename var76 fprodval /*total value of farm products sold or used by farm households ($000s), 1944*/
	replace fprodval = fprodval*1000
	rename var77 livestock_percent /*percent of farm sales from livestock & livestock products, 1944*/
	rename var78 crop_percent /*percent of farm sales from crops, 1944*/
	rename var73 farmval /*value of farmland and farm buildings, ($000s), 1945*/
	replace farmval = farmval*1000
	rename var74 avfarval /*average value of farmland and farm buildings, per farm, 1945*/
	rename var75 avacrval /*average value of farmland and farm buildings, per acre, 1945*/
	rename var69 farms /*number of farms, 1/1/1945*/
	rename var68 farmpop /*farm population, 1/1/1945*/
	rename var70 percent_tenant /*percent of farms operated by tenants*/
	rename var71 acres /*total land in farms, acres, 1945*/
	replace acres=acres*1000
	rename var2 retsales /*total sales of all retail establishments, 1948*/
	rename var34 mfgestab /*number of manufacturing establishments, 1947*/
	rename var36 mfgavear /*average annual number of employees in manufacturing, 1947*/
	rename var37 mfgwages /*total wages and salaries paid to those in manufacturing ($000s), 1947*/
	replace mfgwages=mfgwages*1000
	rename var35 mfgvalad /*total manufacturing value added ($000s), 1947*/
	replace mfgvalad=mfgvalad*1000
	
	/*create year variable*/
	gen year=1945
	/*sort and save for appending with panel*/
	sort fips
	drop if fips==.
	save `icpsr_1945', replace
	clear


*** 1950 ***
	/*import 1950 datafile 1*/
	use 02896-0035-Data.dta
	/*keep only county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep state county name totpop urb950 urbfarm memp femp unempm14 unempf14 cropval fprodval farms acres avfarval accrop haccrop farmfown acfown farmpown acpown farmman acman farmten acten hacten accrpast accrout acwoodpa acwoodnp acothpas acothlan acpastur acwoods area areaac fips
	/*create total farm value variable*/
	gen farmval = avfarval*farms
	/*rename variable for consistency in panel*/
	rename haccrop acharves /*number of acres of cropland harvested, 1949*/
	rename urb950 urban
	/*sort and save data for merge with 1950 datafile 2*/
	sort fips
	drop if fips==.
	save `icpsr_1950_1', replace
	clear

	/*import 1950 datafile 2*/
	use 02896-0072-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips var9 var106 var107 var108 var109
	/*rename variables for consistency with other years in panel*/
	rename var9 rurfarm /*rural farm population, 1950*/
	rename var106 value_crops /*value of crops sold ($000s), 1949 - THE REASON THIS VARIABLE IS NOT BEING MULTIPLIED BY 1000 AS THE CODEBOOK SUGGESTS IS BECAUSE IT'S VALUE SEEMS TO BE ALREADY AT THAT LEVEL, AND REFER TO CROPVAL IN FILE 35.*/
	rename var107 value_livestock /*value of livestock and (non-dairy, non-poultry) products sold ($000s), 1949*/
	replace value_livestock= value_livestock*1000
	rename var108 value_dairy /*value of dairy products ($000s), 1949*/
	replace value_dairy= value_dairy*1000
	rename var109 value_poultry /*value of poultry products ($000s), 1949*/
	replace value_poultry= value_poultry*1000
	/*sort and save dataset for merge with 1950 datafile 1 and then appending to panel*/
	sort fips
	drop if fips==.
	merge 1:1 fips using `icpsr_1950_1'
	drop _merge
	/*create year variable*/
	gen year=1950
	/*sort and save for upcoming append*/
	sort fips
	save `icpsr_1950', replace
	clear

	
*** 1954 ***
	/*import 1954 datafile*/
	use 02896-0073-Data.dta
	/*keep only county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep fips var113 var28 var68 var72 var73 var76 var100 var101 var110 var111 var112 var119 var120 var121 var122 var123
	/*rename to match all other years in panel*/
	rename var28 retsales /*retail sales, ($000s), 1954*/
	replace retsales=retsales*1000
	rename var68 mfgestab /*number of manufacturing establishments, 1954*/
	rename var72 mfgavear /*average annual number of employees in manufacturing, 1954*/
	rename var73 mfgwages /*total manufacturing payroll ($000s), 1954*/
	replace mfgwages=mfgwages*1000
	rename var76 mfgvalad /*total manufacturing value added ($000s), 1954*/
	replace mfgvalad=mfgvalad*1000
	rename var100 farms /*number of farms, 1954*/
	rename var101 acres /*total acres in farmland (000s), 1954*/
	replace acres=acres*1000
	rename var112 avfarval /*average per farm value of land and buildings, 1954*/
	gen farmval = avfarval*farms
	rename var113 avacrval /*average per acre value of farm land and buildings, 1954*/
	rename var119 fprodval /*value of all total farm products ($000s), 1954*/
	replace fprodval = fprodval*1000
	rename var120 value_crops /*value of all crops sold ($000s), 1954*/
	replace value_crops = value_crops*1000
	rename var121 value_livestock /*value of all livestock and livestock products sold ($000s), 1954*/
	replace value_livestock= value_livestock*1000
	rename var122 value_dairy /*value of all dairy products sold ($000s), 1954*/
	replace value_dairy= value_dairy*1000
	rename var123 value_poultry /*value of all poultry products sold ($000s), 1954*/
	replace value_poultry= value_poultry*1000
	rename var110 percent_tenant /*percent of farms that are tenant farms, 1954*/
	rename var111 acharves /*total agricultural crop land harvested (000s acres)*/
	replace acharves = acharves*1000
	/*create year variable*/
	gen year=1954
	/*sort and save for appending with rest of panel*/
	sort fips
	drop if fips==.
	save `icpsr_1954', replace
	clear

	
*** 1959 ***
	/*import 1959 datafile*/
	use 02896-0074-Data.dta
	/*keep only county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep fips var147 var3 var6 var7 var137 var146 var148 var149 var150 var151 var152 var100 var86 var89 var90 var94 var135 var145
	/*rename the variables to be consistent with other years in panel*/
	rename var3 totpop /*total population in 1960*/
	rename var6 percent_urban /*percent of population living in an urban area, 1960*/
	gen urban = (percent_urban/100)*totpop
	drop percent_urban
	rename var7 percent_rurfarm /*percent of population living on a farm, 1960*/
	gen rurfarm = (percent_rurfarm/100)*totpop
	drop percent_rurfarm
	rename var137 farms /*number of farms, 1959*/
	rename var146 avfarval /*average per farm value of land and buildings, 1959*/
	gen farmval = avfarval*farms
	rename var147 avacrval /*average per acre value of farm land and buildings, 1959*/
	rename var148 fprodval /*value of all farm products sold ($000s), 1959*/
	replace fprodval = fprodval*1000
	rename var149 value_crops /*value of all crops sold ($000s), 1959*/
	replace value_crops = value_crops*1000
	rename var152 value_livestock /*value of all livestock sold ($000s), 1959*/
	replace value_livestock= value_livestock*1000
	rename var150 value_dairy /*value of all dairy products sold ($000s), 1959*/
	replace value_dairy= value_dairy*1000
	rename var151 value_poultry /*value of all poultry products sold ($000s), 1959*/
	replace value_poultry= value_poultry*1000
	rename var100 retsales /*value of all retail trade sales ($000s), 1958*/
	replace retsales=retsales*1000
	rename var86 mfgestab /*number of manufacturing establishments, 1958*/
	rename var89 mfgavear /*number of manufacturing employees, 1958*/
	rename var90 mfgwages /*manufacturing total annual payroll ($000s), 1958*/
	replace mfgwages=mfgwages*1000
	rename var94 mfgvalad /*manufacturing adjusted value added ($000s), 1958*/
	replace mfgvalad=mfgvalad*1000
	rename var135 acres /*total acreas in farms (000s acres), 1959*/
	replace acres=acres*1000
	rename var145 percent_tenant /*percent tenant farms, 1959*/
	/*create year variable*/
	gen year=1959
	/*sort and save for upcoming append*/
	sort fips
	drop if fips==.
	save `icpsr_1959', replace
	clear

	
*** 1964 ***
	/*import 1964 datafile*/
	use 02896-0075-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips var128 var124 var126 var129 var137 var139 var140 var89 var73 var64 var65 var69 var125
	/*rename the variables to be consistent with other years in panel*/
	rename var124 farms /*number of farms, 1964*/
	rename var126 acres /*total acres in farmland (000s acres), 1964*/
	replace acres=acres*1000
	rename var128 avacrval /*average per acre value of farm land and buildings, 1964*/
	rename var129 avfarval /*average per acre farm value of land and buildings, 1964*/
	rename var137 fprodval /*value of all farm products sold ($000s), 1964*/
	replace fprodval = fprodval*1000
	rename var139 value_crops /*value of crops sold ($000s), 1964*/
	replace value_crops = value_crops*1000
	rename var140 value_livestock /*value of livestock sold ($000s), 1964*/
	replace value_livestock= value_livestock*1000
	rename var89 retsales /*value of retail sales ($000s), 1963*/
	replace retsales=retsales*1000
	rename var73 mfgestab /*number of manufacturing establishments, 1963*/
	rename var64 mfgavear /*number of manufacturing employees, 1963*/
	rename var65 mfgwages /*total annual manufacturing payroll, 1963 - codebook doesn't say ($000s), but (1) figures seem to be
							in ($000s) with an average value of $37,634 and (2) previous years have been in ($000s)*/
	replace mfgwages=mfgwages*1000
	rename var69 mfgvalad /*total manufacturing value added ($000s), 1963*/
	replace mfgvalad=mfgvalad*1000
	rename var125 percent_tenant /*percent of farms operated by tenants, 1964*/
	/*create year variable*/
	gen year=1964
	/*sort and save for upcoming append to panel*/
	sort fips
	drop if fips==.
	save `icpsr_1964', replace
	clear

	
*** 1969 ***
	/*import 1969 datafile*/
	use 02896-0076-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep fips var179 var173 var175 var178 var3 var8 var169 var168 var135 var121 var124 var125 var129
	/*rename variables to be consistent with rest of panel years*/
	rename var173 farms /*number of farms, 1969*/
	rename var175 acres /*total acres of land in farms (000s acres), 1969*/
	replace acres=acres*1000
	rename var178 avfarval /*average value per farm, ($000s), 1969*/
	replace avfarval = avfarval*1000
	gen farmval = avfarval*farms
	rename var179 avacrval /*average value per acre, 1969 */
	rename var3 totpop /*total population, 1970*/
	rename var8 urban_percent /*percent of population living in urban area, 1970*/
	gen urban = totpop*(urban_percent/100)
	drop urban_percent
	rename var169 farmpop /*total farm population, 1970*/
	rename var168 rurnonfarmpop /*rural, nonfarm population, 1970*/
	gen rurfarm = totpop-urban-rurnonfarmpop
	gen urbfarm = farmpop-rurfarm
	drop farmpop rurnonfarmpop
	rename var135 retsales /*value of retail sales ($000s), 1967*/
	replace retsales=retsales*1000
	rename var121 mfgestab /*total number of manufacturing establishments, 1967*/
	rename var124 mfgavear /*total manufacturing employees (00s), 1967*/
	replace mfgavear=mfgavear*100
	rename var125 mfgwages /*total manufacturing payroll ($000,000s), 1967*/
	replace mfgwages=mfgwages*1000000
	rename var129 mfgvalad /*manufacturing value added ($000,000s), 1967*/
	replace mfgvalad=mfgvalad*1000000
	/*create year variable*/
	gen year=1969
	/*sort and save for upcoming append*/
	sort fips
	drop if fips==.
	save `icpsr_1969', replace
	clear


*** 1974 ***
	/*import 1974 datafile*/
	use 02896-0077-Data.dta
	/*keep only county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep fips var284 var274 var278 var283 var282 var281 var219 var181 var184 var185 var189
	/*rename variables to make consistent with other years in panel*/
	rename var274 farms /*number of farms, 1974*/
	rename var278 acres /*acres in farms (000s acres), 1974*/
	replace acres=acres*1000
	rename var283 avfarval /*average value of land and buildings, per farm, ($000s), 1974*/
	replace avfarval = avfarval*1000
	gen farmval = avfarval*farms
	rename var284 avacrval /*average value of land and buildings, per acre, 1974*/
	rename var281 accrop /*cropland acreage (000s) acres, 1974*/
	replace accrop=accrop*1000
	rename var282 percent_harvested /*percent of cropland harvested, 1974*/
	gen acharves = (percent_harvested/100)*accrop
	drop percent_harvested
	rename var219 retsales /*total retail sales ($000s), 1972*/
	replace retsales=retsales*1000
	rename var181 mfgestab /*total number of manufacturing establishments, 1972*/
	rename var184 mfgavear /*total number of manufacturing employees (000s), 1972*/
	replace mfgavear=mfgavear*1000
	rename var185 mfgwages /*total manufacturing payroll ($000,000s), 1972*/
	replace mfgwages=mfgwages*1000000
	rename var189 mfgvalad /*total manufacturing value added ($000,000s), 1972*/
	replace mfgvalad=mfgvalad*1000000
	/*create year variable*/
	gen year=1974
	/*sort and save for upcoming append*/
	sort fips
	drop if fips==.
	save `icpsr_1974', replace
	clear
	
	
*** 1978 ***
	/*import 1978 datafile 1*/
	use 02896-0078-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips var224 var207 var211 var223 var215 var3 var6 var205 var178 var165 var167 var168 var169
	/*rename variables to match other years in panel*/
	rename var207 farms /*number of farms, 1978*/
	rename var211 acres /*acres in farms, 1978*/
	rename var223 avfarval /*average value of land and buildings, per farm, 1978*/
	rename var215 accrop /*acres in cropland, 1978*/
	gen farmval = avfarval*farms
	rename var224 avacrval /*average value of land and buildings, per acre, 1978*/
	rename var3 totpop /*population, 4/1/1980*/
	rename var6 urban /*urban population, 4/1/1980*/
	rename var205 rurfarm /*rural farm population, 4/1/1980*/
	rename var178 retsales /*total retail sales ($000s), 1977*/
	replace retsales=retsales*1000
	rename var165 mfgestab /*number of manufacturing establishments, 1977*/
	rename var167 mfgavear /*number of manufacturing employees (000s), 1977*/
	replace mfgavear=mfgavear*1000
	rename var168 mfgwages /*total manufacturing payroll ($000,000s), 1977*/
	replace mfgwages=mfgwages*1000000
	rename var169 mfgvalad /*total manufacturing value added ($000,000s), 1977*/
	replace mfgvalad=mfgvalad*1000000
	/*sort and save for upcoming merge with 1978 datafile 2*/
	sort fips
	drop if fips==.
	save `icpsr_1978_1', replace
	clear

	/*import 1978 datafile 2*/
	use 02896-0082-Data.dta
	/*keep county-level observations only*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips ag60078d ag62078d ag65078d
	/*rename variables to match other years in panel*/
	rename ag60078d fprodval /*total value of farm products sold ($000s), 1978 - no mention in databook that number is reported in ($000s), but (1) the average value of $34 million makes much more sense than $34,000 and (2) in all prior years, the variable has been reported in ($000s)*/
	replace fprodval=fprodval*1000
	rename ag62078d value_crops /*value of crops sold ($000s), 1978 - no mention in databook that number is reported in ($000s), but see above*/
	replace value_crops= value_crops*1000
	rename ag65078d value_livestock /*value of all livestock sold, 1978 - no mention in databook that number is reported in ($000s), but see above*/
	replace value_livestock= value_livestock*1000
	/*sort and save for merge*/
	sort fips
	drop if fips==.
	merge 1:1 fips using `icpsr_1978_1'
	drop _merge
	/*create year variable*/
	gen year=1978
	/*sort and save for appending to panel*/
	sort fips
	save `icpsr_1978', replace
	clear


*** 1982 ***
	/*import 1982 datafile 1*/
	use 02896-0079-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips var120 var109 var114 var118 var119 var121 var123 var124 var153 var129 var131 var133 var138
	/*rename the variables to match other years in panel*/
	rename var109 farms /*number of farms, 1982*/
	rename var114 acres /*total farm acres (000s), 1982*/
	replace acres=acres*1000
	rename var119 avfarval /*average value of land and buildings ($000s), per farm, 1982*/
	replace avfarval=avfarval*1000
	gen farmval = avfarval*farms
	rename var120 avacrval /*average value of land and buildings, per acre, 1982*/
	rename var118 accrop /*total cropland (000s acres), 1982*/
	replace accrop = accrop*1000
	rename var121 fprodval /*value of all farm products sold ($000,000s), 1982*/
	replace fprodval = fprodval*1000000
	rename var123 crop_percent /*value of all farm products sold, % from crops, 1982*/
	rename var124 livestock_percent /*value of all farm products sold, % from livestock, 1982*/
	rename var153 retsales /*value of all retail sales ($000,000s), 1982*/
	replace retsales=retsales*1000000
	rename var129 mfgestab /*number of manufacturing establishments, 1984*/
	rename var131 mfgavear /*number of manufacturing employees (000s), 1982*/
	replace mfgavear=mfgavear*1000
	rename var133 mfgwages /*total manufacturing payroll ($000,000s), 1982*/
	replace mfgwages=mfgwages*1000000
	rename var138 mfgvalad /*total manufacturing value added ($000,000s), 1982*/
	replace mfgvalad=mfgvalad*1000000
	/*sort for merge with 1982 datafile 2*/
	sort fips
	drop if fips==.
	save `icpsr_1982_1', replace
	clear

	/*import 1982 datafile 2*/
	use 02896-0082-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips ag36082d
	/*rename the variables to match other years in panel*/
	rename ag36082d acharves /*cropland harvested (acres), 1982*/
	/*sort and save for merge with 1982 datafile 1*/
	sort fips
	drop if fips==.
	merge 1:1 fips using `icpsr_1982_1'
	drop _merge
	/*create year variable*/
	gen year=1982
	/*sort and save for upcoming append*/
	sort fips
	save `icpsr_1982', replace
	clear


*** 1987 ***
	/*import 1987 datafile 1*/
	use 02896-0080-Data.dta
	/*keep county-level observations only*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips var156 var162 var160 var005 var154 var182 var167 var169 var171 var174
	/*rename variables so that they're consistently named with other panel year variables*/
	rename var156 farms /*number of farms, 1987*/
	rename var162 acres /*total acres in farms, 1987*/
	rename var160 fprodval /*value of all farm products sold ($000s), 1987*/
	replace fprodval = fprodval*1000
	rename var005 totpop /*population, 1990*/
	rename var154 farmpop /*farm population, 1990*/
	rename var182 retsales /*retail sales ($000s), 1987 - no mention in codebook of ($000s), but (1) prior years have been reported in ($000s) and the average value of $495,389 seems low*/
	replace retsales=retsales*1000
	rename var167 mfgestab /*number of manufacturing establishments, 1987*/
	rename var169 mfgavear  /*number of manufacturing employees (000s), 1987*/
	replace mfgavear=mfgavear*1000
	rename var171 mfgwages /*total manufacturing payroll ($000,000s), 1987*/
	replace mfgwages=mfgwages*1000000
	rename var174 mfgvalad /*total manufacturing value added ($000,000s), 1987*/
	replace mfgvalad=mfgvalad*1000000
	/*sort and save for merge with 1987 datafile 2*/
	sort fips
	drop if fips==.
	save `icpsr_1987_1', replace
	clear

	/*import 1987 datafile 2*/
	use 02896-0082-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips ag44087d ag35087d ag36087d ag43087d ag62087d ag65087d
	/*rename variables consistently with other years in panel*/
	rename ag35087d accrop /*total cropland in acres, 1987*/
	rename ag36087d acharves /*total cropland harvested in acres, 1987*/
	rename ag43087d avfarval /*average value of land and buildings, per farm, 1987*/
	rename ag44087d avacrval /*average value of land and buildings, per acre, 1987*/
	rename ag62087d value_crops /*total value of all farm crops sold ($000s), 1987 - no mention in codebook that the number is reported in ($000s), but (1) an average value of $18.7 million makes much more sense than $18,700 and (2) in all years prior to 1982, the variable was reported in ($000s)*/
	replace value_crops= value_crops*1000
	rename ag65087d value_livestock /*total value of all farm livestock sold, 1987 - no mention in codebook that the number is reported in ($000s), but (1) an average value of $24.5 million makes much more sense than $24,500 and (2) in all years prior to 1982, the variable was reported in ($000s)*/
	replace value_livestock= value_livestock*1000
	/*sort and save for merge*/
	sort fips
	drop if fips==.
	merge 1:1 fips using `icpsr_1987_1'
	drop _merge
	/*create year variable*/
	gen year=1987
	/*sort and save for appending with panel*/
	sort fips
	save `icpsr_1987', replace
	clear


*** 1992 ***
	/*import 1992 datafile 1*/
	use 02896-0082-Data.dta
	/*keep only county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips ag44092d ag01092d ag32092d ag35092d ag36092d ag43092d ag60092d ag62092d ag65092d
	/*rename the variables to be consistent with names in other years*/
	rename ag01092d farms /*number of farms, 1992*/
	rename ag32092d acres /*acres in farms, 1992*/
	rename ag35092d accrop /*acres in cropland, 1992*/
	rename ag36092d acharves /*acres in harvested cropland, 1992*/
	rename ag43092d avfarval /*average value of land and buildings per farm, 1992*/
	rename ag44092d avacrval /*average value of land and buildings per acre, 1992*/
	rename ag60092d fprodval /*total value of farm products sold ($000s), 1992 - no mention in codebook that the number is reported in ($000s), but (1) an average value of $51 million makes much more sense than $51,000 and (2) in all years prior to 1982, the variable was reported in ($000s)*/
	replace fprodval=fprodval*1000
	rename ag62092d value_crops /*value of all crops sold ($000s), 1992 - no mention in codebook that the number is reported in ($000s), but (1) an average value of $23.8 million makes much more sense than $23,800 and (2) in all years prior to 1982, the variable was reported in ($000s)*/
	replace value_crops= value_crops*1000
	rename ag65092d value_livestock /*value of all livestock sold ($000s), 1992 - no mention in codebook that the number is reported in ($000s), but (1) an average value of $27.6 million makes much more sense than $27,600 and (2) in all years prior to 1982, the variable was reported in ($000s)*/
	replace value_livestock= value_livestock*1000
	/*sort and save for merge with other 1992 datafiles*/
	sort fips
	drop if fips==.
	save `icpsr_1992_1', replace
	clear

	/*import 1992 datafile 2*/
	use 02896-0084-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we need*/
	keep fips rt12092d
	/*rename variables to be consistent with other years*/
	rename rt12092d retsales /*total retail sales ($000,000s), 1992 - no mention in codebook that the number is reported in ($000,000s), but (1) an average value of $620 million makes much more sense than $620,000 and (2) in all years prior to 1982, the variable was reported in ($000s)*/
	replace retsales=retsales*1000
	/*sort for merge with 1992 datafile 1*/
	sort fips
	drop if fips==.
	save `icpsr_1992_2', replace
	clear

	/*import 1992 datafile 3*/
	use 02896-0083-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips ma01092d ma10092d ma15092d ma30092d
	/*rename variables to be consistently named with other years in panel*/
	rename ma01092d mfgestab /*number of manufacturing establishments, 1992*/
	rename ma10092d mfgavear /*number of manufacturing employees (000s), 1992 - no mention in codebook that the number is reported in (000s), but (1) an average value of 5,640 makes much more sense than 5.64 and (2) in prior years the variable was reported in (000s)*/
	replace mfgavear=mfgavear*1000
	rename ma15092d mfgwages /*total manufacturing payroll ($000,000s), 1992 - no mention in codebook that the number is reported in ($000,000s), but (1) an average value of $173 million makes much more sense than $173 and (2) in prior years the variable was reported in ($000,000s)*/
	replace mfgwages=mfgwages*1000000
	rename ma30092d mfgvalad /*total manufacturing value added ($000,000s), 1992 - no mention in codebook that the number is reported in ($000,000s), but (1) an average value of $438 million makes much more sense than $438 and (2) in prior years the variable was reported in ($000,000s)*/
	replace mfgvalad=mfgvalad*1000000
	/*sort for upcoming merges*/
	sort fips
	drop if fips==.
	merge 1:1 fips using `icpsr_1992_1'
	drop _merge
	sort fips
	merge 1:1 fips using `icpsr_1992_2'
	drop _merge
	/*create year variable*/
	gen year=1992
	/*sort and save for appending with panel*/
	sort fips
	save `icpsr_1992', replace
	clear

	
*** 1997 ***
	/*import 1997 datafile*/
	use 02896-0081-Data.dta
	/*keep only the county-level observations*/
	keep if level==1
	/*keep only the variables we want*/
	keep fips b10_agr01 b10_agr06 b10_agr09 b10_agr10 b10_agr13 b10_agr15 b1_pop03
	/*rename the variables to be consistent with other years in panel*/
	rename b10_agr01 farms /*number of farms, 1997*/
	rename b10_agr06 acres /*total acres in farms (000s), 1997*/
	replace acres=acres*1000
	rename b10_agr09 accrop /*total cropland acres (000s), 1997*/
	replace accrop = accrop*1000
	rename b10_agr10 fprodval /*value of all farm products sold ($000s), 1997*/
	replace fprodval = fprodval*1000
	rename b10_agr13 crop_percent /*percent of value of all farm products sold ($000s) in crops, 1997*/
	rename b10_agr15 livestock_percent /*percent of value of all farm products sold ($000s) in livestock, 1997*/
	rename b1_pop03 totpop /*total population, 4/1/2000*/
	/*create year variable*/
	gen year=1997
	/*sort for append with other years in panel*/
	sort fips
	drop if fips==.
	save `icpsr_1997', replace
	clear


**************************************************************************************	
****																			******	
****	Merge Great Plains and ICPSR data for each year							******
****	Append all years to create the panel (obs: county-year pairs)			******
****																			******
**************************************************************************************


*merge plains and ICPSR data for each year
foreach y in 1910 1920 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
	use `plains_`y''
	merge 1:1 fips using `icpsr_`y''
	save ``y'', replace
	clear
}

*append all of the years
use `1910'
append using `1920'
append using `1930'
append using `1940'
append using `1945'
append using `1950'
append using `1954'
append using `1959'
append using `1964'
append using `plains_1925' /*no accompanying ICPSR data, so all we have is Plains data*/
append using `plains_1935' /*no accompanying ICPSR data, so all we have is Plains data*/
append using `1969'
append using `1974'
append using `1978'
append using `1982'
append using `1987'
append using `1992'
append using `1997'

*compress the data to save memory, then save the data
compress
save `uncleaned', replace
clear


**************************************************************************************	
****																			******	
****	Clean the panel dataset 												******
****																			******
**************************************************************************************


*** IDs ***
	/*bring in uncleaned panel dataset*/	
	use `uncleaned'
	sort fips year
	/*drop unnecessary variables*/
	drop unyear state county _merge
	/*drop observations with no fips*/
	drop if fips==.
	/*create state code*/
	gen state = floor(fips/1000)
	
*** County area ***
	replace areaac /*county acres, 1910*/ = are_xx_a /*land area, acres*/ if areaac==.
	rename areaac county_acres
	
*** Farmland ***
	/*Correct some errors in the plains data (appear to be others, give priority to ICPSR data)*/
	replace fml_tx_a /*tenant acres*/ = acten /*tenant acres, 1930*/ if acten!=.
	/*fix 1910 total farm acres*/
	replace fml_xx_a /*land in farms*/ = . if year==1910
	replace fml_xx_a = 	fml_tx_a /*acres in tenant farms*/ + fml_of_a /*acres in fully owned farms*/ + fml_mx_a /*acres in managed farms*/ if year==1910 & (fml_tx_a!=. & fml_of_a!=. & fml_mx_a!=.)
	/*fix fully and part owned acres variable for Texas in 1935, may be other errors in 1935*/
	replace fml_of_a=. if year==1935 & state==48
	replace fml_op_a=. if year==1935 & state==48
	
	/*for those counties with no ICPRS data, use Plains data acres*/
		/*total farmland acres*/
		replace acres = fml_xx_a if acres==.
		rename acres farmland
		/*farm acres owned*/
		replace acresown=fml_of_a if (year==1910|year==1920) & acresown==.
		replace fml_of_a=. if year==1910 | year==1920
		replace acfown /*acres in full owner farms*/= fml_of_a if acfown==.
		rename acfown farmland_fullown
		/*part-owned acres*/
		replace acpown = fml_op_a if acpown==.
		rename acpown farmland_partown
		replace acresown=farmland_fullown+farmland_partown if acresown==.
		rename acresown farmland_own
		/*managed acres*/
		replace acman = fml_mx_a if acman==.
		rename acman farmland_manager
		/*tenant acres*/
		replace acten = fml_tx_a if acten==.
		rename acten farmland_tenant
	/*create new farmland variable as the sum of all of the acres owned, managed, and tenant*/
	replace farmland = farmland_own + farmland_tenant + farmland_manager if farmland_own!=. & farmland_tenant!=. & farmland_manager!=. & farmland==.
																			
*** Cropland and other land ***
	/*when plains data are missing, populate with ICPRS data*/
		/*fallow or idle land*/
		replace crp_gx_a /*cropland idle or fallow*/ = acidle /*number of acres idle or fallow*/ if crp_gx_a==.
		rename crp_gx_a cropland_fallow
		replace cropland_fallow = flw_cx_a /*cropland fallow in summer*/ if cropland_fallow==.
		/*failed cropland*/
		replace fal_xx_a /*acres of failed cropland*/ =acfailur /*acres of failed cropland, 1930*/ if fal_xx_a==.
		rename fal_xx_a cropland_fail
		/*harvest cropland*/
		replace crh_xx_a /*harvest cropland*/ = acharves /*harvest cropland, 1930*/ if crh_xx_a==.
		rename crh_xx_a cropland_harvested
		rename hacten cropland_harvested_tenant /*harvest cropland in tenant acres, 1930*/
		/*cropland used for only pasture or grazing*/
		replace crp_qx_a /*cropland used for only pasture or grazing*/ = accrpast /*cropland used for only pasture or grazing*/ if crp_qx_a==.
		rename crp_qx_a pasture_cropland
		replace pasture_cropland=accrpast if pasture_cropland==.
		/*other cropland, not harvested or pasture*/
		replace crp_ex_a /*other cropland, not harvested or pasture*/ = cropland_fallow + cropland_fail if year==1925
		replace crp_ex_a=accrout /*other cropland, not harvested or pasture*/ if crp_ex_a==.
		replace crp_ex_a=crp_eo_a /*other cropland*/ if year==1954
		gen cropland = cropland_harvested+crp_ex_a
		/*pasture land*/
		gen pasture=acpastur /*total acres of pasture land*/
		replace pasture=pst_xx_a /*pastureland, all types*/ if pasture==.
		gen pasture_other = pasture-pasture_cropland
		/*woodland*/
		replace wod_xx_a /*total woodland*/= acwoods /*total acres in woodlands*/ if wod_xx_a==. & year!=1930
		replace wod_qx_a /*woodland pasture*/ = acwoodpa /*number of acres in woodland pasture*/ if wod_qx_a==.
		replace wod_wx_a /*woodland non-pasture*/ = acwoodnp /*woodland non-pasture*/ if wod_wx_a==.
		rename wod_xx_a woodland
		rename wod_qx_a woodland_pasture
		rename wod_wx_a woodland_nonpasture
		/*all other acres (e.g. non pasture, harvest, wood) on farms*/ 
		replace acoth /*number of other farm acres*/ = acothlan /*numbers of acres of other land on farms*/ if acoth==.
		replace acoth=farmland-cropland-pasture-woodland_nonpasture if acoth==.
		rename acoth farmland_other

	/*use 1935 and 1945 average values for missing 1940 values*/
	sort fips year
	by fips: replace farmland_other = (farmland_other[_n-1]+farmland_other[_n+1])/2 if year==1940
	by fips: replace woodland_nonpasture = (woodland_nonpasture[_n-1]+woodland_nonpasture[_n+1])/2 if year==1940
	replace pasture = farmland-cropland-woodland_nonpasture-farmland_other if year==1940
	replace pasture_other = pasture-pasture_cropland if year==1940

	
*** Land values ***
	/*Calculate based on per-farm data, when available. Documentation says the units are dollars, but it's clearly thousands
	  Note: no data available in 1997*/
	replace avfarval = avfarval*1000 if year==1964 /*pre-1000 multiply, the average is 61*/
	replace farmval = avfarval*farms if year==1964 | year==1987 | year==1992
	
	/*Calculate using per-farm data first*/ 
	gen double value_landbuildings_farm=.
		/*1910: variable excluded buildings*/
		replace value_landbuildings_farm = farmval+farmbui if year==1910
		/*1920 and 1930: variable did not exist*/
		replace value_landbuildings_farm = landval+farmbui if year==1930 | year==1920
		/*1940-1992: variable existed as defined*/ 
		replace value_landbuildings_farm = farmval if year>=1940 & year<=1992
		
	/*save dataset*/
	save `pre_landvalue', replace
	clear
		
	/*Calculate using per-acre data when per-farm data unavailable*/
		/*Bring in value of land and buildings per-acre from US Census of Agriculture*/
		use farmval.dta
		/*keep only county-level observations*/
		keep if level==1
		/*fix fips and county codes*/
			/*Neosho county, KS has the incorrect fips-- it has Ness county, KS fips*/
			replace county=1330 /*ICPSR county code*/ if fips==20135 /*Ness county, KS*/
			replace fips=20133 if fips==20135
			replace county=1350 if name=="NESS" & fips==20137
			replace fips=20135 if name=="NESS" & fips==20137
			/*Jackson, GA erroneously has fips of Henry, GA*/
			replace county=1570 if name=="JACKSON" & fips==13151
			replace fips=13157 if name=="JACKSON" & fips==13151
		/*keep only the variables we need*/
		drop region1 region2 level state county name
		/*transpose data to have fips, year, and farmval as variables*/
		reshape long faval, i(fips) j(year)
		/*fix year variable*/
		replace year=1000+year
		/*sort and save for upcoming merge*/
		sort fips year
		save `farmval_temp', replace
		clear
		/*merge with master dataset*/
		use `pre_landvalue'
		sort fips year
		merge 1:1 fips year using `farmval_temp'
		drop _merge
		/*replace average value per farm acre with US Census Ag data if it's missing from ICPRS (master) data*/
		replace avacrval = faval if avacrval==.
		/*create total farm value using the acres variables*/
		gen double value_landbuildings_acre=.
			/*1910: sum of property and buildings*/
			replace value_landbuildings_acre = farmval+farmbui if year==1910
			/*1920, 1930: sum of property and buildings*/
			replace value_landbuildings_acre = landval+farmbui if year==1930|year==1920
			/*1940, 1945: farmval variable already incorporates buildings and land*/
			replace value_landbuildings_acre = farmval if year>=1940 & year<=1945
			/*1950-1992, 1925, 1935: average value per acre * acres of farmland*/
			replace value_landbuildings_acre = avacrval*farmland if year>=1950 & year<=1992
			replace value_landbuildings_acre = avacrval*farmland if year==1925 | year==1935
		/*replace the per-farm value variable for 1925 and 1935*/	
		replace value_landbuildings_farm = avacrval*farmland if year==1925|year==1935
		/*drop fips for which there's no additional data*/
		drop if fips==0|fips==.|fips==56998|fips==11010|fips==2000
	/*sort*/
	sort fips year
	/*fix value of buildings on farms variables*/
	rename farmbui value_buildings
	/*create land value (excluding buildings) variable*/
	gen double value_land = value_landbuildings_acre-value_buildings
	
	/*create farm value variable that's the average of the per-farm and per-acre values*/
	gen value_landbuildings = (value_landbuildings_acre+value_landbuildings_farm)/2
	rename favalten /*total value of farmland and buildings on tenant farms*/ value_landbuildings_tenant

*** Farms ***
	/*If Plains data are missing number of farms, the replace the value with ICPRS number*/
	replace frm_xx_q=farms if frm_xx_q==.
	drop farms
	rename frm_xx_q farms
	
	/*If ICPRS data are missing on number of farms owned, replace with Plains data*/
	replace farmown = frm_of_q if (year==1910|year==1920) & farmown==.
	replace frm_of_q=. if year==1910|year==1920
	replace frm_of_q = farmfown if frm_of_q==.
	rename frm_of_q farms_fullown

	/*If Plains data are missing number of part-owned farms, the replace the value with ICPRS number*/
	replace frm_op_q = farmpown if frm_op_q==.
	rename frm_op_q farms_partown

	/*create total number of farms owned*/
	gen farms_own = farmown
	replace farms_own = farms_fullown+farms_partown if farms_own==.

	/*If Plains data are missing number of managed farms, the replace the value with ICPRS number*/
	replace frm_mx_q = farmman if frm_mx_q==.
	rename frm_mx_q farms_manager
	
	/*If Plains data are missing number of tenant farms, the replace the value with ICPRS number*/
	replace frm_tx_q = farmten if frm_tx_q==.
	rename frm_tx_q farms_tenant
	replace farms_tenant = percent_tenant*farms/100 if farms_tenant==.

*** Population ***
rename totpop population
rename urban population_urban
gen population_rural = population-population_urban
gen population_farm = farmpop
replace population_farm = rurfarm+urbfarm if population_farm==.

*** Employment ***
	/*Gainfully employed workers in 1930*/
	rename gainwrk /*number of gainfully employeed workers, 1930*/ employed
	/*Employed in 1940, over 14, including regular and emergency*/
	gen employed_male = m14emp /*number of employed males 14+, 1940*/ + m14emerg /*number of males 14+ employed in emergency public service work, 1940*/
	gen employed_female = f14emp + f14emerg
	/*Employed in 1950*/
	replace employed_male = memp /*number of males employed, 1950*/ if employed_male==.
	replace employed_female = femp if employed_female==.
	replace employed = employed_male+employed_female if employed==.
	
*** Unemployment ***
	/*Unemployed in 1930 (out of a job, able to work, and looking), including those with a job and on lay-off without pay*/
	gen unemployed = totunemp /*total unemployed workers, 1930*/ + tolayoff /*total laid-off workers, 1930*/
	gen unemployed_male = munemp + mlayoff
	gen unemployed_female = funemp + flayoff
	/*Unemployed in 1940 (and seeking), over 14*/
	replace unemployed_male = m14seek /*males 14+ seeking work, 1940*/ if unemployed_male==.
	replace unemployed_female = f14seek if unemployed_female==.
	/*Unemployed in 1950, over 14*/
	replace unemployed_male = unempm14 if unemployed_male==.
	replace unemployed_female = unempf14 if unemployed_female==.
	replace unemployed = unemployed_male+unemployed_female if unemployed==.

*** Manufacturing Industry ***
rename mfgestab manufacturing_establishments
rename mfgavear manufacturing_workers
/*average manufacturing salary*/
gen manufacturing_salary = mfgwages/manufacturing_workers
rename mfgvalad manufacturing_valueadded
replace manufacturing_valueadded = mfgout /*value of manufacturing output*/ - mfgrms /*COGS at manufacturing establishments*/ if manufacturing_valueadded==.

*** Retail Sales ***
rename retsales retail_sales

*** Farm equipment ***
replace farmequi /*value of equipment farms*/=imp_xx_v /*estimated mkt value of all farm machinery and equipment*/ if farmequi==.
replace eqvalten /*value of equipment on tenant farms*/=imp_tx_v /*total value of farm implements*/ if eqvalten==.
rename farmequi equipment
rename eqvalten equipment_tenant

*** Crop Acreages and Production ***
rename crn_gh_a /*acres of corn for grain or seed*/ corn_grain_a
rename crn_gh_b /*bushels of corn for grain or seed*/ corn_grain_y
rename crn_sh_a /*acres of corn for silage or green crop*/ corn_silage_a
rename crn_sh_t /*tons of corn for silage or green crop*/ corn_silage_y
rename wht_xh_a /*acres of wheat for grain*/ wheat_a
rename wht_xh_b /*bushels of wheat for grain*/ wheat_y
rename hay_xh_a /*acres of hay*/ hay_a
rename hay_xh_t /*tons of hay*/ hay_y
rename cot_xh_a /*acres of cotton*/ cotton_a
rename cot_xh_c /*bales of cotton*/ cotton_y
rename oat_xh_a /*acres of oats for grain*/ oats_a
rename oat_xh_b /*bushels of oats for grain*/ oats_y
rename bar_xh_a /*acres of barley for grain*/ barley_a
rename bar_xh_b /*bushels of barley for grain*/ barley_y
rename rye_xh_a /*harvested acres of rye for grain*/ rye_a
rename rye_xh_b /*harvested bushels of rye for grain*/rye_y

*** Livestock inventory ***
rename ctl_xx_q /*number of cattle and calves*/ cows
rename swn_xx_q /*number of pigs and hogs*/ pigs
rename chk_xx_q /*number of chickens*/ chickens


*** Value of Crops, Animal Products, and Total Revenue ***
	/*value of all crops*/
	replace value_crops = crop_percent*fprodval/100 if (year==1940|year==1945|year==1982|year==1997)&value_crops==.
	replace value_crops = cro_tx_v /*market value of all crops*/ if value_crops==.
	replace value_crops = cro_xx_v /*market value of all crops, including nursery and green crops*/ if value_crops==.
	replace value_crops = cropval /*value of all crops*/ if value_crops==.

	/*value of all animal products*/
	egen value_animalproducts = rsum(animrec /*receipt from sale of animals, 1909*/ livslval /*value of animals slaughtered, 1909*/ dairyrec /*receipt from sale of dairy products, 1909*/ pouprrec /*receipt from sale of poultry and eggs, 1909*/ hwaxval /*value of honey and wax produced, 1909*/ woolval /*value of wool produced, 1909*/) if year==1910
	replace value_animalproducts = stk_tc_v /*market value of livestock and poultry*/ if (year==1950|year==1954|year==1959)
	replace value_animalproducts = value_livestock+value_dairy+value_poultry if (year==1950|year==1954|year==1959)&value_animalproducts==.
	replace value_animalproducts = stk_tc_v if year>=1964&value_animalproducts==.
	replace value_animalproducts = livestock_percent*fprodval/100 if (year==1940|year==1945|year==1982|year==1997)&value_animalproducts==.
	replace value_animalproducts = value_livestock if year>=1964&value_animalproducts==.
	gen value_dairypoultry = stk_tc_v-stk_te_v /*value of livestock except dairy and poultry*/
	replace value_dairy = dairyrec if year==1910
	replace value_poultry = pouprrec if year==1910
	replace value_dairypoultry = value_dairy+value_poultry if value_dairypoultry==.
	replace value_animalproducts = value_livestock+value_dairypoultry if value_animalproducts==.

	/*combined value of crops and animal products*/
	rename fprodval value_all
	replace value_all = value_crops+value_animalproducts if value_all==.

	/*for those years without data (i.e. 1920, 1925, 1930), interpolate*/
		/*generate flow/stock ratio for 1910, 1940 and use to interpolate for 1920, 1925, 1930*/
		replace livstock = stk_xx_v /*total value of domestic animals*/ if livstock==.
		/*create variable for animal products as a percent of all livestock value for 1910 and 1940*/
		gen animalproducts_percent_10 = value_animalproducts/livstock if year==1910
		gen animalproducts_percent_40 = value_animalproducts/livstock if year==1940
			/*assign the percent to all years for each fips*/
			sort fips
			by fips: egen animalproducts_percent_1910 = max(animalproducts_percent_10)
			by fips: egen animalproducts_percent_1940 = max(animalproducts_percent_40)
		/*create substitute animal products using 1940 data and assign the value to 1910, 1920, 1925, and 1930*/ 
		gen value_animalproducts_base1940 = livstock*animalproducts_percent_1940 if year==1920|year==1925|year==1930|year==1910
		/*create substitute animal products using weighted average of 1910 and 1940 data, weights based on year*/
		 	/*assign equal average to midpoint year, 1925*/
			gen value_animalproducts_mix = livstock*(.5*animalproducts_percent_1910+.5*animalproducts_percent_1940) if year==1925
			/*assign 1940-heavy average to 1930*/ 
			replace value_animalproducts_mix = livstock*((1/3)*animalproducts_percent_1910+(2/3)*animalproducts_percent_1940) if year==1930
			/*assign 1910-heavy average to 1920*/ 
			replace value_animalproducts_mix = livstock*((2/3)*animalproducts_percent_1910+(1/3)*animalproducts_percent_1940) if year==1920
		replace value_animalproducts = value_animalproducts_mix if year == 1920|year==1925|year==1930
		replace value_all = value_crops+value_animalproducts if year==1920|year==1925|year==1930

*** Government program expenditures ***
rename gvt_xx_v /*total received government payments*/ government_allmoney
rename gvt_xc_v /*received government payments- CRP and WRP*/ government_crpmoney


*** keep only the cleaned variables that we need for the 1910 border analysis
keep state fips year name county_acres farmland farmland_own farmland_fullown farmland_partown farmland_manager farmland_tenant cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_acre value_landbuildings_farm value_landbuildings_tenant value_land value_buildings farms	farms_own farms_fullown farms_partown farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural population_urban employed employed_male employed_female unemployed unemployed_male unemployed_female manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts	value_animalproducts_base1940 livstock barley_a barley_y corn_grain_a corn_grain_y corn_silage_a corn_silage_y oats_a oats_y rye_a rye_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y pigs chickens cows government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins
					
order state fips year name county_acres farmland farmland_own farmland_fullown farmland_partown farmland_manager farmland_tenant cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_acre value_landbuildings_farm value_landbuildings_tenant value_land value_buildings farms	farms_own farms_fullown farms_partown farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural population_urban employed employed_male employed_female unemployed unemployed_male unemployed_female manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts	value_animalproducts_base1940 livstock barley_a barley_y corn_grain_a corn_grain_y corn_silage_a corn_silage_y oats_a oats_y rye_a rye_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y pigs chickens cows government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins
compress
save `DustBowl_clean', replace
clear

**************************************************************************************	
****																			******
****	Adjust county borders 													******
****																			******
**************************************************************************************

*save individual year datasets with fips renamed "id"
foreach year of numlist 1910 1920 1925 1930 1935 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
	use `DustBowl_clean'
	keep if year == `year'
	rename fips id
	sort id
	save `DustBowl_clean_`year'', replace
	clear
}

**************************************************************************************
*** Years for which we have county border data in GIS (i.e. Round number years)		**
**************************************************************************************

foreach year of numlist 1920 1930 1940 1950 {
	/*bring in county-level area data created from ARC-GIS*/
	insheet using Export_`year'1910.txt, tab
	/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
	keep if state==state_1
	/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
	gen percent = new_area /*area of intersected piece county*/ /area /*total area of base county*/
	/*sort by county id (i.e. state-county pairs)*/
	sort id
	rename state state_name
	rename state_1 state_1_name
	/*merge the pieces data with the clean DB data*/
	merge m:1 id using `DustBowl_clean_`year''
	
	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since the old one got knocked out with the aggregation*/
	gen year_1 = `year'
	/*save for the upcoming append*/
	save `DustBowl_clean_`year'1910', replace
	clear
}

*******************************************************************************************
*** Years for which we have DO NOT have county border data in GIS 						***
*** 																					***
*** For these years, we define county boundaries separately for each county. We define	***
*** them as the Census boundaries pertaining to either (1) the most recent Census (e.g. ***
*** 1940 for 1945) or (2) the most recent subsequent Census (e.g. 1950 for 1945). We 	***
*** choose the boundaries that provide a county area most similar to the county area	***
*** we have from the ICPRS data. 														***	
*******************************************************************************************

*** 1925 ***
	/*create data using the earlier borders (1920)*/
		/*import boundary matching file*/
		insheet using Export_19201910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*merge the pieces data with the clean DB data*/
		rename state state_name
		rename state_1 state_1_name
		merge m:1 id using `DustBowl_clean_1925'
	
	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1925
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19251910_1', replace
	clear

	
	/*Create data using the later borders (1930)*/
		/*import boundary matching file*/
		insheet using Export_19301910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1925'
		
	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1925
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	save `DustBowl_clean_19251910_2', replace
	clear

		
*** 1935 ***
	/*Create data using the earlier borders (1930)*/
		/*import boundary matching file*/
		insheet using Export_19301910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/
		merge m:1 id using `DustBowl_clean_1935'
		
	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1935
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19351910_1', replace
	clear

	/*Create data using the later borders (1940)*/
		/*import boundary matching file*/
		insheet using Export_19401910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/
		merge m:1 id using `DustBowl_clean_1935'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1935
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19351910_2', replace
	clear
		
*** 1945 ***
	/*Create data using the earlier borders (1940)*/
		/*import boundary matching file*/
		insheet using Export_19401910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1945'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1945
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19451910_1', replace
	clear

	/*Create data using the later borders (1950)*/
		/*import boundary matching file*/
		insheet using Export_19501910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1945'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1945
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19451910_2', replace
	clear

*** 1954 ***
	/*Create data using the earlier borders (1950)*/
		/*import boundary matching file*/
		insheet using Export_19501910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1954'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1954
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19541910_1', replace
	clear

	/*Create data using the later borders (1960)*/
		/*import boundary matching file*/
		insheet using Export_19601910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1954'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1954
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19541910_2', replace
	clear


*** 1959 ***
	/*Create data using the earlier borders (1950)*/
		/*import boundary matching file*/
		insheet using Export_19501910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1959'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}
	
	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1959
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19591910_1', replace
	clear

	/*Create data using the later borders (1960)*/
		/*import boundary matching file*/
		insheet using Export_19601910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1959'
		
	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1959
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19591910_2', replace
	clear


		
*** 1964 ***
	/*Create data using the earlier borders (1960)*/
		/*import boundary matching file*/
		insheet using Export_19601910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/
		merge m:1 id using `DustBowl_clean_1964'
				
	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1964
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19641910_1', replace
	clear


	/*Create data using the later borders (1970)*/
		/*import boundary matching file*/
		insheet using Export_19701910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/
		merge m:1 id using `DustBowl_clean_1964'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1964
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19641910_2', replace
	clear

*** 1969 ***
	/*Create data using the earlier borders (1960)*/
		/*import boundary matching file*/
		insheet using Export_19601910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/
		merge m:1 id using `DustBowl_clean_1969'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}
	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1969
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19691910_1', replace
	clear

	
	/*Create data using the later borders (1970)*/
		/*import boundary matching file*/
		insheet using Export_19701910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/
		merge m:1 id using `DustBowl_clean_1969'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1969
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19691910_2', replace
	clear


*** 1974 ***
	/*Create data using the earlier borders (1970)*/
		/*import boundary matching file*/
		insheet using Export_19701910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		rename state state_name
		rename state_1 state_1_name
		/*merge the pieces data with the clean DB data*/		
		merge m:1 id using `DustBowl_clean_1974'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1974
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19741910_1', replace
	clear

			
	/*Create data using the later borders (1980)*/
		/*import boundary matching file*/
		insheet using Export_19801910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1974'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1974
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19741910_2', replace
	clear


*** 1978 ***
	/*Create data using the earlier borders (1970)*/
		/*import boundary matching file*/
		insheet using Export_19701910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/	
		merge m:1 id using `DustBowl_clean_1978'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}
	
	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1978
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19781910_1', replace
	clear

	
	/*Create data using the later borders (1980)*/
		/*import boundary matching file*/
		insheet using Export_19801910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1978'
				
	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1978
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19781910_2', replace
	clear


*** 1982 ***
	/*Create data using the earlier borders (1980)*/
		/*import boundary matching file*/
		insheet using Export_19801910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1982'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}
		
	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1982
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19821910_1', replace
	clear

	/*Create data using the later borders (1990)*/
		/*import boundary matching file*/
		insheet using Export_19901910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1982'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1982
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19821910_2', replace
	clear

		
*** 1987 ***
	/*Create data using the earlier borders (1980)*/
		/*import boundary matching file*/
		insheet using Export_19801910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1987'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1987
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19871910_1', replace
	clear

	
	/*Create data using the later borders (1990)*/
		/*import boundary matching file*/
		insheet using Export_19901910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1987'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1987
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19871910_2', replace
	clear


*** 1992 ***
	/*Create data using the earlier borders (1990)*/
		/*import boundary matching file*/
		insheet using Export_19901910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1992'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}
	
	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1992
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19921910_1', replace
	clear

	/*Create data using the later borders (1999)*/
		/*import boundary matching file*/
		insheet using Export_20001910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1992'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}
	
	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1992
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19921910_2', replace
	clear

		
*** 1997 ***
	/*Create data using the earlier borders (1990)*/
		/*import boundary matching file*/
		insheet using Export_19901910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*assign to each intersected piece (i.e. each row) the fraction of the base county it comprises*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1997'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1997
	/*create flag for fact that is from the earlier Census boundary year*/
	gen census = 1
	/*save for upcoming append*/
	save `DustBowl_clean_19971910_1', replace
	clear

	/*Create data using the later borders (1999)*/
		/*import boundary matching file*/
		insheet using Export_20001910.txt, tab
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		keep if state==state_1
		/*drop intersections that assign a piece of the county to another state- this is due to overlay error*/
		gen percent = new_area/area
		/*sort by county-state pairs*/
		sort id
		/*rename state and state_1 since the panel dataset has a "state" variable that's the numeric state code, 
		  so a merge requires different names for different types of variables*/
		rename state state_name
		rename state_1 state_1_name
		/*merge boundaries data with panel data*/
		merge m:1 id using `DustBowl_clean_1997'

	/*assign to each piece of each county (i.e. each row) the fraction of the county's value for each variable that comes from the piece*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = `var'*percent
	}

	/*if the value is missing and the piece makes up at least 1% of the county, assign the piece's contribution a huge
	  negative number so that when we aggregate by county, we can replace the variable with a "." whenever a substantial piece
	  (i.e. more than 1%) has missing data*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = -100000000000000000000000 if `var'==. & percent>0.01
	}

	/*aggregate the data by 1910 (the new base year) fips*/
	collapse (sum) county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins, by(id_1)

	/*replace with a "." all county values that are negative (i.e. had a 1%+ piece with missing data) contribute to the aggregation*/
	foreach var of varlist 	county_acres farmland farmland_own farmland_tenant farmland_manager cropland cropland_harvested cropland_harvested_tenant cropland_fail cropland_fallow pasture pasture_cropland pasture_other woodland woodland_pasture woodland_nonpasture farmland_other value_landbuildings value_landbuildings_tenant value_land value_buildings farms farms_own farms_manager farms_tenant equipment equipment_tenant population population_farm population_rural employed unemployed manufacturing_establishments manufacturing_workers manufacturing_salary manufacturing_valueadded retail_sales value_all value_crops value_animalproducts value_animalproducts_base1940 livstock corn_grain_a corn_grain_y corn_silage_a corn_silage_y wheat_a wheat_y hay_a hay_y cotton_a cotton_y oats_a oats_y barley_a barley_y rye_a rye_y cows pigs chickens government_allmoney government_crpmoney pcpubwor pcaaa pcrelief pcndloan pcndins {
		replace `var' = . if `var' < 0
	}

	/*format id as number*/
	format id_1 %05.0f
	/*re-create year variable since it was lost in the aggregation*/
	gen year_1 = 1997
	/*create flag for fact that is from the later Census boundary year*/
	gen census = 2
	/*save for upcoming append*/
	save `DustBowl_clean_19971910_2', replace
	clear


**************************************************************************************
*** 	Stack the yearly county-boundary-adjusted data 							******
**************************************************************************************

*stack data
use `DustBowl_clean_1910'
rename id id_1
rename year year_1
append using `DustBowl_clean_19201910'
append using `DustBowl_clean_19251910_1'
append using `DustBowl_clean_19251910_2'
append using `DustBowl_clean_19301910'
append using `DustBowl_clean_19351910_1'
append using `DustBowl_clean_19351910_2'
append using `DustBowl_clean_19401910'
append using `DustBowl_clean_19451910_1'
append using `DustBowl_clean_19451910_2'
append using `DustBowl_clean_19501910'
append using `DustBowl_clean_19541910_1'
append using `DustBowl_clean_19541910_2'
append using `DustBowl_clean_19591910_1'
append using `DustBowl_clean_19591910_2'
append using `DustBowl_clean_19641910_1'
append using `DustBowl_clean_19641910_2'
append using `DustBowl_clean_19691910_1'
append using `DustBowl_clean_19691910_2'
append using `DustBowl_clean_19741910_1'
append using `DustBowl_clean_19741910_2'
append using `DustBowl_clean_19781910_1'
append using `DustBowl_clean_19781910_2'
append using `DustBowl_clean_19821910_1'
append using `DustBowl_clean_19821910_2'
append using `DustBowl_clean_19871910_1'
append using `DustBowl_clean_19871910_2'
append using `DustBowl_clean_19921910_1'
append using `DustBowl_clean_19921910_2'
append using `DustBowl_clean_19971910_1'
append using `DustBowl_clean_19971910_2'

*rename id fips
rename id_1 fips

*rename year variable created in boundary steps
rename year_1 year

*sort panel by county then year
sort fips year

*fill down - i.e. assign same value to all years within a county
	/*state code*/
	by fips:  replace state = sum(state)
	/*county name*/
	by fips:  replace name = name[_n-1] if name[_n-1]!=""
	
*order variables for viewing purposes	
order state fips name year census county_acres

*create a single observation for each county-year pair-- the non-Census boundary years still have two observations per county-year pair
	/*sort by county year then Census flag for earlier or later*/
	sort fips year census
	/*calculate the difference in county acres between (1) the acres according to the later Census and (2) the prior year's acres*/
	by fips: gen diff2 = abs(county_acres-county_acres[_n-2]) if census==2
	/*calculate the difference in county acres between (1) the acres according to the earlier Census and (2) the prior year's acres*/
	by fips: gen diff1 = abs(county_acres-county_acres[_n-1]) if census==1
	/*create a single "difference" variable that is the difference between the observation and the prior year's acres*/
	gen diff = diff2
	replace diff = diff1 if diff==.
	drop diff1 diff2
	/*create flag for census=2 observations (later) all observations whose later acreage difference is greater than the earlier 
	acreage difference- we'll want to drop these observations because the acres they calculate are more different from the earlier 
	year's acres than the acres calculated by the earlier census*/
	by fips: gen drop2 = (diff-diff[_n-1]>0.5&census==2)
	/*create flag for census=1 observations (earlier) we want to drop because the census=2 observation (later) provides a closer
	calculation of acreage to the prior year's acreage*/
	by fips: gen drop1 = (drop2[_n+1]==0&census==1)
	/*drop the flagged observations-- i.e. obs whose calculated acreage is further from the previous year's acreage*/
	drop if drop2==1
	drop if drop1==1
	/*drop the variables we used to determine the best boundaries*/
	drop diff census drop2 drop1
	
*drop all observations with no county
drop if fips==.

*save the panel dataset
compress
save `DustBowl_base1910', replace


/*PREPARE WOODLAND INFORMATION*/
	/*we now calculate the fraction of each fips that is in woodland areas*/
	clear
	insheet using woodland_1910.txt, tab
	rename icpsrfip fips
	drop if fips == 0
	replace id = 10 if id==100
	sort fips id 
	by fips: egen tot_area = sum(woodland_area) /*calculate total area of fips by summing the fips-woodland (polygon) areas*/
	by fips id: egen id_area = sum(woodland_area) /*calculate total area of fips in each type of woodland*/
	by fips id: keep if [_n]==1
	
	gen woodland_frac = id_area / tot_area /*calculate fraction of fips in each type of woodland*/
	gen grassland = 0 /*create fraction of county in grasslands*/
	replace grassland = woodland_frac if 	id == 1 | /*Tall grass*/ id == 2 | /*Oak-Hickory*/ id == 3 | /*Short Grass*/ id == 4 | /*Desert Savana*/ id == 9  /*Desert Grassland*/
	by fips: egen frac_grassland_tot = sum(grassland)
	by fips: keep if [_n]==1
	keep fips frac_grassland_tot
	sort fips
	save `woodland_map_1910', replace

/*PREPARE CENTROID INFORMATION*/
	clear
	insheet using centroids_1910.txt, tab
	rename icpsrfip fips
	drop if fips == 0
	sort fips
	save `centroid_map_1910', replace
	
/*PREPARE EROSION INFORMATION*/
	clear
	insheet using erosion_1910.txt, tab
	rename icpsrfip fips
	drop if fips == 0
	sort fips id
	by fips: egen tot_area = sum(erosion_area)
	by fips id: egen id_area = sum(erosion_area)
	gen erosion_medium = id_area/tot_area if id==1
	gen erosion_high = id_area/tot_area if id==2
	by fips: egen m1_1 = max(erosion_medium)
	by fips: egen m1_2 = max(erosion_high)
	replace m1_1 = 0 if m1_1==.
	replace m1_2 = 0 if m1_2==.
	gen m1_0 = 1 - m1_1 - m1_2
	by fips: keep if [_n]==1
	keep fips m1_0 m1_1 m1_2
	sort fips
	save `erosion_map_1910', replace
	clear


/*Merge the datasets together*/
	use `DustBowl_base1910'
	sort fips
	merge m:1 fips using `woodland_map_1910'
	drop _merge
	sort fips
	merge m:1 fips using `centroid_map_1910'
	drop _merge
	sort fips
	merge m:1 fips using `erosion_map_1910'
	drop _merge
	sort fips year
	compress
	save DustBowl_All_base1910.dta, replace
	clear
	
log close
