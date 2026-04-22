
cd "/Users/thiemo/Dropbox/Research/Austerity and Brexit/Replication V2/"
use "data files/INDIVIDUAL.PANEL.V2.dta", clear

rename lad id
rename pidpanon pidp
rename hidpanon hidp

label variable pidp "Respondent identifier (numeric)"
label variable id "District identifier (numeric)"
label variable hidp "Household identifier (numeric)"

gen noqual = hiqual_dv_sd_num ==1 if hiqual_dv_sd_num!=.
gen qual4plusdum = hiqual_dv_sd_num ==4 if hiqual_dv_sd_num!=.

label variable noqual "No formal qualifications"
label variable qual4plusdum "University degree"
label variable dvage "Age"
 
 
encode code, gen(id)

gen tq = yq(year, quarter)
egen idwtq = group(id wave tq)
duplicates drop pidp tq, force
xtset pidp tq

tab jbnssec8_dv, gen(NSSEC_)

tab SIC2007Section, gen(SIC2007_)


forvalues i=1(1)19 {


local label : variable label SIC2007_`i'
local label = substr("`label'",17,.)

di "`label'"
label variable  SIC2007_`i'  "`label'"


}


foreach var in colbens1 colbens2 colbens3 colbens4 { 

replace `var' = . if `var'<0
}


replace perpolinf = . if perpolinf <0 | perpolinf==11 

gen LeaveEU = eumem ==7 if eumem ==7 | eumem ==6


gen partyeither = partystandardizevote4 + partystandardizevote3
gen ukipeither = partyeither=="ukipother" | partyeither=="ukip" | partyeither=="other" | partyeither=="bnp"  if partyeither !=""

gen coneither = partyeither =="con" if partyeither!=""
gen noneither = partyeither =="none" if partyeither!=""
gen labeither = partyeither =="lab" if partyeither!=""
gen libdemeither = partyeither =="ld" if partyeither!=""
gen nonevote = partyeither =="none" if partyeither!=""


gen socialrented = tenure_dv == "local authority rent" | tenure_dv=="housing assoc rented"  
gen privaterented = tenure_dv =="rented private furnished" | tenure_dv =="rented private unfurnished" if tenure_dv !=""
gen owned_outright = tenure_dv =="owned outright" if tenure_dv !=""
gen mortgage = tenure_dv =="owned with mortgage" if tenure_dv !=""

**construct group identifiers indicating individuals that 1) always received DLA/PIP, 2) always lived in social rented housing with an excess bedroom oor 3) always received council tax benefit

*number of times individual is observed
egen countid = count(sex), by(pidp)


***DLA/PIP REFORM 
*DLA indicator is constructed from the different USOC waves variables 
*bendis 
*pbnft3 (proxy respondents) 
*this is combined in the variable bprxy_dla_pip which takes four values: inapplicable, mentioned, not mentioned, proxy
* == inapplicable in case individual does not receive any disability related benefits
* == mentioned in case individual states he/she receives DLA/PIP benefiut
* == not mentioned in case individual states he/she does not receive DLA/PIO
* == proxy responses filled out by a proxy respondent (other family member) but that respondent did not know (small set of individuals)
egen sum_bprxy_dla_pip_dum = sum(bprxy_dla_pip_dum), by(pidp)
gen alwys_bprxy_dla_pip_dum = sum_bprxy_dla_pip_dum ==countid if countid!=. & sum_bprxy_dla_pip_dum!=.


***BEDROOM TAX

*Social rented housing
drop countid
egen alwayssocialrented = sum(socialrented ), by(pidp )
egen countid = count(socialrented), by(pidp)
gen socialrentedshare =  alwayssocialrented/countid
replace alwayssocialrented = socialrentedshare ==1


*construct set of households with excess bedroom approximating the governments definition
gen hbencut = 0
*one bedroom for each household of size less than 2 adult members
replace hbencut = 1 if hsbeds >1 & nkids_dv ==0 & hhsize <=2 & hhsize>0 & hsbeds>0 & hsbeds!=. & hhsize!=.
*at most two bedrooms for households of size 3 
replace hbencut = 1 if hsbeds >2 &  hhsize <=3 & hhsize>0 & hsbeds>0  & hsbeds!=. & hhsize!=.
*at most two bedrooms for a couple with two children under the age of 15 irrespective of sex
replace hbencut = 1 if hsbeds >2 &  hhsize ==4 & nkids_dv==2 & nkids015==2 & hhsize>0 & hsbeds>0  & hsbeds!=. & hhsize!=.
*at most three bedrooms for household with parents and three kids, but one kid older than 15 yrs in which case own bedroom is granted
replace hbencut = 1 if hsbeds >3 &  hhsize ==5 & nkids_dv==3 & nkids015==2  & hhsize>0 & hsbeds>0  & hsbeds!=. & hhsize!=.

replace hbencut = 0 if hbencut==.

**identify the most recent time individuals were surveyed prior to the reform becoming effective

gen timetohbcut = tm-19449

egen temp = max(timetohbcut ) if timetohbcut < 0, by(pidp)

gen temp2 = hbencut if  temp==timetohbcut
egen hbcut_cand = mean(temp2), by(pidp)
drop temp temp2

*treatment group identifier -- living in house with excess bedroom 
gen hbcuttype = hbcut_cand * alwayssocialrented  


**identify individuals who always received council tax in a three year window prior to the benefit being abolished 
*ben_council_tax_benefit measures the council tax benefit value in GBP per month
gen receivecounciltaxbenefit = ben_council_tax_benefit>0 if ben_council_tax_benefit !=.
replace  receivecounciltaxbenefit = 0 if (ben_council_tax_benefit==. )
egen receivecounciltaxbenepre212 = sum(receivecounciltaxbene) if tq>=200 & tq<212, by(pidp)

egen countprior212 = count(receivecounciltaxbenefit) if tq>=200 & tq<212, by(pidp)
gen alwaysreceived = receivecounciltaxbenepre212 / countprior212 
egen meanalways = mean(alwaysreceived ), by(pidp)
gen always_counciltaxbenefit = meanalways ==1

drop countprior212 meanalways receivecounciltaxbenepre212 

gen anytreat = always_counciltaxbenefit==1 | alwys_bprxy_dla_pip_dum==1 | hbcuttype ==1


drop countid


gen behindcounciltax = xphsdct=="yes" if xphsdct!=""
gen behindrent = xphsdb=="yes" if xphsdb!=""


egen rwtq = group(region wave tq)


egen mintq = min(tq) if partyeither !="", by(pidp)

gen partyfirstreported = partyeither if tq==mintq

replace partyfirstreported = "other" if partyfirstreported=="greens" | partyfirstreported =="plaid cymru" | partyfirstreported =="snp" | partyfirstreported =="sinn fein"
replace partyfirstreported = "Conservatives" if partyfirstreported =="con"
replace partyfirstreported = "Labour" if partyfirstreported =="lab"
replace partyfirstreported = "Lib Dems" if partyfirstreported =="ld"
replace partyfirstreported = "None" if partyfirstreported =="none"
replace partyfirstreported = "UKIP" if partyfirstreported =="ukipother"
replace partyfirstreported = "Other" if partyfirstreported =="other"


encode partyfirstreported , gen(initpartypref)

sort pidp tq
by pidp: carryforward initpartypref , replace

gen partylastreported = partyeither

replace partylastreported = "other" if partylastreported=="greens" | partylastreported =="plaid cymru" | partylastreported =="snp" | partylastreported =="sinn fein"
replace partylastreported = "Conservatives" if partylastreported =="con"
replace partylastreported = "Labour" if partylastreported =="lab"
replace partylastreported = "Lib Dems" if partylastreported =="ld"
replace partylastreported = "None" if partylastreported =="none"
replace partylastreported = "UKIP" if partylastreported =="ukipother"
replace partylastreported = "Other" if partylastreported =="other"


encode partylastreported , gen(lastpartypref)


gen turnoutlast = vote7 == "yes" if vote7=="yes" | vote7=="no"
gen voteintentdum = voteintent >5 if  voteintent <=10 & voteintent>=0
replace voteintent = . if voteintent<0 | voteintent>10 


encode jbnssec8_dv , gen(nssec8)


gen strugglewithrent = xphsdb=="yes" if xphsdb!=""

gen perpolinf_dum = perpolinf <=3  if perpolinf!=.
gen poleff4_dum = poleff4 == "strongly agree" |  poleff4 == "agree"  if poleff4_num !=.



sort pidp tq


encode region, gen(reg)

tab maxhiqual_dv_sd_num , gen(maxqual_)

tab hiqual_dv_sd_num, gen(hiqual_)
tab jbstat_sd , gen(jbstat_)

replace fimnlabgrs_dv = 0 if fimnlabgrs_dv<0
replace fimnsben_dv = 0 if fimnsben_dv<0

gen logbenincome = log(fimnsben_dv+1)

gen loglabincome = log(fimnlabgrs_dv+1)

gen ownhouse  = owned_outright+mortgage
gen male = sex==5 | sex==11


****FOR REGRESSION TABLES
gen post212 = tq>212
gen post214 = tq>214

gen post_anytreat = (tq>212) * anytreat

gen post_counciltaxbenefit = (tq>212) * always_counciltaxbenefit
gen post_dlapip = (tq>214) * alwys_bprxy_dla_pip_dum
gen post_hbcuttype = (tq>212) * hbcuttype


label variable post_anytreat "Post $\times$ Any of the three"
label variable post_counciltaxbenefit "Post $\times$ Council Tax Benefit"
label variable post_dlapip "Post $\times$ DLA to PIP conversion"
label variable post_hbcuttype "Post $\times$ Bedroom Tax"


**refined control groups
egen maxeversocialrented = max(socialrented), by(pidp )
egen maxevercounciltaxbenefit = max(receivecounciltaxbenefit), by(pidp)
egen maxeverltsick = max(jbstat_5), by(pidp )

gen maxeveranything = maxeversocialrented+maxevercounciltaxbenefit+maxeverltsick
replace maxeveranything = 1 if maxeveranything>0 &maxeveranything!=.

label variable maxeveranything "Ever among potential receipients of three benefits studied"


egen qual_wtq = group(hiqual_dv_sd_num wave tq)
label variable qual_wtq "Qualification x Wave x Time FE"
egen rw_qual_wtq = group(region hiqual_dv_sd_num wave tq)
label variable rw_qual_wtq "Region x Qualification x Wave x Time FE"
egen jbstat_wtq = group(jbstat_sd wave tq)
label variable jbstat_wtq "Economic activity Status x Wave x Time FE"
egen rw_jbstat_sd_wtq = group(jbstat_sd region wave tq)
label variable rw_jbstat_sd_wtq "Region x Economic activity Status x Wave x Time FE"

egen jbstatlonghisttq = group(jbstathistory wave tq)
label variable jbstatlonghisttq "Economic Activity History x Wave x Time FE"


saveold "data files/temporary data files/INDIVIDUAL.PANEL.MATCHING.dta", replace

global reform0 ="post_anytreat post212 anytreat maxeveranything"
global reform1 ="post_counciltaxbenefit post212 always_counciltaxbenefit maxevercounciltaxbenefit"
global reform2 ="post_dlapip post214 alwys_bprxy_dla_pip_dum maxeverltsick"
global reform3 ="post_hbcuttype post212 hbcuttype maxeversocialrented"

****************************
****
****PART 1 - INDIVIDUAL LEVEL MAIN PANEL ANALYSIS
****
****************************

matrix Fstats = J(18,3,.)

*matrix rownames Fstats = $balvars
*matrix colnames Fstats = tranche1 tranche2 t1t2 tranche3 t2t3 tranche4 t3t4 tranche5 t4t5
estimates clear

local i = 1
local labels ""


foreach var in always_counciltaxbenefit alwys_bprxy_dla_pip_dum hbcuttype ukipeither  coneither labeither libdemeither nonevote colbens1 colbens2 colbens3 poleff3_num poleff4_num perpolinf {

local label : variable label `var'
loc labels `"`labels' "`label'""'

su `var'   
	matrix Fstats[`i',3] = `r(N)'
	matrix Fstats[`i',2] = `r(sd)'
	matrix Fstats[`i',1] = `r(mean)'

local i = `i'+1
}


*matrix rownames Fstats = `"`labels'"'
matrix rownames Fstats = "T$\sb{i, CTB}$" "T$\sb{i,DLA}$" "T$\sb{i,BTX}" "support UKIP"  "support Conservatives"  "support Labour"  "support Lib-Dems" "support Neither party" "Like/Dislike Conservatives" "Like/Dislike Labour" "Like/Dislike LibDems" "Public officals dont care" "No say in what govt does" "Vote doesnt make diff"
matrix colnames Fstats = "Mean" "SD" "N"

estout matrix(Fstats,fmt(3) ) using "tables/summary_stats_ind.tex", replace unstack   style(tex)      



**This produces Figure  1 B) Support for ukip over time
preserve
duplicates drop pidp tq , force

drop if nonevote==1
foreach var in ukipeither  {
egen mean`var' = mean(`var') , by(anytreat tq)
}

label variable meanukipeither " "
format tq %tq

replace meanukipeither = meanukipeither*100
sort anytreat tq
twoway (connected meanukipeither   tq if anytreat ==1 & reg==5 &year<=2015 , col(navy) ) (connected meanukipeither    tq if anytreat ==0 & reg==5 &year<=2015,  lp(dash) col(maroon))   ,legend(label(1 "exposed to any of the three reforms") label(2 "everybody else") region(lwidth(none)) cols(3)) scheme(s1color)
graph export "figures/individual-level-ukipsupport.eps",  replace

restore




**PRODUCES TABLE 2
foreach depvar in  ukipeither   {
foreach fe in "id rwtq" "idwtq"  "pidp idwtq" {
estimates clear

forvalues rr=0(1)3 {  
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local sample : word 4 of ${reform`rr'}

gen temp = `var'
eststo : reghdfe `depvar'  temp  `pop'  , absorb(`fe') keepsingletons vce(cl id)
estadd ysumm

drop temp

}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp"," ","-",.)

esttab  using "tables/reform-did-`depvar'-$temp.tex", keep(temp ) coeflabels(temp "Post $\times$ Benefit cut") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par))  stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers
}
}




****PRODUCES TABLE 3
foreach depvar in    coneither labeither libdemeither nonevote {
foreach fe in   "pidp idwtq" {
estimates clear

forvalues rr=0(1)3 {  
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local sample : word 4 of ${reform`rr'}

gen temp = `var'

eststo : reghdfe `depvar'  temp  `pop'  , absorb(`fe') keepsingletons vce(cl id)
estadd ysumm

drop temp
}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp"," ","-",.)
esttab  using "tables/reform-did-`depvar'-$temp.tex", keep(temp ) coeflabels(temp "Post $\times$ Benefit cut") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par))  stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers
}
}

**PRODUCES TABLE 4 (poleff3_num, poleff4_num, perpolinf_dum)  
foreach depvar in  voteintent poleff3_num poleff4_num perpolinf_dum  {
estimates clear
forvalues rr=0(1)0 {  
estimates clear
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local sample : word 4 of ${reform`rr'}

gen temp = `var'

eststo : reghdfe `depvar'  temp  `pop'    , absorb(id   rwtq ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar' temp  `pop' , absorb(idwtq   ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar'  temp    , absorb(pidp  idwtq  ) keepsingletons vce(cl id)
estadd ysumm

drop temp


esttab  using "tables/reform-did-`depvar'-`var'.tex", keep(temp ) coeflabels(temp "Post $\times$ Benefit cut") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

}
}



***THIS PRODUCES TABLE A5
forvalues rr=0(1)0 {  
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local time = subinstr("`time'","post","",.)
local ref : word 4 of ${reform`rr'}

gen temp = `var'
foreach fe in "id rwtq" "idwtq" "pidp idwtq" {
estimates clear

foreach var in "" "rw_qual_wtq" "rw_jbstat_sd_wtq"  "rw_qual_wtq rw_jbstat_sd_wtq" "jbstatlonghisttq" "rw_qual_wtq rw_jbstat_sd_wtq jbstatlonghisttq" {

eststo: reghdfe ukipeither  temp  `pop' , absorb(`fe' `var')  vce(cl id)  

}
global temp = subinstr("`fe'"," ","-",.)

label variable temp "Post x Benefit cut"
esttab using "tables/robustness-time-varying-`pop'-$temp.tex", keep(temp ) replace coeflabels(post_anytreat "Post $\times$ Benefit cut") nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N , labels("Mean of DV"  "Observations" ) fmt(%9.3g)) nonumbers
}
drop temp

}

*TABLE A6 PANEL "Narrower control group"
foreach depvar in  ukipeither   {
foreach ref in "ref" {

foreach fe in "id rwtq" "idwtq"  "pidp idwtq" {
estimates clear

forvalues rr=0(1)3 {  
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local sample : word 4 of ${reform`rr'}

gen temp = `var'
if("`ref'"!="") {
eststo : reghdfe `depvar'  temp  `pop' if `sample'==1 , absorb(`fe') keepsingletons vce(cl id)
}
estadd ysumm

drop temp
}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp"," ","-",.)
if("`ref'"!="") {
global temp = "$temp-refinedcontrolgroup"
}
esttab  using "tables/reform-did-`depvar'-$temp.tex", keep(temp ) coeflabels(temp " ") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par))  stats(ymean N_clust1 N  , labels(" " " " " " ) fmt(%9.3g)) nonumbers

}
}
}

***PRODUCES TABLE A7

label variable post_anytreat "Post $\times$ Any"

***PARTY MOVES TO AND FROM
estimates clear
foreach var in ukipeither coneither labeither libdemeither nonevote  {

eststo: reghdfe `var'    c.post_anytreat#i.initpartypref    , absorb(pidp idwtq i.initpartypref#c.post212) vce(cl id) old
estadd ysumm

}

esttab  using "tables/partymovesto-from.tex",  replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local authority districts" "Observations" ) fmt(%9.3g)) nonumbers




**PRODUCES TABLE A8  (colbens1, colbens2, colbens3)
foreach depvar in  colbens1  colbens2  colbens3  {
estimates clear
forvalues rr=0(1)0 {  
estimates clear
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local sample : word 4 of ${reform`rr'}

gen temp = `var'

eststo : reghdfe `depvar'  temp  `pop'    , absorb(id   rwtq ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar' temp  `pop' , absorb(idwtq   ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar'  temp    , absorb(pidp  idwtq  ) keepsingletons vce(cl id)
estadd ysumm

drop temp


esttab  using "tables/reform-did-`depvar'-`var'.tex", keep(temp ) coeflabels(temp "Post $\times$ Benefit cut") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

}
}



***TABLE A9 - controlling for party preference
foreach depvar in  poleff3_num poleff4_num  perpolinf_dum  {
estimates clear

forvalues rr=0(1)0 {  
estimates clear
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local sample : word 4 of ${reform`rr'}

gen temp = `var'

eststo : reghdfe `depvar'  temp  `pop' , absorb(id ukipeither coneither noneither labeither libdemeither nonevote  rwtq ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar' temp  `pop' ,absorb(idwtq coneither noneither labeither libdemeither nonevote  ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar'  temp     , absorb(pidp coneither noneither labeither libdemeither nonevote idwtq  ) keepsingletons vce(cl id)
estadd ysumm

drop temp

esttab  using "tables/reform-did-controlparty-`depvar'-`var'.tex", keep(temp ) coeflabels(temp "Post $\times$ Benefit cut") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

}
}

**TABLE A10 (poleff3_num, poleff4_num, perpolinf_dum, voteintent)
foreach depvar in voteintent poleff3_num poleff4_num perpolinf perpolinf_dum  {
estimates clear
forvalues rr=0(1)3 {  
estimates clear
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}
local sample : word 4 of ${reform`rr'}

gen temp = `var'
local add= ""

eststo : reghdfe `depvar'  temp  `pop' `add'  , absorb(id   rwtq ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar' temp  `pop' `add', absorb(idwtq   ) keepsingletons vce(cl id)
estadd ysumm

eststo : reghdfe `depvar'  temp     `add', absorb(pidp  idwtq  ) keepsingletons vce(cl id)
estadd ysumm

drop temp
if(`rr'==0) {
esttab  using "tables/reform-wide-did-`depvar'-`var'.tex", keep(temp ) coeflabels(temp "Post $\times$ Benefit cut") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers
} 
else {
esttab  using "tables/reform-wide-did-`depvar'-`var'.tex", keep(temp ) coeflabels(temp " ") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels(" " " " " " ) fmt(%9.3g)) nonumbers
}

}
}


*****
*****
*****INDIVIDUAL REFORMS EVENT STUDIES FIGURES 6, 7 and A5 and A6
*****
*****
**subset to individuals which we see on both sides of the event


preserve
** survey wave 8 collected from 2016 onwards does not include the politics module. 
** event studies focused on data up to 2015 to avoid figures distorted due to composition 
** effects
keep if year<=2015

global reformevent0 ="anytreat 212 200 223"
global reformevent1 ="always_counciltaxbenefit 212 200 223"
global reformevent2 ="alwys_bprxy_dla_pip_dum 214 200 223"
global reformevent3 ="hbcuttype 212 200 223"

foreach fe in  "id rwtq" {
foreach depvar in ukipeither behindcounciltax  behindrent hsbeds fimnlabnet_dv  fimnsben_dv fimngrs_dv {

forvalues rr=0(1)3 {  

local var : word 1 of ${reformevent`rr'}
local date : word 2 of ${reformevent`rr'}
local start : word 3 of ${reformevent`rr'}
local end : word 4 of ${reformevent`rr'}

di "`var'"

reghdfe `depvar'  i.tq#c.`var'  if tq>=`start' & tq<=`end'    , absorb( id rwtq   ) vce(cl id)

capture drop tq_*
capture  drop tq*_`var'
capture  drop hrid*

tab tq if e(sample), gen(tq_)

local rows = `r(r)'
forvalues i=1(1)`rows' {
gen tq`i'_`var'  = tq_`i' * `var' 

su tq if tq_`i'==1
if(`r(mean)' == `date') {

local omit=`i'
}
}

di "`omit'"

reghdfe `depvar'  tq1_`var'-tq`rows'_`var'  if tq>=`start' & tq<=`end'  , absorb( `fe'   ) vce(cl id)

matrix hrid = J(80 ,6, 0)

global iter  = 1
forvalues i=1(1)`rows' {

  lincom  tq`i'_`var'
  matrix hrid[$iter,3] = `r(estimate)'
  matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
  matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
  su tq if  tq_`i'== 1
  matrix hrid[$iter, 1] = `r(mean)'
 *  matrix hrid[$iter, 1] = `i'
  matrix hrid[$iter, 5] = `r(N)'

	
  global iter=$iter+1
  }

  svmat hrid

sort hrid1
replace hrid6 = hrid3

drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0


su hrid2
local miny = round(`r(min)',0.01)
su hrid4
local maxy = round(`r(max)',0.01)

if(abs(`miny')>100) {
su hrid2
local miny = round(`r(min)',0)
su hrid4
local maxy = round(`r(max)',0)
}
local temp = `maxy'-`miny'
local sep =.01
if(`temp'/.01 > 5) {
local sep = .05
}
if(`temp'/.05 > 5) {
local sep = .1
}
if(`temp'/.1 > 5) {
local sep = .2
}
if(`temp'/10 > 5) {
local sep = 200
}
di "Min-y `miny' and Max-y `maxy'"
su hrid3 if hrid1<=`date'

gen hrid7 = `r(mean)' if hrid1<=`date'

su hrid3 if hrid1>`date' & hrid1!=.

replace hrid7 = `r(mean)' if hrid1>`date'

 
su hrid1
sort hrid1

global temp = subinstr("`fe'"," ","-",.)

format hrid1 %tq
twoway (connected hrid3 hrid1  ,  lpattern(dash) lcolor(gray) xline(`date'.5)) (rcap hrid2 hrid4 hrid1  if hrid3!=0, lpattern(none) lcolor(*.5)) (scatter hrid3 hrid1 ,   ytitle("Coefficient estimate", axis(1)))   (line hrid7 hrid1 if hrid1<=`date' , lpattern(dash) lcolor(blue))  (line hrid7 hrid1 if hrid1>`date' , lpattern(dash) lcolor(blue)) , scheme(s1color) legend(off) xtitle("Quarter", size(4))   xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[4]`r(max)')   yscale(range(`miny' `maxy') ) ylabel(`miny'[`sep']`maxy') 
graph export "figures/`depvar'-`var'-event-$temp.eps", replace

}
}
}

restore


**FIGURE A7

sort pidp tq
by pidp: carryforward lastpartypref , replace

tab lastpartypref, gen(last_)
foreach var in last_1 last_2 last_3 last_4 last_5 last_6 {
local lab: variable label `var'

local lab = substr("`lab'",16,.)

label variable `var' "`lab'"
}

tab initpartypref, gen(init_)
foreach var in init_1 init_2 init_3 init_4 init_5 init_6 {
local lab: variable label `var'

local lab = substr("`lab'",16,.)

label variable `var' "`lab'"
}

reg LeaveEU init_6 init_1 init_4 init_2 init_3 init_5, nocons
estimates store pre
 
reg LeaveEU last_6 last_1 last_4 last_2 last_3 last_5, nocons
estimates store post
coefplot (pre,label(earliest))  (post,label(most recent)),xscale(range(0 1)) xlabel(0[.1]1) scheme(s1mono) order(init_6 last_6 init_1 last_1 init_4 last_4 init_2 last_2 init_3 last_3 init_5 last_5) legend(region(lwidth(none)))
graph export "figures/coefplot-leave-last-earliest-party.eps", replace




****************************
****
****PART 2 - SEEMINGLY UNRELATED REGRESSIONS
****
****************************



egen mean1 = mean(ukipeither) if tq<213, by(pidp )
egen meanukippre = mean(mean1) , by(pidp )
egen mean2 = mean(ukipeither) if tq>=213, by(pidp )
egen meanukippost = mean(mean2) , by(pidp )

gen switchukipmean = meanukippost -meanukippre 


**carry forward health conditions as questions not asked in each wave
foreach var in  hcond1_dum  hcond10_dum  hcond11_dum  hcond12_dum  hcond13_dum  hcond14_dum  hcond15_dum  hcond16_dum  hcond17_dum  hcond2_dum  hcond3_dum  hcond4_dum  hcond5_dum  hcond6_dum  hcond7_dum  hcond8_dum  hcond9_dum {

egen temp = max(`var'), by(pidp) 

replace `var' = temp
drop temp

}

xtile incomedecile = fihhmngrs_dv, nq(10)

egen sic = group(SIC2007Section )
egen tenure = group(tenure_dv )
egen jbst = group(jbstat_sd)
encode jbnssec8_dv, gen(nssec)

replace dvage = . if dvage<0


estimates clear
local i =1
foreach reform in anytreat   {

foreach fe in " "  "i.hiqual_dv_sd_num i.dvage" " i.hiqual_dv_sd_num i.dvage i.jbst" " i.hiqual_dv_sd_num i.dvage i.jbst i.incomedecile"  " i.hiqual_dv_sd_num i.dvage i.jbst i.incomedecile  c.hcond1_dum c.hcond10_dum c.hcond11_dum c.hcond12_dum c.hcond13_dum c.hcond14_dum c.hcond15_dum c.hcond16_dum c.hcond17_dum c.hcond2_dum c.hcond3_dum c.hcond4_dum c.hcond5_dum c.hcond6_dum c.hcond7_dum c.hcond8_dum c.hcond9_dum" "i.hiqual_dv_sd_num i.dvage i.jbst i.incomedecile i.sic i.nssec c.hcond1_dum c.hcond10_dum c.hcond11_dum c.hcond12_dum c.hcond13_dum c.hcond14_dum c.hcond15_dum c.hcond16_dum c.hcond17_dum c.hcond2_dum c.hcond3_dum c.hcond4_dum c.hcond5_dum c.hcond6_dum c.hcond7_dum c.hcond8_dum c.hcond9_dum"  {


gen temp = `reform'


* if LeaveEU !=. & switchukipmean!=.
eststo s1: reg   LeaveEU  temp `fe' , absorb(id )    
* if LeaveEU !=. & switchukipmean!=. & e(sample)
eststo s2: reg   switchukipmean  anytreat if LeaveEU !=. & switchukipmean!=. & e(sample)   , absorb(id )      


eststo sur`i': suest s1 s2,vce(cl id)

su switchukipmean, det
estadd scalar switchukipmean = `r(mean)'
su LeaveEU, det
estadd scalar leavemean = `r(mean)'
test [s2_mean]anytreat = [s1_mean]temp
estadd scalar chisq = round(`r(p)',.001)


local i=`i'+1
drop temp


}
}

estimates drop s1 s2
esttab sur1 sur2 sur3 sur4 sur5 sur6  using "tables/seemingly-unrelated-old.tex", keep(temp anytreat)  coeflabels(temp "Benefit cut $\phi$" anytreat "Benefit cut $\gamma$" ) replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(eq chisq  N_clust N  , labels(" " "$\phi = \gamma$ p-value" "Local authority districts" "Observations" ) fmt(%3 %9.3g %9.3g)) nonumbers  substitute(s2_mean "\emph{Switch to UKIP}" s1_mean "\emph{Leave}")



*TABLE A11
**carry forward most recent time variable recorded as not all questions are asked in each wave
sort pidp tq

foreach var in voteintent lastpartypref poleff3_num poleff4_num perpolinf_dum perpolinf behindcounciltax behindrent    {

by pidp: carryforward `var', replace

}

label variable poleff3_num "Public officials don't care"
label variable poleff4_num "Don't have a say in what government does"
label variable perpolinf_dum "My vote doesnt matter"

label variable behindcounciltax "Behind with council tax"
label variable behindrent "Behind with rent"


estimates clear
local i =1

foreach fe in " " "i.hiqual_dv_sd_num  i.dvage" " i.hiqual_dv_sd_num i.dvage i.jbst" " i.hiqual_dv_sd_num i.dvage i.jbst i.incomedecile" "i.hiqual_dv_sd_num i.dvage i.jbst hcond1_dum hcond10_dum hcond11_dum hcond12_dum hcond13_dum hcond14_dum hcond15_dum hcond16_dum hcond17_dum hcond2_dum hcond3_dum hcond4_dum hcond5_dum hcond6_dum hcond7_dum hcond8_dum hcond9_dum"  "i.hiqual_dv_sd_num i.dvage i.jbst i.sic i.nssec hcond1_dum hcond10_dum hcond11_dum hcond12_dum hcond13_dum hcond14_dum hcond15_dum hcond16_dum hcond17_dum hcond2_dum hcond3_dum hcond4_dum hcond5_dum hcond6_dum hcond7_dum hcond8_dum hcond9_dum"  {


* if LeaveEU !=. & switchukipmean!=.
eststo s`i': reghdfe   LeaveEU  poleff3_num poleff4_num perpolinf_dum behindcounciltax behindrent  if LeaveEU !=. , absorb(lastpartypref `fe' code )  vce(cl id)   nocons

local i=`i'+1


}

esttab s1 s2 s3 s4 s5 s6  using "tables/crosssectional-leave-regs-otherproxies.tex",   replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(eq   N_clust N  , labels(" " "Local authority districts" "Observations" ) fmt(%3 %9.3g %9.3g)) nonumbers  



****************************
****
****PART 3 - MATCHING ESTIMATION FOR ROBUSTNESS
****
****************************


use "data files/temporary data files/INDIVIDUAL.PANEL.MATCHING.dta", clear


set seed 13012019
gen rand = runiform() 
sort rand

gen u = runiform()



egen sic = group(SIC2007Section )
egen tenure = group(tenure_dv )
egen jbst = group(jbstat_sd)
encode jbnssec8_dv, gen(nssec)




set matsize 10000

global reform0 ="post_anytreat post212 anytreat maxeveranything"
global reform1 ="post_counciltaxbenefit post212 always_counciltaxbenefit maxevercounciltaxbenefit"
global reform2 ="post_dlapip post214 alwys_bprxy_dla_pip_dum maxeverltsick"
global reform3 ="post_hbcuttype post212 hbcuttype maxeversocialrented"

global matchingvar ="male dvage jbstat_2 jbstat_3 jbstat_8 jbstat_9 jbstat_10 jbstat_11 privaterented owned_outright mortgage hiqual_1 hiqual_2 hiqual_3 hiqual_4 hiqual_5 logbenincome"


forvalues rr=0(1)3 { 

local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local time = subinstr("`time'","post","",.)
local pop : word 3 of ${reform`rr'}


*egen mintq = min(tq)

preserve
keep if tq<`time'


gsort-  tq

duplicates drop pidp, force

psmatch2  `pop' ${matchingvar} ,   out(u)  neighbor(1)

sort _id
gen long pair_si = pidp[_n1] 
gen long pair_id = pidp 


keep if _treated ==1

sort pidp
keep  pidp rand u _pscore _treated _support _weight _u _id _n1 _nn _pdif pair_si pair_id 


egen pairid = group(pidp)
sort pairid

expandby 2, by(pairid)
sort pairid

by pairid: gen row = _n
replace pair_si = pair_id if row==2
drop pair_id pidp
rename pair_si pidp

keep  pidp pairid _pdif  

rename _pdif `pop'_pdif
rename pairid `pop'_pairid

gen rowid = _n
expandby 37, by(rowid)
sort rowid
by rowid: gen tq = _n
replace tq = tq+195

gen reformtest = "`pop'"
*duplicates drop pidp, force
saveold "data files/temporary data files/matchedpairs-`pop'-noreplace.dta", version(12) replace

restore


}


clear

use "data files/temporary data files/matchedpairs-always_counciltaxbenefit-noreplace.dta"
append using "data files/temporary data files/matchedpairs-alwys_bprxy_dla_pip_dum-noreplace.dta"
append using "data files/temporary data files/matchedpairs-anytreat-noreplace.dta"
append using "data files/temporary data files/matchedpairs-hbcuttype-noreplace.dta"

merge m:m pidp tq using "data files/temporary data files/INDIVIDUAL.PANEL.MATCHING.dta"

keep if _merge==3


local caliper = 0.01
estimates clear


***TABLE A6 PANEL "MATCHED SAMPLE"
foreach depvar in   ukipeither  {

foreach fe in "id rwtq" "idwtq"  "pidp idwtq" {

estimates clear

forvalues rr=0(1)3 {  
local var : word 1 of ${reform`rr'}
local time : word 2 of ${reform`rr'}
local pop : word 3 of ${reform`rr'}

gen temp = `var'

eststo : reghdfe `depvar'  temp  `pop'  if  `pop'_pdif<`caliper' , absorb(`fe' ) keepsingletons vce(cl id)
estadd ysumm

drop temp

}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp"," ","-",.)
esttab  using "tables/reform-matched-did-`depvar'-$temp.tex", keep(temp ) coeflabels(temp " ") replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par))  stats(ymean N_clust1 N  , labels(" " " " " " ) fmt(%9.3g)) nonumbers

}
}

**THIS CARRIES FORWARD HEALTH CONDITIONS AS THESE QUESTIONS NOT ALWAYS ASKED
foreach var in  hcond1_dum  hcond10_dum  hcond11_dum  hcond12_dum  hcond13_dum  hcond14_dum  hcond15_dum  hcond16_dum  hcond17_dum  hcond2_dum  hcond3_dum  hcond4_dum  hcond5_dum  hcond6_dum  hcond7_dum  hcond8_dum  hcond9_dum {

egen temp = max(`var'), by(pidp) 

replace `var' = temp
drop temp

}

xtile incomedecile = fihhmngrs_dv, nq(10)

egen sic = group(SIC2007Section )
egen tenure = group(tenure_dv )
egen jbst = group(jbstat_sd)
encode jbnssec8_dv, gen(nssec)

label variable anytreat "Any Reform"



***TABLE A12
estimates clear
foreach fe in "id" "id hiqual_dv_sd_num" "id hiqual_dv_sd_num dvage" "id hiqual_dv_sd_num dvage jbst" "id hiqual_dv_sd_num dvage jbst incomedecile" "id hiqual_dv_sd_num dvage jbst incomedecile sic" "id hiqual_dv_sd_num dvage jbst incomedecile sic nssec" "id hiqual_dv_sd_num dvage jbst sic nssec hcond1_dum hcond10_dum hcond11_dum hcond12_dum hcond13_dum hcond14_dum hcond15_dum hcond16_dum hcond17_dum hcond2_dum hcond3_dum hcond4_dum hcond5_dum hcond6_dum hcond7_dum hcond8_dum hcond9_dum"  {

eststo: reghdfe LeaveEU anytreat if anytreat_pdif<0.01 , absorb(`fe') vce(cl id) nocons
estadd ysumm

}

esttab  using "tables/crosssectional-leave-regs-matched.tex",  replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local authority districts" "Observations" ) fmt(%9.3g)) nonumbers


