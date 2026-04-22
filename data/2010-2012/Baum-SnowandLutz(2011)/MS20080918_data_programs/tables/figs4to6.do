clear
set more off
set mem 500m

set matsize 2000

capture log close
log using figs5to7.log, replace text

************ 1.  Establish Sample  **********************

use ../data/dis70panx.dta
keep if major==1
drop if imp==.
replace imp = imp+1900
keep msa year imp south area marea
compress
sort msa year
save temp3.dta, replace

use ../data/tractpanx.dta

** Drop tract area
drop area

** Drop tracts for which we don't know location
drop if cbd_dis==999999

** Put cbd-dis in KM
replace cbd_dis = cbd_dis/1000
sort msa year
merge msa year using temp3.dta
tab _merge
** Merge=1 is MSAs without major plans, Merge=2 is untracted MSA/years
keep if _merge==3
drop _merge

*** Fix data a bit and set sample
drop if black+white+other==0

*** We're Only Doing Central District Tracts 
keep if ccdis70==1

*** Define pop variable 
gen pop = white+black


****** 2.  Define distance metric using 1990 population CDFs for central districts ****

*** Build Distance metric for 1990
egen sumpop = sum(pop) if year==1990, by(msa year)
sort msa year cbd_dis
by msa year: gen cumpop = sum(pop) if year==1990
gen dis = cumpop/sumpop if year==1990

*** Allocate locations for tracts 1960-1980
sort msa cbd_dis
by msa: replace dis = dis[_n-1] if dis==.
gsort msa -cbd_dis
by msa: replace dis = dis[_n-1] if dis==.
drop cumpop


********** 3. Create Additional Variables ******************

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

*** In 1960 because of data construction we have non-integer counts: fix
replace white = round(white,1)
replace black = round(black,1)
replace publicelemhsw = round(publicelemhsw,1)
replace publicelemhsb = round(publicelemhsb,1)
replace privatelemhsw = round(privatelemhsw,1)
replace privatelemhsb = round(privatelemhsb,1)

*** Restrict sample to tracts with data for both whites and blacks
drop if publicelemhsw==.|publicelemhsb==.

*** Only keep needed variables
keep msa year south imp dis publicelemhsw publicelemhsb privatelemhsw privatelemhsb white black pop

*** Key Dependent Variables Level
gen imp_postw = (year>=imp)
gen imp_postb = (year>imp+3)

*** Create nonlinearities 
gen dis1 = (dis>0 & dis<=.25) 
gen dis2 = (dis>.25 & dis<=.5) 
gen dis3 = (dis>.5 & dis<=.75) 
gen dis4 = (dis>.75 & dis<=1) 
gen disX = 0
replace disX = 1 if dis1==1
replace disX = 2 if dis2==1
replace disX = 3 if dis3==1
replace disX = 4 if dis4==1

*** Create dummy set 
xi i.year

*** Calculate Weights - Each MSA Equally
sort msa disX 
by msa disX: gen wgt = 1/_N

xtset msa 
save temp3.dta, replace

*** This Program is Called for Different Dependent Variables
capture program drop flexform
program define flexform


****************** 4. Generate Point Estimates **************************

matrix beta = J(2,4,0) 

use temp3.dta, clear
keep if south==1
*** Run Basic Spec
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis1==1, fe iterate(25)
matrix beta[1,1] = _b[imp_post`2']
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis2==1, fe iterate(25)
matrix beta[1,2] = _b[imp_post`2']
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis3==1, fe iterate(25)
matrix beta[1,3] = _b[imp_post`2']
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis4==1, fe iterate(25)
matrix beta[1,4] = _b[imp_post`2']
save temps2.dta, replace

use temp3.dta, clear
keep if south==0
*** Run Basic Spec
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis1==1, fe iterate(25)
matrix beta[2,1] = _b[imp_post`2']
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis2==1, fe iterate(25)
matrix beta[2,2] = _b[imp_post`2']
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis3==1, fe iterate(25)
matrix beta[2,3] = _b[imp_post`2']
xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis4==1, fe iterate(25)
matrix beta[2,4] = _b[imp_post`2']
save tempn2.dta, replace

matrix list beta


************ 5. Generate Distribution of Point Estimates ************************** 

*** For some reason, Stata won't let us do bootstrap with weights, so do it with a loop
*** If xtpoisson doesn't converge, resample and reestimate
set seed 210
local i = 1

matrix bsc = J(500,4,0) 
matrix bnc = J(500,4,0) 
while `i' <=500 {
  disp `i'
  use temps2.dta, clear
  local x = 1
  while `x'==1 {
    local x = 0
    bsample, cluster(msa) 
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis1==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bsc[`i',1] = _b[imp_post`2']
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis2==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bsc[`i',2] = _b[imp_post`2']
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis3==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bsc[`i',3] = _b[imp_post`2']
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis4==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bsc[`i',4] = _b[imp_post`2']
  }
  use tempn2.dta, clear
  local x = 1
  while `x'==1 {
    local x = 0
    bsample, cluster(msa)
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis1==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bnc[`i',1] = _b[imp_post`2']
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis2==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bnc[`i',2] = _b[imp_post`2']
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis3==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bnc[`i',3] = _b[imp_post`2']
    cap xtpoisson `1' imp_post`2' _Iyear_* [w=wgt] if dis4==1, fe iterate(25)
    if e(ic)==25 {
      local x = 1 
    }
    cap matrix bnc[`i',4] = _b[imp_post`2']
  }
  local i = `i'+1
}

drop _all

*** Create dataset of output - 1,2,3,4 are quartiles of distance
svmat bsc
svmat bnc

collapse (sd) bsc* bnc*

l bsc*
l bnc*

end


***** 8. Call flexform program passing it [1] Depvar and [2] Timing of treatment

flexform publicelemhsw w
flexform publicelemhsb b
flexform white w
flexform black b
flexform privatelemhsw w
flexform privatelemhsb b 
flexform privatelemhsb w 

log close

erase temp3.dta
erase tempn2.dta
erase temps2.dta

