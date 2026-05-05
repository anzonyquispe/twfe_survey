* =============================================================================
* Munshi & Rosenzweig (2016) - Networks and Misallocation
* Partial replication: Table 6 (bootstrap + reghdfe for 2-way clustering)
* and Table 8a (cgmwildboot)
* =============================================================================

clear all
set more off
cap log close _all

* Paths
global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Munshi and Rosenzweig (2016)/data"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Munshi and Rosenzweig (2016)/full"

cd "$outdir"

log using "$outdir/run_munshi.log", text replace

* =============================================================================
* TABLE 6 -- Migration and Income
* =============================================================================
di _n "===== TABLE 6 ====="

use "$datadir/table6", clear

* Column 1: bootstrap reg
di _n "--- Table 6, Column 1 ---"
bootstrap, rep(200) seed(12345): reg mig pminc jpminc if total>=30 & cvsq<100 & icrisat==1,  cluster(castecode)

* Column 2: bootstrap reg with cvsq
di _n "--- Table 6, Column 2 ---"
bootstrap, rep(200) seed(12345): reg mig pminc jpminc cvsq if total>=30 & cvsq<100 & icrisat==1,  cluster(castecode)

* Column 3: areg with village FE
di _n "--- Table 6, Column 3 ---"
bootstrap, rep(200) seed(12345): areg mig pminc jpminc cvsq vjpminc  if total>=30 & cvsq<100 & icrisat==1, a(village) cluster(castecode)

* Columns 4-6: two-way clustering (village, castecode) using reghdfe
* Original uses cgmreg which hangs; reghdfe provides equivalent two-way clustering
di _n "--- Table 6, Column 4 (reghdfe) ---"
reghdfe mig pminc jpminc cvsq vpminc if total>=30 & cvsq<100 & icrisat==1, noabsorb vce(cluster village castecode)

di _n "--- Table 6, Column 5 (reghdfe) ---"
reghdfe mig pminc jpminc cvsq vpminc second bank hlthctr bus towndist if total>=30 & cvsq<100 & icrisat==1, noabsorb vce(cluster village castecode)
testparm second bank hlthctr bus towndist

di _n "--- Table 6, Column 6 (reghdfe) ---"
reghdfe mig pminc jpminc cvsq vjpminc second bank hlthctr bus towndist if total>=30 & cvsq<100 & icrisat==1, noabsorb vce(cluster village castecode)
testparm second bank hlthctr bus towndist

di _n "===== TABLE 6 DONE ====="


* =============================================================================
* TABLE 8A -- Wild Bootstrap Tests
* =============================================================================
di _n "===== TABLE 8A ====="

#delimit ;

use "$datadir/table8a.dta", clear ;

di _n "--- Table 8a, Row 1 ---" ;
cap noi cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

di _n "--- Table 8a, Row 2 ---" ;
cap noi cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

di _n "--- Table 8a, Row 3 ---" ;
cap noi cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

di _n "--- Table 8a, Row 4 ---" ;
cap noi cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

#delimit cr

* NOTE: table8b.dta not available, so last 2 rows of Table 8a are skipped

di _n "===== TABLE 8A DONE ====="

log close
