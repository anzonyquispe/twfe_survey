/*==============================================================
  Master: Corre todos los do-files (02-11a) en secuencia
  con un solo log para revision.

  Uso: abrir Stata, hacer:
    cd "C:/Users/Usuario/Documents/GitHub/twfe_survey"
    do STATA/run_all.do
==============================================================*/

clear all
set more off

global path "C:/Users/Usuario/Documents/GitHub/twfe_survey"
cd "$path"

cap log close _all
log using "replications/polisci/run_all_log.txt", text replace

di "============================================"
di "  MASTER RUN: Inicio `c(current_date)' `c(current_time)'"
di "============================================"

* --- 02 Clayton ---
di _n ">>>>>>>>>> CORRIENDO 02_clayton.do <<<<<<<<<<"
cap noi do "replications/polisci/02_clayton.do"
di ">>>>>>>>>> FIN 02_clayton.do (rc=" _rc ") <<<<<<<<<<"

* --- 03 Christensen ---
di _n ">>>>>>>>>> CORRIENDO 03_christensen.do <<<<<<<<<<"
cap noi do "replications/polisci/03_christensen.do"
di ">>>>>>>>>> FIN 03_christensen.do (rc=" _rc ") <<<<<<<<<<"

* --- 04 Hankinson ---
di _n ">>>>>>>>>> CORRIENDO 04_hankinson.do <<<<<<<<<<"
cap noi do "replications/polisci/04_hankinson.do"
di ">>>>>>>>>> FIN 04_hankinson.do (rc=" _rc ") <<<<<<<<<<"

* --- 05 Eckhouse ---
di _n ">>>>>>>>>> CORRIENDO 05_eckhouse.do <<<<<<<<<<"
cap noi do "replications/polisci/05_eckhouse.do"
di ">>>>>>>>>> FIN 05_eckhouse.do (rc=" _rc ") <<<<<<<<<<"

* --- 06 Paglayan ---
di _n ">>>>>>>>>> CORRIENDO 06_paglayan.do <<<<<<<<<<"
cap noi do "replications/polisci/06_paglayan.do"
di ">>>>>>>>>> FIN 06_paglayan.do (rc=" _rc ") <<<<<<<<<<"

* --- 07 Kuipers ---
di _n ">>>>>>>>>> CORRIENDO 07_kuipers.do <<<<<<<<<<"
cap noi do "replications/polisci/07_kuipers.do"
di ">>>>>>>>>> FIN 07_kuipers.do (rc=" _rc ") <<<<<<<<<<"

* --- 08 Esberg ---
di _n ">>>>>>>>>> CORRIENDO 08_esberg.do <<<<<<<<<<"
cap noi do "replications/polisci/08_esberg.do"
di ">>>>>>>>>> FIN 08_esberg.do (rc=" _rc ") <<<<<<<<<<"

* --- 09 Hirano ---
di _n ">>>>>>>>>> CORRIENDO 09_hirano.do <<<<<<<<<<"
cap noi do "replications/polisci/09_hirano.do"
di ">>>>>>>>>> FIN 09_hirano.do (rc=" _rc ") <<<<<<<<<<"

* --- 10a Trounstine ---
di _n ">>>>>>>>>> CORRIENDO 10a_trounstine.do <<<<<<<<<<"
cap noi do "replications/polisci/10a_trounstine.do"
di ">>>>>>>>>> FIN 10a_trounstine.do (rc=" _rc ") <<<<<<<<<<"

* --- 11a Hainmueller ---
di _n ">>>>>>>>>> CORRIENDO 11a_hainmueller.do <<<<<<<<<<"
cap noi do "replications/polisci/11a_hainmueller.do"
di ">>>>>>>>>> FIN 11a_hainmueller.do (rc=" _rc ") <<<<<<<<<<"

di _n "============================================"
di "  MASTER RUN: Fin `c(current_date)' `c(current_time)'"
di "============================================"

log close
