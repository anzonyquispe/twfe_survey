


*bring in data from sheet 3 of Industry Characteristics Tables.xlsx
*Then:
if "`c(os)'"=="Windows" {
global censodir="C:/Data/Mexico/mexico_censo/"
global firmdir="C:/Data/Mexico/mexico_ss_Stata/"
global workdir="C:/Data/Mexico/Stata10/"
global inddir="C:/Data/Mexico/mexico_ss_Stata/"
global dir="C:/Work/Mexico/"
global dirgraphs="C:/Work/Mexico/Graphs/"
global dirmaq="C:/Work/Mexico/Maquiladora Data/"
}






gen ind1=ind2
replace ind1="Export Manufacturing" if ind2=="Low-Tech Export Manufacturing"
replace ind1="Export Manufacturing" if ind2=="High-Tech Export Manufacturing"

graph bar exportsintotaloutput  maquilaexportsintotalindustryexp employeesinforeignownedfirms industryexportsintotalexports , ///
over(ind, sort(sort) label( labsize(vsmall)) relabel(2 `" "Food, Beverage"   "& Tobacco" "' 1 `" "Chemicals, Plastics," "Mineral prods, Metals, Paper" "' 3 `" "Metalic prods," "Machinery & Equipment" "' 4 `" "Textiles, Apparel," "Leather" "' 5 `" "Wood prods," "Furniture" "')   ) ///
over(ind1, sort(sort) label( labsize(medsmall))  relabel( 2 `" "Non-Export" "Manufacturing" "' 1 `" "Export" "Manufacturing" "')) ///
legend(order(1 3 2 4) symxsize(*.3) size(small) label(3 "% Employees in Foreign Owned Firms") label(2 "% Maquila Exports in Industry Exports") label(4 "% Industry Exports in Total Exports") label(1 "% Exports in Total Output")) ///
nofill   nolabel ytitle("Percentage") ylabel(0 50 100 150)  



graph save "${dirgraphs}industry_characteristics.gph", replace
graph export "${dirgraphs}industry_characteristics.eps", replace



