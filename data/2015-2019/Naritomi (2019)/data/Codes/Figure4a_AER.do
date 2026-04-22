********************
* Figure 4a
* Google searches
********************
*Google trends - searches between Oct.07-Dec.11
* Search words "Nota Fiscal Paulista": "nfp"+"nfp sp"+"nfp paulista"+"nfp fazenda"+"consulta nfp"+"nfp gov"+"sorteio nfp"+"nfp gov br"+"nfp cadastro"+"consultar nfp"+"site nfp"+"saldo nfp"+"nfp fazenda gov"+"nf paulista"
* Search words "Search volume (Futebol)": "futebol"

clear all
set more off
# delimit cr

global MainDir "XX\Replication" /* replace XX with the directory path*/
cd "$MainDir\Data"

// Prepare the data

* merge NFP searches and soccer searches
use nfp_google_searches.dta, clear
merge 1:1 period using "futebol_google_searches.dta" 

* the data is recorded by week: convert to daily data
gen beg=substr(period,1, 10)
gen date=date(beg,"YMD",2011)
gen day=substr(beg,9,2)
destring day, replace

* Create a balanced panel
tsset date
tsfill
gen date_n=date
format date %td

drop beg period day

gen XX=searches

* replace missing values with the last value in the data before missing
replace searches=searches[_n-1] if searches==. 
replace soccer_searches=soccer_searches[_n-1] if soccer_searches==. 
gen date_aux = dofm(date)
format date_aux %d
gen month=month(date)
gen yr=year(date)

* lottery flag lottery day
gen lot_day=0
forvalue x = -1(1)3{
#delimit;
replace lot_day=1 if
date_n==    17546 + 365*`x'+1
|date_n==   17577 + 365*`x'+1
|date_n==	17606 + 365*`x'
|date_n==	17637 + 365*`x'
|date_n==	17667 + 365*`x'
|date_n==	17698 + 365*`x'
|date_n==	17728 + 365*`x'
|date_n==	17759 + 365*`x'
|date_n==	17790 + 365*`x'
|date_n==	17820 + 365*`x'
|date_n==	17851 + 365*`x'
|date_n==	17881 + 365*`x'
;
#delimit cr
}

* create event-time
gen auxevent=date_n if lot_day==1 
bys month yr: egen event=max(auxevent)
gen event_n=date_n - event

* drop October and April (tax rebate disbursement months) that may alter the salience effect of the lottery results 
drop if month==10|month==4

* aggregate data by event-months
collapse search soccer_searches, by(event_n)

* scale data based on 14 days before event
gen auxscale=searches if event_n==-14
egen scale=max(auxscale)
gen  searchessc=searches/scale

gen auxsoccer_searches=soccer_searches  if event_n==-14
egen scalesoccer_searches=max(auxsoccer_searches)
gen  soccer_searches_ssc=soccer_searches/scalesoccer_searches

* count number of days in the month
gen days=15+event


// Figure 4a

twoway scatter searchessc days if days>0&days<31 , c(1)  lcolor(navy) lwidth(medium) mcolor(navy) ///
||scatter soccer_searches_ssc days if days>0&days<31 , c(1) lpattern(dash) lcolor(gray) lwidth(small) mcolor(gray) msize(small) msize(tiny) xlabel(0[5]30) ///
graphregion(color(white)) ///
xlabel(1[2]30, labsize(small)) ylabel(, labsize(small) noticks) ///
ytitle("Search volume relatively to the 1st day of the month", size(small)) xtitle("day of the month", size(small)) legend(order(1 "Nota Fiscal Paulista" 2 "search volume ('Futebol')") size(vsmall))
