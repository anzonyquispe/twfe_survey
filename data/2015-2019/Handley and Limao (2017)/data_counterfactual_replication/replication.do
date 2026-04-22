**************************************************
**  THIS FILE CREATES THE OUTPUT IN 			**	
**  Policy Uncertainty, Trade and Welfare: 		**
**  Theory and Evidence for China and the U.S.	**
**  AER, by Kyle Handley and Nuno Limao 		**
**************************************************

								
	version 13
	capture cd  C:
	cd "/replication"
	
	
	capture log close
	log using "replication.log", replace text
	
	drop _all
	set more off
	set matsize 800

/*** install packages that are needed ***/

	capture adoupdate estout, update
	capture adoupdate outreg2, update
	capture adoupdate mat2txt, update


/*** TABLES 1-6 START HERE ***/



do summary_stats_full_revised_replicate.do

do table2_baseline_replicate.do

do regs_twn_chn_compare_replicate.do

do regs_EU_chn_compare_replicate.do

do price_product_sunk_intxn_regs_replicate.do

do replicate_NLS_aer_replicate.do

do replicate_NLS_quant_values_for_simulation.do

/*** FIGS 2,3,4 START HERE ***/

do graphs_aer_replicate.do

do graphs_semiparametric_replicate.do


	
					
/**** REPLICATION OF APPENDIX *****/

	do replication_appendix.do
				

/**********************************/				

graph close _all


log close
exit
