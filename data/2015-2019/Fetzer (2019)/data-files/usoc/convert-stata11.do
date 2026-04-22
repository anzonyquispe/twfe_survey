**load all data files and safe as Stata 11 file 

forvalues wave=1(1)8 { 
cd "data files/usoc/ukhls_w`wave'"

fs *.dta

local getfile "use"
foreach file in `r(files)' {
	use `file', clear
	
	
	saveold `file', version(11) replace
}

}





