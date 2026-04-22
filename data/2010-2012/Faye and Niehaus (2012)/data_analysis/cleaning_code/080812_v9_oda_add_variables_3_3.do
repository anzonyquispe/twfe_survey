*******************************************************************************************
*   oda_add_variables_3_3
*   June 2008
*   Michael Faye and Paul Niehaus
*
*   Third step in the data assembly process. Computes derived variables from existing ones
*   and gives variables descriptive labels.
*
******************************************************************************************

******************************************************************************************
* Stata settings
******************************************************************************************

    clear
    set more off

******************************************************************************************
* Directory settings
******************************************************************************************

    local date =  string(date(c(current_date), "DMY"), "%tdYYNNDD")
    local elecdate="080107"
    local dir = "~/Ec Projects/completed/PAC/submission/aer/data_analysis/data"

    local odatype = "commit"
    * Choices for unvotes_term: unvotes, unvotesL1, unvotes_term
    local unvotes="unvotes_term"

******************************************************************************************
* Load DAC data
******************************************************************************************

    cd "`dir'"
    use "`date'_oda_estimation_sample_`odatype'_`elecdate'.dta"

    egen rcode = group(wbcode_r)
    quietly sum rcode
    local numrecip = r(max)

**************************************************************************************************
*    Generate ODA variable
***************************************************************************************************

    gen oda=odaPair_`odatype'USD
    * note that the odaPair_Election is taken from CRS_`odatype' so matches aid type
    * it is also alreay reported in 2004 constant USD

    * Subtract election aid
    replace oda=oda - odaPair_Election

******************************************************************************************
* Combine information in percentfirst and percentlast
******************************************************************************************

    * We first must `fix' the percentage data: it is currently recorded as the percent
    * that the winner received in the most recent election but the percent variable
    * in the election year is the percentage winner received in last election. We first fix the
    * election year data. We then assign previous years in election cycle to forthcoming
    * elections competitiveness

    tsset paircode year
    replace percentlast_ex=F1.percentlast
    replace percentfirst_ex=F1.percentfirst

    gen percent = percentlast_ex if i_elecex==1
    replace percent = percentfirst_ex if percent==. & percentfirst_ex!=. & i_elecex==1

    bysort paircode termcode: egen temp=max(percent)
    replace percent=temp


***************************************************************************************************
* Toggle which unvotes measure to use
***************************************************************************************************

    tsset paircode year
    gen unvotesL1=L1.unvotes
    bysort paircode termcode: egen unvotes_term=mean(unvotes)

    replace unvotes=`unvotes'

**************************************************************************************************
*    Generate Other Derived Variables
***************************************************************************************************

    * key interactions
    gen p_unvotes_elecleg = unvotes * i_elecleg
    gen p_unvotes_elecex = unvotes * i_elecex

    * rescale corruption to the same scale as UN votes: corruption originally from 0-6
    replace corruption = 1-(corruption/6)
    gen p_corr_elecex = corruption * i_elecex


    forvalues i = 1/`numrecip' {

           quietly gen _ryear`i' = 0
           quietly replace _ryear`i' = year if rcode == `i'

    }

    * make competitiveness (%) vars
    gen i_far_pct=.
    replace i_far_pct=0 if percent<75 & percent !=.
    replace i_far_pct=1 if percent>=75 & percent!=.
    gen p_unvotes_ifarpct=i_far_pct * unvotes
    gen p_elecex_ifarpct=i_far_pct*i_elecex
    gen p_unvotes_elecex_ifarpct=unvotes*i_elecex*i_far_pct

    * make competitiveness (EIEC) vars
    gen i_far_eiec=.
    replace i_far_eiec=0 if eiec>=5 & eiec!=.
    replace i_far_eiec=1 if eiec<5 & eiec!=.
    gen p_unvotes_ifareiec=i_far_eiec * unvotes
    gen p_elecex_ifareiec=i_far_eiec*i_elecex
    gen p_unvotes_elecex_ifareiec=unvotes*i_elecex*i_far_eiec

    * make year dummies
    quietly tab year, gen(yeardum)

    * decompose UN votes
    sort wbcode_recipient year
    by wbcode_recipient year: egen unvotes_rt = mean(unvotes) if donorgroup==1
    gen unvotes_resid = unvotes - unvotes_rt
    gen p_unvotes_rt_elecex = i_elecex * unvotes_rt
    gen p_unvotes_resid_elecex = i_elecex * unvotes_resid

    *generate per capita income
    gen gdppc2000=gdp2000/pop

    * rescale controls: population in millions, GDP in billions
    replace pop = pop / 1000000
    replace gdp2000 = gdp2000 / 1000000000
    replace pop_donor = pop_donor / 1000000
    replace gdp2000_donor = gdp2000_donor / 1000000000


******************************************************************************************
* Clean NED Variables
******************************************************************************************

    * fill in zeros
    local allaidtypes "total acils cipe iri ndi"
    foreach at of local allaidtypes {
        replace NED`at' = 0 if wbcode_d=="USA" & year > 1989 & NED`at'==.
    }

    * generate political and non-political groupings
    gen NEDother = NEDtotal - NEDiri - NEDndi
    local downscale "total iri ndi acils cipe other"
    foreach t of local downscale {
        replace NED`t' = NED`t' / 1000000
    }

     * setup for comparison to ODA
    gen NEDODA = oda if NEDtotal!=.


******************************************************************************************
* Label variables
******************************************************************************************

    label variable unvotes "UN Agreement"
    label variable i_elecex "Exec. Election"
    label variable p_unvotes_elecex "Exec. Election * UN Agreement unvotes"
    label var p_corr_elecex "Exec. Election * Corruption"

    label variable pop "Recip. Pop."
    label var pop_donor "Donor Pop."
    label var gdp2000_donor "Donor GDP"

    label variable oda "Bilateral ODA"

******************************************************************************************
* Output
******************************************************************************************

    * all donors
    save `date'_oda_final_data_`odatype'_`elecdate'_`unvotes'.dta, replace

    * Big 5 donors
    keep if wbcode_d=="USA" | wbcode_d=="GBR" | wbcode_d=="FRA" | wbcode_d=="DEU" | wbcode_d=="JPN"
    save `date'_oda_final_data_big5_`odatype'_`elecdate'_`unvotes'.dta, replace
