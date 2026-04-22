version 15.0
clear all
set more off

**********************************
* Replicates all figures and tables
**********************************

/*
Many scripts use the Stata package reghdfe available at: https://github.com/sergiocorreia/reghdfe.
Note the code requires a version of reghdfe earlier than version 4.5.0 07jun2018.
The earlier versions do not display the baselevel of factor variables properly, thus a custom function
called save_coefmat was added. The issue has been resolved since version 4.5.0 07jun2018
For more detials: https://github.com/sergiocorreia/reghdfe/issues/103
*/

* Table 1
include table1A.do
include table1B.do

* Table 2
include table2.do

* Table 3
* Online Appendix Table A1 
* Online Appendix Table A2
include table3.do

* Table 4
include table4.do

* Table 5
include table5A.do
include table5B.do
include table5C.do
include table5D.do

* Table 6
* Online Appendix Figure A2
* Online Appendix Figure A3
include table6.do

* Table 7
include table7.do

* Figure 1
include figure1.do

* Figure 2
include figure2.do

* Figure 3: run R script figure3.Rmd

* Figure 4
include figure4.do

* Figure 5
include figure5.do

* Figure 6
include figure6A.do
include figure6B.do

* Figure 7
* Figure 8
include figure7_8.do

* Online Appendix Table A3
include tableA3.do

* Online Appendix Figure A1
include figureA1.do
