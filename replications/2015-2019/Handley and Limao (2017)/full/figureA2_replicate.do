
set more off


use  replication_maindata1,clear


/*make graph for appendix Figure A4 */
twoway (lpolyci ldif_ln_pindex_hs6_cont unc_pre if pindex_sample==1 & trim_025tails==1,degree(0)  ) ,/*
	title (Change in HS6 continuer price index (ln) 2005-2000) 
	*/xtitle(1-({&tau}{sub:2V}/{&tau}{sub:1V}){sup:-3}) legend(off)
	*ylabel(-0.15(.05)0.25)
	
graph export figureA2.pdf, as(pdf) replace


exit
 