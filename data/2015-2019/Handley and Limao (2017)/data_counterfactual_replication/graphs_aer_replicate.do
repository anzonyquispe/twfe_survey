
set more off

use replication_maindata1,clear

	
xtset hs6 year	


* need value lables for sections * 

label def sectvals 1 "Live Animals; Animal Products" 2 "Vegetable Products" 3 "Animal or Vegetable Fats and Oils; Prepared Edible Fats" 4 "Prepared Foodstuffs" /*
*/ 5 "Mineral Products"/*
*/6	"Products of the Chemical or Allied Industries" /*
*/7	"Plastics, Rubber and Articles Thereof" /*
*/8	"Raw Hides and Skins, Leather; Travel Goods, Handbags and Similar" /*
*/9	"Wood and Articles of Wood; Manuf. of Straw, Esparto or Plaiting Materials; Basketware and Wickerwork" /*
*/10	"Pulp Of  Wood or of Other Fibrous Cellulosic Material; Paper and Paperboard and Articles Thereof" /*
*/11	"Textiles and Textile Articles" /*
*/12	"Footwear, Headgear, Umbrellas...and Parts Thereof; Prepared Feathers and Articles Made Therewith; Artificial Flowers" /*
*/13	"Articles of Stone, Plaster, Cement, Asbestos, Mica or Similar Materials; Ceramic Products; Glass and Glassware" /*
*/14	"Natural or Cultured Pearls, Precious or Semi-Precious Stones, Precious Metals, Metals Clad with Precious Metal and Articles Thereof; Imitation Jewellery; Coin Thereof; Imitation Jewellery; Coin" /*
*/15	"Base Metals and Articles of Base Metal" /*
*/16	"Machinery and Mechanical Appliances; Electrical Equipment; Parts Thereof; Sound Recorders and Reproducers, Television Image and Sound Recorders and Reproducers, and Parts and Accessories of Such Articles" /*
*/17	"Vehicles, Aircraft, Vessels and Associated Transport Equipment" /*
*/18	"Optical, Photographic, Cinematographic, Medical or Surgical Instruments and Apparatus; Clocks and Watches; Musical Instruments" /*
*/19	"Arms and Ammunition; Parts and Accessories Thereof" /*
*/20	"Miscellaneous Manufactured Articles" /*
*/21	"Works of Art, Collectors' Pieces and Antiques"

label values section sectvals

tab section

 

capture drop unc_3



qui reg dif_ln_imp_5  dif_advalorem_mfn_5 dif_ln_tcost_5 unc_pre if year==2005   


xtile unc_3=unc_pre if e(sample),n(3)
recode unc_3 (2=3)
gen xtilesample=e(sample)


**** LOCAL POLYNOMIAL OF LN(RATIO) FOR  EXPORTS *****
xtset hs6 year

gen ln_rat=-ln(rat_2000)

qui reg dif_ln_imp_5 dif_advalorem_mfn_5 dif_ln_tcost_5 unc_pre if  year==2005
gen olssample=e(sample)
twoway (lpolyci dif_ln_imp_5 ln_rat if olssample,degree(0)  ),/*
		*/xtitle(ln({&tau}{sub:2V}/{&tau}{sub:1V})) /*
		*/xlabel(0(0.1)0.7) legend(off)
	*ylabel(-0.15(.05)0.25)

graph export Figure4a.pdf, as(pdf) replace



*** LOCAL POLYNOMIAL OF LN(RATIO) FOR TOTAL PRICE INDEX***
twoway (lpolyci ldif_ln_pindex_hs6_total ln_rat if pindex_sample==1 & trim_025tails==1,degree(0) bw(.1)  ) ,/*
	*//*title (Change in HS6 price index (ln) 2005-2000) *//*
	*/xtitle(ln({&tau}{sub:2V}/{&tau}{sub:1V})) /*
		*/xlabel(0(0.1)0.7)  legend(off)
	
graph export Figure4b.pdf, as(pdf) replace


	

**** KOLM-SMIRNOV TEST OF EXPORT DISTRIBUTION AND GRAPHS *****
label var dif_ln_imp_5 "Chinese Export Growth"
	 
ksmirnov dif_ln_imp_5 if xtilesample, by(unc_3) 
local kspval=round(`r(p)',.001) 
 
twoway (kdensity dif_ln_imp_5 if unc_3 == 3 & xtilesample, kernel(epan) range(-5 7.5) ) (kdensity dif_ln_imp_5 if unc_3 == 1 & xtilesample,kernel(epan) range(-5 7.5) lpattern(dash)) ,/*
	*/xlabel(-5(2.5)7.5) legend(label(1 "High Uncertainty") label(2 "Low Uncertainty") cols(1) ring(0) pos(2) region(lstyle(none)))/*
	*/ xtitle("Export Change") ytitle("")	/*
	*/caption(Equality of distributions rejected with p-value of `kspval' in Kolmogorov-Smirnov test, size(small) position(5))

graph export Figure3a.pdf, as(pdf) replace




**** KOLM-SMIRNOV TEST OF PRICE DISTRIBUTION AND GRAPHS *****

capture drop lprice_2centile trim_025tails
	
	xtile lprice_2centile=ldif_ln_pindex_hs6_total  if e(sample) & pindex_sample==1, n(200)
	
	gen trim_025tails=(lprice_2centile>5 & lprice_2centile<196) if pindex_sample==1
		
		
		
label var ldif_ln_pindex_hs6_total "Chinese Industry(HS-6) Price Index"
	 
ksmirnov ldif_ln_pindex_hs6_total if xtilesample & trim_025tails==1, by(unc_3) 
local kspval=round(`r(p)',.001) 
 
twoway (kdensity ldif_ln_pindex_hs6_total if unc_3 == 3 & xtilesample & trim_025tails==1, kernel(epan) range(-2.5 2.5) ) (kdensity ldif_ln_pindex_hs6_total if unc_3 == 1 & xtilesample & trim_025tails==1,kernel(epan) range(-2.5 2.5) lpattern(dash)) ,/*
	*/xlabel(-2.5(.5)2.5) legend(label(1 "High Uncertainty") label(2 "Low Uncertainty") cols(1) ring(0) pos(2) region(lstyle(none)))/*
	*/ xtitle("Price Index Change") ytitle("")	/*
	*/caption(Equality of distributions rejected with p-value of `kspval' in Kolmogorov-Smirnov test, size(small) position(5))

graph export Figure3b.pdf, as(pdf) replace

  
* label * 
capture label drop sectvals
label def sectvals 1 "Animals" 2 "Vegetables" 3 "Fats & Oils" 4 "Prepared Foodstuffs" /*
*/ 5 "Minerals"/*
*/6	"Chemicals" /*
*/7	"Plastics, Rubber & Articles" /*
*/8	"Hides, Leather, & Articles" /*
*/9	"Wood, Straw & Articles" /*
*/10	"Pulp, Paper & Articles" /*
*/11	"Textiles & Articles" /*
*/12	"Footwear, Headgear, other" /*
*/13	"Stone, Plaster, Cement, other" /*
*/14	"Precious stones, Metals, Jewellery,..." /*
*/15	"Base Metals & Articles" /*
*/16	"Machinery; Electrical Equipment; Electronics" /*
*/17	"Vehicles, Aircraft, Vessels" /*
*/18	"Optical, Medical & other instruments" /*
*/19	"Arms and Ammunition" /*
*/20	"Miscellaneous Manufactures" /*
*/21	"Art and Antiques" /*
*/99 	"Total"




keep if e(sample)


egen imp_tot_05= sum(cifvalue_all) if y==2005
bysort section: egen imp_share_05= sum(cifvalue_all) if y==2005
replace imp_share_05=100*imp_share_05/imp_tot_05

sort section
local sumvars "unc_pre dif_ln_imp_5 ldif_ln_pindex_hs6_total ln_rat  "

local stats "sd p50 min max"

foreach var of local stats{

local sumvars`var' "unc_pre_`var'=unc_pre dif_ln_imp_5_`var'=dif_ln_imp_5 ldif_ln_pindex_hs6_total_`var'=ldif_ln_pindex_hs6_total "
}

preserve
collapse  (mean) imp_share `sumvars' (p50) `sumvarsp50' (sd) `sumvarssd' (min) `sumvarsmin' (max) `sumvarsmax' (count) nobs_imp=dif_ln_imp_5 
gen section=99
drop ldif_ln_pin*
save temp,replace
restore


*sector price linear fit scatter graphs*
preserve
keep if pindex_sample==1 & trim_025tails==1

collapse  (mean) imp_share `sumvars' (p50) `sumvarsp50' (sd) `sumvarssd' (min) `sumvarsmin' (max) `sumvarsmax' (count) nobs_p=ldif_ln_pindex_hs6_total, by(section)

twoway (scatter ldif_ln_pindex_hs6_total ln_rat [fweight = nobs] if section!=21, msymbol(circle_hollow) )  /*
	*/(scatter ldif_ln_pindex_hs6_total ln_rat if section!=21,   msymbol(point) msize(vsmall) mlabel(section) mlabsize(tiny) mcolor(blue) mlabposition(10) ) /*
	*/(lfit ldif_ln_pindex_hs6_total ln_rat [fw=nobs]), bgcolor(white) graphregion(color(white))/*
	*/xtitle("Sector Mean of ln({&tau}{sub:2}/{&tau}{sub:1})") ylabel(-.6(.2).4) ytitle("")  legend(off) /*
	*/ title("(b) Change in Price Index ({&Delta}ln)") name(price)



graph export Figure2b.pdf,  replace


	
restore

*sector import growth linear fit scatter graphs*

collapse  (mean) imp_share `sumvars' (p50) `sumvarsp50' (sd) `sumvarssd' (min) `sumvarsmin' (max) `sumvarsmax' (count) nobs=dif_ln_imp_5, by(section)


twoway (scatter dif_ln_imp_5 ln_rat [fweight = nobs] if section!=21 , msymbol(circle_hollow)  ) /*
	*/(scatter dif_ln_imp_5 ln_rat if section!=21,   msymbol(point) msize(vsmall) mlabel(section) mlabsize(tiny) mcolor(blue)  mlabposition(10) ) /*
	*/(lfit dif_ln_imp_5 ln_rat [fw=nobs]), bgcolor(white) graphregion(color(white))/*
	*/xtitle("Sector Mean of ln({&tau}{sub:2}/{&tau}{sub:1})") ytitle("") legend(off) title("(a) Change in Exports ({&Delta}ln)") name(exp)

graph export Figure2a.pdf, as(pdf) replace


*** finally export summary stats for exports by section

append using temp

*drop price variables as sample size is not the same, not directly comparable*

capture drop ln_ra* ldif_ln_pin*
export delimited using tableA1.csv, replace

rm temp.dta

exit 


