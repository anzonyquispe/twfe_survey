/********************************
This file creates a dummy dataset with variable names and senames
to be create output files from withint supplanalysis_spatialse.do
********************************/

clear

****************************
* set up variables here
****************************
local x1 kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0
local x2 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
local xadd d_prop_waterclose d_prop_flush
local district district2 district3 district4 district5 district6 district7 district8 district9 district10

preserve
clear
set obs 100
gen varnames="varnames" in 1
replace varnames="mean_grad_new" in 2
replace varnames = "spse_mean_grad_new" in 3
replace varnames="const" in 4
replace varnames = "spse_const" in 5

local varcount : word count `x1'
local i = 6
local j = 7
local counter=1 
while `counter' < = `varcount' {
	local hold : word `counter' of `x1'
	replace varnames = "`hold'" in `i'
	replace varnames ="spse_`hold'" in `j'
	local i = `i'+2
	local j = `j'+2
	local counter=`counter'+1
}

local varcount : word count `x2'
local counter=1 
while `counter' < = `varcount' {
	local hold : word `counter' of `x2'
	replace varnames = "`hold'" in `i'
	replace varnames ="spse_`hold'" in `j'
	local i = `i'+2
	local j = `j'+2
	local counter=`counter'+1
}

local varcount : word count `district'
local counter=1 
while `counter' < = `varcount' {
	local hold : word `counter' of `district'
	replace varnames = "`hold'" in `i'
	replace varnames ="spse_`hold'" in `j'
	local i = `i'+2
	local j = `j'+2
	local counter=`counter'+1
}

local varcount : word count `xadd'
local counter=1 
while `counter' < = `varcount' {
	local hold : word `counter' of `xadd'
	replace varnames = "`hold'" in `i'
	replace varnames ="spse_`hold'" in `j'
	local i = `i'+2
	local j = `j'+2
	local counter=`counter'+1
}

replace varnames = "cut1" in `i'
replace varnames = "cut2" in `j'
local j = `j'+1
replace varnames = "N" in `j'

drop if varnames==""
gen id=_n
ren varnames mylist
sort id
save "$temp\varnames_ols.dta", replace

replace mylist= "T" if mylist=="mean_grad_new"
replace mylist = "spse_T" if mylist=="spse_mean_grad_new"
sort id
save "$temp\varnames_iv.dta", replace

clear


****************************
* set up variables for md level analysis here
****************************
local x femelec female femtrend

clear
set obs 200
gen varnames="varnames" in 1
replace varnames="mdelec2" in 2
replace varnames = "spse_mdelec2" in 3
replace varnames="trend" in 4
replace varnames = "spse_trend" in 5
replace varnames="const" in 6
replace varnames = "spse_const" in 7

local varcount : word count `x'
local i = 8
local j = 9
local counter=1 
while `counter' < = `varcount' {
	local hold : word `counter' of `x'
	replace varnames = "`hold'" in `i'
	replace varnames ="spse_`hold'" in `j'
	local i = `i'+2
	local j = `j'+2
	local counter=`counter'+1
}

local md=2 
while `md' < = 46 {
	replace varnames = "md`md'" in `i'
	replace varnames ="spse_md`md'" in `j'
	local i = `i'+2
	local j = `j'+2
	local md=`md'+1
}

local mdtrend=2 
while `mdtrend' < = 46 {
	replace varnames = "mdtrend`mdtrend'" in `i'
	replace varnames ="spse_mdtrend`mdtrend'" in `j'
	local i = `i'+2
	local j = `j'+2
	local mdtrend=`mdtrend'+1
}

replace varnames = "cut1" in `i'
replace varnames = "cut2" in `j'
local j = `j'+1
replace varnames = "N" in `j'

drop if varnames==""
gen id=_n
ren varnames mylist
sort id
save "$temp\varnames_ols_md.dta", replace
clear




