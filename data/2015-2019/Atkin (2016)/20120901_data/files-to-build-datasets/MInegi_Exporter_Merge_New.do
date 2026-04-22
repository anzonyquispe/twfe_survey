
clear all
set more off





if "`c(os)'"=="Windows" {
local tempdir="C:/Data/Mexico/mexico_ss_Stata/"
local dir="C:/Work/Mexico/"
local dirmaq="C:/Work/Mexico/Maquiladora Data/"
local inegidir="C:/Work/Mexico/INEGI Firm Data/"
local inegicreate="C:/Work/Mexico/INEGI Firm Data/Created Data/"
}








/**

*first lets look at raw inegi files which this data comes from (although i dont have EIM). this also get correspindances to rama
use "`inegidir'Tybout/data files/mex8490.dta" 
egen empleatot=total(EMPLEA), by(MUN EN RAMA DIV CLAVE CLASE PER)
egen obrtot=total(OBRERO), by(MUN EN RAMA DIV CLAVE CLASE PER)
egen emptot=total(TOPEOC), by(MUN EN RAMA DIV CLAVE CLASE PER)
egen tag=tag(MUN EN RAMA DIV CLAVE CLASE PER)
keep if tag==1
keep MUN RAMA DIV CLAVE EN emptot obrtot empleatot  CLASE PER
gen muncenso= EN*1000+ MUN
save "`inegicreate'Totals8490.dta", replace

tab muncenso if EN==1
tab RAMA if EN==15

egen tag=tag(CLASE)
keep if tag==1
rename CLASE cmap84
keep cmap84 RAMA
rename RAMA rama84
d
local obse=r(N)+2
set obs `obse'
replace cmap84=3121 if _n ==`obse'
replace rama84=36 if _n ==`obse'
replace cmap84=3831 if _n ==`obse'-1
replace rama84=58 if _n ==`obse' -1
*mexico data.pdf (in tybout data) suggests these corrections        
sort cmap84
save "`inegicreate'CMAP84toRAMA84.dta", replace




use  "`inegidir'/CMAP_9403/CMAP_94-03.dta"  
egen emptot=total(v1), by( p sector rama ent mun)
egen tag=tag(p sector rama ent mun)
keep if tag==1
keep  emptot  p sector rama ent mun
gen muncenso= ent*1000+ mun
save "`inegicreate'Totals9403.dta", replace

tab muncenso if ent==1
tab rama if ent==15

clear
use "`dir'Cmap94_to_scian02_3digit.dta"
keep if  cmap94_3dig>=300 &  cmap94_3dig<400
keep if  scian02_3dig>=300 &  scian02_3dig<400
*egen nvalscamp3=nvals( cmap94_3dig), by( scian02_3dig)
*egen nvalsscian3=nvals(scian02_3dig), by(cmap94_3dig)
egen scian02_3d=mode(scian02_3dig), by(cmap94_3dig)
egen tag=tag( cmap94_3dig)
keep if tag==1
keep  cmap94_3dig scian02_3d
sort  cmap94_3dig
save "`inegicreate'Cmap94_to_scian02_3digit_concordance.dta", replace



*now bring in panel similar to used in verhoogen
foreach ends in raw_cmap84 8401 9301 {

clear
insheet using "`inegidir'XXX Data/for_david_atkin_`ends'.csv"
cap gen cmap84=cmap if cmap<9999
cap gen cmap94=cmap if cmap>9999
gen cmap94_4dig=floor(cmap94/100)
gen cmap94_3dig=floor(cmap94/1000)
sort cmap94_3dig
merge cmap94_3dig using "`inegicreate'Cmap94_to_scian02_3digit_concordance.dta", nokeep _merge(_me94)
sort scian02_3d
merge scian02_3d using "`dir'scian02_3digit_to_hcode_concordance.dta", nokeep _merge(_me942) keep(hcode)
rename hcode hcode94
cap {
sort cmap84
merge cmap84 using "`inegicreate'CMAP84toRAMA84.dta", nokeep _merge(_me84)
sort rama84
merge rama84 using  "`dir'rama84_to_hcode_concordance.dta",  nokeep keep(hcode) _merge(_me842)
rename hcode hcode84
}
egen hcode=rowmin(hcode*)

drop cmap94_?dig
gen muncenso= ent*1000+ mpio if cmap>9999
*replace  muncenso= ent*1000+ mpio if cmap<9999
*these codes are currently wrong.
keep  periodo  muncenso em ob em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 hcode
collapse (sum) em ob em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 , by(periodo  muncenso hcode)
sort periodo  muncenso hcode
save "`inegicreate'XXX_`ends'.dta", replace

}

**/




/**

*now bring in panel from verhoogen
foreach ends in raw_cmap84 8401 9301 {
clear
insheet using "`inegidir'XXX Data/for_david_atkin_`ends'.csv"
rename mpio mpio`ends'
gen mpio0`ends'=mpio`ends'
gen mpio1`ends'=mpio`ends'
gen mpio2`ends'=mpio`ends'
save "`inegidir'XXX Data/for_david_atkin_`ends'.dta", replace
}

use  "`inegidir'XXX Data/for_david_atkin_raw_cmap84.dta", clear
merge m:m periodo ent em ob em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 using "`inegidir'XXX Data/for_david_atkin_8401.dta", keepusing(mpio8401) generate(merge8401) keep(match master)
replace mpio8401=. if em==0 & ob==0
replace mpio8401=. if periodo>=1993
merge m:m periodo ent em ob using "`inegidir'XXX Data/for_david_atkin_8401.dta", keepusing(mpio08401) generate(merge08401) keep(match master)
replace mpio08401=. if em==0 & ob==0
replace mpio08401=. if periodo>=1993
merge m:m periodo ent em_exporter1 ob_exporter1 using "`inegidir'XXX Data/for_david_atkin_8401.dta", keepusing(mpio18401) generate(merge18401) keep(match master)
replace mpio18401=. if em_exporter1==0 & ob_exporter1==0
replace mpio18401=. if periodo>=1993
merge m:m periodo ent em_exporter2 ob_exporter2 using "`inegidir'XXX Data/for_david_atkin_8401.dta", keepusing(mpio28401) generate(merge28401) keep(match master)
replace mpio28401=. if em_exporter2==0 & ob_exporter2==0
replace mpio28401=. if periodo>=1993


*merge m:m periodo ent em ob using "`inegidir'XXX Data/for_david_atkin_9301.dta", keepusing(mpio9301) generate(merge9301) keep(match master)

egen nvals8401=nvals(mpio8401), by(ent mpioraw_cmap84 periodo)
egen nvals08401=nvals(mpio08401), by(ent mpioraw_cmap84 periodo)
egen nvals18401=nvals(mpio18401), by(ent mpioraw_cmap84 periodo)
egen nvals28401=nvals(mpio28401), by(ent mpioraw_cmap84 periodo)

egen max8401=max(mpio8401), by(ent mpioraw_cmap84 cmap periodo)
egen max08401=max(mpio08401), by(ent mpioraw_cmap84 cmap periodo)
egen max18401=max(mpio18401), by(ent mpioraw_cmap84 cmap periodo)
egen max28401=max(mpio28401), by(ent mpioraw_cmap84 cmap periodo)

egen xmax8401=max(mpio8401), by(ent mpioraw_cmap84 cmap)
egen xmax08401=max(mpio08401), by(ent mpioraw_cmap84 cmap)
egen xmax18401=max(mpio18401), by(ent mpioraw_cmap84 cmap)
egen xmax28401=max(mpio28401), by(ent mpioraw_cmap84 cmap)

egen xxmax8401=max(mpio8401), by(ent mpioraw_cmap84 periodo)
egen xxmax08401=max(mpio08401), by(ent mpioraw_cmap84 periodo)
egen xxmax18401=max(mpio18401), by(ent mpioraw_cmap84 periodo)
egen xxmax28401=max(mpio28401), by(ent mpioraw_cmap84 periodo)

egen xxxmax8401=max(mpio8401), by(ent mpioraw_cmap84)
egen xxxmax08401=max(mpio08401), by(ent mpioraw_cmap84)
egen xxxmax18401=max(mpio18401), by(ent mpioraw_cmap84)
egen xxxmax28401=max(mpio28401), by(ent mpioraw_cmap84)

gen mpio=mpioraw_cmap84 if periodo>=1993
replace  mpio=mpio8401 if mpio==.
replace  mpio=mpio08401 if mpio==.
replace  mpio=mpio18401 if mpio==.
replace  mpio=mpio28401 if mpio==.
*first replace with that entry

foreach beg in "" "x" "xx" "xxx" {
replace  mpio=`beg'max8401 if mpio==.
replace  mpio=`beg'max08401 if mpio==.
replace  mpio=`beg'max18401 if mpio==.
replace  mpio=`beg'max28401 if mpio==.
}

keep periodo cmap ent em ob em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 mpio mpioraw_cmap84

save "`inegidir'XXX Data/for_david_atkin_raw_muni.dta", replace

cap gen cmap84=cmap if cmap<9999
cap gen cmap94=cmap if cmap>9999
gen cmap94_4dig=floor(cmap94/100)
gen cmap94_3dig=floor(cmap94/1000)
sort cmap94_3dig
merge cmap94_3dig using "`inegicreate'Cmap94_to_scian02_3digit_concordance.dta", nokeep _merge(_me94)
sort scian02_3d
merge scian02_3d using "`dir'scian02_3digit_to_hcode_concordance.dta", nokeep _merge(_me942) keep(hcode)
rename hcode hcode94
cap {
sort cmap84
merge cmap84 using "`inegicreate'CMAP84toRAMA84.dta", nokeep _merge(_me84)
sort rama84
merge rama84 using  "`dir'rama84_to_hcode_concordance.dta",  nokeep keep(hcode) _merge(_me842)
rename hcode hcode84
}
egen hcode=rowmin(hcode*)

drop cmap94_?dig
gen muncenso= ent*1000+ mpio 
*replace  muncenso= ent*1000+ mpio if cmap<9999
*these codes are currently wrong.
keep  periodo  muncenso em ob em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 hcode
collapse (sum) em ob em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 , by(periodo  muncenso hcode)
sort periodo  muncenso hcode

save "`inegicreate'XXX_raw_muni.dta", replace







*so now I have all three files at hcode level by municipality. As i dont yet have the mun codes prior to 91 I will merge in what I do have. 
*So use verhoogan panel file, and then add from the raw post 94. Actually this is silly. Just use raw data post 92. When I get other data use that.
/*
use "`dir'XXX_8401.dta", clear
gen all=em+ob
gen all_exporter1=em_exporter1 + ob_exporter1
gen all_exporter2=em_exporter2 + ob_exporter2
renvars em* ob* all*,  prefix(P)
sort periodo  muncenso hcode
merge periodo  muncenso hcode using "`dir'XXX_raw_cmap84.dta"
drop if muncenso==.
gen all=em+ob
gen all_exporter1=em_exporter1 + ob_exporter1
gen all_exporter2=em_exporter2 + ob_exporter2
renvars em* ob* all*,  prefix(R)

rename periodo year
egen id=group(muncenso hcode)
tsset id year
foreach type of varlist P* R*  {
gen delta`type'=d.`type'
}



foreach varx in em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 all em ob all_exporter1 all_exporter2 {
foreach beg in "" "delta" {
gen `beg'D`varx'=`beg'R`varx' - `beg'P`varx'
gen `beg'`varx'=`beg'D`varx' + `beg'P`varx'
replace `beg'`varx'=`beg'P`varx' if `beg'R`varx'==.
replace `beg'`varx'=`beg'R`varx' if `beg'P`varx'==.

*this is the new data difference
*egen `varx'=rowmax(R`varx' P`varx')
}
}
*so basically use raw changes excpet where missing in which case bring in panel changes. may jump in mid 90's
*if just want raw consistent data look 1994-2001


drop *P* *R* *D* *merge* id
renvars *exporter1* , sub(exporter1 expa00)
renvars *exporter2* , sub(exporter2 expb00)
renvars *em *ob *all, postfix(00)
renvars *em* , sub(em ski)
renvars *ob* , sub(ob usk)
sort  muncenso year hcode

save "`dir'Inegi_xxx_merge.dta", replace
*/



use  "`inegidir'YYY Data/totempobrmunic.dta", clear
gen muncenso= ent*1000+ muni
rename  TotEmpleadossMunExp25  TotEmpleadosMunExp25

fillin year muncenso
mvencode Tot*, mv(0) o 

gen all0021= TotEmpleadosMun+ TotObrerosMun
gen all_expa0021=TotEmpleadosMunExp+ TotObrerosMunExp
gen all_expb0021=TotEmpleadosMunExp25+ TotObrerosMunExp25
renpfix TotEmpleadosMun ski
renpfix TotObrerosMun usk
renvars ski* usk* , sub(Exp _expa)
renvars ski* usk* , sub(expa25 expb)
renvars ski* usk* , postfix(0021)

keep  year muncenso  ski* usk* all*
order  year muncenso  ski* usk* all*

egen id=group(muncenso)
tsset id year
foreach type of varlist ski* usk* all*  {
replace `type'=`type'/12
*these are total employment in year summing each month
gen delta`type'=d.`type'
gen delta2`type'=(d.`type')/2+(f.d.`type')/2
*this is the more comparable measure to the IMSS data. Since these are id year averages, for demp86 I take (emp87+emp86)/2 - (emp86+emp85)/2
}
drop id
*keep muncenso  year delta*
sort  muncenso  year 
save "`inegicreate'inegi_yyy.dta", replace

*yyy is 21


*now get total in mun/state by year from xxxs raw data
foreach ends in raw_cmap84 8401 9301 {
clear
insheet using "`inegidir'XXX Data/for_david_atkin_`ends'.csv"
rename periodo year
gen muncenso94= ent*1000+ mpio if cmap>9999
*replace  muncenso= ent*1000+ mpio if cmap<9999
gen muncenso84= ent*1000+ mpio if cmap<9999
gen muncenso=muncenso94 // change this when I get mun codes
gen all=em+ob
gen all_exporter1=em_exporter1 + ob_exporter1
gen all_exporter2=em_exporter2 + ob_exporter2

foreach unit in  muncenso ent {
preserve 
drop if `unit'==.
keep em ob all em_exporter1 ob_exporter1 all_exporter1 em_exporter2 ob_exporter2 all_exporter2 year `unit'
collapse (sum) em ob all em_exporter1 ob_exporter1 all_exporter1 em_exporter2 ob_exporter2 all_exporter2, by(year `unit')
fillin year `unit' 
mvencode em* ob* all*, mv(0) o
tsset `unit' year
foreach type of varlist all* em* ob*  {
gen delta`type'=d.`type'
gen delta2`type'=(d.`type')/2+(f.d.`type')/2
*this is the more comparable measure to the IMSS data. Since these are id year averages, for demp86 I take (emp87+emp86)/2 - (emp86+emp85)/2
}
renvars *exporter1* , sub(exporter1 expa)
renvars *exporter2* , sub(exporter2 expb)
renvars *em* , sub(em ski)
renvars *ob* , sub(ob usk)
sort `unit' year
save "`inegicreate'inegi_xxx_`ends'_`unit'.dta", replace
restore
}
}


*now get total in mun/state by year from xxxs raw data
foreach ends in raw_muni {
clear
use "`inegidir'XXX Data/for_david_atkin_`ends'.dta"
rename periodo year
gen muncenso94= ent*1000+ mpio 
*replace  muncenso= ent*1000+ mpio if cmap<9999
*gen muncenso84= ent*1000+ mpio if cmap<9999
gen muncenso=muncenso94 // change this when I get mun codes
gen all=em+ob
gen all_exporter1=em_exporter1 + ob_exporter1
gen all_exporter2=em_exporter2 + ob_exporter2

foreach unit in  muncenso ent {
preserve 
drop if `unit'==.
keep em ob all em_exporter1 ob_exporter1 all_exporter1 em_exporter2 ob_exporter2 all_exporter2 year `unit'
collapse (sum) em ob all em_exporter1 ob_exporter1 all_exporter1 em_exporter2 ob_exporter2 all_exporter2, by(year `unit')
fillin year `unit' 
mvencode em* ob* all*, mv(0) o
tsset `unit' year
foreach type of varlist all* em* ob*  {
gen delta`type'=d.`type'
gen delta2`type'=(d.`type')/2+(f.d.`type')/2
*this is the more comparable measure to the IMSS data. Since these are id year averages, for demp86 I take (emp87+emp86)/2 - (emp86+emp85)/2
}
renvars *exporter1* , sub(exporter1 expa)
renvars *exporter2* , sub(exporter2 expb)
renvars *em* , sub(em ski)
renvars *ob* , sub(ob usk)
sort `unit' year
save "`inegicreate'inegi_xxx_`ends'_`unit'.dta", replace
restore
}
}


use  "`inegicreate'inegi_xxx_raw_cmap84_muncenso.dta", clear
renvars ski* usk* all* delta*, postfix(0020)
keep delta* ski* usk* all* muncenso year
sort muncenso year
save "`inegicreate'temp111.dta", replace

use  "`inegicreate'inegi_xxx_raw_muni_muncenso.dta", clear
renvars ski* usk* all* delta*, postfix(0024)
keep delta* ski* usk* all* muncenso year
sort muncenso year
save "`inegicreate'temp113.dta", replace

use  "`inegicreate'inegi_xxx_9301_muncenso.dta", clear
renvars ski* usk* all* delta*, postfix(0023)
keep delta* ski* usk* all* muncenso year
sort muncenso year
save "`inegicreate'temp112.dta", replace

use  "`inegicreate'inegi_xxx_8401_muncenso.dta", clear
renvars ski* usk* all* delta*, postfix(0022)
keep delta* ski* usk* all* muncenso year
sort muncenso year
merge muncenso year  using "`inegicreate'temp111.dta" , _merge(_mergeraw) keep(delta* ski* usk* all* muncenso year)
sort muncenso year
merge muncenso year  using "`inegicreate'temp112.dta" , _merge(_mergeraw2) keep(delta* ski* usk* all* muncenso year)
sort muncenso year
merge muncenso year  using "`inegicreate'temp113.dta" , _merge(_mergeraw3) keep(delta* ski* usk* all* muncenso year)
sort muncenso year
merge muncenso year  using "`inegicreate'inegi_yyy.dta" , _merge(_mergeyyy) keep(delta* ski* usk* all* muncenso year)
save "`inegicreate'inegi_xxx_yyy_combo.dta", replace
erase "`inegicreate'temp111.dta"
erase "`inegicreate'temp112.dta"
erase "`inegicreate'temp113.dta"



*now we are getting the municipality list to the 1991 municipalities
do "`dir'munchanges.do"

foreach var of varlist delta*  ski* usk* all* {
cap egen x`var'=total(`var'), by (muncenso year) missing
cap drop `var'
}
renpfix x 
egen tagmunyear=tag(muncenso year)
drop if tagmunyear==0
ls
sort muncenso
merge muncenso using `dir'mungeog, _merge(_mergegeog) keep(state) nokeep
*fillin year muncenso
compress
sort year muncenso
save "`tempdir'inegi_simple_skill.dta", replace

rename muncenso munimx
sort munimx
merge munimx using `dir'zonamet.dta, nokeep _merge(_mergeZM)
drop _mergeZM
replace munimxZM=munimx if munimxZM==.
drop munimx
rename munimxZM muncenso
replace muncenso=12 if muncenso>8999 & muncenso<10000

foreach var of varlist delta* ski* usk* all* {
cap egen x`var'=total(`var'), by (muncenso year) missing
cap drop `var'
}


renpfix x 
egen tagmunyear2=tag(muncenso year)
drop if tagmunyear2==0
cap drop state
cap drop _fillin

sort muncenso
merge muncenso using `dir'mungeogZM, _merge(_mergegeogzm) keep(state)





*now this gets all the firm size variables to be two digits apart from 100 which is three

compress
sort year muncenso
save "`tempdir'inegi_simpleZM_skill.dta", replace



 
joinby muncenso year using "`dir'munworkdatafirm.dta", unm(u)


 


foreach var of varlist delta*  ski* usk* all* {
replace  `var'=`var'/2 if splitters==2
}
foreach var of varlist delta*  ski* usk* all* {
cap egen x`var'=total(`var'), by (muncensonew year) missing
cap drop `var'
}





renpfix x 


egen tagmunyear3=tag(muncensonew year)
drop if tagmunyear3==0

drop muncenso
rename muncensonew muncenso






*now this gets all the firm size variables to be two digits apart from 100 which is three
forval n=20/24 {
egen count`n'=count(deltaall00`n'), by(year)
mvencode delta*00`n' if count`n'>0, mv(0) o
egen counta`n'=count(all00`n'), by(year)
mvencode all*00`n' ski*00`n' usk*00`n' if counta`n'>0, mv(0) o
}

*so fill in zeros where no firms in mun



compress
sort year muncenso
save "`tempdir'inegi_simpleMerge_skill.dta", replace





*keep year muncenso delta*00300 delta*00301
*sort year muncenso 
*save "`dir'inegi_simpleMerge_total.dta", replace

use year muncenso deltaempImaq00* deltaemp50* deltaemp00* emp00* emp50* using "`tempdir'newind_simpleMerge.dta"



foreach thing in deltaempImaq00 deltaemp00 deltaemp50 emp00 emp50  {
gen `thing'20=`thing'2+`thing'4 + `thing'1+`thing'3 + `thing'6+`thing'5 +`thing'16
gen `thing'21=`thing'2+`thing'4 + `thing'1+`thing'3 + `thing'6+`thing'5 +`thing'16
gen `thing'22=`thing'2+`thing'4 + `thing'1+`thing'3 + `thing'6+`thing'5 +`thing'16
gen `thing'23=`thing'2+`thing'4 + `thing'1+`thing'3 + `thing'6+`thing'5 +`thing'16
gen `thing'24=`thing'2+`thing'4 + `thing'1+`thing'3 + `thing'6+`thing'5 +`thing'16
gen `thing'26=`thing'9+`thing'10+`thing'14
gen `thing'29=`thing'11+`thing'12 +`thing'13 

gen `thing'25=`thing'2+`thing'4 + `thing'1+`thing'3 + `thing'6+`thing'5 + `thing'7+`thing'8  + `thing'9+`thing'10 + `thing'11+`thing'12 +`thing'13 +`thing'14 +`thing'15 +`thing'16 +`thing'17
*all jobs



foreach nr of numlist  1/17 {
drop `thing'`nr'
}
}

sort year muncenso
merge  year muncenso using "`tempdir'inegi_simpleMerge_skill.dta", nokeep _merge(_mergemaq)




foreach ends in 20 21 22 23 24 { //20 is xxxs raw data (so no codes prior to 1994), 21 is yyys-starts one year later for some reason, 22 is xxxs panel (so codes back to 85), 23 is xxxs post 93 data
gen deltamaq00`ends'=deltaempImaq00`ends'
*maquiladoras (approx)
gen deltaempx00`ends'=deltaemp00`ends' if deltaall00`ends'!=.
gen deltanex00`ends'=deltaemp00`ends'-deltaall00`ends'-deltamaq00`ends'
* firms not maquiladoras or in the INEGI sample
foreach type in a b { //a is exports anything, b is export 25% of output
gen deltanex`type'00`ends'=deltaemp00`ends'-deltaall_exp`type'00`ends'-deltamaq00`ends'
*firms that are not maquialdoras or exporters in INEGI sample
gen deltanmq`type'00`ends'=deltaall_exp`type'00`ends'
*firms that are exporters in INEGI sample
gen deltaski`type'00`ends'=deltaski_exp`type'00`ends'
*workers that are at skilled exporters in INEGI sample
gen deltausk`type'00`ends'=deltausk_exp`type'00`ends'
*workers that are at unskilled exporters in INEGI sample
gen deltaexp`type'00`ends'=deltaall_exp`type'00`ends'+deltamaq00`ends'
*total exporters (maq + firms)
gen deltaskinx`type'00`ends'=deltaski00`ends'-deltaski_exp`type'00`ends'
*workers that are at skilled non-exporters in INEGI sample
gen deltausknx`type'00`ends'=deltausk00`ends'-deltausk_exp`type'00`ends'
*workers that are at unskilled non-exporters in INEGI sample
gen deltanx`type'00`ends'=deltaall00`ends'-deltaall_exp`type'00`ends'
*workers that are at non-exporters in INEGI sample
}

gen delta2maq00`ends'=deltaempImaq00`ends'
*maquiladoras (approx)
gen delta2empx00`ends'=deltaemp00`ends' if delta2all00`ends'!=.
gen delta2nex00`ends'=deltaemp00`ends'-delta2all00`ends'-delta2maq00`ends'
* firms not maquiladoras or in the INEGI sample
foreach type in a b { //a is exports anything, b is export 25% of output
gen delta2nex`type'00`ends'=deltaemp00`ends'-delta2all_exp`type'00`ends'-delta2maq00`ends'
*firms that are not maquialdoras or exporters in INEGI sample
gen delta2nmq`type'00`ends'=delta2all_exp`type'00`ends'
*firms that are exporters in INEGI sample
gen delta2ski`type'00`ends'=delta2ski_exp`type'00`ends'
*workers that are at skilled exporters in INEGI sample
gen delta2usk`type'00`ends'=delta2usk_exp`type'00`ends'
*workers that are at unskilled exporters in INEGI sample
gen delta2exp`type'00`ends'=delta2all_exp`type'00`ends'+delta2maq00`ends'
*total exporters (maq + firms)
gen delta2skinx`type'00`ends'=delta2ski00`ends'-delta2ski_exp`type'00`ends'
*workers that are at skilled non-exporters in INEGI sample
gen delta2usknx`type'00`ends'=delta2usk00`ends'-delta2usk_exp`type'00`ends'
*workers that are at unskilled non-exporters in INEGI sample
gen delta2nx`type'00`ends'=delta2all00`ends'-delta2all_exp`type'00`ends'
*workers that are at non-exporters in INEGI sample
}

}





sort year muncenso
save "`tempdir'newind_simpleMerge_exporters_new.dta", replace


pause on
pause here 

do "C:\Work\Mexico\Revision\New_code\MCohort_Firm_Merge_redo_exporters_new.do"

die
**/
*idea is as follows... Assume all exporters either large firms in EIM or maquiladoras. 
*Then can get export jobs from these three sources and have remainder of jobs from IMSS




*now by hcode. this is for stats about maq and exporters in 2.1


foreach set in 8401 raw_cmap84  9301 {
use "`inegicreate'XXX_`set'", clear
*drop if periodo<1993
drop if muncenso==.
rename periodo year

gen all=em+ob
gen all_exporter1=em_exporter1 + ob_exporter1
gen all_exporter2=em_exporter2 + ob_exporter2


*now i fill in missings when there are obs for thta mun/ind but not all years
reshape wide  ob* em* all*  , i(muncenso year) j(hcode)
fillin year muncenso
foreach type of varlist all???  {
egen c`type'=count(`type'), by(muncenso)
mvencode `type' if c`type'>0, mv(0) o
drop c`type'
}
foreach type in em ob all { 
foreach del in ""  {
foreach ends in "" "_exporter1" "_exporter2" {
foreach indu in 310 311 312 314 315 321 322 323 324 325 326 330 331 332 333 335 336 337 {
cap mvencode `del'`type'`ends'`indu' if all`indu'!=. , mv(0) o
}
}
}
}
reshape long  em ob em_exporter1 ob_exporter1 em_exporter2 ob_exporter2 all all_exporter1 all_exporter2  , i(muncenso year) j(hcode)

egen id=group(muncenso hcode)
tsset id year
foreach type of varlist all* em* ob*  {
gen delta`type'=d.`type'
}

drop id
renvars *exporter1* , sub(exporter1 expa00)
renvars *exporter2* , sub(exporter2 expb00)
renvars *em *ob *all, postfix(00)
renvars *em* , sub(em ski)
renvars *ob* , sub(ob usk)
sort  muncenso year hcode

*Now I have the data set in long form, reshape it wide
reshape wide  ski* usk* all* delta* , i(muncenso year) j(hcode)
*mvencode ski* usk* all* delta*, mv(0) if year>1984
*note that the change at 94 is dubious as delat would appear just because of resampling. presumably I dont want that. 
*I guess I want sum of deltas from panel plus sum of deltas from new firms.

*now I get mun totals"
foreach type in ski usk all { 
foreach del in "" "delta" {
foreach ends in "" "_expa" "_expb" {
egen `del'`type'`ends'00300=rowtotal(`del'`type'`ends'00*), missing
}
}
}
*300 is total manufacturing
order year muncenso
sort muncenso year 
save "`inegicreate'Inegi_xxx_merge_hcode.dta", replace

preserve
keep delta* year muncenso
*keep delta*300 year muncenso
sort muncenso year 
save "`inegicreate'inegi_xxx.dta", replace
restore
**/




*now we are getting the municipality list to the 1991 municipalities
do "`dir'munchanges.do"

foreach var of varlist delta*   ski* usk* all*  {
cap egen x`var'=total(`var'), by (muncenso year) missing
cap drop `var'
}
renpfix x 
egen tagmunyear=tag(muncenso year)
drop if tagmunyear==0
ls
sort muncenso
merge muncenso using `dir'mungeog, _merge(_mergegeog) keep(state) nokeep
*fillin year muncenso
compress
sort year muncenso
save "`tempdir'inegi_simple_skill.dta", replace

pause on
pause here 

rename muncenso munimx
sort munimx
merge munimx using `dir'zonamet.dta, nokeep _merge(_mergeZM)
drop _mergeZM
replace munimxZM=munimx if munimxZM==.
drop munimx
rename munimxZM muncenso
*do "`dir'zonametropolitan.do"
replace muncenso=12 if muncenso>8999 & muncenso<10000

foreach var of varlist delta*  ski* usk* all*  {
cap egen x`var'=total(`var'), by (muncenso year) missing
cap drop `var'
}


renpfix x 
egen tagmunyear2=tag(muncenso year)
drop if tagmunyear2==0
cap drop state
cap drop _fillin

sort muncenso
merge muncenso using `dir'mungeogZM, _merge(_mergegeogzm) keep(state)





*now this gets all the firm size variables to be two digits apart from 100 which is three

compress
sort year muncenso



 
joinby muncenso year using "`dir'munworkdatafirm.dta", unm(u)


 


foreach var of varlist delta*  ski* usk* all*  {
replace  `var'=`var'/2 if splitters==2
}
foreach var of varlist delta*   ski* usk* all*  {
cap egen x`var'=total(`var'), by (muncensonew year) missing
cap drop `var'
}


renpfix x 
egen tagmunyear3=tag(muncensonew year)
drop if tagmunyear3==0

drop muncenso
rename muncensonew muncenso




*now this gets all the firm size variables to be two digits apart from 100 which is three
foreach n in 310 311 312 314 315 321 322 323 324 325 326 330 331 332 333 335 336 337 {
cap {
egen count`n'=count(deltaall00`n'), by(year)
mvencode delta*00`n' if count`n'>0, mv(0) o
egen counta`n'=count(all00`n'), by(year)
mvencode all*00`n' ski*00`n' usk*00`n' if counta`n'>0, mv(0) o
}
}

*so fill in zeros where no firms in mun


foreach thing in all all_expa all_expb  {
foreach cut in 00 50 {
cap gen `thing'`cut'11=`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	
cap gen `thing'`cut'12=`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'13=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+	`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'18=`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'14=   `thing'`cut'310    +   `thing'`cut'326    +   `thing'`cut'325    +    `thing'`cut'311    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'324    +   `thing'`cut'330    +   `thing'`cut'323 
cap gen `thing'`cut'19=   `thing'`cut'335    +   `thing'`cut'332    +   `thing'`cut'333   +   `thing'`cut'331 +   `thing'`cut'337 +    `thing'`cut'315        +   `thing'`cut'336    +   `thing'`cut'314       +   `thing'`cut'312   

cap gen `thing'`cut'26=  `thing'`cut'314 + `thing'`cut'315 + `thing'`cut'336    +   `thing'`cut'332    +   `thing'`cut'333   +   `thing'`cut'331 +   `thing'`cut'337 +   `thing'`cut'335

cap gen `thing'`cut'27=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+ `thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'321	+	`thing'`cut'322	+ `thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	

cap gen `thing'`cut'25=`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'321	+	`thing'`cut'322	+ `thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	

}
}


foreach thing in all all_expa all_expb  {
foreach cut in 00 50 {
forval n=10/99{
cap egen tot`thing'`cut'`n'=total(`thing'`cut'`n') if muncenso!=12, by(year)
cap egen tot2`thing'`cut'`n'=total(`thing'`cut'`n') , by(year)
}
}
}

compress
sort year muncenso

pause on
pause `set' 

}
