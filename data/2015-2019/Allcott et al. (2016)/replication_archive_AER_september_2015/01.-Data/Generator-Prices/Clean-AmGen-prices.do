insheet using "C:\Users\Steve\Documents\My Dropbox\India Power Shortages\01. Data\Generator Prices\AmericansGenerators_June2014.csv", comma names clear
drop from

replace text = trim(lower(text))
g capacity = substr(text,1,strpos(text," ")-1)
replace text = trim(substr(text, strpos(text," "), .))
g measure = substr(text,1,strpos(text," ")-1)
replace text = trim(substr(text, strpos(text," "), .))
g price = substr(text,strpos(text,"$")+1, .)
replace text = trim(substr(text, 1, strpos(text,"$")-1))
replace text = subinstr(text," diesel generator set ","",.)
replace text = subinstr(text," diesel generator set","",.)
replace text = subinstr(text," diesel generator ","",.)
g epa = 0
replace text = subinstr(text,"non epa","",.)
replace text = subinstr(text,"non-epa","",.)
replace epa = 1 if strpos(text,"epa")>0
replace text = subinstr(text,"epa certified","",.)
replace text = subinstr(text,"epa","",.)
g brand = substr(text, 1, strpos(text,"-")-1)
drop text
replace price = subinstr(price,",","",.)
destring price capacity, replace
order brand
gsort brand +capacity
saveold "C:\Users\Steve\Documents\My Dropbox\India Power Shortages\04. Working\AMGen_prices.dta", replace
