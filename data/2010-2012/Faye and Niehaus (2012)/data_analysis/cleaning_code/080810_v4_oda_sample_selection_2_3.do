*******************************************************************************************
*   oda_sample_selection_2_3
*   June 2008
*   Michael Faye and Paul Niehaus
*
*   Second step in the data assembly process. Imposes a series of restrictions on the main
*   data file to arrive at the final sample we use for our estimation, and examines the
*   effects of each restriction along the way.
*
******************************************************************************************

******************************************************************************************
* Stata settings
******************************************************************************************

    clear
    set more off

******************************************************************************************
* Parameter settings
******************************************************************************************

    local date =  string(date(c(current_date), "DMY"), "%tdYYNNDD")
    local odatype = "commit"
    local elecdate="080107"
    
******************************************************************************************
* Directory settings
******************************************************************************************

    *local dir="C:\Documents and Settings\hbsuser\My Documents\Research\Aid\"
    *local dir= "/export/projects/aidflow_project/"
    local dir = "C:\Ec Projects\aid and elections\data_final"

******************************************************************************************
* Load
******************************************************************************************

    cd "`dir'"
    use "`date'_oda_baseline_data_`elecdate'.dta"

******************************************************************************************
* Preliminaries
******************************************************************************************

    * generate identifier for observations with zero aid flows
    gen i = 1 if odaPair_`odatype'>0
    replace i = 0 if odaPair_`odatype'==0

    * initial look at the panel structure
    egen paircode = group(wbcode_donor wbcode_recipient)
    tsset paircode year

******************************************************************************************
* Restriction 1: Create indicator only look at big five donors - we will focus on these
* (we leave other donors in for the moment for the sake of summary stats)
******************************************************************************************

    * this obviously does not introduce any gaps
    gen donorgroup=1 if wbcode_d=="USA"| wbcode_d=="JPN" | wbcode_d=="GBR" | wbcode_d=="FRA" | wbcode_d=="DEU"
    keep if wbcode_d=="AUS" |  wbcode_d=="AUT" |  wbcode_d=="BEL" |  wbcode_d=="CAN" | wbcode_d=="DNK" |  wbcode_d=="FIN" |  wbcode_d=="FRA" | wbcode_d=="DEU" | wbcode_d=="GRC" | wbcode_d=="IRL" | wbcode_d=="ITA" |wbcode_d=="JPN" |wbcode_d=="LUX" |wbcode_d=="NLD" |wbcode_d=="NZL" |wbcode_d=="NOR" | wbcode_d=="PRT" | wbcode_d=="ESP" |wbcode_d=="SWE" |wbcode_d=="CHE" |wbcode_d=="GBR" | wbcode_d=="USA"

******************************************************************************************
* Restriction 2: only consider years for which we have election data (1975-2004)
******************************************************************************************

    drop if year<1975

******************************************************************************************
* Restriction 3: drop Israel (we do not include this restriction)
******************************************************************************************

    *drop if wbcode_r=="ISR"

******************************************************************************************
* Restriction 4: drop recipient years before we have data for unvotes or elections
******************************************************************************************

    gen vyear = year
    replace vyear = . if (unvotes == . | i_elecex==.)
    bysort paircode: egen fy = min(vyear)
    keep if year >= fy

******************************************************************************************
* Restriction 5: drop observations for which we don't have both election and unvotes
******************************************************************************************

    gen hole_elecex=0
    replace hole_elecex=1 if i_elecex==.

    gen hole_unvotes=0
    replace hole_unvotes=1 if unvotes==.

    gen hole_any=hole_unvotes+hole_elecex
    drop if hole_any>=1

******************************************************************************************
* Restriction 6: drop recipients with any holes in their unvotes or elections series
******************************************************************************************

    * We now look at any true holes remainining; the true holes will no longer
    * have empty observations but will have skipped years; we identify these as follows:

    *bysort wbcode_r: egen min=min(year)
    *bysort wbcode_r: egen max=max(year)
    *gen diff=max-min+1
    *egen t=tag(wbcode_r year)
    *keep if t==1
    *bysort wbcode_r: gen count=_N if t==1

    *gen probdiff=count-diff
    *egen tag=tag(wbcode_r)
    * list wbcode_r if tag==1 & probdiff!=0

    drop if wbcode_recipient=="BDI"
    drop if wbcode_recipient=="BIH"
    drop if wbcode_recipient=="CAF"
    drop if wbcode_recipient=="COM"
    drop if wbcode_recipient=="DOM"
    drop if wbcode_recipient=="GMB"
    drop if wbcode_recipient=="GNB"
    drop if wbcode_recipient=="GNQ"
    drop if wbcode_recipient=="GRD"
    drop if wbcode_recipient=="IRQ"
    drop if wbcode_recipient=="KGZ"
    drop if wbcode_recipient=="KHM"
    drop if wbcode_recipient=="LBR"
    drop if wbcode_recipient=="MRT"
    drop if wbcode_recipient=="NER"
    drop if wbcode_recipient=="TCD"
    drop if wbcode_recipient=="TJK"
    drop if wbcode_recipient=="UZB"
    drop if wbcode_recipient=="VUT"
    drop if wbcode_recipient=="ZAR"

    * inspect the results
    xtdes if donorgroup==1, patterns(20)

******************************************************************************************
* Drop recipient-years empty observations for countries that weren't eligible for ODA
******************************************************************************************

    *http://www.oecd.org/document/55/0,3343,en_2649_34485_35832055_1_1_1_1,00.html

        bysort wbcode_r year: egen oda_total=sum(odaPair_`odatype')

    * Based on data and vague text on DAC website about Asian countries becoming elible in 1970s & 1980s

        drop if wbcode_r=="CHN" & year<1979 & oda_total==0
        drop if wbcode_r=="MNG" & year<1985 & oda_total==0

    * Based on specifics of text and website (they sometimes disagree e.g., ALB 1988 has aid flows but website says not eligible)

        drop if wbcode_r=="ALB" & year<1989 & oda_total==0
        drop if wbcode_r=="KAZ" & year<1992 & oda_total==0
        drop if wbcode_r=="TKM" & year<1992 & oda_total==0
        drop if wbcode_r=="ARM" & year<1993 & oda_total==0
        drop if wbcode_r=="GEO" & year<1993 & oda_total==0
        drop if wbcode_r=="AZE" & year<1993 & oda_total==0
        drop if wbcode_r=="MDA" & year<1997 & oda_total==0

        drop if wbcode_r=="BHS" & year>=1996 & oda_total==0
        drop if wbcode_r=="BRN" & year>=1996 & oda_total==0
        drop if wbcode_r=="KWT" & year>=1996 & oda_total==0
        drop if wbcode_r=="ARE" & year>=1996 & oda_total==0
        drop if wbcode_r=="QAT" & year>=1996 & oda_total==0
        drop if wbcode_r=="SGP" & year>=1996 & oda_total==0

        drop if wbcode_r=="ISR" & year>=1997 & oda_total==0
        drop if wbcode_r=="CYP" & year>=1997 & oda_total==0

        drop if wbcode_r=="LBY" & year>=2000 & oda_total==0
        drop if wbcode_r=="KOR" & year>=2000 & oda_total==0

        drop if wbcode_r=="MLT" & year>=2003 & oda_total==0
        drop if wbcode_r=="SVN" & year>=2003 & oda_total==0

    * The following recipient years do not have any aid flows and we leave at 0
        * Croatia 92,93: (Croatia was first recognized on January 15, 1992 by the European Union and the United Nations)
        * Kazakhstan 92: DAC website said it was added to eligible list in 92, yet there is no aid
        * Macedonia 93: first admitted to UN in April 93, 18 months after independence
        * Slovenia 92, 93: no aid recorded
        * Turkmenistan 92: DAC website said it was added to eligible list in 92, yet there is no aid

******************************************************************************************
* Drop recipient-years when the country was under military occupation
******************************************************************************************

    drop if wbcode_r=="AFG" & year>=2001
    drop if wbcode_r=="IRQ" & year>=2003

******************************************************************************************
* output
******************************************************************************************

    save "`date'_oda_estimation_sample_`odatype'_`elecdate'.dta", replace
