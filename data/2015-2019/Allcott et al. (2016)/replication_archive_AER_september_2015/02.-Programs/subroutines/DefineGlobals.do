/* DefineGlobals.do */
* This defines globals so that there is no discrepancy across do files

** Quartile Rainfall bins
global AltQRainfallBins = "PD_rainU_b1 PD_rainU_b2 PD_rainU_b3 PD_rainU_b4 ND_rainU_b1 ND_rainU_b2 ND_rainU_b3"
global dAltQRainfallBins = "dPD_rainU_b1 dPD_rainU_b2 dPD_rainU_b3 dPD_rainU_b4 dND_rainU_b1 dND_rainU_b2 dND_rainU_b3"


* Wider bin widths (100mm)
global Alt100RainfallBins = "PD_rainU_b010 PD_rainU_b1020 PD_rainU_b2030 PD_rainU_b30 ND_rainU_b010 ND_rainU_b1020 ND_rainU_b2030"
global dAlt100RainfallBins = "dPD_rainU_b010 dPD_rainU_b1020 dPD_rainU_b2030 dPD_rainU_b30 dND_rainU_b010 dND_rainU_b1020 dND_rainU_b2030"

* Medium bin widths (60mm)
global Alt60RainfallBins = "PD_rainU_b006 PD_rainU_b0612 PD_rainU_b1218 PD_rainU_b1824 PD_rainU_b24 ND_rainU_b006 ND_rainU_b0612 ND_rainU_b1218 ND_rainU_b1824"
global dAlt60RainfallBins = "dPD_rainU_b006 dPD_rainU_b0612 dPD_rainU_b1218 dPD_rainU_b1824 dPD_rainU_b24 dND_rainU_b006 dND_rainU_b0612 dND_rainU_b1218 dND_rainU_b1824"

* Narrower bin widths (50mm)
global Alt50RainfallBins = "PD_rainU_b005 PD_rainU_b0510 PD_rainU_b1015 PD_rainU_b1520 PD_rainU_b2025 PD_rainU_b25 ND_rainU_b005 ND_rainU_b0510 ND_rainU_b1015 ND_rainU_b1520 ND_rainU_b2025"
global dAlt50RainfallBins = "dPD_rainU_b005 dPD_rainU_b0510 dPD_rainU_b1015 dPD_rainU_b1520 dPD_rainU_b2025 dPD_rainU_b25 dND_rainU_b005 dND_rainU_b0510 dND_rainU_b1015 dND_rainU_b1520 dND_rainU_b2025"

** Rainfall bins for regressions
global RainfallBins = "$Alt60RainfallBins"
global dRainfallBins = "$dAlt60RainfallBins"


** Alternative bin source (NCC instead of UDel)
* NCC Quartile bin widths
global AltQNRainfallBins = "PD_rain_b1 PD_rain_b2 PD_rain_b3 PD_rain_b4 ND_rain_b1 ND_rain_b2 ND_rain_b3"
global dAltQNSRainfallBins = "dPD_rain_b1 dPD_rain_b2 dPD_rain_b3 dPD_rain_b4 dND_rain_b1 dND_rain_b2 dND_rain_b3"

* NCC 50 mm bin widths
global Alt50NRainfallBins = "PD_rain_b005 PD_rain_b0510 PD_rain_b1015 PD_rain_b1520 PD_rain_b2025 PD_rain_b25 ND_rain_b005 ND_rain_b0510 ND_rain_b1015 ND_rain_b1520 ND_rain_b2025"
global dAlt50NRainfallBins = "dPD_rain_b005 dPD_rain_b0510 dPD_rain_b1015 dPD_rain_b1520 dPD_rain_b2025 dPD_rain_b25 dND_rain_b005 dND_rain_b0510 dND_rain_b1015 dND_rain_b1520 dND_rain_b2025"

* NCC 60 mm bin widths
global Alt50NRainfallBins = "PD_rain_b006 PD_rain_b0612 PD_rain_b1218 PD_rain_b1824 PD_rain_b24 ND_rain_b006 ND_rain_b0612 ND_rain_b1218 ND_rain_b1824"
global dAlt50NRainfallBins = "dPD_rain_b006 dPD_rain_b0612 dPD_rain_b1218 dPD_rain_b1814 dPD_rain_b24 dND_rain_b006 dND_rain_b0612 dND_rain_b1218 dND_rain_b1824"


global AltSRainfallBins = "$Alt60NRainfallBins"
global dAltSRainfallBins = "$dAlt60NRainfallBins"


** Cluster variables
global ClusterVars = "statenumxyear statenumxyear_1"
global FEClusterVars = "panelgroup statenumxyear"

/* Instrument variables */
** If Hydro_InstC_rr (based on consumption and res/run hydro)
global Inst = "Hydro_InstC_rr"

global Instxsniclambda = "Hydro_InstC_rrxsniclambda"
global InstxElecIntensive = "Hydro_InstC_rrxElecIntensive"
global InstxanyyearEprod = "Hydro_InstC_rrxanyyearEprod"
global InstxmedianlnK = "Hydro_InstC_rrxmedianlnK"
global InstxLargeK = "Hydro_InstC_rrxLargeK"

/*
** If C1Hydro_InstC_rr (based on consumption and res/run hydro plus capacity addition)
	* This is what we had included in the second round submission, but we were asked to use only the hydro instrument.
global Inst = "C1Hydro_InstC_rr"

global Instxsniclambda = "C1Hydro_InstC_rrxsniclambda"
global InstxElecIntensive = "C1Hydro_InstC_rrxElecIntensive"
global InstxanyyearEprod = "C1Hydro_InstC_rrxanyyearEprod"
global InstxmedianlnK = "C1Hydro_InstC_rrxmedianlnK"
global InstxLargeK = "C1Hydro_InstC_rrxLargeK"
global InstxShortage_L4 = "C1Hydro_InstC_rrxShortage_L4"
*/

