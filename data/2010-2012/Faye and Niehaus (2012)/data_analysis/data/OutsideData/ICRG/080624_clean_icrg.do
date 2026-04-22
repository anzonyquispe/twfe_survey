***************************************************************************************************
*   080628_clean_icrg.do
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
    local usedate="080624"

    *local indir = "D:\Ec Projects\aid and elections\analysis\data"
    *local outdir = "D:\Ec Projects\aid and elections\analysis\data\estimation_samples"
    local indir = "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\data\Outside Data\ICRG"
    local outdir = "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\data\Outside Data\ICRG"

    cd "`indir'"
    use "`usedate'_icrg_corruption_original.dta"
    * Note: The original data has funny characters for Coted'Ivoire so I changed
    * the name manually in the dataset

**********************************************************
* II. Drop 2008 data
**********************************************************

    drop *_2008

**********************************************************
* III. Generate average annual values (data orig. in months)
**********************************************************ic

    local months "01 02 03 04 05 06 07 08 09 10 11 12"

    foreach m in `months'{
        forvalues yr=1985(1)2007{
            destring _`m'_`yr', replace
            }
    }

    forvalues yr=1985(1)2007 {
        egen y`yr'=rmean(_01_`yr' - _12_`yr')
    }

    keep country y19*

**********************************************************
* IV. Reshape data
**********************************************************

    reshape long y, i(country) j(year)
    rename y corruption
    label var corruption "ICRG Corruption Index"

**********************************************************
* V. Merge wbcodes in
**********************************************************

    replace country=upper(country)
    sort country
    merge country using "icrgwbcode.dta"
    tab _merge
    drop _merge

    order wbcode_r country year corruption
    sort wbcode_r year

**********************************************************
* VI. Save
**********************************************************

    cd "`outdir'"
    save `date'_icrg_final.dta, replace
