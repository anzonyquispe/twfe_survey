
set more off

clear
clear matrix
clear mata
*set matsize 800
*set maxvar 20000

dis "$root"
global data "$root/01. Data/"
global do "$root/02. Programs/"
global analyses "$root/03. Analyses/"
global work "$root/04. Working/"
global logs "$root/04. Working/LogFiles/"
global intdata "$root/05. Intermediate Datasets/"
global RegResults "$root/08. TeX/RegResults"
global date=c(current_date)
global time=subinstr(c(current_time),":","",.)
dis "$date"
cd "$work"


cap program drop repl_conf
program define repl_conf
    gettoken varname 0 : 0, parse(=) 
    confirm var `varname' 
    gettoken eq 0 : 0, parse(=) 
    syntax anything [if] 
    qui count `if'
    if r(N) == 0 {
         di as err "NO MATCHES -- NO REPLACE"
         exit 9
    }
    else {
         qui replace `varname' = `anything' `if'
         noi di "SUCCESSFUL REPLACE of >=1 OBS -- " r(N) " OBS replaced"
    }
end

cap program drop drop_conf
program define drop_conf
    syntax [if] 
    qui count `if'
    if r(N) == 0 {
         di as err "NO MATCHES -- NO DROPS"
         exit 9
    }
    else {
         qui drop `if'
         noi di "SUCCESSFUL DROP of >=1 OBS -- " r(N) " OBS DROPPED"
    }
end

