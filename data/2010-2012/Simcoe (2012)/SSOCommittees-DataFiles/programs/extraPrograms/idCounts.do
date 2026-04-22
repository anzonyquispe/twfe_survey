*************************************
* Top Contributors by Time-Period / TechArea

use rawdata/ietfIdAu9005a, clear


** Merge TechArea Names
replace wg = "ipngwg" if (wg == "ipv6" | wg == "ipng")
replace wg = "osix400" if wg == "osix500"
replace wg = "pwe3" if wg == "pwe3i"
replace wg = "svrloc" if wg == "srvloc"
replace wg = "x400ops" if wg == "x400opx"
rename wg wgname
sort wgname

merge wgname using stata/wgareas, uniqusing
drop if _merge == 2
encode area2, gen(techarea)
replace techarea = 0 if techarea == .
label def techarea 0 "none", modify
drop _merge area area2

keep series date affil techarea tldaffiltype
drop if affil == ""
g tmp = year(date)
bysort series : egen yr = min(tmp)
drop tmp date
duplicates drop
keep if yr >=1992 & yr<=2004
save stata/temp, replace

** Top Contributors by Techarea
g aflCnt=1
*drop if (techarea == "usv" | techarea== "none" | techarea == "gen")
drop if (techarea == 9 | techarea== 0 | techarea == 2)
replace techarea = 4 if techarea == 7
collapse (sum) aflCnt, by(affil techarea tldaffiltype)

gsort techarea -aflCnt
by techarea : gen rank = _n
keep if rank <= 5
list rank techarea affil

** Top Contributors by Time Period
use stata/temp, clear
g period = 1 
replace period = 2 if yr>1994
replace period = 3 if yr>1997
replace period = 4 if yr>2000

g aflCnt=1
collapse (sum) aflCnt, by(affil period tldaffiltype)
gsort period -aflCnt
by period : gen rank = _n

log using tables/topNames.log, replace
list if rank<=6
collapse (sum) aflCnt, by(affil tldaffiltype)
gsort -aflCnt
list if _n<=25

gsort tldaffiltype -aflCnt
by tldaffiltype : g rank = _n
list if rank<=6

log close
erase stata/temp.dta
