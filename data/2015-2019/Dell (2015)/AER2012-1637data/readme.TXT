Readme:

These files can be used to reproduce the tables and figures in "Trafficking Networks and the Mexican Drug War." Both program and data files are clearly labeled. Some confidential data, described in detail in the study, have been redacted. Either the variable is set to missing, or the relevant data file is not included, as described in more detail below. These data can be requested from the Mexican federal government at https://www.infomex.org.mx/gobiernofederal/home.action. 

Software requirements: Stata, Matlab, and R

Table 1: Run the do file maketable1.do

Table 2: Run the do file maketable2.do. The variable drughom (drug trade-related homicides) has been redacted. Panel B can be reproduced with the data made publicly available here.

Table 3: Run the do file maketable3.do. The variable drughom has been redacted. Panel B can be reproduced with the data made publicly available here.

Table 4: Run the do file maketable4.do. The variables drughom and border (bordering drug trafficking organizations) are redacted.

Table 5: Run the do file maketable5.do. The variable drughom has been redacted.

Tables 6 and 7: To obtain the predicted route variable used in Panel A of these tables, run the Matlab program SPrun.m. It will call the function SPflows.m. To obtain the predicted route variable used in Panel B, first run the Matlab program DrugNet.m to estimate the congested routing parameters. It must be run first to obtain the parameters needed to calculate the optimal weighting matrix and then again using the optimal weighting matrix in the estimation of the congestion parameters. WeightMatrix.m calculates the optimal weighting matrix. The functions TrafficObjective.m, FrankWolfe.m, and NetworkLength.m are called by the main program. Standard errors for the parameters can be obtained using CovFn.m and ConleyCovFn.m. Once the parameters are estimated, the routes can be calculated using CongestionRun.m. The following data files are not included due to confidentiality restrictions: Conf.mat (illicit drug seizures) and Org0.mat-Org10.mat (drug producing municipalities).

Once the paths are calculated, the Stata program files maketable6_panelA.do, maketable6_panelB.do, maketable7_panelA.do, and maketable7_panelB.do can be used to reproduce tables 6 and 7. The following data files are not included due to confidentiality restrictions: producers.dta (drug producing municipalities), dtrh.dta (drug-related homicides), and seizures.dta (illicit drug seizures). 

Figures 1 and 2 are maps. 

Figure 3 can be reproduce using makefigure3.do. The variable drughom has been redacted.

Figure 4 can be reproduced using makefigure4.do.

To reproduce Figure 5, Panels A and B, first run the Stata program makefigure5_panelsAB.do. The variable drughom has been redacted. Then us the output from this program to run the R programs BaselineQ.R and BaselineQind.R. To reproduce Panel C, use the Stata program makefigure5_panelC.do and the R program long_all_q.R. The R programs can also be run without first running the Stata programs, as the output from the Stata programs is also in the reproduction folder. 






