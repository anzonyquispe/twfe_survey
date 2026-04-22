/* Regressions*/
drop _all
set mem 500m

set more off
pause on

capture log close

cd C:\research\minwage\calculatingInitDistForSim
log using scf.log, replace


* the downpayment rate.  .4 => 40% down
local downpaymentrate = .4

********* the state vars *************************
* a = measure of assets relevant to paper
* wageincome = measure of income relevant to paper
* durables = measure of durables relevant to paper

********* 
use C:\research\minwage\SCF\scfregdata8907, clear

gen homeval= homeeq+ housedebt
gen homeowner=0
replace homeowner=1 if homeval>0 & homeval~=.

gen vehicleowner=0
replace vehicleowner=1 if vehicles>0 & vehicles~=.
gen netFinancialAssets= financialassets- financialdebt

keep wageincome homeowner homeval housedebt vehicleowner vehicles veh_inst  otherassets otherinstall netFinancialAssets creditcard educationdebt age totaldebt totalassets minwage* wgt year havecc

gen Non_collateralized_debt= creditcard+educationdebt
gen collateralized_debt=housedebt+veh_inst+ otherinstall  

order wageincome homeowner homeval housedebt vehicleowner vehicles veh_inst  otherassets otherinstall netFinancialAssets creditcard educationdebt age Non_collateralized_debt collateralized_debt totaldebt totalassets minwage* wgt havecc 

gen durables = vehicles+otherassets
gen durabledebt=veh_inst + otherinstall

gen a= netFinancialAssets- (durabledebt)


sum wageincome durables durabledebt [w= wgt]
*sum [w= wgt], detail

sum [w= wgt] if  minwageworker==0
*sum [w= wgt], detail  if  minwageworker==0

sum  [w= wgt] if  minwage==1
*sum [w= wgt], detail  if  minwageworker==1

gen a2=a-housedebt
gen totdurables=durables+homeval

* in the paper i call this variable "resources"

gen buffer=(durables*(1-`downpaymentrate'))+a


gen agecat=0
replace agecat=1 if age <30 
replace agecat=2 if age >=30 & age<40 
replace agecat=3 if age >=40 & age<50
replace agecat=4 if age >=50 



sum wageincome durables durabledebt netFinancialAssets a homeowner  creditcard educationdebt  totaldebt totalassets buffer age [w= wgt]
sum wageincome durables durabledebt netFinancialAssets a homeowner creditcard educationdebt  totaldebt totalassets buffer age [w= wgt], detail

sum wageincome durables durabledebt netFinancialAssets a homeowner creditcard educationdebt  totaldebt totalassets buffer age [w= wgt]  if  minwageworker==0
sum wageincome durables durabledebt netFinancialAssets a homeowner creditcard educationdebt  totaldebt totalassets buffer age [w= wgt]  if  minwageworker==0, detail

sum wageincome durables durabledebt netFinancialAssets a homeowner creditcard educationdebt  totaldebt totalassets buffer age [w= wgt]  if  minwage==1
sum wageincome durables durabledebt netFinancialAssets a homeowner creditcard educationdebt totaldebt totalassets buffer age [w= wgt]  if  minwage==1, detail



* some top and bottom codes here
sum
replace durables=50000 if durables>50000 & durables ~=.
replace a=50000 if a>50000 & a ~=.
replace a=-3000 if a<-30000 & a ~=.
replace wageincome=50000 if wageincome>50000 & wageincome ~=.
replace wageincome=2000 if wageincome<2000 & wageincome ~=.

* make wageincome quarterly
replace wageincome=wageincome/4


* age restriction here
keep if age>17 & age<=25

keep age* durables a wageincome  totdurables a2 buffer wgt year havecc minwage
save scf_full, replace



keep if  minwage==1
save scf, replace


* generate initial conditions here 
keep durables a wageincome  totdurables a2 
order wageincome durables a a2 totdurables
local outputname = `downpaymentrate' * 100
*outsheet using "scf_pi`outputname'",nonames replace
outsheet using "scf",nonames replace


* Summary statistics for web Appendix Table A4

* generate distribution of the buffer that we wish to match
use C:\research\minwage\calculatingInitDistForSim\scf_full, clear
keep if age==21
sum buffer, detail 
use C:\research\minwage\calculatingInitDistForSim\scf_full, clear
keep if age==33
sum buffer, detail 
use C:\research\minwage\calculatingInitDistForSim\scf_full, clear
keep if age==49
sum buffer, detail
use C:\research\minwage\calculatingInitDistForSim\scf_full, clear
* I used this for the paper on "distn of buffer"
keep if age==21|age==33|age==49 
sum buffer, detail 
use C:\research\minwage\calculatingInitDistForSim\scf_full, clear
keep if age==21|age==22|age==33|age==34|age==49|age==50
sum buffer, detail 
use C:\research\minwage\calculatingInitDistForSim\scf_full, clear
keep if age==21|age==22|age==23|age==33|age==34|age==35|age==49|age==50|age==51
sum buffer, detail 
use C:\research\minwage\calculatingInitDistForSim\scf_full, clear
sum buffer, detail 
use C:\research\minwage\calculatingInitDistForSim\scf, clear
sum buffer, detail 






log close
exit, clear







