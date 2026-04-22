clear

*set mem 200m

use statesector, clear


replace year = int(year/100)

gen region31 = 3

replace region31 = 1 if state == "Connecticut" | state=="Maine" | state=="Massachusetts" | state=="New Hampshire" ///
                      | state=="Vermont" | state=="Rhode Island" | state=="New Jersey" | state=="New York" ///
                      | state=="Pennsylvania"

replace region31 = 2 if state=="Illinois" | state=="Indiana" | state=="Michigan" | state=="Ohio" | state=="Wisconsin" ///
                       | state=="Iowa" | state=="Kansas" | state=="Minnesota" | state=="Missouri" | state=="Nebraska" ///
                       | state=="North Dakota" | state=="South Dakota" 

replace region31 = 4 if state=="Arizona" | state=="Colorado" | state=="Idaho" | state=="Montana" | state=="Nevada" ///
                      | state=="New Mexico" | state=="Utah" | state=="Wyoming" | state=="Alaska" | state=="California" ///
                      | state=="Hawaii" | state=="Oregon" | state=="Washington"


gen indcat31 = 1 if sic_d=="Forestry, Fishing, Hunting, and Agriculture Support" | sic_d=="AG. SERVICES, FORESTRY, FISHING" ///
                   | sic_d=="Agriculture, forestry, fishing, & hunting" 

replace indcat31 = 2  if sic_d=="Mining" | sic_d=="MINING"

replace indcat31 = 3  if sic_d=="Construction" | sic_d=="CONSTRUCTION"

replace indcat31 = 4  if sic_d=="Manufacturing" | sic_d=="MANUFACTURING"

replace indcat31 = 5  if sic_d=="Transportation and Warehousing" | sic_d=="Utilities" ///
                       | sic_d=="TRANSPORTATION, COMM., UTILITIES" | sic_d=="Utilities" ///
                       | sic_d=="Transportation & Warehousing"

replace indcat31 = 6  if sic_d=="WHOLESALE" | sic_d=="Wholesale trade"  | sic_d=="Wholesale Trade" 

replace indcat31 = 6  if sic_d=="Retail Trade" | sic_d=="RETAIL" 
                    

replace indcat31 = 7  if sic_d=="Finance and Insurance" | sic_d=="Real Estate and Rental and Leasing" ///
                       | sic_d =="FINANCE, INSURANCE, REAL ESTATE" | sic_d=="Finance & insurance" ///
                       | sic_d=="Real estate & rental & leasing"

replace indcat31 = 8 if sic_d=="Other Services (except Public Administration)" ///
                        | sic_d=="Other services (except public administration)" ///
                        | sic_d=="Auxiliaries, exc corp, subsidiary, & regional managing offices"

replace indcat31 = 4  if sic_d=="Information"

replace indcat31 = 9 if sic_d=="Educational Services" | sic_d=="Health Care and Social Assistance" ///
                        | sic_d=="Educational services" | sic_d=="Health care & social assistance"


replace indcat31 = 10 if sic_d=="Accommodation and Food Services" | sic_d=="Arts, Entertainment, and Recreation" ///
                        | sic_d=="Arts, entertainment, & recreation" | sic_d=="Accommodation & foodservices"

replace indcat31 = 11  if sic_d=="Professional, Scientific, and Technical" ///
                        | sic_d=="Professional, scientific, & technical services" ///
                        | sic_d=="Professional, scientific, & technical services" ///
                        | sic_d=="Professional, Scientific, and Technical Services" ///
                        | sic_d=="SERVICES"


replace indcat31 = 11   if sic_d=="Management of Companies and Enterprises" | sic_d=="Management of companies & enterprises"  ///
                        | sic_d=="Administrative and Support and Waste Management and Remediation Services"  ///
                        | sic_d=="Administrative & support & waste management & remediation serv"



replace indcat31 = 13   if sic_d=="NONCLASSIFIABLE ESTABLISHMENTS"



drop if indcat31==.

save firmsturn, replace


keep if data_type=="Initial year establishments"
destring total, force gen(est_total)

label var est_total "Initial year establishments"

keep year region31 indcat31 est_total sic_des state

sort year region31 indcat31 sic_des state

save firm1, replace


use firmsturn, clear

keep if data_type=="Establishment births"
destring total, force gen(est_births)

label var est_births "Establishment births"

keep year region31 indcat31 est_births sic_des state

sort year region31 indcat31 sic_des state
save firm2, replace

use firmsturn, clear

keep if data_type=="Establishment deaths"
destring total, force gen(est_deaths)

label var est_deaths "Establishment deaths"

keep year region31 indcat31 est_deaths sic_des state
sort year region31 indcat31 sic_des state
save firm3, replace

use firmsturn, clear

keep if data_type=="Initial year employment"
destring total, force gen(emp_total)

label var emp_total "Initial year employment"

keep year region31 indcat31 emp_total sic_des state

sort year region31 indcat31 sic_des state

save firm4, replace


use firmsturn, clear

keep if data_type=="Change in employment due to births"
destring total, force gen(emp_births)

label var emp_births "Change in employment due to births"

keep year region31 indcat31 emp_births sic_des state

sort year region31 indcat31 sic_des state
save firm5, replace


use firmsturn, clear

keep if data_type=="Change in employment due to deaths"
destring total, force gen(emp_deaths)

label var emp_deaths "Change in employment due to deaths"

keep year region31 indcat31 emp_deaths sic_des state
replace emp_deaths=-emp_deaths if year ~= 1998
sort year region31 indcat31 sic_des state
save firm6, replace



sort  year region31 indcat31 sic_des state
merge year region31 indcat31 sic_des state using firm1

tab _m 
drop _m

sort  year region31 indcat31 sic_des state
merge year region31 indcat31 sic_des state using firm2

tab _m 
drop _m

sort  year region31 indcat31 sic_des state
merge year region31 indcat31 sic_des state using firm3

tab _m 
drop _m

sort  year region31 indcat31 sic_des state
merge year region31 indcat31 sic_des state using firm4

tab _m 
drop _m

sort  year region31 indcat31 sic_des state
merge year region31 indcat31 sic_des state using firm5

tab _m 
drop _m




collapse (sum) emp_deaths (sum) emp_births (sum) emp_total ///
         (sum) est_deaths (sum) est_births (sum) est_total, by(year indcat31 region31)

gen emp_death_rate = emp_deaths/emp_total
gen emp_birth_rate = emp_births/emp_total

gen est_death_rate = est_deaths/est_total
gen est_birth_rate = est_births/est_total


gen est_reallo_rate = (est_deaths+est_births)/est_total
gen emp_reallo_rate = (emp_deaths+emp_births)/emp_total




egen id = group(indcat31 region31)








tsset id year

expand 2 if year==2003

bysort id year: gen count = _n

replace year = year+count-1 if count>1

sort id year

sort year indcat31 region31
save firmsall, replace

erase firm1.dta
erase firm2.dta
erase firm3.dta
erase firm4.dta
erase firm5.dta
erase firm6.dta

erase firmsturn.dta

