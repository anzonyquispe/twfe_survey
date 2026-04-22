
    *****************************************************************************
    ***  Merge DPI elections data with WBCodes and label variables **************
    ***  August 3, 2007                                         *************
    ******************************************************************************

    ***************************************************
    *** Input file: dpi2004_missing.dta             ***
    *** Output file:dpi2004_electionsCLEAN          ***
    ***************************************************


    *************************************************
    * I. Setup
    ************************************************

    clear
    use "/export/home/doctoral/mfaye/aid/Elections/dpi2004_missing.dta"
    local date=string(date(c(current_date), "dmy"), "%dYND")

    *************************************************
    * II. Label and rename variables
    ************************************************

    rename countryc recipientname
    rename ifs wbcode
    rename system system_ex
    label var system_ex "Direct presidential (0); strong president elected by assembly (1); Parliamentary (2)"

    rename yrsoffc yrsoffc_ex
    label var yrsoffc_ex "How many years has the chief executive been in office"

    rename finittrm finittrm_ex
    label var finittrm_ex "Is there a finite term in office? (1=yes; 0=no)"

    rename yrcurnt yrcurnt_ex
    label var yrcurnt_ex "Years left in current term"

    rename multpl_ mult_ex
    label var mult_ex "Can exec. serve multiple terms? (1=yes)"

    rename military milit_ex
    label var milit_ex "Is Chief Executive a military officer"

    label var defmin "Is defense minister a military officer?"

    rename percent1 percentfirst_ex
    label var percentfirst_ex "% of votes president got of votes in first round"
    rename percentl percentlast_ex
    label var percentlast_ex "% of votes president got of votes in first round"
    label var prtyin "Length party of chief executive has been in office"

    label var execrlc "Exec party: Right (R) Left (L); Center (C)"
    label var gov1rlc "Largest govt party: Right (R) Left (L); Center (C)"
    label var opp1rlc "Largest opposition party: Right (R) Left (L); Center (C)"

    label var execnat "Executive party: nationalist"
    label var gov1nat "Largest govt party: nationalist?"
    label var opp1nat "Largest opposition party: nationalist?"

    rename execme execname
    label var allhouse "Does party of executive control all houses?"

    label var dateleg "When were legistlative elections held? (13= unknown month)"
    label var dateexec "When were executive elections held?"

    ******************************************************************
    * III. Generate new variables
    *******************************************************************

    * Note that we do we do not include observations in which either the
    * government party or opposition party does not exist or is NA (according to dpi)
    gen i_execopp_diff=.
    replace i_execopp_diff=1 if (execrlc=="R" & opp1rlc=="L") | (execrlc=="L" & opp1rlc=="R")
    replace i_execopp_diff=0 if (execrlc=="R" & opp1rlc=="R") | (execrlc=="L" & opp1rlc=="L") | (execrlc=="C" | opp1rlc=="C")
    label var i_execopp_diff "Indicator of whether exec and opposition parties far apart (R vs L)"

   gen i_execright=.
   replace i_execright=1 if execrlc=="R"
   replace i_execright=0 if (execrlc=="L" | execrlc=="C")

   gen i_execleft=.
   replace i_execleft=1 if execrlc=="L"
   replace i_execleft=0 if (execrlc=="R" | execrlc=="C")

   label var i_execright "Indicator of whether executive is member of right wing party"
   label var i_execleft "Indicator of whether executive is member of left wing party"


    ******************************************************************
    * IV. Clean variables in preparation for merging
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
    * Not sure about Yemen
    replace recipientname="Yugoslavia, Sts Ex-Yugo. Unspec." if recipientname=="Yugoslavia"


    *****************************************************
    * IV. Reduce dataset to essential variables
    *****************************************************

    keep recipientname wbcode year *_ex date* prtyin percent* allhouse exelec legelec execnat gov1nat opp1nat  execrlc gov1rlc opp1rlc i_execopp_diff i_execright i_execleft eiec finittrm fraud


    *****************************************************
    * V. Merge outside data
    *****************************************************

    rename wbcode wbcode_recipient
    sort wbcode_recipient
    rename recipientname recipient_name
    cd "/export/home/doctoral/mfaye/aid/OutsideData"

    merge wbcode_recipient using WBCODErecipient
    keep if _==3
    drop _
    sort recipientcode year

    gen dataset="dpi"

    cd "/export/home/doctoral/mfaye/aid/Elections"
    save `date'_dpi2004_electionsCLEAN, replace

    *********************************************************
    * VI. Add IDEA data for additional years
    **********************************************************

    clear
    set mem 3g
    local elections="/export/home/doctoral/mfaye/aid/Elections"
    cd "`elections'"
    use `date'_dpi2004_electionsCLEAN.dta

    append using elections_idea.dta
    keep if dataset!="idea" | year<1975

    *********************************************************
    * VII. Generate dummy variables
    **********************************************************


    replace exelec=1 if exelec==1


    gen i_elecex=.
    replace i_elecex=0 if (dateexec==.| dateexec==0) & (dataset=="dpi")
    replace i_elecex=1 if (dateexec!=. & dateexec!=0) & (dataset=="dpi")

    gen i_elecleg=.
    replace i_elecleg=0 if (dateleg==.| dateleg==0) & (dataset=="dpi")
    replace i_elecleg=1 if (dateleg!=. & dateleg!=0) & (dataset=="dpi")

    gen i_elecex_both=.
    replace i_elecex_both=0 if dataset=="dpi" | dataset =="idea"
    replace i_elecex_both=1 if i_elecex==1 | i_elec_idea==1

    gen i_elecex_old=i_elecex

    replace i_elecex=. if exelec==.
    replace i_elecex=1 if wbcode_r=="GHA" & year==2004
    replace i_elecex=1 if wbcode_r=="IDN" & year==1998
    replace i_elecex=0 if wbcode_r=="IDN" & year==1999
    replace i_elecex=1 if wbcode_r=="CMR" & year==1997
    replace i_elecex=1 if wbcode_r=="DJI" & year==1987

    egen i=group(wbcode_r)
    tsset i year
    gen elecex_win = 0 if i_elecex == 1
    replace elecex_win = 1 if i_elecex == 1 & F.yrsoffc_ex != 1
    drop i

    gen i_compet=.
    replace i_compet=1 if eiec==4 |eiec==5 | eiec==6 | eiec==7
    replace i_compet=0 if eiec==1 | eiec==2 | eiec==3

    label var i_elec_idea "Indicator of election year from IDEA data"
    label var i_elec_wiki "Indicator of election year from Wikipedia"
    label var i_elecex "Indicator of election year from DPI"
    label var i_elecex_both "Indicator of election year (DPI and IDEA)"
    label var elecex_win "Indicator of whether incumbent won reelection"
    label  var eiec "Index of executive eletoral competitiveness (1-7, 7 is most comp.)
    label var i_compet "Binary index of competitvness (1: eiec>3, 0: eiec<=3)"


    * Of 328 elections in DPI data, fraud variable is empty for 39 of them
    * Also, the fraud variable exists for years in which there were no elections,
    * since variable refers to most recent election year (e.g., only way to change
    * variable is to hold free election

    sort wbcode_r year
    replace fraud=fraud[_n+1]
    label var fraud "Was there fraud in most recent election?"

    *********************************************************
    * VIII. Calculate UN votes overall whole term
    **********************************************************

    replace finittrm_ex="." if finittrm_ex=="NA"
    destring finittrm_ex, replace


    local numobs = _N
    gen termcode = .

    local currecip = 1              /* Generate counter for recipient */
    local curtermcode = 1           /* Generate indicator of what term individual is in */

    sort wbcode_recipient year
    egen recipient=group(wbcode_recipient)  /* Just so that we have numeric indicator of recipient country */

    forvalues i=1/`numobs' {

        if recipient[`i']==`currecip' {

            if i_elecex[`i']==1 & (year[`i']!=year[`i'-1]) {
                quietly replace termcode=`curtermcode' if _n==`i'
                local curtermcode=`curtermcode'+1
                        }

            if i_elecex[`i']!=1 | (i_elecex[`i']==1 & year[`i']==year[`i'-1]) {

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
    * IX. Save
    **********************************************************

    sort wbcode_r year
    drop legelec exelec recipientcode country_recipient m i_elecleg i_elecex_old recipient dataset

    save "/export/projects/aidflow_project/OutsideData/Elections/`date'_dpi2004_electionsCLEAN.dta", replace
