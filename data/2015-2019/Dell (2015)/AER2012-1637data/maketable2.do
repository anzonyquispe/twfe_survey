**------This file analyzes how PAN victories impact the homicide rate
**---The sample consists of municipalities with elections in 2007 or 2008 with at least six months of pre-election drug-related homicide data. This is the set of municipalities for which drug-related homicide data are also available for the full-term of the mayor. The post-innauguration period includes the mayor's full-term.
**---Confidential data on drug-trade related homicides have been redacted.

clear
set more off, permanently

******************
*Table 2, Panel A
******************

*********Post-innauguration period
use table2, clear

keep if postInn==1	
keep if drughom!=.

g DummyDeaths=0
replace DummyDeaths=1 if drughom>0

collapse (mean) DummyDeaths drughom spread PANwin pob_total, by(id_mun)

*rate
g xhom=(drughom/pob_t)*12*100000  

*rd terms
g spreadPW=spread*PANwin
g spread2=spread^2
g spreadPW2=spreadPW^2
tempfile post_innaug
save `post_innaug', replace

**********Lame duck period
use table2, clear

keep if postElec==1 
keep if drughom!=.

g DummyDeaths=0
replace DummyDeaths=1 if drughom>0

collapse (mean) DummyDeaths drughom spread PANwin pob_total, by(id_mun)

*rate
g xhom=(drughom/pob_t)*12*100000  

*rd terms
g spreadPW=spread*PANwin
g spread2=spread^2
g spreadPW2=spreadPW^2

tempfile post_elec
save `post_elec', replace	

*******PreElec
use table2, clear
keep if (postElec==0 & postInn==0)
keep if drughom!=.

g DummyDeaths=0
replace DummyDeaths=1 if drughom>0

collapse (mean) DummyDeaths drughom spread PANwin pob_total, by(id_mun)

*rate
g xhom=(drughom/pob_t)*12*100000  

*rd terms
g spreadPW=spread*PANwin
g spread2=spread^2
g spreadPW2=spreadPW^2

tempfile pre_elec
save `pre_elec', replace

******define global variables for regressions    
global x1 "PANwin spread spreadPW"  
global x2 "PANwin spread spread2 spreadPW spreadPW2"

use `post_innaug', clear
reg DummyDeaths $x2 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons replace bdec(3)

use `post_elec', clear
reg DummyDeaths $x2 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg DummyDeaths $x2 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)

use `post_innaug', clear
reg DummyDeaths $x1 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)

use `post_elec', clear
reg DummyDeaths $x1 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg DummyDeaths $x1 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)

use `post_innaug', clear
reg xhom $x2 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)

use `post_elec', clear
reg xhom $x2 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg xhom $x2 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)

use `post_innaug', clear
reg xhom $x1 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)

use `post_elec', clear
reg xhom $x1 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg xhom $x1 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panela, excel less(0) nocons append bdec(3)

******************
*Table 2, Panel B
******************

*********Post-innauguration period
use table2, clear

keep if postInn==1	

g DummyDeaths=0
replace DummyDeaths=1 if hom>0

collapse (mean) DummyDeaths hom spread PANwin pob_total, by(id_mun)

*rate
g xhom=(hom/pob_t)*12*100000  

*rd terms
g spreadPW=spread*PANwin
g spread2=spread^2
g spreadPW2=spreadPW^2
tempfile post_innaug
save `post_innaug', replace

**********Lame duck period
use table2, clear

keep if postElec==1

g DummyDeaths=0
replace DummyDeaths=1 if hom>0

collapse (mean) DummyDeaths hom spread PANwin pob_total, by(id_mun)

*rate
g xhom=(hom/pob_t)*12*100000  

*rd terms
g spreadPW=spread*PANwin
g spread2=spread^2
g spreadPW2=spreadPW^2

tempfile post_elec
save `post_elec', replace	

*******PreElec
use table2, clear

keep if (postElec==0 & postInn==0)

g DummyDeaths=0
replace DummyDeaths=1 if hom>0

collapse (mean) DummyDeaths hom spread PANwin pob_total, by(id_mun)

*rate
g xhom=(hom/pob_t)*12*100000  

*rd terms
g spreadPW=spread*PANwin
g spread2=spread^2
g spreadPW2=spreadPW^2

tempfile pre_elec
save `pre_elec', replace

******define global variables for regressions

use `post_innaug', clear
reg DummyDeaths $x2 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons replace bdec(3)

use `post_elec', clear
reg DummyDeaths $x2 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg DummyDeaths $x2 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)

use `post_innaug', clear
reg DummyDeaths $x1 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)

use `post_elec', clear
reg DummyDeaths $x1 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg DummyDeaths $x1 if abs(spread)<.05, robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)

use `post_innaug', clear
reg xhom $x2 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)

use `post_elec', clear
reg xhom $x2 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg xhom $x2 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)
	
use `post_innaug', clear
reg xhom $x1 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)

use `post_elec', clear
reg xhom $x1 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)	

use `pre_elec', clear
reg xhom $x1 if abs(spread)<.05 [aw=pob_t], robust cluster(id_m)
outreg2 PANwin using t2_panelb, excel less(0) nocons append bdec(3)
