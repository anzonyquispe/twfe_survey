capture cd u:/fdz295

**************************************************************
*****             Master-Datei des Projektes             *****
*  Schätzung der qualifikatorischen Nachfrageelastzitäten    *
******             für Deutschland (fdz259)             ******
**************************************************************

* Preliminaries 
clear mata
clear
cap clear matrix
pause on
set graphics off
set emptycells drop , perm 
version 13.1
set more off
set linesize 255
set matsize 11000
set maxvar  32767
mata: mata mlib index				//update mata libraries
mata: mata set matafavor speed, perm		//favors speed over space
set seed 12345671
adopath ++ prog             //adds all Do-Files into Ordner prog

**************************************************************
*******************       Setting      ***********************
**************************************************************

*** Switch data prep on/off
global gerdaten=1	// 0_*.do
global perdaten=1	// 1_*.do
global empdaten=1	// 2_*.do
global comdaten=1	// 3_*.do

*** Project definition
global pro G

*** Waves
global wave 	"1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008"  

global start_year : word 1 of $wave
global wave_rest : subinstr global wave "${start_year}" ""

global sample = 0		//0: full 1: work 2: test 
global sam full

*****************************************************************
*****************************************************************
** Run programs ** 
*****************************************************************
*****************************************************************

** ado-files
*ssc inst reghdfe.ado		//comment in if not installed
*ssc inst tabstatmat.ado	//comment in if not installed
*ssc inst estout.ado 		//comment in if not installed

** Data preparation
if $gerdaten == 1 	do "${prog}/0_GewerbDat_${pro}.do"  // Prep of muni data 
if $perdaten == 1      	do "${prog}/1_PersDat_${pro}.do"    // Prep of worker data
if $empdaten == 1 | $perdaten == 1 	///
			do "${prog}/2_BetrDat_${pro}.do"    // Prep of firm data 
if $comdaten == 1 | $gerdaten == 1 | $empdaten == 1 | $perdaten == 1     ///
			do "${prog}/3_Combine_${pro}.do"    // Combine muni, worker and firm data to panels ready for empirical analysis 

** Empirical analysis
global datalevel DiD_firm_R3 ES_firm_R3 ES_muni_R3 DiD_muni_R3 DL_firm_R3 DiD_ind_R3      

foreach d of global datalevel {
	do "${prog}/4_Estim_${pro}_`d'.do"  
} //d
	
capture log close

** Documentation of files in data folders (required by IAB)
log using "${log}/dateiliste.log", replace
dir "${prog}/*"
dir "${log}/*"
dir "${data}/*"
dir "${orig}/*"
dir "${doc}/*"

cap log close
clear

***


