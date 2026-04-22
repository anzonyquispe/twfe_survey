clear
set more off




use "$datapath_misalloc/misallocation_paneldata.dta"

keep corporate_rate fipstate year statename
keep if year >= 1978

saveold "$dtapath/Figures/Appendix_Figure1.dta", replace
