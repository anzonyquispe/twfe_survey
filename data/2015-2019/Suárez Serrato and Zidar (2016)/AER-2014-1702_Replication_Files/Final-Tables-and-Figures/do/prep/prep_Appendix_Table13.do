clear
set more off

use "$dropbox/Local_Econ_Corp_Tax/AER Revisions/ACCRA 081315/accra_conspuma.dta", clear /*Local price data*/
sort conspuma year
tempfile local_price_data
save `local_price_data'
rename state_fips fipstate
order fipstate year
sort fipstate year
tempfile local_price_data_state
save `local_price_data_state'

replace year = 1980 if year == 1981 /* Important */
keep if inlist(year, 1980, 1990, 2000, 2010)
merge 1:m conspuma year using "$datapath_final/ForTables_decade_09-23-2014.dta"
sort conspuma year
tsset conspuma year
g d_y = ln(f_non_trade_2) - ln(L10.f_non_trade_2)

keep d_y f_non_trade_2 fipstate year epop fe_group d_keep_itc_state dtotalexpenditure_pop bartik d_corp_ext d_bus_dom2

saveold "$dtapath/Tables/Appendix_Table13.dta", replace
