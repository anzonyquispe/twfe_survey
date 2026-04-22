use stata/idLevel, clear

log using tables/sampleTable.log, replace
* Columns 1 and 2
keep if pubCohort >= 1993 & pubCohort <=2003
drop if (rfctype == 1 | rfctype == 2 | rfctype == 7 | rfctype == 4)
tab exiType wgDum
bysort wg : gen wgInd = (_n==1)
count if (wgInd == 1)
drop wgInd

* Age > 1
drop if age == 1
tab exiType wgDum
bysort wg : gen wgInd = (_n==1)
count if (wgInd == 1)
drop wgInd

* Estimation Sample
drop if (!wgDum | age == 1)
drop if (techarea == 0 | techarea == 2 | techarea == 9)
tab exiType wgDum
bysort wg : gen wgInd = (_n==1)
count if (wgInd == 1)
drop wgInd

log close
