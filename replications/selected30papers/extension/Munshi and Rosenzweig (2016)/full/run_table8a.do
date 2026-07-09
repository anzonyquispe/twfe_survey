* Table 8a only
clear all
set more off
cap log close _all
* --- Auto-detect user / set repo paths --------------------------------
* Add a branch with your OS username if you're a new collaborator.
if "`c(username)'" == "anzony.quisperojas" {
    global twfe_root   "/Users/anzony.quisperojas/Documents/GitHub/twfe_survey"
    global papers_root "/Users/anzony.quisperojas/Documents/GitHub/papers_economic"
}
else if "`c(username)'" == "Usuario" {
    global twfe_root   "C:/Users/Usuario/Documents/GitHub/twfe_survey"
    global papers_root "C:/Users/Usuario/Documents/GitHub/papers_economic"
}
else {
    di as error "Unknown user `c(username)'. Add your repo paths to the user-detection block at the top of this dofile."
    exit 198
}
* ---------------------------------------------------------------------

adopath + "${twfe_root}/replications/2015-2019/Munshi and Rosenzweig (2016)/full"
global datadir "${twfe_root}/data/2015-2019/Munshi and Rosenzweig (2016)/data"
global outdir  "${twfe_root}/replications/2015-2019/Munshi and Rosenzweig (2016)/full"
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
