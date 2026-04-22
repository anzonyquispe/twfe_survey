**NOTE: things that the user might want to adjust are marked with "*CUSTOM," followed by instructions

clear
capture log close
*cd c:\work\m14
*log using c:\work\m14\wage_gap, replace text  
*cd n:\km619\work\m14
*log using n:\km619\work\m14\wage_gap, replace text  
*use migstructure_final
*use migstructure4
*use migstructure_final_dups_cleaned_with_cons

log using wage_gap, replace text
use migstructure_final_dups_cleaned_with_cons_land
egen stid=group(state)
egen stcst=group(state caste)

*drop data that we won't use
keep if icrisat
keep if cvsq < 100
by stcst, sort: egen castepop = count(pminc)
drop if castepop < 30

* construct education categories from REDS data

gen edcat=1 if ed==0
replace edcat=2 if ed>=1 & ed<=4
replace edcat=3 if ed==5
replace edcat=4 if ed>=6 & ed<=9
replace edcat=5 if ed>=10

* rural wage
gen rw=40.614 if edcat==1
replace rw=49.104 if edcat==2
replace rw=52.571 if edcat==3
replace rw=58.701 if edcat==4
replace rw=109.174 if edcat==5

* real wage-gaps by educational category
gen wage_gap = 49.354-40.614 if edcat==1
replace wage_gap = 62.840-49.104 if edcat==2
replace wage_gap = 65.992-52.571 if edcat==3
replace wage_gap = 74.424-58.701 if edcat==4
replace wage_gap = 163.188-109.174 if edcat==5

* real wage-gaps by educational category (with moving costs)
gen wage_gap_adj = 45.571-40.614 if edcat==1
replace wage_gap_adj = 58.266-49.104 if edcat==2
replace wage_gap_adj = 61.095-52.571 if edcat==3
replace wage_gap_adj = 68.956-58.701 if edcat==4
replace wage_gap_adj = 153.017-109.174 if edcat==5


* construct income-change

gen income_change=(312*wage_gap)/(0.05*landval+312*q15*rw) if mig1 == 1
gen income_change_adj=(312*wage_gap_adj)/(0.05*landval+312*q15*rw) if mig1 == 1

summ income_change, detail
summ income_change_adj, detail

* construct one nu for everyone
* CUSTOM - choose whether you would like to use income gain or adjusted income gain for calculating nu
egen avg_inc_change = mean(income_change)
egen avg_mig = mean(mig1)

* calculate nu for everyone
gen pnu = -ln(avg_mig/2)/ln(1 + avg_inc_change) 

* construct relative income-classes within each caste
* CUSTOM - specify number of relative income groups in the variable ri

quietly bys stcst (pminc q3): gen f=(_n-1)/_N
gen ri = 6
gen inccat=int(f*ri)

gen byte notmig = 0
replace notmig = 1 if mig1 != 1

* collapse into relative income groups
collapse  (count) pop=pminc (mean) pminc pvarinc mig1 pnu (sum) notmig (mean) ptcon = ptconr4, by(stid stcst inccat)

* construct predicted lambda from REDS consumption data
by stcst, sort: gen lamaut = pminc/pminc[_N]
by stcst: gen plam = ptcon/ptcon[_N]
replace plam = lamaut if plam < lamaut
replace plam = 1 if plam > 1


* prepare to generate data for Maple
count
order pop inccat pminc pvarinc mig1 stcst stid pnu notmig plam
sort stid stcst inccat
disp _N/(inccat[_N]+1)

outfile pop inccat pminc pvarinc mig1 stcst stid pnu notmig plam using data, replace wide


save rawdata_wagegap.dta, replace

log close
