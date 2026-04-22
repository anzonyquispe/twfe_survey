

*****This is the master files for replicating the tables of "The Collateral Channel" by Chaney et al.


/**********************************************************************************************************/
/********************************************   PROGRAMS 	      *****************************************/
/**********************************************************************************************************/

cap program drop _all 

***cleaning program: windsorize at 5*interquartile range
capture program drop clean
program define clean
sum `1',d
replace `1'=(r(p50)-5*(r(p75)-r(p25))) if `1'<(r(p50)-5*(r(p75)-r(p25)))&`1'~=.
replace `1'=(r(p50)+5*(r(p75)-r(p25))) if `1'>(r(p50)+5*(r(p75)-r(p25)))&`1'~=.
end

***cleaning program 2: windsorize at the 5 percentile level -- we use it for variables that are left-censored to 0 (debt-related variables)
capture program drop clean2
program define clean2
sum `1',d
replace `1'=r(p95) if `1'>r(p95)&`1'~=.
replace `1'=r(p5) if `1'<r(p5)&`1'~=.
end

***lag program: create varm, 1 year lagged value of var
program define lag
sort gvkey year
quietly by gvkey: gen `1'm=`1'[_n-1] if gvkey[_n-1]==gvkey&year[_n-1]==year-1
end


* set the do files folder;
cd "/Users/Thomas/Desktop/CollateralChannel/progs"

*****First we construct the first-stage regression results.
do first_stage.do

*****Then, we construct the dataset for the main regression results.
do construc.do

***this program creates 2 datasets. dataset_final (sample with firms active in 1993) and 
*** unbalanced.dta, sample of firms, with no restriction on the starting dates. 

*****Then, we construct the dataset with info on the 10k (which constructs msaownership.dta, constructed from the 10k extraction) for the 1997 year
*****this info is merged with COMPUSTAT for firms in 1997
do construc_msaownership.do

***Then we run the main regression program. 
do reg.do

***Then we run the regression for the diff in diff (before/after acquisition). 
do diff_in_diff.do

***Bubble analysis. It uses headquarter_2000.dta, which is constructed from construc_headquarter_2000.do)
do bubble.do

***Bootstrap to compute standard errors for regressions using IV specification
do bootstrap.do
