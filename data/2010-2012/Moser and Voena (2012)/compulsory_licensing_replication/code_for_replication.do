******************************************************************************************           TABLES          *********************************************************************************************************clearset more off
set mem 2g

****** TABLE 1********use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/table1.dta"
****Col 1
tab true_nat
****Col 2
codebook patnum if usa==1
codebook patnum if germany==1
codebook patnum if usa==0 & germany==0



/****** TABLE 2********use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_maindataset.dta"forvalues x=1876/1939 {	gen td_`x'=0	qui replace td_`x'=1 if grn==`x'	}
xtreg count_usa treat count_for_2 td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, replacextreg count_usa treat count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, appendxtreg count_usa treat td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, appendxtreg count_usa count_cl count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, appendxtreg count_usa count_cl count_cl_2 count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, appendxtreg count_usa count_cl td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, appendxtreg count_usa year_conf year_conf_2 count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, appendxtreg count_usa year_conf count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, appendxtreg count_usa year_conf  td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table2.xls, append****** TABLE 3********xtreg count_usa count_cl_itt count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using itt_table3.xls, replacextreg count_usa count_cl_itt  td*, fe i(class_id) robust cluster(class_id)outreg2 using itt_table3.xls, appendxtreg count_usa year_conf_itt count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using itt_table3.xls, appendxtreg count_usa year_conf_itt  td*, fe i(class_id) robust cluster(class_id)outreg2 using itt_table3.xls, append****** TABLE 4********xtreg count_cl count_cl_itt  td*, fe i(class_id)  robustoutreg2 using iv_table4.xls, replacextreg year_conf year_conf_itt   td*, fe i(class_id) robust outreg2 using iv_table4.xls, appendxtivreg count_usa (count_cl= count_cl_itt) td*, fe i(class_id) outreg2 using iv_table4.xls, appendxtivreg count_usa (year_conf= year_conf_itt)  td*, fe i(class_id) outreg2 using iv_table4.xls, append****** TABLE 5********xi: xtreg count_usa treat count_for i.main*i.grn, fe i(class_id) robust cluster(class_id)xi: xtreg count_usa count_cl count_for i.main*i.grn, fe i(class_id) robust cluster(class_id)xi: xtreg count_usa year_conf count_for i.main*i.grn, fe i(class_id) robust cluster(class_id)*/****** TABLE 6 *******sort uspto_class grnbys uspto: gen ccc=sum(count)foreach var in count_usa count  {	qui replace `var'=. if ccc==0 	}gen aaa=1 if ccc==0 & grn==1919bys uspto: egen bbb=max(aaa)drop if bbb==1drop if ccc==0drop aaa bbb cccxtreg count_usa treat count_for_2 td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, replacextreg count_usa treat count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, appendxtreg count_usa treat td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, appendxtreg count_usa count_cl count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, appendxtreg count_usa count_cl count_cl_2 count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, appendxtreg count_usa count_cl  td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, appendxtreg count_usa year_conf year_conf_2 count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, appendxtreg count_usa year_conf count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, appendxtreg count_usa year_conf  td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table6.xls, append****** TABLE 7 *******use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_primaryclassesdataset.dta", clear

forvalues x=1876/1939 {	gen td_`x'=0	qui replace td_`x'=1 if grn==`x'	}
xtreg count_usa treat count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table7.xls, replacextreg count_usa count_cl count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table7.xls, appendxtreg count_usa year_conf count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table7.xls, append****** TABLE 8 *******use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_indigodataset.dta", clear

forvalues x=1876/1939 {	gen td_`x'=0	qui replace td_`x'=1 if grn==`x'	}
xtreg count_usa treat count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table8.xls, replacextreg count_usa count_cl count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table8.xls, appendxtreg count_usa year_conf count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using ols_table8.xls, append****** TABLE 9 *******use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/dupont_data.dta", clearxtreg patents treat_NO_dupont treat_dupont count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using table9.xls, replacextreg patents treat_NO_dupont treat_dupont td*, fe i(class_id) robust cluster(class_id)outreg2 using table9.xls, appendxtreg patents count_NO_dupont count_dupont count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using table9.xls, appendxtreg patents count_NO_dupont count_dupont td*, fe i(class_id) robust cluster(class_id)outreg2 using table9.xls, appendxtreg patents year_conf_NO_dupont year_conf_dupont count_for td*, fe i(class_id) robust cluster(class_id)outreg2 using table9.xls, appendxtreg patents year_conf_NO_dupont year_conf_dupont td*, fe i(class_id) robust cluster(class_id)outreg2 using table9.xls, append******************************************************************************************           FIGURES          ********************************************************************************************************clearset more offset mem 950m
********* FIGURE 1 ********
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/fig1.dta", clear
reg count_ger td* if licensed_class==0, noco
reg count_ger td* if licensed_class==1, noco

********* FIGURE 2 ********
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_maindataset.dta", clear
preserve
keep if grn==1930
browse count_cl
restore
********* FIGURE 3 ********
preserve
keep if grn==1930
browse year_conf
restore

***********FIGURE 4 *****************
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_maindataset.dta", clear
forvalues x=1875/1918 {	gen td_`x'=0	qui replace td_`x'=1 if grn==`x'	}

foreach var in treat  {
forvalues x=1875/1918 {	cap gen `var'_`x'=`var' if grn==`x'	qui replace `var'_`x'=0 if grn!=`x'	}
}
drop td_1900 treat_1900
xtreg count_usa treat_* count_for td*, fe i(class_id) robust cluster(class_id)

********* FIGURE 5 ********
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/fig5.dta", clear
sum share if share>=0 & share<0.1 & licensed_class==0sum share if share>=0.1 & share<0.2 & licensed_class==0sum share if share>=0.2 & share<0.3 & licensed_class==0sum share if share>=0.3 & share<0.4 & licensed_class==0sum share if share>=0.4 & share<0.5 & licensed_class==0sum share if share>=0.5 & share<0.6 & licensed_class==0sum share if share>=0.6 & share<0.7 & licensed_class==0sum share if share>=0.7 & share<0.8 & licensed_class==0sum share if share>=0.8 & share<0.9 & licensed_class==0sum share if share>=0.9 & share<1 & licensed_class==0sum share if share==1 & licensed_class==0sum share if share>=0 & share<0.1 & licensed_class==1sum share if share>=0.1 & share<0.2 & licensed_class==1sum share if share>=0.2 & share<0.3 & licensed_class==1sum share if share>=0.3 & share<0.4 & licensed_class==1sum share if share>=0.4 & share<0.5 & licensed_class==1sum share if share>=0.5 & share<0.6 & licensed_class==1sum share if share>=0.6 & share<0.7 & licensed_class==1sum share if share>=0.7 & share<0.8 & licensed_class==1sum share if share>=0.8 & share<0.9 & licensed_class==1sum share if share>=0.9 & share<1 & licensed_class==1sum share if share==1 & licensed_class==1


********* FIGURE 7 ********
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_maindataset.dta", clear
forvalues x=1876/1939 {	gen td_`x'=0	qui replace td_`x'=1 if grn==`x'	}

foreach var in treat count_cl year_conf {
forvalues x=1919/1939 {	cap gen `var'_`x'=`var' if grn==`x'	qui replace `var'_`x'=0 if grn!=`x'	}
}
xtreg count_usa treat_* count_for td*, fe i(class_id) robust cluster(class_id)

********* FIGURE 8 ********
xtreg count_usa count_cl_* count_for td*, fe i(class_id) robust cluster(class_id)

********* FIGURE 9 ********
xtreg count_usa year_conf_* count_for td*, fe i(class_id) robust cluster(class_id)

********* FIGURE 10 ********
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/fig10.dta", clear

xtreg y usa_treat_td1919-usa_treat_td1939 usa_td* usa_treat treat_td* usa td_*, fe i(class_id) robust cluster(class_id)

*********
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_maindataset.dta", clear

********* FIGURE 11 ********
xtreg count_france treat_* td*, fe i(class_id) robust cluster(class_id)

********* FIGURE 12 ********
xi: xtreg count_usa treat_* td* i.class_id*grn, fe i(class_id) robust cluster(class_id)

********* FIGURE 13 ********
use "/Users/alessandravoena/Documents/My work/RESEARCH/compulsory_licensing_replication/chem_patents_indigodataset.dta", clear

forvalues x=1876/1939 {	gen td_`x'=0	replace td_`x'=1 if grn==`x'	}

foreach var in treat {
forvalues x=1919/1939 {	cap gen `var'_`x'=`var' if grn==`x'	replace `var'_`x'=0 if grn!=`x'	}
}
xtreg count_us treat_* count_for td*, fe i(class_id) robust cluster(class_id)
