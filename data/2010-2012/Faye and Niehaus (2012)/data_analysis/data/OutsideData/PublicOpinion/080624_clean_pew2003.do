***************************************************************************************************
*   080628_clean_pew2003.do
*   June 2008
*   Michael Faye and Paul Niehaus
*
* In this do file, we extract information on perceptions on donor countrues from Pew
* Global Attitudes Project 2002
***************************************************************************************************


**********************************************************
* I. Stata setup and load data
**********************************************************

    clear
    set mem 300m
    set more off
    set matsize 800

    local date =  string(date(c(current_date), "DMY"), "%tdYYNNDD")
    local year="2003"

    *local indir = "D:\Ec Projects\aid and elections\analysis\data"
    *local outdir = "D:\Ec Projects\aid and elections\analysis\data\estimation_samples"
    local indir = "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\data\Outside Data\PublicOpinion\PewGlobal`year'"
    local outdir = "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\data\Outside Data\PublicOpinion"


    cd "`indir'"
    use "pewgap`year'.dta"

**********************************************************
* II. Keep relevant variables
**********************************************************

    * Q61b: What is your opinion of the US
    * Q62: In making intl policy decisions, to what extent does US take into account interest of countries like yours

    keep country psraid quest_id weight q61b q62

**********************************************************
* III. Generate aggregate measures
**********************************************************

    *Generate count variable that tallies number of surveys in
    *the countries: ranges from 500-3000

            bysort country: gen count=_N

    *Question 61b: what is your opinion of US

        *Generate indicator of whether they had favorable opinion
        *Generate indicator of whethery they answered

            gen i_61b_favorable=1 if q61b==1 | q61b==2
            gen i_61b_count=1 if q61b==1 | q61b==2 | q61b==3 | q61b==4

        *Aggregate without weights: % favorable opinion

            bysort country: egen sum_61b_favorable=sum(i_61b_favorable)
            bysort country: egen count_61b=sum(i_61b_count)

            gen pct_61b_favorable=sum_61b_favorable/count_61b

        *Aggregate with weights: % favorable opinion

            gen w_61b_favorable=weight*i_61b_favorable
            gen w_61b_count=weight*i_61b_count

            bysort country: egen sumw_61b_favorable=sum(w_61b_favorable)
            bysort country: egen countw_61b=sum(w_61b_count)

            gen pctw_61b_favorable=sumw_61b_favorable/countw_61b


    *Question 62: Does US take into account interests of countries like yours?

        *Generate indicator of whether US cared
        *Generate indicator of whethery they answered

            gen i_62_care=1 if q62==1 | q62==2
            gen i_62_count=1 if q62==1 | q62==2 | q62==3 | q62==4

        *Aggregate without weights

            bysort country: egen sum_62_care=sum(i_62_care)
            bysort country: egen count_62=sum(i_62_count)

            gen pct_62_care=sum_62_care/count_62

        *Aggregate with weights

            gen w_62_care=weight*i_62_care
            gen w_62_count=weight*i_62_count

            bysort country: egen sumw_62_care=sum(w_62_care)
            bysort country: egen countw_62=sum(w_62_count)

            gen pctw_62_care=sumw_62_care/countw_62

**********************************************************
* IV. Reduce dataset: 1 observation per country
**********************************************************

    egen tag=tag(country)
    keep if tag==1
    keep country pct_* pctw_*

    label var pct_61b_favorable "% of people who have favoirable opinion of US"
    label var pctw_61b_favorable "weighted % of people who have favoirable opinion of US"
    label var pct_62_care "% of people who think US cares about country"
    label var pctw_62_care "weighted % of people who think US cares about country"


**********************************************************
* V. Merge wbcodes in
**********************************************************

    decode country, gen(c)
    drop country
    rename c country
    sort country

    cd "`indir'"
    merge country using  "pew_wbcodes.dta"
    drop if _merge==2
    drop _merge

    order country wbcode_rec pct_61b* pctw_61b* pct_62* pctw_62*
    sort wbcode_r

**********************************************************
* VI. Output
**********************************************************

    cd "`outdir'"
    save "`date'_pew`year'_final.dta", replace
