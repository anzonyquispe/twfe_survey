
* In this do file, we extract information on perceptions on donor countrues from Pew
* Global Attitudes Project 2002

use "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\PubPercep\PewGlobal2003\pewgap2003.dta", clear
*keep country psraid quest_id weight q61* q62 q63 q64 q65 q66-q72 q76 q78
keep country psraid quest_id weight q61b q62 q65
cd "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\PubPercep\"
save pewgap2003_short.dta, replace

bysort country: gen count=_N

gen i_61b_favorable=1 if q61b==1 | q61b==2
gen i_61b_count=1 if q61b==1 | q61b==2 | q61b==3 | q61b==4

bysort country: egen sum_61b_favorable=sum(i_61b_favorable)
bysort country: egen count_61b=sum(i_61b_count)

gen pct_61b_favorable=sum_61b_favorable/count

gen w_61b_favorable=weight*i_61b_favorable
bysort country: egen sumw_61b_favorable=sum(w_61b_favorable)
gen pctw_61b_favorable=sumw_61b_favorable/count

replace  pct_61b_favorable_2007=pct_61b_favorable_2007/100
*****************************
* Question 62: Does US Increase of Decrease gap bw rich and poor
******************************

gen i_62_care=1 if q62==1 | q62==2
gen i_62_count=1 if q62==1 | q62==2 | q62==3 | q62==4

bysort country: egen sum_62_care=sum(i_62_care)
gen pct_62_care=sum_62_care/count

gen w_62_care=weight*i_62_care
bysort country: egen sumw_62_care=sum(w_62_care)
gen pctw_62_care=sumw_62_care/count



egen tag=tag(country)
keep if tag==1
keep country pct_* pctw_*

label var pct_61b_favorable "% of people who have favoirable opinion of US"
label var pctw_61b_favorable "weighted % of people who have favoirable opinion of US"
label var pct_62_care "% of people who think US cares about country"
label var pctw_62_care "weighted % of people who think US cares about country"
