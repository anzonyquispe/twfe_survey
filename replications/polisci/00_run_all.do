/*==============================================================
  MASTER RUNNER: Ejecutar toda la pipeline de Stata

  PREREQUISITO: Antes de correr este archivo, ejecutar en R:
    source("STATA/00_convert_rds_to_dta.R")
  Eso genera los 11 archivos data_*.dta necesarios.

  Luego en Stata:
    do "replications/polisci/00_run_all.do"

  Pipeline:
    1. 11 papers individuales -> replications/polisci/output/{paper}_estimates.dta
    2. 10_combine_summary.do  -> replications/polisci/output/summary.dta
    3. 11_figure4.do          -> replications/polisci/output/fig4_coefficients.pdf
                                 replications/polisci/output/fig4_zscores.pdf
==============================================================*/

clear all
set more off
cap set maxvar 32000

global path "C:/Users/Usuario/Documents/GitHub/twfe_survey"
cd "$path"

* Crear directorio de output si no existe
cap mkdir "replications/polisci/output"

* Verificar que existan los datos
local papers "bischof clayton christensen hankinson eckhouse paglayan kuipers esberg hirano trounstine hainmueller"
local missing = 0
foreach p of local papers {
    cap confirm file "data/polisci/data_`p'.dta"
    if _rc != 0 {
        di as error "FALTA: STATA/data_`p'.dta"
        local missing = `missing' + 1
    }
}
if `missing' > 0 {
    di as error ""
    di as error "=== Faltan `missing' archivos .dta ==="
    di as error "Ejecutar primero en R:"
    di as error "  source('STATA/00_convert_rds_to_dta.R')"
    exit 601
}

di ""
di "============================================"
di "  TODOS LOS DATOS ENCONTRADOS"
di "  Iniciando pipeline..."
di "============================================"
di ""

timer clear
timer on 1

* ==============================================================
* PASO 1: Correr los 11 papers individuales
* ==============================================================

local dofiles "01_bischof 02_clayton 03_christensen 04_hankinson 05_eckhouse 06_paglayan 07_kuipers 08_esberg 09_hirano 10a_trounstine 11a_hainmueller"

foreach f of local dofiles {
    di ""
    di "************************************************************"
    di "  Corriendo: STATA/`f'.do"
    di "************************************************************"
    di ""
    cap noi do "replications/polisci/`f'.do"
    if _rc != 0 {
        di as error ""
        di as error "*** ERROR en STATA/`f'.do (rc = " _rc ") ***"
        di as error "*** Continuando con el siguiente paper... ***"
        di as error ""
    }
}

* ==============================================================
* PASO 2: Combinar resultados
* ==============================================================

di ""
di "************************************************************"
di "  Corriendo: STATA/10_combine_summary.do"
di "************************************************************"
di ""
do "replications/polisci/10_combine_summary.do"

* ==============================================================
* PASO 3: Generar figuras
* ==============================================================

di ""
di "************************************************************"
di "  Corriendo: STATA/11_figure4.do"
di "************************************************************"
di ""
do "replications/polisci/11_figure4.do"

timer off 1

di ""
di "============================================"
di "  PIPELINE COMPLETADA"
di "============================================"
di ""
di "Archivos generados:"
di "  replications/polisci/output/bischof_estimates.dta"
di "  replications/polisci/output/clayton_estimates.dta"
di "  replications/polisci/output/christensen_estimates.dta"
di "  replications/polisci/output/hankinson_estimates.dta"
di "  replications/polisci/output/eckhouse_estimates.dta"
di "  replications/polisci/output/paglayan_estimates.dta"
di "  replications/polisci/output/kuipers_estimates.dta"
di "  replications/polisci/output/esberg_estimates.dta"
di "  replications/polisci/output/hirano_estimates.dta"
di "  replications/polisci/output/trounstine_estimates.dta"
di "  replications/polisci/output/hainmueller_estimates.dta"
di "  replications/polisci/output/summary.dta"
di "  replications/polisci/output/fig4_coefficients.pdf"
di "  replications/polisci/output/fig4_zscores.pdf"
di ""
timer list 1
