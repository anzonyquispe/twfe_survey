clear
local dir1="c:\ag562\research\health\AERfiles"
cd `dir1'

use dyn_st_89_98s1.dta

replace state=state[_n-1] if state==""

drop if sic_title=="Total"

drop if state=="U.S."

gen jlind = sic
recode jlind (700=1) (1000=2) (1500=2) (2000=3) (4000=5) (5000=6) (5200=7)  (6000=8)  (7000=9)  (9900=10)

gen 		rabplace = 1 if state == "Maine" | state == "New Hampshire" | state == "Vermont"| state == "Massachusetts"| state == "Rhode Island"

replace 	rabplace = 2 if state == "New York" | state == "Connecticut" | state == "New Jersey"| state == "Pennsylvania"

replace 	rabplace = 5 if state == "West Virginia" | state == "Delaware" | state == "Maryland"| state == "District of Columbia" | /// 
                            state == "Virginia" | state == "North Carolina"| state == "South Carolina" | state == "Georgia" | state == "Florida"

replace 	rabplace = 6 if state == "Kentucky" | state == "Tennessee" | state == "Mississippi"| state == "Alabama" 

replace 	rabplace = 7 if state == "Oklahoma" | state == "Arkansas" | state == "Louisiana"| state == "Texas" 

replace 	rabplace = 3 if state == "Wisconsin" | state == "Michigan" | state == "Ohio"| state == "Indiana" | state == "Illinois" 

replace 	rabplace = 4 if state == "North Dakota" | state == "South Dakota" | state == "Nebraska"| state == "Kansas" | state == "Minnesota" | ///
                            state == "Iowa"| state == "Missouri" 

replace 	rabplace = 8 if state == "Montana" | state == "Idaho" | state == "Wyoming"| state == "Nevada" | state == "Utah" | ///
                            state == "Colorado" | state == "Arizona" | state == "New Mexico" 

replace 	rabplace = 9 if state == "Washington" | state == "Oregon" | state == "California"| state == "Alaska" | state == "Hawaii" 

*replace rabplace = 11 if state=="U.S." 


drop if jlind==.

gen est_death=death_tot
gen emp_death=death_emp_tot


ren beg_yr year

destring emp_death, replace force
destring yr1_emp_tot, replace force

collapse (sum) est_death emp_death yr1_emp_tot yr1_estabs_tot, by(rabplace year)

gen fsize = yr1_emp/yr1_estabs

replace emp_death = abs(emp_death) 

gen emp_death_r = emp_death/yr1_emp
gen est_death_r = est_death/yr1_est

keep if year==1989
drop year
sort rabplace 

save hrs_newinst.dta, replace

