clear

local dir1="c:\ag562\research\health\AERfiles"
cd `dir1'


use ads-laws, clear

gen 		rabplace = 1 if abbrev == "ME" | abbrev == "NH" | abbrev == "VT"| abbrev == "MA"| abbrev == "RI"

replace 	rabplace = 2 if abbrev == "NY" | abbrev == "CT" | abbrev == "NJ"| abbrev == "PA"

replace 	rabplace = 5 if abbrev == "WV" | abbrev == "DE" | abbrev == "MD"| abbrev == "DC" | abbrev == "VA" | abbrev == "NC"| abbrev == "SC" | ///
                            abbrev == "GA" | abbrev == "FL"

replace 	rabplace = 6 if abbrev == "KY" | abbrev == "TN" | abbrev == "MS"| abbrev == "AL" 

replace 	rabplace = 7 if abbrev == "OK" | abbrev == "AR" | abbrev == "LA"| abbrev == "TX" 

replace 	rabplace = 3 if abbrev == "WI" | abbrev == "MI" | abbrev == "OH"| abbrev == "IN" | abbrev == "IL" 

replace 	rabplace = 4 if abbrev == "ND" | abbrev == "SD" | abbrev == "NE"| abbrev == "KS" | abbrev == "MN" | abbrev == "IA"| abbrev == "MO" 

replace 	rabplace = 8 if abbrev == "MT" | abbrev == "ID" | abbrev == "WY"| abbrev == "NV" | abbrev == "UT" | abbrev == "CO"| abbrev == "AZ" | ///
                            abbrev == "NM" 

replace 	rabplace = 9 if abbrev == "WA" | abbrev == "OR" | abbrev == "CA"| abbrev == "AK" | abbrev == "HI" 



collapse (mean) gf ic pp, by (rabplace year)

replace year = year + 1900

keep if year == 1980 | year == 1990


reshape wide gf ic pp, i(rabplace) j(year)
sort rabplace 

save hrs_ins1.dta, replace



