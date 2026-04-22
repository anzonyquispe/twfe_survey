**********************************************************************
* reshape_wdi.do
* April 2008
* Michael Faye and Paul Niehause
*
* This takes the raw WDI data and reshapes and renames it appropriately
* Outputs both donor and recipent stats
****************************************************************

**********************************************************
* Setup and loading of raw data
**********************************************************
    clear
    local dir="C:\Documents and Settings\hbsuser\My Documents\Research\Aid\data\Outside Data\WDI Data"
    cd "`dir'"
    use "wdi_raw_data_2007.dta"

**********************************************************
* Reshape data so that we have year and data as columns
**********************************************************

    drop series_code
    gen id = _n
    reshape long y, i(id) j(year)
    encode series_name, gen(vardum)

    drop id series_name
    rename y data
    egen id=group(country_name year)
    reshape wide data, i(id) j(vardum)

**********************************************************
* Save intermediate file that we will use to generate
* both donor and recipient stats from
**********************************************************

    save wdi_temp_2007.dta, replace

**********************************************************
* Clean and output recipient WDI
**********************************************************

    rename data1 gdp2000
    rename data2 pop
    label var gdp2000 "GDP (constant 2000 US$) - Recip"
    label var pop "Population, total - Recip"

    rename country_code wbcode_recipient
    rename country_name recipient_name

    drop id

    replace gdp2000="." if gdp2000==".."
    replace pop="." if pop==".."

    destring gdp2000, replace
    destring pop, replace

    sort wbcode_r year
    save `date'_WDIdata_recipient_final.dta, replace
**********************************************************
* Clean and output recipient WDI
**********************************************************

    use wdi_temp_2007.dta

    rename data1 gdp2000_donor
    rename data2 pop_donor
    label var gdp2000_donor "GDP (constant 2000 US$) - Donor"
    label var pop_donor "Population, total - Donor"

    rename country_code wbcode_donor
    rename country_name donor_name

    drop id

    keep if wbcode_d=="AUS" |  wbcode_d=="AUT" |  wbcode_d=="BEL" |  wbcode_d=="CAN" | wbcode_d=="DNK" |  wbcode_d=="FIN" |  wbcode_d=="FRA" | wbcode_d=="DEU" | wbcode_d=="GRC" | wbcode_d=="IRL" | wbcode_d=="ITA" |wbcode_d=="JPN" |wbcode_d=="LUX" |wbcode_d=="NLD" |wbcode_d=="NZL" |wbcode_d=="NOR" | wbcode_d=="PRT" | wbcode_d=="ESP" |wbcode_d=="SWE" |wbcode_d=="CHE" |wbcode_d=="GBR" | wbcode_d=="USA"

    replace gdp2000_donor="." if gdp2000_donor==".."
    replace pop_donor="." if pop_donor==".."

    destring gdp2000_donor, replace
    destring pop_donor, replace

    sort wbcode_d year
    save `date'_WDIdata_donor_final.dta, replace
