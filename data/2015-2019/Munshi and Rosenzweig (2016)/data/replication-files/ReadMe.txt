BASIC INSTRUCTIONS TO REPLICATE STRUCTURAL ESTIMATION for Munshi and Rosenzweig (2015)
"Networks and Misallocation":

Note that all Maple progams require a file "data.raw" in the working directory in order 
to run properly. The contents and format of data.raw is not consistent across 
specifications, so make sure to run the appropriate Stata do-file before running each 
specification in order to generate the correct data.raw data table.

To reproduce the benchmark "single nu" specification (Table 7, columns (3) and (4)), the 
benchmark counterfactual  simulations in Figure 6, and the counterfactual simulations in 
Figure A1, do the following:
1. run the Stata do-file: "wage_gap_one_nu.do"
2. run the Maple program "benchmark_single_nu.mw"
3. view the resulting Excel files to reconstruct the benchmark observations in Figure 6
(decbeta_single_nu.xlsx contains data for decreasing beta, incnu_single_nu.xlsx contains
data for increasing nu) and Figure A1 (decnu_single_nu.xslx contains data for this figure). 
Note that there might be some slight variation in the predicted migration level due to 
optimization errors ("bads").

To reproduce the "estimating nu by absolute income-class" specification (Table 7, columns 
(5) and (6)), do the following:
1. run the Stata do-file: "wage_gap_by_abs_inc.do"
2. run the Maple program "nu_by_absolute_inc.mw"

To reproduce the "estimating nu by caste" specification (Table 7, columns (7) and (8)):
1. run the Stata do-file: "wage_gap_nu_by_caste.do"
2. run the Maple program "nu_by_caste.mw"

To reproduce the "flexible" specification (Table 7, columns (9) and (10)), the 
corresponding counterfactual simulations in Figure 6, and the additional counterfactual
simulations in Figure 7 and Figure 8, do the following:
1. run the Stata do-file: "wage_gap_nu_by_caste.do"
2. run the Maple program "nu_by_caste_flexible.mw"
3. view resulting Excel files to reconstruct counterfactual simulations:
	- Figure 6, flexible, decreasing beta: decbeta_flex.xslx
	- Figure 6, flexible, increasing nu: incnu_flex
	- Figure 7, decbeta_flex_highabsinc
	- Figure 8, decbeta_flex_lowabsinc.xlsx.
Note that the flexible specification uses a grid search for optimization rather than
numerical methods. 

To reproduce the results with different numbers of relative income classes (Table A4):
For 4 relative income classes:
1. run the Stata do-file: "wage_gap_4_rel_inc_classes.do"
2. run the Maple program "4_rel_inc_classes.mw"
For 6 relative income classes
1. run the Stata do-file: "wage_gap_6_rel_inc_classes.do"
2. run the Maple program "6_rel_inc_classes.mw"

Calculating standard errors (for all specifications):
All standard errors in the tables mentioned above (Table 7 and Table A4) are estimated
using a leave-one-out "jackknife" procedure. This procedure can be run by uncommenting
the last part of each Maple file. Note that jackknifing can take several hours or even
several days. It is recommended to divide the leave-one-out for loop into chunks of 10
(i.e. run for x from 1 to 10, then from 11 to 20, etc.). Programs sometimes freeze if
they are left running for too long, which is one reason why it is recommended to break 
it up. Once complete, the formula for calculating the standard error from the 
leave-one-out estimation results is:
sqrt[ ((n-1)/n) * sum_i (x_{-i} - x)^2 ]
where x_[-i] is the estimate when leaving out observation i, and x is the original 
estimate. Since 100 castes are used for this estimation, n is 100 in the formula above.