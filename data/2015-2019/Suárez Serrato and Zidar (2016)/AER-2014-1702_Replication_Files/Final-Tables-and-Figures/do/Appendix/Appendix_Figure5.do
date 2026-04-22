clear
set more off

cd "$append_graphpath"
use "$dtapath/Figures/Appendix_Figure5.dta"

*Appendix Figure 5a
maptile g_estshare, geo(state) 
graph export "Appendix_Figure5a.pdf", replace

*Appendix Figure 5b
maptile g_popshare, geo(state) 
graph export "Appendix_Figure5b.pdf", replace
