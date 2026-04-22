version 15.0
clear all
set more off

******************
* Appendix Table 3
******************

prog main
    reg_main using "data/infutor/parcel15_add10"
end

prog reg_main
    syntax using/, [smpstub(str)]

    use "`using'", clear

    //variable label
    lab var treat "Treat"

    //value labels
    cap label drop treatl
    label define treatl 0 "Control" 1 "Treat"
    label values treat treatl

    eststo clear

    eststo: areg incpc10_blkgrp i.treat if use_code == 3, absorb(zip_id) vce(cluster parcel)
    //mean of dependent variable in control group
    qui sum incpc10_blkgrp if treat==0
    estadd scalar depvar_mean = r(mean)
    estadd scalar depvar_sd = r(sd)

    esttab using "output/treat_income_blkgrp`smpstub'.tex", replace ///
        cells(b(star fmt(0)) se(par fmt(0))) ///
        keep(1.treat _cons) nobaselevels ///
        stats(depvar_mean depvar_sd r2 N, fmt(0 0 3 0) layout(@ @ @ @) ///
        labels(`"Control Mean"' `"Control S.D."' `"\(R^{2}\)"' `"Observations"')) ///
        star(* 0.1 ** 0.05 *** 0.01) ///
        label wrap booktabs collabels(none) ///
        mtitles("Per Capita Income")
end

main
