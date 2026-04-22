clear
set more off


*********************************************************
* PROGRAM
*********************************************************

capture program drop Table3
program Table3
syntax, yvar(varname) tax(varname) tablename(name) cluster(varname)
 
xi: reg `yvar' `tax' i.year i.fe_group [aw = epop], cluster(`cluster') r
outreg2 using `tablename', label tex(frag) replace bdec(2) sdec(2) drop(_I*)

xi: reg `yvar' `tax' d_keep_itc_state i.year i.fe_group [aw = epop], cluster(`cluster') r
outreg2 using `tablename', label tex(frag) append bdec(2) sdec(2) drop(_I*)

xi: reg `yvar' `tax' dtotalexpenditure_pop i.year i.fe_group [aw = epop], cluster(`cluster') r 
outreg2 using `tablename', label tex(frag) append bdec(2) sdec(2) drop(_I*)

xi: reg `yvar' `tax' bartik i.year i.fe_group [aw = epop], cluster(`cluster') r
outreg2 using `tablename', label tex(frag) append bdec(2) sdec(2) drop(_I*)

xi: reg `yvar' `tax' d_corp_ext  i.year i.fe_group [aw = epop], cluster(`cluster') r
outreg2 using `tablename', label tex(frag) append bdec(2) sdec(2) drop(_I*)

xi: reg `yvar' `tax'  dtotalexpenditure_pop d_keep_itc_state bartik d_corp_ext  i.year i.fe_group [aw = epop], cluster(`cluster') r
outreg2 using `tablename', label tex(frag) append bdec(2) sdec(2) drop(_I*)

end

*********************************************************
* EXECUTE
*********************************************************

cd "$append_tablepath"
use "$dtapath/Tables/Appendix_Table12.dta", replace /* d_y = ln(f_composite_index_2) - ln(L10.f_composite_index_2) */

Table3, yvar(d_y) tax(d_bus_dom2) tablename(Appendix_Table12) cluster(fipstate) /* Appendix Table 12 */


