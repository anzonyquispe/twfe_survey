***************************************************************************************************
*   080628_clean_dpi.do
*   June 2008
*   Michael Faye and Paul Niehaus
*
*
***************************************************************************************************

* When changing date of original files change use command line and remname counrty
***************************************************************************************************
* I. Stata settings
***************************************************************************************************

    clear
    set mem 300m
    set more off
    set matsize 800

    local indir = "C:\Ec Projects\aid and elections\data_final\OutsideData\Elections"
    local outdir = "C:\Ec Projects\aid and elections\data_final\OutsideData\Elections"
    *local indir = "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\data\Outside Data\Elections"
    *local outdir = "C:\Documents and Settings\hbsuser\My Documents\Research\Aid\data\Outside Data\Elections"

    local date =  string(date(c(current_date), "DMY"), "%tdYYNNDD")
    local datadate = "`date'"
    local elecdate = "080107"

    cd "`indir'"
    use "dpi2004_missing"
    *use "DPI2006_rev42008.dta"

*********************************************************************************************
* II. Label and rename variables
*********************************************************************************************

    * countryc corresponds to 080107; countryname to 080801
    rename countryc recipientname
    *rename countryname recipientname
    rename ifs wbcode

    rename percent1 percentfirst_ex
    label var percentfirst_ex "% of votes president got of votes in first round"

    rename percentl percentlast_ex
    label var percentlast_ex "% of votes president got of votes in first round"


******************************************************************
* III. Clean variables in preparation for merging
*******************************************************************

    replace recipientname="Bosnia-Herzegovina" if recipientname=="Bosnia-Herz"
    replace recipientname="Cape Verde" if recipientname=="C.Verde Is."
    replace recipientname="Cape Verde" if wbcode=="CPV"

    replace recipientname="Central African Rep." if recipientname=="Cent. Af. Rep."
    replace recipientname="Central African Rep." if wbcode=="CAF"

    replace recipientname="China" if recipientname=="PRC"

    replace recipientname="Comoros" if recipientname=="Comoro Is."

    replace recipientname="Congo, Dem. Rep. (Zaire)" if recipientname=="Zaire (Democ Republic Congo)"
    replace recipientname="Congo, Rep." if recipientname=="Congo (Republic of Congo)"

    replace recipientname="Dominican Republic" if recipientname=="Dom. Rep."

    replace recipientname="Equatorial Guinea" if recipientname=="Eq. Guinea"
    replace recipientname="Equatorial Guinea" if wbcode=="GNQ"

    replace recipientname="Korea, Dem. Rep." if recipientname=="PRK"
    replace recipientname="Kyrgyz Rep." if recipientname=="Kyrgyzstan"
    replace recipientname="Macedonia" if recipientname=="Macedonia, FYROM"
    replace recipientname="Macedonia" if wbcode=="MKD"

    replace recipientname="Papua New Guinea" if recipientname=="P. N. Guinea"
    replace recipientname="Papua New Guinea" if wbcode=="PNG"

    replace recipientname="Solomon Islands" if recipientname=="Solomon Is."
    replace recipientname="South Africa" if recipientname=="S. Africa"

    replace recipientname="Trinidad & Tobago" if recipientname=="Trinidad-Tobago"
    replace recipientname="United Arab Emirates" if recipientname=="UAE"

    replace recipientname="Viet Nam" if recipientname=="Vietnam"
    replace recipientname="Yugoslavia, Sts Ex-Yugo. Unspec." if recipientname=="Yugoslavia"

*******************************************************
* IV. Replace empty NA cells with .
*******************************************************

    local varlist="exelec legelec dateexec eiec percentfirst_ex percentlast_ex"
    foreach i in `varlist' {
        replace `i'=. if `i'==-999
    }


*********************************************************
* V. Fix election years for which dateexec and exelec
*     do not agree
**********************************************************

    * Croatia held election: http://en.wikipedia.org/wiki/Croatian_presidential_election,_2000
    * Korea had pres. elections in 2002 (http://en.wikipedia.org/wiki/South_Korean_presidential_election,_2002)
    * Can't find documentation that Bolivia had presidential election in 1998
    * Can't find documentation that Indonesia had presidential election in 1998
    * (appears that they had leg elections in 1999) (http://en.wikipedia.org/wiki/Elections_in_Indonesia)


    list recipientname year dateexec exelec if (dateexec!=. & dateexec!=0) & exelec!=1
    replace exelec=1 if recipientname=="Croatia" & year==2000
    replace exelec=1 if recipientname=="ROK" & year==2002
    replace exelec=1 if recipientname=="Panama" & year==2004



    * Cameroon elections were in 1997 not 1998 (http://africanelections.tripod.com/cm.html)
    * Romania elections were confirmed in 1990, 1992, 1996,2004 (http://psephos.adam-carr.net/countries/r/romania/; http://en.wikipedia.org/wiki/Romanian_presidential_elections,_2004)
    * Djoubiti 1987 elections were confirmed (http://africanelections.tripod.com/dj.html)
    * Ghana presidential election in 2004 confirmed (http://en.wikipedia.org/wiki/Ghanaian_presidential_election,_2004)

    list recipientname year dateexec exelec if (dateexec==. | dateexec==0) & exelec==1
    replace exelec=0 if recipientname=="Cameroon" & year==1998
    replace exelec=1 if recipientname=="Cameroon" & year==1997

*****************************************************
* VI. Reduce dataset to essential variables
*****************************************************

    keep recipientname wbcode year exelec legelec percent* eiec execrlc yrsoffc system

*******************************************************************
* VI. Merge outside data
*******************************************************************

    rename wbcode wbcode_recipient
    sort wbcode_recipient
    rename recipientname recipient_name

    cd "`indir'"
    merge wbcode_recipient using WBCODErecipient
    keep if _==3
    drop _
    sort recipientcode year

*********************************************************
* VII. Generate variables of interest
**********************************************************

    gen i_elecex=exelec
    * Azerbaijan mistakenly has exeelec=10 in 2003; they did have an election (http://en.wikipedia.org/wiki/Azerbaijan_presidential_election,_2003)
    replace i_elecex=1 if wbcode_r=="AZE" & year==2003 & i_elecex==10

    gen i_elecleg=legelec

    label var i_elecex "Indicator of ex. election year from DPI"
    label var i_elecleg "Indicator of legislative election year from DPI"
    label var eiec "Index of executive eletoral competitiveness (1-7, 7 is most comp.)


*********************************************************
* VIII. Percent that winner received variables are
*       recorded in following year: shifts data so that
*       results recorded in actual election year
**********************************************************

    tsset recipientcode year
    replace percentfirst_ex = F1.percentfirst_ex
    replace percentlast_ex = F1.percentlast_ex

    gen F1_yrsoffc=F1.yrsoffc
*****************************************************************************************
* Generate term codes
******************************************************************************************

    local numobs = _N
    gen termcode = .

    local currecip = 1
    local curtermcode = 1

    sort wbcode_recipient year
    egen recipient=group(wbcode_recipient)

    forvalues i=1/`numobs' {

        if recipient[`i']==`currecip' {

            if (i_elecex[`i']==1 & (year[`i']!=year[`i'-1])) | (F1_yrsoffc[`i']==1 & (year[`i']!=year[`i'-1]))   {
                quietly replace termcode=`curtermcode' if _n==`i'
                local curtermcode=`curtermcode'+1
                        }

            else if i_elecex[`i']!=1 | (i_elecex[`i']==1 & year[`i']==year[`i'-1]) {

                quietly replace termcode=`curtermcode'  if _n==`i'

            }

        }

        if recipient[`i']!=`currecip' {

        quietly replace termcode=1 if _n==`i'
            local currecip=`currecip'+1
            local curtermcode=1
                        }

    }

    replace termcode=. if i_elecex==.
    label var termcode "Numeric counter of election period (doesnt account for change in govt)"



*********************************************************
* VIII. Generate variables of interest
**********************************************************

    keep wbcode year i_elecex i_elecleg eiec percent* termcode  yrsoffc system
  cd "`outdir'"
    sort wbcode_r year
    save `date'_`elecdate'_DPI_final, replace
