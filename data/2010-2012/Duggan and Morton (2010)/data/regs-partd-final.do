set more 1
set memory 500000

log using regs-partd-final.log, replace

* start with data from 2003 meps that estimates medicare market shares

use meps03share
drop mcd03paidamt mcd03numndcs mcd03otcfrac
d, fullname
sum

* merge this with comparable info from 2002 meps to increase sample size

sort shortnam
merge shortnam using meps02share
tab _merge
drop _merge

* drop those with meps02paid and meps03paid missing

count
drop if meps02paid==. & meps03paid==.
count

* how many drugs are in both versus only one

count if meps02paid!=. & meps03paid!=.
count if meps02paid!=. & meps03paid==.
count if meps02paid==. & meps03paid!=.

* now let's see how 02 and 03 shares are correlated

gen regwgt = (1 / ((1/meps02scripts) + (1/meps03scripts)))

* fraction of scripts that are generic in meps - ignore those with missing
* gbo and thus divide by share either brand or generic here
* fraction missing generic info is 1 - gen02meps - brand02meps

gen gen03frac = gen03meps / (brand03meps + gen03meps)
gen gen02frac = gen02meps / (brand02meps + gen02meps)

sum brand02meps gen02meps gen02frac meps02scripts
sum brand03meps gen03meps gen03frac meps03scripts

* now pool to estimate share of prescriptions in 02 and 03 that are generic
* a bit messy b/c have to scale down meps02scripts and meps03scripts to
* account for those scripts that have missing generic-brand info
* but otherwise just a weighted avg of 02 and 03 share . . . if one
* year has no info then just use other year's generic share

gen gen0203frac = (gen02frac * (meps02scripts * (brand02meps + gen02meps))) + (gen03frac * (meps03scripts * (brand03meps + gen03meps)))
replace gen0203frac = gen0203frac / ((meps02scripts * (brand02meps + gen02meps)) + (meps03scripts * (brand03meps + gen03meps)))
replace gen0203frac = gen02frac if gen03frac==. & gen02frac!=.
replace gen0203frac = gen03frac if gen02frac==. & gen03frac!=.

sum gen02frac gen03frac gen0203frac
sum gen02frac gen03frac gen0203frac if gen02frac!=. & gen03frac!=.

* a few strange cases where gen0203frac falls outside of gen02frac and
* gen03frac range but only b/c of rounding

list gen02frac gen03frac gen0203frac if gen02frac!=. & gen03frac!=. & gen02frac > gen0203frac & gen03frac > gen0203frac
list gen02frac gen03frac gen0203frac if gen02frac!=. & gen03frac!=. & gen02frac < gen0203frac & gen03frac < gen0203frac

* average medicare market shares in each year

sum mcar03mepsrx [aw=meps03scripts]
sum mcar02mepsrx [aw=meps02scripts]

* regress these two measures

reg mcar03mepsrx mcar02mepsrx [aw=regwgt], robust

* exclude over the counter drugs

reg mcar03mepsrx mcar02mepsrx [aw=regwgt] if mcd03otcfrac<=0.1, robust

* exclude generic drugs

reg mcar03mepsrx mcar02mepsrx [aw=regwgt] if mcd03otcfrac<=0.1 & gen0203frac<=0.1, robust

* or just weight by total scripts - very similar estimate

reg mcar03mepsrx mcar02mepsrx [aw=meps02scripts+meps03scripts] if mcd03otcfrac<=0.1 & gen0203frac<=0.1, robust

* mcar self share

reg mcself03mepsrx mcself02mepsrx [aw=meps02scripts+meps03scripts] if mcd03otcfrac<=0.1 & gen0203frac<=0.1, robust

* dual share

reg dual03mepsrx dual02mepsrx [aw=meps02scripts+meps03scripts] if mcd03otcfrac<=0.1 & gen0203frac<=0.1, robust

* total number of scripts adding 02 and 03

gen     meps0203scripts = meps02scripts + meps03scripts
replace meps0203scripts = meps02scripts if meps03scripts==. & meps0203scripts==.
replace meps0203scripts = meps03scripts if meps02scripts==. & meps0203scripts==.

label var meps0203scripts "total scripts in 02 + 03 meps"


* weighted medicare market share - the key explanatory variable

gen mcar0203mepsrx = ((meps02scripts * mcar02mepsrx) + (meps03scripts * mcar03mepsrx)) / meps0203scripts
replace mcar0203mepsrx = mcar02mepsrx if mcar03mepsrx==. & mcar0203mepsrx==.
replace mcar0203mepsrx = mcar03mepsrx if mcar02mepsrx==. & mcar0203mepsrx==.

label var mcar0203mepsrx "weighted medicare mkt share 02,03"


* weighted medicare market share for spending - a variant on key expl var

gen mcar0203mepspd = ((meps02scripts * mcar02mepspd) + (meps03scripts * mcar03mepspd)) / meps0203scripts
replace mcar0203mepspd = mcar02mepspd if mcar03mepspd==. & mcar0203mepspd==.
replace mcar0203mepspd = mcar03mepspd if mcar02mepspd==. & mcar0203mepspd==.

label var mcar0203mepspd "weighted medicare mkt share in $ 02,03"


* weighted dual share

gen dual0203mepsrx = ((meps02scripts * dual02mepsrx) + (meps03scripts * dual03mepsrx)) / meps0203scripts
replace dual0203mepsrx = dual02mepsrx if dual03mepsrx==. & dual0203mepsrx==.
replace dual0203mepsrx = dual03mepsrx if dual02mepsrx==. & dual0203mepsrx==.

* weighted medicare self pay share

gen mcself0203mepsrx = ((meps02scripts * mcself02mepsrx) + (meps03scripts * mcself03mepsrx)) / meps0203scripts
replace mcself0203mepsrx = mcself02mepsrx if mcself03mepsrx==. & mcself0203mepsrx==.
replace mcself0203mepsrx = mcself03mepsrx if mcself02mepsrx==. & mcself0203mepsrx==.

label var dual0203mepsrx "weighted dual mkt share 02,03"
label var mcself0203mepsrx "weighted medicare-self market share 02,03"

sort shortnam
save merge0203AA, replace
d, fullname
sum
quietly by shortnam: gen temp = _n
tab temp 
clear


* get subcategories - will use later to determine which are prot classes, etc.
* this is all levels of the ims data

use ims0106all.dta

d, fullname

drop if salesq401==. & salesq402==. & salesq403==. & salesq404==. & salesq405==. & salesq406==.

tab level, missing

keep if level==2
keep if salesq403>0 & salesq403!=.
keep nameshort thercat cat subcat
replace nameshort = ltrim(rtrim(upper(nameshort)))
rename nameshort subcat1_03
sort subcat1_03
save temp, replace
d
sum
clear



* get subcategory that accounts for most spending for each drug
* this is just drug level ims data (e.g. not firm, etc.)

use ims0106data2

drop if salesq401==. & salesq402==. & salesq403==. & salesq404==. & salesq405==. & salesq406==.

tab level, missing

d namemerge subcatn, fullname

keep if imsgrouprank03<=1000 & salesq403>0 & salesq403!=.

count

gen vers03 = 1

collapse (sum) salesq403 vers03, by(namemerge subcatn)

count

egen tot03 = sum(salesq403), by(namemerge)
egen versions03 = sum(vers03), by(namemerge subcatn)
gen  sc03shar = salesq403 / tot03
gsort namemerge - salesq403

quietly by namemerge: gen counter = _n
quietly by namemerge: gen subcats03 = _N

sum sc03shar if counter==1, detail
keep if counter==1
keep namemerge subcatn subcats03 sc03shar
rename namemerge shortnam
rename subcatn subcat1_03

label var subcat1_03 "major sub category in 03 data"
label var subcats03  "# of subcategories in 03"

sort subcat1_03
count
merge subcat1_03 using temp
tab _merge
tab _merge if subcats03!=.

drop if subcats03==.
drop _merge

replace subcat1_03 = ltrim(rtrim(upper(subcat1_03)))

gen byte protected = 0
replace  protected = 1 if substr(subcat1_03,1,1)=="L"
replace  protected = 1 if substr(subcat1_03,1,3)=="N6A"
replace  protected = 1 if substr(subcat1_03,1,3)=="N5A"
replace  protected = 1 if substr(subcat1_03,1,3)=="N3A"
replace  protected = 1 if substr(subcat1_03,1,3)=="J5C"

tab subcat1_03 if protected==1, missing

sort shortnam

save subcats03, replace

d
sum

clear



* ims 01-06 data for level 4 obs

use ims0106data2

* this has all level 4 obs from the 01-06 ims data
* there are sometimes more than 1 obs for same drug
* for example Zyprexa and Zyprexa Zydis, etc.

drop if salesq401==. & salesq402==. & salesq403==. & salesq404==. & salesq405==. & salesq406==.

sum imsgrouprank03

d, fullname

replace fullname  = upper(ltrim(rtrim(fullname)))
replace namemerge = upper(ltrim(rtrim(namemerge)))

* namemerge is the name used to merge to the meps data - see the list in
* the meps02share.do and meps03share.do files

* how many drugs do we now have (excluding those with no "namemerge")?

sort namemerge salesq403
quietly by namemerge: gen temp6 = _n
replace temp6 = . if namemerge==""
count if temp6==1

* let's start by just collapsing the salesq401, etc. vars by namemerge
* this will create vars like pat's gsalesq401 but also for quantities, etc.

* keep fdayear and otc indicator - these do not vary across products
* with same namemerge

rename gbo imsgbo

gen doses01 = stdq401 / ddoseq401
gen doses02 = stdq402 / ddoseq402
gen doses03 = stdq403 / ddoseq403
gen doses04 = stdq404 / ddoseq404
gen doses05 = stdq405 / ddoseq405
gen doses06 = stdq406 / ddoseq406

keep if imsgrouprank03<=1000

collapse (sum) salesq401 salesq402 salesq403 salesq404 salesq405 salesq406 doses0*, by(namemerge fdayear otc imsgbo imsgrouprank03)

d
sum

* drop if not in our top 1000

drop if namemerge==""

* make sure we have just one obs per drug

sort namemerge
quietly by namemerge: gen temp = _n
tab temp
drop temp

* merge ims sales to meps data on medicare market shares

rename namemerge shortnam
count
sort shortnam
merge shortnam using merge0203AA
tab _merge
drop _merge
count if imsgrouprank03==.

* we have medicare share for vast majority of ims 2003 sales

sum salesq403 if mcar0203mepsrx==.
sum salesq403 if mcar0203mepsrx!=.

* list drugs for which we do not have medicare market share from 02-03 meps
* also list ims 03 sales and medicaid 03 spending for them

gsort - salesq403 shortnam
list shortnam salesq403 mcd03paidamt if salesq403!=. & salesq403>0 & mcar0203mepsrx==. & imsgrouprank03<=300

* drop drugs with no 2003 sales

drop if salesq403==0

count

* use this otc variable rather than medicaid derived one b/c it catches 
* ibuprofen, motrin, etc. - medicaid may only pay for prescription versions 
* of these - the mcd03otcfrac represents share of medicaid spending for this
* drug in ndc's that report that they are otc

sum otc if mcar0203mepsrx!=.
tab otc if mcar0203mepsrx!=., missing

sum mcd03otcfrac if otc==1 & mcar0203mepsrx!=.
sum mcd03otcfrac if otc==2 & mcar0203mepsrx!=.
sum mcd03otcfrac if otc==. & mcar0203mepsrx!=.

rename salesq401 salesq2001
rename salesq402 salesq2002
rename salesq403 salesq2003
rename salesq404 salesq2004
rename salesq405 salesq2005
rename salesq406 salesq2006

rename doses01 doses2001
rename doses02 doses2002
rename doses03 doses2003
rename doses04 doses2004
rename doses05 doses2005
rename doses06 doses2006

gen lsalesq0603 = log(salesq2006/((201.6 / 184.0) * salesq2003))
gen lsalesq0302 = log(salesq2003/salesq2002)
gen lsalesq0201 = log(salesq2002/salesq2001)

gen yrs03onmkt = 2003 - fdayear
tab yrs03onmkt if imsgrouprank03<=300 & mcar0203mepsrx!=., missing
replace yrs03onmkt = 0 if yrs03onmkt < 0

gen ldoses0603 = log(doses2006 / doses2003)
gen ldoses0302 = log(doses2003 / doses2002)
gen ldoses0201 = log(doses2002 / doses2001)

gen priceperday06 = salesq2006 / doses2006
gen priceperday03 = (201.6 / 184.0) * (salesq2003 / doses2003)
gen priceperday02 = salesq2002 / doses2002
gen priceperday01 = salesq2001 / doses2001

gen lppd0603 = log(priceperday06 / priceperday03)
gen lppd0302 = log(priceperday03 / priceperday02)
gen lppd0201 = log(priceperday02 / priceperday01)

gen lppd06 = log(priceperday06)
gen ppd0603 = priceperday06 - priceperday03

* log versus level of prices

sum lppd0603 ppd0603 lppd06 priceperday06 ldoses0603 if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & ldoses0302!=. [aw=meps0203scripts], detail

* merging to data on whether a small category and so forth

rename shortnam namemerge
count
sort namemerge
merge namemerge using usp548final
tab _merge
drop _merge

tab gen_548, missing

gen doelngth = length(gen_doe)
tab doelngth
gen gen_yr = real(substr(gen_doe,doelngth-3,4))

gen anygen01 = (nogen==0) & gen_yr<=2001
replace anygen01 = . if gen_548==.
tab anygen01, missing

gen anygen06 = (nogen==0) & gen_yr>=2002 & gen_yr<=2006
replace anygen06 = . if gen_548==.
tab anygen06, missing

sum lppd0603 ppd0603 lppd06 priceperday06 ldoses0603 if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & ldoses0302!=. & smallcat!=. [aw=meps0203scripts], detail

gen str148 ther1 = ther_cat_usp1 + ther_subclass_usp1
replace ther1 = "X" if ther1=="" & gen_548!=.
* misssing for 21 of the 548

tab smallcat if gen_548!=., missing
replace smallcat = 0 if smallcat==. & gen_548!=.

gen anygen = max(anygen01,anygen06)

* here merging to data on subcats to determine which are in prot categories

rename namemerge shortnam
count
sort shortnam
merge shortnam using subcats03
tab _merge, missing

* 2 cases with otc discrepancy though stick with original definition

d otc otc_548
tab otc otc_548, missing

* table 2 - weight regs to account for variation across drugs in # of scripts
* in the meps used to estimate medicare market share

* sum stats column
sum lppd0603 ldoses0603 mcar0203mepsrx lppd0201 yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=.
sum lppd0603 if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=., detail

* column 1
reg lppd0603 mcar0203mepsrx if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. [aw=meps0203scripts], robust

* column 2 - add controls
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. [aw=meps0203scripts], robust

* column 3 - drop outliers
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 [aw=meps0203scripts], robust

* column 4 - exclude cancer
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], robust

* column 5 - use share of spending instead of share of scripts
reg lppd0603 mcar0203mepspd yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], robust

* column 6 - focus on top 200
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=292 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], robust

* table 3

* sum stats column
sum ldoses0603 ldoses0201 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=.
sum ldoses0603 if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=., detail

* column 1
reg ldoses0603 mcar0203mepsrx if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. [aw=meps0203scripts], robust

* column 2 - add controls
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. [aw=meps0203scripts], robust

* column 3 - drop outliers
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 [aw=meps0203scripts], robust

* column 4 - drop cancer
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], robust

* column 5 - use share of spending instead of share of scripts
reg ldoses0603 mcar0203mepspd yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], robust

* column 6 - focus only on top 200
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=293 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], robust

* column 7 - drop those facing generic competition by 2006 or earlier

reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 & anygen==0 [aw=meps0203scripts], robust

* table 4

* differentiate b/w medicare self-pay and all other medicare scripts

* all medicare non-self pay (includes duals, those privately insured, etc.)
gen mcoth0203mepsrx = mcar0203mepsrx - mcself0203mepsrx

sum mcar0203mepsrx mcoth0203mepsrx mcself0203mepsrx lppd0201 ldoses0201 lsalesq0201 yrs03onmkt anygen if imsgrouprank<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603!=. & mcar0203mepsrx!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8

* all non-self and non-dual
gen mcoth0203mepsrx2 = mcar0203mepsrx - mcself0203mepsrx - dual0203mepsrx
sum mcar0203mepsrx mcoth0203mepsrx2 mcself0203mepsrx dual0203mepsrx if imsgrouprank<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603!=. & mcar0203mepsrx!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8

* column 1
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], robust

* column 2
reg lppd0603 mcself0203mepsrx mcoth0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], robust

* column 3
reg lppd0603 mcself0203mepsrx mcoth0203mepsrx2 dual0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], robust

* column 4
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], robust

* column 5
reg ldoses0603 mcself0203mepsrx mcoth0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], robust

* column 6
reg ldoses0603 mcself0203mepsrx mcoth0203mepsrx2 dual0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], robust

* column 7
reg lsalesq0603 mcar0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lsalesq0603>=-3.7 & lsalesq0603<=1.72 & thercat!=8 [aw=meps0203scripts], robust

* column 8
reg lsalesq0603 mcself0203mepsrx mcoth0203mepsrx yrs03onmkt anygen if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lsalesq0603>=-3.7 & lsalesq0603<=1.72 & thercat!=8 [aw=meps0203scripts], robust


* table 5

* make smallcat equal to 1 for the 2 drugs where there are just 2 ingredients

tab numclass smallcat, missing
replace smallcat = 1 if smallcat==0 & numclass<=2

* define the interactions with protected and small category
gen mcar0203prot = mcar0203mepsrx * protected
gen scmcar0203 = smallcat * mcar0203mepsrx

tab smallcat protected if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8, missing

* column 1
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen protected mcar0203prot if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], cluster(ther1)

* column 2
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen smallcat scmcar0203 if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], cluster(ther1)

* column 3
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen smallcat scmcar0203 protected mcar0203prot if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 [aw=meps0203scripts], cluster(ther1)

* column 4
reg lppd0603 mcar0203mepsrx yrs03onmkt anygen smallcat scmcar0203 protected mcar0203prot if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & lppd0603>=-1.100 & lppd0603<=1.095 & thercat!=8 & anygen==0 [aw=meps0203scripts], cluster(ther1)

* column 5
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen protected mcar0203prot if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], cluster(ther1)

* column 6
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen smallcat scmcar0203 if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], cluster(ther1)

* column 7
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen smallcat scmcar0203 protected mcar0203prot if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 [aw=meps0203scripts], cluster(ther1)

* column 8
reg ldoses0603 mcar0203mepsrx yrs03onmkt anygen smallcat scmcar0203 protected mcar0203prot if imsgrouprank03<=1000 & otc==2 & imsgbo==2 & fdayear<=2003 & smallcat!=. & ldoses0603>=-3.95 & ldoses0603<=1.51 & thercat!=8 & anygen==0 [aw=meps0203scripts], cluster(ther1)

log close

exit

