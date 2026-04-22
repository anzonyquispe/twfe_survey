************************************************************************
**** DD estimates - sector level
**** Figure 2b, Figure 6a, Table A1 Panel B, Figure A4, Table A3 Panel B
************************************************************************
clear all
set more off


// Setting globals

global MainDir "XX\Replication" 			/*replace XX with main directory*/
global doaux "$MainDir\Codes\aux_programs" 	 //folder with auxiliary codes
global results "$MainDir\Results\"
global winsor p99 p99_9 p95   				 // p99.9 p99 p95 winsorization   

cd "$MainDir\Data\"


// Preparing the data

** Load data
use SectorData, clear
set more off

** Taking logs

foreach o in Tax_all Rev_all {
foreach w in $winsor {
local y `o'`w'
gen ln`y'=ln(`y')
}
}

** Simple before vs after - DD
gen post=0
replace post=1 if date_taxref_n>=tm(2007m10)
gen dd_treatRW=treatRW*post

** 6-months DD
	forvalue y=1/8{
	gen post`y'=0
	replace post`y'=1 if date_taxref_n>=(573 +6*`y')&date_taxref_n<573+6*(`y'+1)
	gen dd`y'_treatRW=treatRW*post`y'
	}
	forvalue y=0/8{
	gen post_`y'=0
	replace post_`y'=1 if date_taxref_n>=(573 -6*`y')&date_taxref_n<573 -6*(`y'-1)
	gen dd_`y'_treatRW=treatRW*post_`y'
	}	

** Format time
gen time=.
	forvalue y=1/8{
	replace time =`y' if date_taxref_n>=(573 +6*`y')&date_taxref_n<573+6*(`y'+1)
	}
	forvalue y=0/8{
	replace time =-`y' if date_taxref_n>=(573 -6*`y')&date_taxref_n<573 -6*(`y'-1)
	}	

	#delimit ;	
	label define lablx 
	-8 " Jan.04-Mar.04" 
	 -7 "Apr.04-Sep.04" 
	 -6 "Oct.04-Mar.05" 
	 -5 "Apr.05-Sep.05" 
	 -4 "Oct.05-Mar.06" 
	 -3 "Apr.06-Sep.06" 
	 -2 "Oct.06-Mar.07" 
	 -1 "Apr.07-Sep.07" 
	 0 "Oct.07-Mar.08" 
	 1 "Apr.08-Sep.08" 
	 2 "Oct.08-Mar.09" 
	 3 "Apr.09-Sep.09" 
	 4 "Oct.19-Mar.10" 
	 5 "Apr.10-Sep.10" 
	 6 "Oct.10-Mar.11" 
	 7 "Apr.11-Sep.11" 
	 8 "Oct.11-Dec.11" ;
	#delimit cr	
	label val time lablx
	
** Tag observations for graphs
egen tagg=tag(treatRW time)
	
** Regressions
global timebinsnocons6  dd_8_treatRW dd_7_treatRW dd_6_treatRW dd_5_treatRW dd_4_treatRW dd_3_treatRW dd_2_treatRW dd_1_treatRW dd_0_treatRW dd1_treatRW dd2_treatRW dd3_treatRW dd4_treatRW dd5_treatRW dd6_treatRW dd7_treatRW dd8_treatRW  


/////////////////////////////////////////////////////////////////////
// Figure 2 b
/////////////////////////////////////////////////////////////////////

local z Rev_allp99		

			*Differences across time - Coefficients for 6-month bins
			qui reg ln`z'  ${timebinsnocons6} i.date_taxref_n ibn.cnae, nocons vce(cluster cnae)
			global outcomegr `z' // input in the program to create figure
			do "${doaux}\Main_graphs_aux.do" // program to create figure



/////////////////////////////////////////////////////////////////////
// Table A1 - Panel B  (includes coefficient reported in Figure 2a)
/////////////////////////////////////////////////////////////////////

** create regression table to add columns
global outfilemain  "$results\SecMain_coefs_w"
qui reg Rev_all Rev_all
outreg2 using ${outfilemain}, nolabel  excel nonotes bracket replace


** Simple DD looping over alternative top coding options: p99 p95 p99.9
foreach w in $winsor {

local z Rev_all`w'

		* Differences-in-differences - Entire period
		qui areg ln`z'  dd_treatRW  i.date_taxref_n, absorb(cnae) vce(cluster cnae)
		outreg2  dd_treatRW  using ${outfilemain}, ctitle(`z'`l') nolabel bracket excel nonotes append	

}



/////////////////////////////////////////////////////////////////////
// Figure 6a and Figure A4
/////////////////////////////////////////////////////////////////////


foreach o in Tax_all Rev_all {

local z `o'p99

			*Differences across time - Coefficients for 6-month bins
			qui reg ln`z'  ${timebinsnocons6} i.date_taxref_n ibn.cnae if ST_1!=1, nocons vce(cluster cnae)
			global outcomegr `z' // input in the program to create figure
			do "${doaux}\Main_graphs_aux.do" // program to create figure



}


//////////////////////////////////////////////////////////////////////////
// Table A3 - Panel B (includes coefficient reported in Figure 6a and A4)
//////////////////////////////////////////////////////////////////////////

foreach o in Tax_all Rev_all {
foreach w in $winsor {

local z `o'`w' 

		* Differences-in-differences - Entire period
		qui areg ln`z'  dd_treatRW  i.date_taxref_n if ST_1!=1, absorb(cnae) vce(cluster cnae)
		outreg2  dd_treatRW  using ${outfilemain}, ctitle(`z'`l') nolabel bracket excel nonotes append	

}
}


