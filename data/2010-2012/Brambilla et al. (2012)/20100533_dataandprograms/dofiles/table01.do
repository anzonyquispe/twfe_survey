* TABLE 1
* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

clear
set mem 50m
set more off
set logtype text
local opt="excel bracket se nocons nonotes"
local root="results"
capture mkdir "`root'"

local outpath="`root'"+"/table1.txt"

********************************************************************************************************
* -- PANEL A
********************************************************************************************************
use data, clear

gen h1=(Exports_high1>0 & Exports_high1~=.)
gen h2=(Exports_high2>0 & Exports_high2~=.)

matrix define A=J(5,4,0)
matrix rownames A = Observations Exportedint Exportedsometime Expsales Numberofdestinations
matrix colnames A = All Exporter High1 High2

* --- Column 1
qui sum exporter
matrix A[1,1]=r(N)
matrix A[2,1]=r(mean)
qui sum exporter2
matrix A[3,1]=r(mean)
qui sum expsales
matrix A[4,1]=r(mean)
* --- Column 2
qui sum expsales if exporter==1
matrix A[1,2]=r(N)
matrix A[4,2]=r(mean)
* --- Column 3
qui sum expsales if h1==1
matrix A[1,3]=r(N)
matrix A[4,3]=r(mean)
* --- Column 4
qui sum expsales if h2==1
matrix A[1,4]=r(N)
matrix A[4,4]=r(mean)
* --- Last row
use datalong, clear
gen numberdest=1
collapse (count) numberdest (mean) exporter Exports_high1 Exports_high2, by(firmid year)
sum numberdest
matrix A[5,1]=r(mean)
sum numberdest if exporter==1
matrix A[5,2]=r(mean)
sum numberdest if Exports_high1>0
matrix A[5,3]=r(mean)
sum numberdest if Exports_high2>0
matrix A[5,4]=r(mean)

log using `outpath', replace
matrix list A
log off

********************************************************************************************************
* -- PANEL B
********************************************************************************************************
use data, clear

gen h1=(Exports_high1>0 & Exports_high1~=.)
gen h2=(Exports_high2>0 & Exports_high2~=.)
gen wage=exp(lwage)

matrix define B=J(8,4,0)
matrix rownames B = Sales se Workers se Wage se SkillShare se 
matrix colnames B = All Exporter High1 High2

* --- Column 1 ------------------------------------------
local c=1
local r=1
display `c'
foreach i of varlist sales workers wage skillp {
   qui sum `i'
   matrix B[`r',`c']=r(mean)
   local r=`r'+2
   }

* --- Column 2 ------------------------------------------
local c=`c'+1
local r=1
foreach i of varlist lsales lwork lwage skillp {
   qui xi: reg `i' exporter i.isicmain i.year, robust
   matrix B[`r',`c']=_b[exporter]
   matrix B[`r'+1,`c']=_se[exporter]
   local r=`r'+2
   }

* --- Column 3 ------------------------------------------
local c=`c'+1
local r=1
foreach i of varlist lsales lwork lwage skillp {
   qui xi: reg `i' h1 i.isicmain i.year if exporter==1, robust
   matrix B[`r',`c']=_b[h1]
   matrix B[`r'+1,`c']=_se[h1]
   local r=`r'+2
   }

* --- Column 4 ------------------------------------------
local c=`c'+1
local r=1
foreach i of varlist lsales lwork lwage skillp  {
   qui xi: reg `i' h2 i.isicmain i.year if h1==1, robust
   matrix B[`r',`c']=_b[h2]
   matrix B[`r'+1,`c']=_se[h2]
   local r=`r'+2
   }

log on
matrix list B
log close
clear
