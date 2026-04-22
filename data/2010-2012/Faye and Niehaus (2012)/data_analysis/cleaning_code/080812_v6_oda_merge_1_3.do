*******************************************************************************************
*   oda_merge_1_3
*   June 2008
*   Michael Faye and Paul Niehaus
*
*   First step in the data assembly process. Creates final databse using OECD DAC data
*   from scratch. Input files:
*
*   (1) DACaidflows_Commitdisburse (Original aid flows data) (http://www.oecd.org/document/33/0,2340,en_2649_34447_36661793_1_1_1_1,00.html Table 3a)
*   (2) icrg_final (Corruption data) (http://www.prsgroup.com.ezp-prod1.hul.harvard.edu/prsgroup_shoppingcart/personal_page.aspx)
*   (3) WDIdata_recipient/donor_final (WDI data: pop, GDP, etc.)
*   (4) DPI_final.dta  (Database of political institutions elections data)  (http://econ.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/0,,contentMDK:20649465~pagePK:64214825~piPK:64214943~theSitePK:469382,00.html)
*   (5) pew2003_final (Public perception data from Pew)
*   (6) CRSdata_commit (Disaggregated aid data which includes election aid)
*   (7) ned_grants_90-05_restricted (NED grants to non governmental organizations)
*   (8) unvotes_final (Constructed dataset on unvotes agreement (http://home.gwu.edu/~voeten/UNVoting.htm)
*   (9) dac_deflators
******************************************************************************************

******************************************************************************************
* Stata settings
******************************************************************************************

    clear
    set mem 200M

******************************************************************************************
* Parameter settings
******************************************************************************************

    local elecdate = "080107"
    *local date =  string(date(c(current_date), "DMY"), "%tdYYNNDD")
    * date is the date of all outside data being merged in EXCEPT icrg which is 080812
    local date="080625"
    local today= string(date(c(current_date), "DMY"), "%tdYYNNDD")
    local odatype="commit"

******************************************************************************************
* Directory settings
******************************************************************************************
    
    local datadir="~/Ec Projects/completed/PAC/submission/aer/data_analysis/data"
    local base="`datadir'/"
    local original="`datadir'/OriginalFiles/"
    local wdi="`datadir'/OutsideData/Wdi/"
    local elections="`datadir'/OutsideData/Elections/"
    local unvotes="`datadir'/OutsideData/Voting/"
    local opinion="`datadir'/OutsideData/PublicOpinion/"
    local icrg="`datadir'/OutsideData/ICRG/"
    local ned="`datadir'/OutsideData/NED/"
    
******************************************************************************************
* Load DAC data
******************************************************************************************

    cd "`original'"
    use DACaidflows_CommitDisburse.dta

******************************************************************************************
* Fill in empty donor-recipient year cells to rectangularize data
******************************************************************************************

    fillin wbcode_recipient wbcode_donor year
    drop _fillin

******************************************************************************************
* Label and rename variables for clarity
******************************************************************************************

    rename recipient recipient_name
    rename donor donor_name
    rename commit odaPair_commit
    rename disburse odaPair_disburse

    label var odaPair_commit "ODA commitments (OECD DAC database)"
    label var odaPair_disburse "ODA Disbursements - gross (OECD DAC database)"

    * Replace empty observations with 0; there are no zeroes in original data, an empty observation
    * signifies no aid flows
    replace odaPair_commit=0 if odaPair_commit==.
    replace odaPair_disburse=0 if odaPair_disburse==.


******************************************************************************************
* Merge outside data in:
*    - WDI Data
*    - DAC deflators
*    - Elections data (DPI)
*    - Polity
*    - PITF
*    - ICRG
*    - Kuziemko and Werker
*    - Election aid
******************************************************************************************

    * WDI recipients
    sort wbcode_recipient year
    cd "`wdi'"
    merge wbcode_recipient year using `date'_WDIdata_recipient_final.dta
    drop if _merge==2
    drop _merge

    * WDI donors
    sort wbcode_donor year
    merge wbcode_donor year using `date'_WDIdata_donor_final.dta
    drop if _merge==2
    drop _merge

    * DAC deflators
    cd "`original'"
    sort wbcode_donor year
    merge wbcode_donor year using 080602_dac_deflators.dta
    drop if _merge==2
    drop _merge

    * DPI recipients
    sort wbcode_recipient year
    cd "`elections'"
    merge wbcode_recipient year using 100217_080107_DPI_final.dta
    drop if _merge==2
    drop _

    * Pew data
    sort wbcode_r
    cd "`opinion'"
    merge wbcode_r using `date'_pew2003_final.dta
    drop if _merge==2
    drop _merge

    * ICRG corruption data
    sort wbcode_r year
    cd "`icrg'"
    merge wbcode_r year using 080812_icrg_final.dta
    drop if _merge==2
    drop _merge

    * NED data in
    sort wbcode_d wbcode_r year
    cd "`ned'"
    merge wbcode_d wbcode_r year using 080813_ned_grants_90-05_restricted_final.dta
    drop if _merge==2
    drop _merge

    * election specific aid from CRS data
    sort wbcode_d wbcode_r year
    cd "`base'"
    merge wbcode_d wbcode_r year using "`date'_CRSdata_`odatype'.dta"
    drop if _==2
    drop _
    replace odaPair_Election=0 if odaPair_Election==.

    * UNVOTES data
    sort wbcode_recipient wbcode_donor year
    cd "`unvotes'"
    merge wbcode_recipient wbcode_donor year using "`date'_unvotes_final.dta"
    drop if _merge==2
    drop _merge

******************************************************************************************
* Deflate oda variables from current USD to 2004 USD
******************************************************************************************
    *Note that the CRS data is alread in constant 2004 USD

    *Covert to 2004 USD
    gen dac_deflator2004=dac_deflator if year==2004
    bysort wbcode_d: egen temp=max(dac_deflator2004)
    replace dac_deflator2004=temp
    drop temp
    gen odaPair_commitUSD=odaPair_commit*(dac_deflator2004/dac_deflator)
    gen odaPair_disburseUSD=odaPair_disburse*(dac_deflator2004/dac_deflator)

    local nedtypes = "total acils cipe iri ndi"
    foreach i of local nedtypes {
        replace NED`i'=NED`i'*(dac_deflator2004/dac_deflator)
    }

    * Replace original ODA variables w/ those measured in constant dollars
    * to prevent confusion
    replace odaPair_commit=odaPair_commitUSD
    replace odaPair_disburse=odaPair_disburseUSD

******************************************************************************************
* Output
******************************************************************************************

    * main data
    save "`datadir'/`today'_oda_baseline_data_`elecdate'.dta", replace
