version 13
cd "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Handley and Limao (2017)/full"
adopath + "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Handley and Limao (2017)/full"

drop _all
set more off
set matsize 800

/**** REPLICATION OF APPENDIX *****/
do replication_appendix.do

graph close _all
