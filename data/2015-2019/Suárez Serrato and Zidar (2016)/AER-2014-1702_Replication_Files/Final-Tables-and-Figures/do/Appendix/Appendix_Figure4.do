clear
set more off

use "$dtapath/Figures/Appendix_Figure4.dta", clear
cd "$append_graphpath"

*Appendix Figure 4a
maptile estshare, geo(state) 
graph export "Appendix_Figure4a.pdf", replace

*Appendix Figure 4b
maptile popshare, geo(state) 
graph export "Appendix_Figure4b.pdf", replace
