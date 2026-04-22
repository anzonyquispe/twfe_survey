clear
set more off, permanently

use table4_0708, clear

foreach X in rival ally gang {
	g `X'=0
	replace `X'=1 if border=="`X'"
}

collapse (mean) drughom spread PANwin pob_total FarUS SafeMun gang rival ally, by(id_mun)

g deathsx=(drughom/pob_t)*12*100000
g spreadPW=spread*PANwin

foreach var in FarUS SafeMun gang rival ally {
	g panx`var'=PANwin*`var'
	g spreadx`var'=spread*`var'
	g spwx`var'=spread*PANwin*`var'
}

*baseline
reg deathsx PANwin spread spreadPW if abs(spread)<0.05 [aw=pob_t], robust
outreg2 PANwin using table4, excel less(0) nocons replace bdec(3) 

foreach var in FarUS SafeMun {
		
	reg deathsx PANwin `var' panx`var' spread spreadPW spreadx`var' spwx`var' if abs(spread)<0.05 [aw=pob_t], robust

	lincom PANwin + panx`var'
	local coeff`var' = r(estimate)
	local se`var'= r(se)
	test PANwin + panx`var' = 0
	local p`var' = r(p)
								
	outreg2 PANwin panx`var' using table4, excel less(0) nocons append bdec(3) adds(coeff`var', `coeff`var'',se`var',`se`var'',p`var', `p`var'')

}

reg deathsx PANwin gang rival ally panxgang panxrival panxally spread spreadPW spreadxgang spwxgang spreadxrival spwxrival spreadxally spwxally if abs(spread)<0.05 [aw=pob_t], robust

foreach var in gang rival ally {
	lincom PANwin + panx`var'
	local coeff_`var' = r(estimate)
	local se_`var'= r(se)
	test PANwin + panx`var' = 0
	local p_`var' = r(p)
}
			
outreg2 PANwin panxgang panxally panxrival using table4, excel less(0) nocons append bdec(3) adds("Local Gang", `coeff_gang',se_gang,`se_gang',p_gang, `p_gang', "Borders Ally", `coeff_ally',se_ally,`se_ally',p_ally, `p_ally', "Borders Rival", `coeff_rival',se_rival,`se_rival',p_rival, `p_rival')

*****************************************
*****************************************
***---2007-2010
*****************************************
*****************************************

use table4_0710, clear

foreach X in rival ally gang {
	g `X'=0
	replace `X'=1 if border=="`X'"
}

collapse (mean) drughom spread PANwin pob_total FarUS SafeMun gang rival ally, by(id_mun elec_c)

g deathsx=(drughom/pob_t)*12*100000
g spreadPW=spread*PANwin

foreach var in FarUS SafeMun gang rival ally {
	g panx`var'=PANwin*`var'
	g spreadx`var'=spread*`var'
	g spwx`var'=spread*PANwin*`var'
}

*Baseline
reg deathsx PANwin spread spreadPW if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using table4, excel less(0) nocons append bdec(3) 

foreach var in FarUS SafeMun {
	
	reg deathsx PANwin `var' panx`var' spread spreadPW spreadx`var' spwx`var' if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)	

	lincom PANwin + panx`var'
	local coeff`var' = r(estimate)
	local se`var'= r(se)
	test PANwin + panx`var' = 0
	local p`var' = r(p)

								
	outreg2 PANwin panx`var' using table4, excel less(0) nocons append bdec(3) adds(coeff`var', `coeff`var'',se`var',`se`var'',p`var', `p`var'')

}

reg deathsx PANwin gang rival ally panxgang panxrival panxally spread spreadPW spreadxgang spwxgang spreadxrival spwxrival spreadxally spwxally if abs(spread)<0.05 [aw=pob_t], robust cluster(id_m)

foreach var in gang rival ally {
	lincom PANwin + panx`var'
	local coeff_`var' = r(estimate)
	local se_`var'= r(se)
	test PANwin + panx`var' = 0
	local p_`var' = r(p)
}
			
outreg2 PANwin panxgang panxally panxrival using table4, excel less(0) nocons append bdec(3) adds("Local Gang", `coeff_gang',se_gang,`se_gang',p_gang, `p_gang', "Borders Ally", `coeff_ally',se_ally,`se_ally',p_ally, `p_ally', "Borders Rival", `coeff_rival',se_rival,`se_rival',p_rival, `p_rival')


