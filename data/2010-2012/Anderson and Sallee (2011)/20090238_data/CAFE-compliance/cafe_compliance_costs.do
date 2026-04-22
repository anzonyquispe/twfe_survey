*********************
***** FILE INFO *****
*********************
* Name: cafe_compliance
* Author: Soren Anderson
* Date: May 28, 2010
* Description:



*************************
***** PRELIMINARIES *****
*************************
clear
pause on
set more off
set mem 500m
cd
cd "Y:/Biofuels/FFV CAFE/CAFE compliance"
log using cafe_compliance_costs.txt, replace text



**********************************************************
***** TABLE 8: MARGINAL COMPLIANCE COSTS PER VEHICLE *****
**********************************************************
* NOTE: PERFORM ADDITIONAL CALCULATIONS USING THIS OUTPUT IN EXCEL

use cafe_compliance

* DROP YEARS BEFORE AMFA INCENTIVE TOOK EFFECT
drop if year<1993

* SALES-WEIGHTED GPM YEAR-BY-YEAR FOR EACH AUTOMAKER AND FLEET: ACTUAL FOR FFVS, ACTUAL FOR ALL VEHICLES, AMFA FOR ALL VEHICLES, AND CAFE STANDARD
keep if mfr=="DCC" | mfr=="FMC" | mfr=="GMC" | mfr=="NIS"
bysort fleet: table year mfr [weight=sales_ffv], c(mean gpm_actual)
bysort fleet: table year mfr [weight=sales], c(mean gpm_actual)
bysort fleet: table year mfr [weight=sales], c(mean gpm_amfa)
bysort fleet: table year mfr [weight=sales], c(mean gpm_std)

* DO SOME CALCULATIONS IN EXCEL TO FIGURE OUT WHEN WE ARE AT CORNER SOLUTIONS ...

* ZERO-OUT SALES FOR YEARS WITH NO FFVS
replace sales_ffv=0 if year<2003 & mfr=="DCC" & fleet=="DP"
replace sales_ffv=0 if year<2003 & mfr=="DCC" & fleet=="IP"
replace sales_ffv=0 if year<1998 & mfr=="DCC" & fleet=="LT"
replace sales_ffv=0 if year<1996 & mfr=="FMC" & fleet=="DP"
replace sales_ffv=0 if year<1999 & mfr=="FMC" & fleet=="LT"
replace sales_ffv=0 if year<2006 & mfr=="GMC" & fleet=="DP"
replace sales_ffv=0 if year<2000 & mfr=="GMC" & fleet=="LT"
replace sales_ffv=0 if year<2005 & mfr=="NIS" & fleet=="LT"
replace sales_ffv=0 if year>2005 & mfr=="DCC" & fleet=="IP"
replace sales=0 if year<2003 & mfr=="DCC" & fleet=="DP"
replace sales=0 if year<2003 & mfr=="DCC" & fleet=="IP"
replace sales=0 if year<1998 & mfr=="DCC" & fleet=="LT"
replace sales=0 if year<1996 & mfr=="FMC" & fleet=="DP"
replace sales=0 if year<1999 & mfr=="FMC" & fleet=="LT"
replace sales=0 if year<2006 & mfr=="GMC" & fleet=="DP"
replace sales=0 if year<2000 & mfr=="GMC" & fleet=="LT"
replace sales=0 if year<2005 & mfr=="NIS" & fleet=="LT"
replace sales=0 if year>2005 & mfr=="DCC" & fleet=="IP"

* ZERO-OUT SALES FOR YEARS WITH BACKSTOP CONSTRAINT CORNER SOLUTIONS
replace sales_ffv=0 if year==2002 & mfr=="GMC" & fleet=="LT"
replace sales_ffv=0 if year==2003 & mfr=="GMC" & fleet=="LT"
replace sales_ffv=0 if year==2003 & mfr=="FMC" & fleet=="LT"
replace sales_ffv=0 if year==2004 & mfr=="GMC" & fleet=="LT"
replace sales_ffv=0 if year==2004 & mfr=="FMC" & fleet=="LT"
replace sales_ffv=0 if year==2006 & mfr=="GMC" & fleet=="DP"
replace sales=0 if year==2002 & mfr=="GMC" & fleet=="LT"
replace sales=0 if year==2003 & mfr=="GMC" & fleet=="LT"
replace sales=0 if year==2003 & mfr=="FMC" & fleet=="LT"
replace sales=0 if year==2004 & mfr=="GMC" & fleet=="LT"
replace sales=0 if year==2004 & mfr=="FMC" & fleet=="LT"
replace sales=0 if year==2006 & mfr=="GMC" & fleet=="DP"

* ZERO-OUT SALES FOR YEARS WITH 100% FFV SHARE CORNER SOLUTIONS
replace sales_ffv=0 if year==2001 & mfr=="GMC" & fleet=="LT"
replace sales_ffv=0 if year==2002 & mfr=="DCC" & fleet=="LT"
replace sales=0 if year==2001 & mfr=="GMC" & fleet=="LT"
replace sales=0 if year==2002 & mfr=="DCC" & fleet=="LT"


* SALES-WEIGHTED GPM ON AVERAGE 1993-2006 (REMOVING CORNER SOLUTIONS) FOR EACH AUTOMAKER AND FLEET: ACTUAL FOR FFVS AND AMFA FOR ALL VEHICLES
table fleet mfr [weight=sales_ffv], c(mean gpm_actual)
table fleet mfr [weight=sales], c(mean gpm_amfa)
clear



log close
exit
