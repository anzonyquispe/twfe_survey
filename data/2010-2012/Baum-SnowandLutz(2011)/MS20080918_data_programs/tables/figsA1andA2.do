/*** figsA1andA2.do

This do-file creates descriptive graphs of 

white fraction
white & black mean income

as a function of CBD distance and whether an area is inside 
or outside the central school district

***/


clear
set more off
set mem 500m

set matsize 2000

capture log close
log using figsA1andA2.log, replace text


******************** 1. Set up Data and Sample ***************************

*** Establish Sample from the 70 districts panel data
use ../data/dis70panx.dta

*** Basic sample restrictions
keep if major==1
drop if imp==.
replace imp = imp+1900

*** Only keep MSAs that have both central and suburban district regions
drop if area==marea
tab year

keep msa year imp south area marea
compress
sort msa year
save temp.dta, replace

*** Merge onto the tracts data to establish consistent sample
use ../data/tractpanx.dta

** Drop tract area
drop area

** Drop tracts for which we don't know location
drop if cbd_dis==999999
** Drop tracts that are put out in the Pacific Ocean (most of which are prisons with 0 school age pop)
drop if x_coord<-2000000 & y_coord>1350000

** Put cbd-dis in KM
replace cbd_dis = cbd_dis/1000

sort msa year
merge msa year using temp.dta
tab _merge
** Merge=1 is MSAs without major plans, Merge=2 is untracted MSA/years
tab year _merge
keep if _merge==3
drop _merge

*** Fix data a bit and set sample
gen pop = white+black
drop if white+black+other==0

******* Create Same sample as Regressions 
replace publicelemhsw = publicelemw+publichsw if year~=1990
replace publicelemhsb = publicelemb+publichsb if year~=1990
replace privatelemhsw = privatelemw+privatehsw if year~=1990
replace privatelemhsb = privatelemb+privatehsb if year~=1990

replace publicelemhsb = 0 if publicelemhsb==. & pop59b+pop1014b+pop1519b==0
replace publicelemhsb = 0 if publicelemhsb==. & black==0 
replace privatelemhsb = 0 if privatelemhsb==. & pop59b+pop1014b+pop1519b==0
replace privatelemhsb = 0 if privatelemhsb==. & black==0 
replace publicelemhsw = 0 if publicelemhsw==. & pop59w+pop1014w+pop1519w==0
replace publicelemhsw = 0 if publicelemhsw==. & white==0 
replace privatelemhsw = 0 if privatelemhsw==. & pop59w+pop1014w+pop1519w==0
replace privatelemhsw = 0 if privatelemhsw==. & white==0 

*** Restrict sample to tracts with data for both whites and blacks
drop if publicelemhsw==.|publicelemhsb==.

*** Drop MSAs with only 1-6 tracts in city or suburbs in 1990 or 1960
egen obs90 = count(ccdis70) if year==1990 | year==1960, by(msa year ccdis70)
gen badmsa = 0
replace badmsa = 1 if obs90<6
egen BADMSA = max(badmsa), by(msa)
drop if BADMSA==1
drop badmsa BADMSA obs90

*** Drop MSAs with no obs in city or no obs in suburbs in every year
egen maxcc = max(ccdis70), by(msa year)
egen mincc = min(ccdis70), by(msa year)
keep if maxcc==1 & mincc==0

*** Identify MSAs with no data in 1960 
egen minyr = min(year), by(msa)
keep if minyr==1960

*** Record number of MSAs in dataset
sort msa ccdis70 year
by msa ccdis70 year: gen numsamp = _n==1
sort year
by year: tab numsamp ccdis70


**************** 2. Define distance metric ************************

*** Define distance metric using 1990 population CDFs
sort msa year ccdis70 cbd_dis
by msa year ccdis70: gen cumpop = sum(pop) if year==1990
egen sumpop = sum(pop) if year==1990, by(msa year ccdis70)
gen dis = cumpop/sumpop

*** Allocate locations for tracts 1960-1980
sort msa ccdis70 cbd_dis
by msa ccdis70: replace dis = dis[_n-1] if dis==.
replace dis = .001 if dis==.|dis==0

*** Create Dtdis variable which is useful for graphing
gen Dtdis = int(dis*10)/10+.05
replace Dtdis = .95 if Dtdis>1
replace Dtdis = Dtdis+1 if ccdis70==0


**************** 3. Create Variables Appropriate for Graphing *********************

*** Apply appropriate weights for the incomes
egen sumsampw = sum(incdw), by(msa year Dtdis)
egen sumsampb = sum(incdb), by(msa year Dtdis)
replace incw = incw*incdw/sumsampw
replace incb = incb*incdb/sumsampb

#delimit ;

collapse (sum) white black pop incw incb 
(mean) cbd_dis, by(msa south year Dtdis);
#delimit cr

gen fracw = white/pop

**** Observations in each group
table Dtdis year, contents(n pop)


******************* 5. Final Results *******************************

table Dtdis year, contents(mean fracw)
table Dtdis year, contents(mean incw)
table Dtdis year, contents(mean incb)


log close

erase temp.dta

