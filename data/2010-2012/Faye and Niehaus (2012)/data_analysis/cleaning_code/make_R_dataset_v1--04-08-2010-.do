***************************************************************************************************
*   make_r_datasets.do
*   April 2008
*   Michael Faye and Paul Niehaus
*
*   This performs various de-meanings of key variables in order to send them to
*   R to have the estimation done.
*
***************************************************************************************************

***************************************************************************************************
* Stata settings
***************************************************************************************************

    clear
    set more off
    set matsize 800

    local date =  string(date(c(current_date), "DMY"), "%tdYYNNDD")
    local elecdate="080107"
    
***************************************************************************************************
* Initial Setup of locals
***************************************************************************************************

    * Define what type of aid we generate tables for (commit, gross)
    local odatype = "commit"

    * Define what measure of unvotes we use
    local unvotes = "unvotes_term"

    * Define standard list of control variables and other parameters
    local controls "pop gdp2000 pop_donor gdp2000_donor"

    local indir = "~/Ec Projects/completed/PAC/submission/aer/data_analysis/data"
    local outdir = "~/Ec Projects/completed/PAC/submission/aer/data_analysis/data"

***************************************************************************************************
* Load data and output as csv for R
***************************************************************************************************

    use "`indir'/`date'_oda_final_data_big5_`odatype'_`elecdate'_`unvotes'.dta"
    outsheet wbcode_donor wbcode_recipient year oda odaPair_disburse gdp2000 pop gdp2000_donor pop_donor unvotes i_elecex p_unvotes_elecex  unvotes_rt unvotes_resid p_unvotes_rt_elecex p_unvotes_resid_elecex  i_far_pct p_unvotes_ifarpct p_elecex_ifarpct p_unvotes_elecex_ifarpct i_far_eiec p_unvotes_ifareiec p_elecex_ifareiec p_unvotes_elecex_ifareiec NEDtotal NEDODA dateexec system using "`indir'/`date'_oda_final_data_big5_`odatype'_`elecdate'_`unvotes'.csv", comma replace
    
    
