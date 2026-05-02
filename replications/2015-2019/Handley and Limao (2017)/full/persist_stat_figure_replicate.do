
use replication_appxdata9,clear

sum

sum hs4_coeff, det
sum hs4_coeff_stat, det

label var hs4_coeff_stat "Persistence coefficient t-stat"
label var hs4_coeff "Persistence coefficient"

twoway (scatter hs4_coeff_stat hs4_coeff, msize(zero) msymbol(none) mlabel(hs4n) mlabsize(tiny) mlabcolor(navy) mlabgap(zero)), yline(3.09, lwidth(thin)) 	
graph export "figureA3.pdf", as(pdf) replace

