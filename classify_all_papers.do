/*==============================================================================
  MASTER: classify_design for all 24 papers (Ola 1 + Ola 2)

  For each paper:
    1. Run run_twowayfe.do (generates panel_GTD.dta via STEP 6)
    2. Load panel_GTD.dta
    3. Run classify_design G T D
    4. Append result to classify_results.txt

  Run with:  "D:/era_data2/StataMP-64.exe" /e do classify_all_papers.do
==============================================================================*/

clear all
set more off

if "`c(username)'" == "anzony.quisperojas" {
    global twfe_root   "/Users/anzony.quisperojas/Documents/GitHub/twfe_survey"
    global papers_root "/Users/anzony.quisperojas/Documents/GitHub/papers_economic"
}
else if "`c(username)'" == "Usuario" {
    global twfe_root   "C:/Users/Usuario/Documents/GitHub/twfe_survey"
    global papers_root "C:/Users/Usuario/Documents/GitHub/papers_economic"
}
else {
    di as error "Unknown user `c(username)'. Add your repo paths to the user-detection block at the top of this dofile."
    exit 198
}

local resfile "$twfe_root/classify_results.txt"
cap file close fh
file open fh using "`resfile'", write replace
file write fh "paper|G|T|D|design|subtype" _n
file close fh




* =============================================================================
* PAPER 9: Acemoglu et al. (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 9: Acemoglu et al. (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Acemoglu et al. (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Acemoglu et al. (2011)/panel_GTD.dta", clear
    classify_design id year fpresence
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Acemoglu et al. (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Acemoglu et al. (2011)|id|year|fpresence|`d'|`s'" _n
file close fh




* =============================================================================
* PAPER 1: Algan and Cahuc (2010)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 1: Algan and Cahuc (2010)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Algan and Cahuc (2010)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Algan and Cahuc (2010)/panel_GTD.dta", clear
    classify_design cty_num period_num trustgss
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Algan and Cahuc (2010): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Algan and Cahuc (2010)|cty_num|period_num|trustgss|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 2: Zhang and Zhu (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 2: Zhang and Zhu (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Zhang and Zhu (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Zhang and Zhu (2011)/panel_GTD.dta", clear
    classify_design id week_num after
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Zhang and Zhu (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Zhang and Zhu (2011)|id|week_num|after|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 3: Bagwell and Staiger (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 3: Bagwell and Staiger (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Bagwell and Staiger (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Bagwell and Staiger (2011)/panel_GTD.dta", clear
    classify_design HS2 country_num Import_M
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Bagwell and Staiger (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Bagwell and Staiger (2011)|HS2|country_num|Import_M|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 4: Wang (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 4: Wang (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Wang (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Wang (2011)/panel_GTD.dta", clear
    classify_design province_num year post_mismatch
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Wang (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Wang (2011)|province_num|year|post_mismatch|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 5: Duranton and Turner (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 5: Duranton and Turner (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Duranton and Turner (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Duranton and Turner (2011)/panel_GTD.dta", clear
    classify_design msa year Dl_ln_IH
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Duranton and Turner (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Duranton and Turner (2011)|msa|year|Dl_ln_IH|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 6: Moser and Voena (2012)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 6: Moser and Voena (2012)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Moser and Voena (2012)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Moser and Voena (2012)/panel_GTD.dta", clear
    classify_design class_id grntyr treat
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Moser and Voena (2012): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Moser and Voena (2012)|class_id|grntyr|treat|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 7: Enikolopov et al. (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 7: Enikolopov et al. (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Enikolopov et al. (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Enikolopov et al. (2011)/panel_GTD.dta", clear
    classify_design tik_id _j Watch_probit_
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Enikolopov et al. (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Enikolopov et al. (2011)|tik_id|_j|Watch_probit_|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 8: Forman et al. (2012)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 8: Forman et al. (2012)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Forman et al. (2012)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Forman et al. (2012)/panel_GTD.dta", clear
    classify_design county_id period surv_deeppost00
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Forman et al. (2012): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Forman et al. (2012)|county_id|period|surv_deeppost00|`d'|`s'" _n
file close fh



* =============================================================================
* PAPER 10: Hornbeck (2012)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 10: Hornbeck (2012)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Hornbeck (2012)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Hornbeck (2012)/panel_GTD.dta", clear
    classify_design fips year D_high_post
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Hornbeck (2012): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Hornbeck (2012)|fips|year|D_high_post|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 11: Besley and Mueller (2012)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 11: Besley and Mueller (2012)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Besley and Mueller (2012)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Besley and Mueller (2012)/panel_GTD.dta", clear
    classify_design region time L1_wtd
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Besley and Mueller (2012): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Besley and Mueller (2012)|region|time|L1_wtd|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 12: Simcoe (2012)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 12: Simcoe (2012)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Simcoe (2012)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Simcoe (2012)/panel_GTD.dta", clear
    classify_design techarea pubCohort st_stbafl1yr
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Simcoe (2012): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Simcoe (2012)|techarea|pubCohort|st_stbafl1yr|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 13: Dinkelman (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 13: Dinkelman (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Dinkelman (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Dinkelman (2011)/panel_GTD.dta", clear
    classify_design comm_id year D
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Dinkelman (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Dinkelman (2011)|comm_id|year|D|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 14: Gentzkow et al. (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 14: Gentzkow et al. (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Gentzkow et al. (2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Gentzkow et al. (2011)/panel_GTD.dta", clear
    classify_design cnty90 year numdailies
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Gentzkow et al. (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Gentzkow et al. (2011)|cnty90|year|numdailies|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 15: Baum-Snow and Lutz (2011)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 15: Baum-Snow and Lutz (2011)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Baum-SnowandLutz(2011)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Baum-SnowandLutz(2011)/panel_GTD.dta", clear
    classify_design leaid year imp_post
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Baum-Snow and Lutz (2011): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Baum-Snow and Lutz (2011)|leaid|year|imp_post|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 16: Faye and Niehaus (2012)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 16: Faye and Niehaus (2012)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2010-2012/Faye and Niehaus (2012)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2010-2012/Faye and Niehaus (2012)/panel_GTD.dta", clear
    classify_design pair_id year i_elecex
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Faye and Niehaus (2012): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Faye and Niehaus (2012)|pair_id|year|i_elecex|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 17: Antecol et al. (2018)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 17: Antecol et al. (2018)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Antecol et al. (2018)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Antecol et al. (2018)/panel_GTD.dta", clear
    classify_design pol_u pol_job_start gncs
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Antecol et al. (2018): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Antecol et al. (2018)|pol_u|pol_job_start|gncs|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 18: Berman et al. (2017)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 18: Berman et al. (2017)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Berman et al. (2017)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Berman et al. (2017)/panel_GTD.dta", clear
    classify_design cell it main_lprice_mines
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Berman et al. (2017): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Berman et al. (2017)|cell|it|main_lprice_mines|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 19: Burgess et al. (2015)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 19: Burgess et al. (2015)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Burgess et al. (2015)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Burgess et al. (2015)/panel_GTD.dta", clear
    classify_design distnum year president
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Burgess et al. (2015): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Burgess et al. (2015)|distnum|year|president|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 20: Donaldson (2018)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 20: Donaldson (2018)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Donaldson (2018)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Donaldson (2018)/panel_GTD.dta", clear
    classify_design distid year RAIL
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Donaldson (2018): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Donaldson (2018)|distid|year|RAIL|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 21: Favara and Imbs (2015)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 21: Favara and Imbs (2015)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Favara and Imbs (2015)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Favara and Imbs (2015)/panel_GTD.dta", clear
    classify_design county year Linter_bra
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Favara and Imbs (2015): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Favara and Imbs (2015)|county|year|Linter_bra|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 22: Fetzer (2019)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 22: Fetzer (2019)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Fetzer (2019)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Fetzer (2019)/panel_GTD.dta", clear
    classify_design id ryr temp
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Fetzer (2019): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Fetzer (2019)|id|ryr|temp|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 23: Kaur (2019)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 23: Kaur (2019)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Kaur (2019)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Kaur (2019)/panel_GTD.dta", clear
    classify_design dist year amons80
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Kaur (2019): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Kaur (2019)|dist|year|amons80|`d'|`s'" _n
file close fh


* =============================================================================
* PAPER 24: Suárez Serrato and Zidar (2016)
* =============================================================================
di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
di ">>> PAPER 24: Suárez Serrato and Zidar (2016)"
di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cap noisily do "$twfe_root/replications/2015-2019/Suárez Serrato and Zidar (2016)/run_twowayfe.do"
adopath + "D:/era_data2/ado/plus"
adopath + "$twfe_root"
local d "FAILED"
local s ""
cap noisily {
    use "$twfe_root/replications/2015-2019/Suárez Serrato and Zidar (2016)/panel_GTD.dta", clear
    classify_design fe_group year d_keeprate
    local d "`r(design)'"
    local s "`r(subtype)'"
}
di ">>> RESULT Suárez Serrato and Zidar (2016): `d' `s'"
cap file close fh
file open fh using "$twfe_root/classify_results.txt", write append
file write fh "Suárez Serrato and Zidar (2016)|fe_group|year|d_keeprate|`d'|`s'" _n
file close fh


* =============================================================================
* FINAL SUMMARY
* =============================================================================
di _n _n "==============================================================="
di "  ALL 24 PAPERS PROCESSED"
di "  Results saved to: classify_results.txt"
di "==============================================================="

cap file close fh
type "$twfe_root/classify_results.txt"

di _n "DONE."
