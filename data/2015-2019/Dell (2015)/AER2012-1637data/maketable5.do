clear
set more off 


********************************
***---Baseline
********************************

use table5_0708, clear

*Limit sample
keep if pan_fs==1 /*only keep places where the Pan was first or second*/

drop if spread_panfs==0 /*ties*/

collapse (mean) drughom spread_panfs spreadPW pan_win pob_total PWPI spreadPI spreadPWPI lPAN alter PANgov, by(id_mun)

g deathsx=(drughom/pob_t)*12*100000

reg deathsx pan_win spread_panfs spreadPW if abs(spread_panfs)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 pan_win using table5, excel less(0) nocons replace bdec(3)

**************************
**--Heterogenous effects by incumbent
**************************
rename spread_panfs spread 
rename PWPI PanWPI
reg deathsx pan_win lPAN PanWPI spread spreadPW spreadPI spreadPWPI if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)

lincom pan_win + PanWPI
local Pincumb_coeff = r(estimate)
local Pincumb_se= r(se)
test pan_win + PanWPI = 0
local Pincumb_p = r(p)
outreg2 pan_win PanWPI using table5, excel less(0) nocons append bdec(3) adds("PAN win effect (PAN incumb.)",`Pincumb_coeff',"S.E._panincumb",`Pincumb_se',"p_panincumb", `Pincumb_p')

********************************
***---Alternation - PAN
********************************
rename alter alterPAN
g spread_alter=spread*alterPAN
reg deathsx alter spread spread_alter if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 alter using table5, excel less(0) nocons append bdec(3)

********************************
***---Pri & Prd
*******************************


use table5_0708, clear

*Limit sample
keep if pri_v_prd==1 /*only keep places where the Pan was first or second*/

drop if spreadPriPrd==0 /*ties*/

rename spreadPriPrd spread

collapse (mean) drughom spread pri_win pob_total alter, by(id_mun)

g deathsx=(drughom/pob_t)*12*100000

g spreadPW=spread*pri_win

reg deathsx pri_win spread spreadPW if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 pri_win using table5, excel less(0) nocons append bdec(3)

*********************************
**---PRI/PRD ALTER
*********************************

rename alter alterPRI_PRD
g spread_alter=spread*alterPRI
reg deathsx alter spread spread_alter if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 alter using table5, excel less(0) nocons append bdec(3)

**************************
**--Heterogenous effects by governor
**************************

use table5_0708, clear

*Limit sample
keep if pan_fs==1 /*only keep places where the Pan was first or second*/
drop if spread_panfs==0 /*ties*/

collapse (mean) drughom spread_panfs spreadPW pan_win pob_total PANgov, by(id_mun)

rename spread_panfs spread

g deathsx=(drughom/pob_t)*12*100000
g PWPG=pan_win*PANgov
g spreadPG=spread*PANgov
g spreadPWPG=spread*pan_win*PANgov
reg deathsx pan_win PANgov PWPG spread spreadPW spreadPG spreadPWPG if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)

lincom pan_win + PWPG
local Pgov_coeff = r(estimate)
local Pgov_se= r(se)
test pan_win + PWPG = 0
local Pgov_p = r(p)
outreg2 pan_win PWPG using table5, excel less(0) nocons append bdec(3) adds("PAN win effect (PAN gov.)",`Pgov_coeff',"S.E._pangov",`Pgov_se',"p_pangov", `Pgov_p')

***************************************************
***----2007-2010 elections
***************************************************

********************************
***---Baseline
********************************

use table5_0710, clear

*Limit sample
keep if pan_fs==1 /*only keep places where the Pan was first or second*/

drop if spread_panfs==0 /*ties*/

collapse (mean) drughom spread_panfs spreadPW pan_win pob_total PWPI spreadPI spreadPWPI lPAN alter PANgov, by(id_mun elec_c)

g deathsx=(drughom/pob_t)*12*100000

reg deathsx pan_win spread_panfs spreadPW if abs(spread_panfs)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 pan_win using table5, excel less(0) nocons append bdec(3)

**************************
**--Heterogenous effects by incumbent
**************************
rename spread_panfs spread 
rename PWPI PanWPI

reg deathsx pan_win lPAN PanWPI spread spreadPW spreadPI spreadPWPI if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)

lincom pan_win + PanWPI
local Pincumb_coeff = r(estimate)
local Pincumb_se= r(se)
test pan_win + PanWPI = 0
local Pincumb_p = r(p)
outreg2 pan_win PanWPI using table5, excel less(0) nocons append bdec(3) adds("PAN win effect (PAN incumb.)",`Pincumb_coeff',"S.E._panincumb",`Pincumb_se',"p_panincumb", `Pincumb_p')

********************************
***---Alternation - PAN
********************************
rename alter alterPAN
g spread_alter=spread*alterPAN
reg deathsx alter spread spread_alter if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 alter using table5, excel less(0) nocons append bdec(3)

********************************
***---Pri & Prd
*******************************

use table5_0710, clear

*Limit sample
keep if pri_v_prd==1 /*only keep places where the Pan was first or second*/

drop if spreadPriPrd==0 /*ties*/

rename spreadPriPrd spread

collapse (mean) drughom spread pri_win pob_total alter, by(id_mun elec_c)

g deathsx=(drughom/pob_t)*12*100000

g spreadPW=spread*pri_win

reg deathsx pri_win spread spreadPW if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 pri_win using table5, excel less(0) nocons append bdec(3)

*********************************
**---PRI/PRD ALTER
*********************************

rename alter alterPRI_PRD
g spread_alter=spread*alterPRI
reg deathsx alter spread spread_alter if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 alter using table5, excel less(0) nocons append bdec(3)

**************************
**--Heterogenous effects by governor
**************************
use table5_0710, clear

*Limit sample
keep if pan_fs==1 /*only keep places where the Pan was first or second*/
drop if spread_panfs==0 /*ties*/

collapse (mean) drughom spread_panfs spreadPW pan_win pob_total PANgov, by(id_mun elec_c)

rename spread_panfs spread

g deathsx=(drughom/pob_t)*12*100000
g PWPG=pan_win*PANgov
g spreadPG=spread*PANgov
g spreadPWPG=spread*pan_win*PANgov
reg deathsx pan_win PANgov PWPG spread spreadPW spreadPG spreadPWPG if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)

lincom pan_win + PWPG
local Pgov_coeff = r(estimate)
local Pgov_se= r(se)
test pan_win + PWPG = 0
local Pgov_p = r(p)
outreg2 pan_win PWPG using table5, excel less(0) nocons append bdec(3) adds("PAN win effect (PAN gov.)",`Pgov_coeff',"S.E._pangov",`Pgov_se',"p_pangov", `Pgov_p')



