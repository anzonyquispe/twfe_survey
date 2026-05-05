* Table 8a only
clear all
set more off
cap log close _all
adopath + "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Munshi and Rosenzweig (2016)/full"
global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Munshi and Rosenzweig (2016)/data"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Munshi and Rosenzweig (2016)/full"
cd "$outdir"
log using "$outdir/run_table8a.log", text replace

#delimit ;
use "$datadir/table8a.dta", clear ;

di _n "--- Table 8a, Row 1 ---" ;
cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

di _n "--- Table 8a, Row 2 ---" ;
cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

di _n "--- Table 8a, Row 3 ---" ;
cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

di _n "--- Table 8a, Row 4 ---" ;
cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

#delimit cr
log close
