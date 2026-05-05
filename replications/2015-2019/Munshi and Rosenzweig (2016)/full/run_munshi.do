* =============================================================================
* Munshi & Rosenzweig (2016) - Networks and Misallocation
* Partial replication: Table 6 and Table 8a
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
bootstrap, rep(200): reg mig pminc jpminc if total>=30 & cvsq<100 & icrisat==1,  cluster(castecode)

* Column 2: bootstrap reg with cvsq
di _n "--- Table 6, Column 2 ---"
bootstrap, rep(200): reg mig pminc jpminc cvsq if total>=30 & cvsq<100 & icrisat==1,  cluster(castecode)

* Column 3: areg with village FE
di _n "--- Table 6, Column 3 ---"
bootstrap, rep(200): areg mig pminc jpminc cvsq vjpminc  if total>=30 & cvsq<100 & icrisat==1, a(village) cluster(castecode)

* Column 4: cgmreg two-way clustering
di _n "--- Table 6, Column 4 ---"
cgmreg mig pminc jpminc cvsq vpminc if total>=30 & cvsq<100 & icrisat==1,  cluster(village castecode)

* Column 5: cgmreg with village amenities
di _n "--- Table 6, Column 5 ---"
cgmreg mig pminc jpminc cvsq vpminc second bank hlthctr bus towndist if total>=30 & cvsq<100 & icrisat==1,  cluster( village castecode)
testparm second bank hlthctr bus towndist

* Column 6: cgmreg with village FE proxy
di _n "--- Table 6, Column 6 ---"
cgmreg mig pminc jpminc cvsq vjpminc second bank hlthctr bus towndist if total>=30 & cvsq<100 & icrisat==1,  cluster( village castecode)
testparm second bank hlthctr bus towndist

di _n "===== TABLE 6 DONE ====="


* =============================================================================
* TABLE 8A -- Wild Bootstrap Tests
* =============================================================================
di _n "===== TABLE 8A ====="

#delimit ;

use "$datadir/table8a.dta", clear ;

di _n "--- Table 8a, Panel 1 ---" ;
cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

di _n "--- Table 8a, Panel 2 ---" ;
cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

di _n "--- Table 8a, Panel 3 ---" ;
cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

di _n "--- Table 8a, Panel 4 ---" ;
cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

#delimit cr

* NOTE: Table 8a also uses table8b.dta but that file is not available in the replication package
* The last two panels (using table8b.dta) are skipped

di _n "===== TABLE 8A DONE ====="

log close
