clear
set more off

***************************************************
* NOTE: TO INSTALL MAPTILE, RUN THE FOLLOWING CODE:
***************************************************
/*
net install maptile, from(http://michaelstepner.com/maptile)
maptile_install using "http://files.michaelstepner.com/geo_county1990.zip"
maptile_install using "http://files.michaelstepner.com/geo_cz.zip"
maptile_install using "http://files.michaelstepner.com/geo_state.zip"
maptile_install using "http://files.michaelstepner.com/geo_zip3.zip"
maptile_install using "http://files.michaelstepner.com/geo_zip5.zip"
ssc install spmap
ssc install  shp2dta
ssc install mergepoly
* MORE INSTRUCTIONS IF NEED BE: http://michaelstepner.com/maptile
*/


cd "$append_graphpath"
use "$dtapath/Figures/Appendix_Figure3.dta"


*********************************************************
*Appendix Figure 3a
*********************************************************
maptile Dcorp, geo(state) 
graph export "Appendix_Figure3a.pdf", replace


*********************************************************
* Appendix Figure 3b
*********************************************************
maptile Dsales, geo(state) 
graph export "Appendix_Figure3b.pdf", replace
