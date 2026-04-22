////////////////////////////////////////////////////////
// Master - Figure A5, Figure 5, Figure A7 and Figure A6 	 
////////////////////////////////////////////////////////
clear all
set more off, perm

global MainDir "XX\Replication" /*replace XX with the main directory*/

// Figure A5, Figure 5 and Figure A7 

** [1] Prepare data for event study around lottery win events and generate Figure A5

do  "$MainDir\Codes\_doFig5FigA5FigA7_dataprep_AER.do"


** [2] Figure 5: graphs and coefficients

do "$MainDir\Codes\_doFig5_AER.do"


** [3] Figure A7: graphs and coefficients

do "$MainDir\Codes\_doFigA7_AER.do"


// Figure A6a and A6b

** Prepare data for event study around lottery win & produce graphs and coefficients
** calls data preparation (_doFigA6_dataprep_AER.do) and data analysis do-files(_doFigA6_analysis_AER.do)
do  "$MainDir\Codes\_doFigA6_AER.do"
