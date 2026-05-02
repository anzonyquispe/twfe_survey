cd "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications"
set more off
display "=== TEST START ==="
display "Current directory: `c(pwd)'"
use "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Handley and Limao (2017)/full/replication_maindata1.dta", clear
describe, short
display "=== TEST END ==="
