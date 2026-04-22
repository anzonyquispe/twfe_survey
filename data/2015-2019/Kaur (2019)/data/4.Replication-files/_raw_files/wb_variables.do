/* Notes:
This do-file takes as an in put the raw data (original WB Climate and Agriculture
dataset plus the rainfall and inflation data - contained in wb_raw.dta in this
directory) and generates the variables that are used in the main exhibits in the 
paper. 

It creates the dataset wb_replication.dta, which can be loaded directly
to replicate the main exhibits in the paper that use the World Bank data.
*/ 


clear
use wb_raw_data.dta


******************** WAGE VARIABLE **************************

gen lwage = log(wage)
label var lwage "log(daily wage)"



******************** DEFINE RAINFALL SHOCKS **************************

* positive shocks:
* note - main specification uses 80th pctile cutoff - rest for robustness checks in appendix
foreach p of numlist 70 75 80 {
	gen amons`p' = (rain5 >= m5p`p')
	replace amons`p' = (rain6 >= m6p`p') if latestate==1
	
	gen lamons`p' = (lagrain5 >= m5p`p')
	replace lamons`p' = (lagrain6 >= m6p`p') if latestate==1
	
	gen l2amons`p' = (lag2rain5 >= m5p`p')
	replace l2amons`p' = (lag2rain6 >= m6p`p') if latestate==1
	
	gen l3amons`p' = (lag3rain5 >= m5p`p')
	replace l3amons`p' = (lag3rain6 >= m6p`p') if latestate==1
	
	label var amons`p' "amonsP = 1{rain in monsoon arrival month is above Pth pctile this year}"
	label var lamons`p' "lamonsP = 1{rain in monsoon arrival month was above Pth pctile last year}"
	label var l2amons`p' "l2amonsP = 1{rain in monsoon arrival month was above Pth pctile 2 years ago}"
	label var l3amons`p' "l3amonsP = 1{rain in monsoon arrival month was above Pth pctile 3 years ago}"
}

* negative shocks:
* note - main specification uses 20th pctile cutoff - rest for robustness checks in appendix
foreach p of numlist 20 25 30 {
	gen bmons`p' = (rain5 < m5p`p')
	replace bmons`p' = (rain6 < m6p`p') if latestate==1
	
	gen lbmons`p' = (lagrain5 < m5p`p')
	replace lbmons`p' = (lagrain6 < m6p`p') if latestate==1
	
	label var bmons`p' "bmonsP = 1{rain in monsoon arrival month is below Pth pctile this year}"
	label var lbmons`p' "lbmonsP = 1{rain in monsoon arrival month was below Pth pctile last year}"
}


* shorthand
gen pos = (amons80==1)
gen neg = (bmons20==1)
gen lpos = (lamons80==1)
gen lneg = (lbmons20==1)
gen zero = (amons80==0 & bmons20==0)
gen lzero = (lamons80==0 & lbmons20==0)

label var pos "positive shock this year (amons80==1)"
label var neg "negative shock this year (bmons20==1)"
label var lpos "positive shock last year (lamons80==1)"
label var lneg "negative shock last year (lbmons20==1)"
label var zero "no shock this year (bmons20==0 & amons80==0)"
label var lzero "no shock last year (lbmons20==0 & lamons80==0)"


* create new lshock vars that are mutually exclusive from main shocks
* l2pos and l3pos are the lagged shock controls used in the specifications in paper
gen l1pos = (lamons80==1 & amons80==0)
gen l2pos = (l2amons80==1 & lamons80==0 & amons80==0)
gen l3pos = (l3amons80==1 & l2amons80==0 & lamons80==0 & amons80==0)

label var l1pos "pos shock last yr, no pos shock this year"
label var l2pos "pos shock 2 yrs ago, no pos shocks since then"
label var l3pos "pos shock 3 yrs ago, no pos shocks since then"


* SET OF SHOCK SEQUENCES: Last year shock, this year shock (3x3=9 cells)
* in shorthand: z=zero shock, p=pos shock, n=neg shock
* omitted category in regressions
gen zz = (lamons80==0 & lbmons20==0 & amons80==0 & bmons20==0)
gen nz = (lamons80==0 & lbmons20==1 & amons80==0 & bmons20==0)
* positive shock this year
gen zp = (lamons80==0 & lbmons20==0 & amons80==1 & bmons20==0)
gen pp = (lamons80==1 & lbmons20==0 & amons80==1 & bmons20==0)
gen np = (lamons80==0 & lbmons20==1 & amons80==1 & bmons20==0)
* non-positive shock last year, negative shock this year
gen zn = (lamons80==0 & lbmons20==0 & amons80==0 & bmons20==1)
gen nn = (lamons80==0 & lbmons20==1 & amons80==0 & bmons20==1)
gen nonpos_neg = (zn==1 | nn==1)
* lagged positive shock, followed by non-positive shock
gen pz = (lamons80==1 & lbmons20==0 & amons80==0 & bmons20==0)
gen pn = (lamons80==1 & lbmons20==0 & amons80==0 & bmons20==1)

label var zz "no shock last yr, no shock this yr"
label var nz "neg shock last yr, no shock this yr"
label var nz "neg shock last yr, no shock this yr"
label var zp "no shock last yr, pos shock this yr"
label var pp "pos shock last yr, pos shock this yr"
label var np "neg shock last yr, pos shock this yr"
label var zn "no shock last yr, neg shock this yr"
label var nn "neg shock last yr, neg shock this yr"
label var pn "pos shock last yr, neg shock this yr"
label var pz "pos shock last yr, no shock this yr"
label var nonpos_neg "non-pos shock last yr, neg shock this yr"



************ STATE-WISE AG CPI DATA (DOWNLOADED FROM INDIA STAT) **********
* average inflation across states - omitting own state's inflation
* note: inflation measure based on CPI for rural laborers (see documentation)
gen avginf_otherstates = .
forvalues s = 1/13 {
	gen temp1 = stateinf_cal
	replace temp1 = . if state==`s'
	* compute mean inflation per year, for all districts except `s'
	egen temp2 = mean(temp1), by(year)
	* replace district s's value in each year with above
	replace avginf_otherstates = temp2 if state==`s'
	drop temp*
}
label var avginf_otherstates "avg inflation in country (excluding own state) - missing for 2 yrs"

* Continuous inflation rate - used in paper
	* for 1956, 1957 (years where state-level inflation not available (so avginf_otherstates is 
	* missing)), fill in simple national inflation rate for those missing years.
gen avginf = avginf_otherstates
replace avginf = natl_inf if avginf_otherstates==.
label var avginf "avg inflation in country (excluding own state's inflation)"

* Binary indicator for inflation above 6%
gen hinf = (avginf > .06) if avginf!=.
label var hinf "1{avginf > 6%}"

* Interactions of inflation variables with main shock variables
* interactions with continuous avginf
gen posXavginf = pos*avginf
gen nonpos_negXavginf = nonpos_neg*avginf
gen pnXavginf = pn*avginf
gen pzXavginf = pz*avginf
* interactions with binary hinf
gen posXhinf = pos*hinf
gen nonpos_negXhinf = nonpos_neg*hinf
gen pnXhinf = pn*hinf
gen pzXhinf = pz*hinf

label var posXavginf "interaction: pos X avginf"
label var nonpos_negXavginf "interaction: nonpos_neg X avginf"
label var pnXavginf "interaction: pn X avginf"
label var pzXavginf "interaction: pz X avginf"
label var posXhinf "interaction: pos X hinf"
label var nonpos_negXhinf "interaction: nonpos_neg X hinf"
label var pnXhinf "interaction: pn X hinf"
label var pzXhinf "interaction: pz X hinf"


**** Percentage change in nominal and real wages (for histograms) ****

* Percentage change in nominal wages
sort dist year
by dist: gen pctchange_n = (wage - wage[_n-1]) / wage[_n-1]
* Top and bottom code at -.5 and .5
gen pctchange_n2 = pctchange_n
replace pctchange_n2 = -.5 if pctchange_n<-.5
replace pctchange_n2 = .5 if pctchange_n>.5 & pctchange_n!=.
label var pctchange_n "% change in nominal wage"
label var pctchange_n2 "% change in nominal wage (top & bottom coded)"

* Compute real wages
* Real wage - state cpi only (missing in the 2 years where no state cpi available)
gen rwage = wage/calcpi
label var rwage "real wage"

* percentage change in real wages
sort dist year
by dist: gen pctchange_r = (rwage - rwage[_n-1]) / rwage[_n-1]
* top and bottom code at -.5 and .5
gen pctchange_r2 = pctchange_r
replace pctchange_r2 = -.5 if pctchange_r<-.5
replace pctchange_r2 = .5 if pctchange_r>.5 & pctchange_r!=.
label var pctchange_r "% change in real wage"
label var pctchange_r2 "% change in real wage (top & bottom coded)"


******************** YIELDS DATA **************************

* total area planted by crops
egen areatot = rowtotal(awheat arice asugar amaize apotato agnut abarley atobac agram atur aragi asesam armseed abajra acotton ajowar aopuls ajute asoy asunflwr), missing
label var areatot "total area planted under crops in district"

foreach v in wheat rice sugar maize potato gnut barley tobac gram tur ragi sesam rmseed bajra cotton jowar opuls jute soy sunflwr {
	egen aw`v' = mean(a`v'/areatot), by(dist)
	label var aw`v' "awC = average share of area planted under crop C in district d (time invariant)"
}

* scale yields variable - relfects shocks - changes in yields relative to average
* District mean: mean yield of each crop in each district
foreach v in wheat rice sugar maize potato gnut barley tobac gram tur ragi sesam rmseed bajra cotton jowar opuls jute soy sunflwr {
	egen avg`v' = mean(y`v'), by(dist)
	capture gen normy`v' = y`v'/avg`v'
	capture replace normy`v' = 0 if avg`v'==0
	label var avg`v' "avgC = (avg yield of crop C in district d)"
	label var normy`v' "normyC = (yield of crop C in district d in yr t) / (avg yield of crop C in district d)"
}


* all crops
gen awyield = normywheat*awwheat + normyrice*awrice + normysugar*awsugar + normymaize*awmaize + normypotato*awpotato +  normygnut*awgnut +  normybarley*awbarley +  normytobac*awtobac + normygram*awgram + normytur*awtur +  normyragi*awragi + normysesam*awsesam + normyrmseed*awrmseed +  normybajra*awbajra + normycotton*awcotton +  normyjowar*awjowar + normyopuls*awopuls + normyjute*awjute +  normysoy*awsoy + normysunflwr*awsunflwr
gen logawyield = log(awyield)
label var awyield "crop yields index (weighted by area planted)"
label var logawyield "log crop yields index (weighted by area planted)"

* Keep only agricultural districts reliant on monsoon (average area under rice cultivation rice >0.5% of land area)
keep if awrice>0.005



******************** REPLICATION DATASET **************************

save "$replication_files/data_wb_replication.dta", replace
