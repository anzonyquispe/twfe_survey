* Install all required Stata packages for polisci replications
clear all
set more off

local pkgs "reghdfe ftools eventstudyinteract did_multiplegt_dyn csdid drdid did_imputation"

foreach pkg of local pkgs {
    cap which `pkg'
    if _rc {
        di "Installing `pkg'..."
        ssc install `pkg', replace
    }
    else {
        di "`pkg' already installed"
    }
}

* reghdfe needs ftools linked
cap reghdfe, compile
cap ftools, compile

di ""
di "=== Package installation complete ==="
