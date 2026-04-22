*This do-file produces the estimates for Table 7 and Figure 3

*Last Modified 11/30/2009

*This step merges the file containing data on succession (family_succession)with 
*the file containing yearly observations on Capex, Lagged Total Assets and Lagged Market-to-Book 
*Ratios together with data on the isic code and country of incorporation for each 
*firm (capex_assets_mb_data)

cd D:\Research_Inheritance
set mem 900M

use family_succession
sort firmid
save family_succession,replace
use capex_assets_mb_data
sort firmid
merge firmid using family_succession
keep if _merge==3
rename _merge merge1
save family_succession,replace
clear

use indices_inheritance
sort country
save indices_inheritance,replace
use family_succession
sort country
merge country using indices_inheritance
keep if _merge==3
rename _merge merge2
save family_succession, replace
clear



*This step generates results in Table 7

use family_succession
keep if in_family_succession==1
gen succession_period=year-succession_year
gen succession=1 if succession_period>=-1
replace succession=0 if succession==.

gen succession_inheritance=succession*inheritance_law
gen succession_investor1=succession*revised_adr_index
gen succession_inheritance_investor1=succession*inheritance_law*revised_adr_index
gen succession_investor2=succession*anti_selfdealing_index
gen succession_inheritance_investor2=succession*inheritance_law*anti_selfdealing_index
gen succession_investor3=succession*spamann_index
gen succession_inheritance_investor3=succession*inheritance_law*spamann_index
gen succession_investor4=succession*creditor_rights_index
gen succession_inheritance_investor4=succession*inheritance_law*creditor_rights_index
gen log_assets=log(lag_assets)
gen log_mb_ratio=log(lag_mb_ratio)


sort year
egen group_year=group(year)
su  group_year, meanonly
forvalues i=1/`r(max)'{
qui by year: gen year_dummy_`i' = 1 if group_year ==`i'
qui by year: replace year_dummy_`i' =0 if group_year!=`i'
}
drop group_year

save family_succession,replace


areg capex succession succession_investor1 succession_inheritance succession_inheritance_investor1 log_assets log_mb_ratio year_dummy_1-year_dummy_17,absorb(firmid) cluster(firmid)

areg capex succession succession_investor2 succession_inheritance succession_inheritance_investor2 log_assets log_mb_ratio year_dummy_1-year_dummy_17,absorb(firmid) cluster(firmid)

areg capex succession succession_investor3 succession_inheritance succession_inheritance_investor3 log_assets log_mb_ratio year_dummy_1-year_dummy_17,absorb(firmid) cluster(firmid)

areg capex succession succession_investor4 succession_inheritance succession_inheritance_investor4 log_assets log_mb_ratio year_dummy_1-year_dummy_17,absorb(firmid) cluster(firmid)



*This step generates Figure 3

sort succession_period
keep if succession_period>=-5 & succession_period<=8
save family_succession_data
collapse (mean) capex,by(succession_period permissive_inheritance)
rename capex capex_permissive_inh
keep if permissive_inheritance==1
save capex_permissive
clear
use family_succession_data
collapse (mean) capex,by(succession_period strict_inheritance)
rename capex capex_strict_inh
keep if strict_inheritance==1
save capex_strict
sort succession_period
save capex_strict,replace
use capex_permissive
sort succession_period
merge succession_period using capex_strict
save family_succesion_graph


twoway (line capex_strict_inh succession_period) (line capex_permissive_inh succession_period),title("Capex Around Succession") ytitle("Capex in %") xtitle("Years Around Succession")

clear
