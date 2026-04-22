log using meps03share.log

set seed 1234567
set linesize 120
set mem 300m
set matsize 800
set more off

* read in person-level file with medicare coverage for each person
* this raw file can be obtained from meps site - see the readme for more detail

infile using h79.dct, using(../year03/raw/H79.DAT)
sort dupersid
save meps03person
d
sum
clear

* read in prescription events file

infile using h77a.dct, using(../year03/raw/H77A.DAT)

sort dupersid

* how many people in this data and how many scripts per person
quietly by dupersid: gen temp_n = _n
quietly by dupersid: gen temp_N = _N
sum temp_N if temp_n==1, detail
drop temp_*

* merge with data that has info on person - esp if they were on medicare
count
sort dupersid
merge dupersid using meps03person
tab _merge
sort _merge
by _merge: sum pd_total

* decent number of people have zero scripts - drop them
drop if pd_total==.
drop _merge

* also drop people with zero weight
sum personwgt, detail
drop if personwgt==0

* code as medicare eligible if they had medicare at any point during year
gen mcarscript = (mcrev03=="1")
tab mcarscript, missing

* define dual script as share of spending for this script done by medicaid
* require that person said they were on medicare and medicaid at some point

gen dualscript = (pd_medicaid / pd_total) if mcrev03=="1" & mcdev03=="1"
replace dualscript = 0 if dualscript==.
sum dualscript, detail

* define medicare out-of-pocket script as share of spending for this script
* that is out of pocket . . . require that person was on medicare at some point

gen mcselfscript = (pd_self / pd_total) if mcrev03=="1"
replace mcselfscript = 0 if mcselfscript==.
sum mcselfscript, detail

sum mcarscript dualscript mcselfscript

* some prescriptions were actually paid by medicare
* almost always those person have mcrev03=="01" so just stick with
* that definition below
gen anymcrpd = (pd_medicare > 0 & pd_medicare!=.)
tab anymcrpd, missing
tab mcarscript anymcrpd, missing

* large number of ndc's are not identified so we won't use this for now
count
count if rxndc=="-9"

*********************************************************************
** 1. Recode drug names for top 1000 (gen shortnam) **

* clean up the name variable (capitalize, remove leading/trailing blanks)
replace medicationname = upper(ltrim(rtrim(medicationname)))

* these are defined to match up with namemerge in Pat's shares file

gen str20 shortnam = ""

**DRUGS 1-10

* 42 rx with generic name 
replace   shortnam = "LIPITOR" if substr(medicationname,1,7)=="LIPITOR"
replace   shortnam = "LIPITOR" if substr(medicationname,1,12)=="ATORVASTATIN"            

* 495 rx with generic name  (zocor off patent 2006)
replace   shortnam = "ZOCOR" if substr(medicationname,1,5)=="ZOCOR"
replace   shortnam = "ZOCOR" if substr(medicationname,1,11)=="SIMVASTATIN"
replace   shortnam = "ZOCOR" if substr(medicationname,1,10)=="SIMVSTATIN"

* 81 rx with generic name   
replace   shortnam = "PREVACID" if substr(medicationname,1,8)=="PREVACID"
replace  shortnam = "PREVACID" if substr(medicationname,1,12)=="LANSOPRAZOLE"

* 3 rx with generic name 
replace   shortnam = "NEXIUM"  if substr(medicationname,1,6)=="NEXIUM"           
replace  shortnam = "NEXIUM" if substr(medicationname,1,12)=="ESOMEPRAZOLE" 

* 101 rx with generic name (zoloft off patent 2006)
replace   shortnam = "ZOLOFT" if substr(medicationname,1,6)=="ZOLOFT"
replace   shortnam = "ZOLOFT" if substr(medicationname,1,10)=="SERTRALINE"

*too few obs; other brand (procrit) with same generic name ERYTHROPOIETIN ALFA, EPOETIN ALFA              
replace   shortnam = "EPOGEN" if substr(medicationname,1,6)=="EPOGEN"

* 16 rx with generic name 
replace   shortnam = "CELEBREX" if substr(medicationname,1,8)=="CELEBREX"         
replace   shortnam = "CELEBREX" if substr(medicationname,1,9)=="CELECOXIB" 

* 41 rx with generic name
replace   shortnam = "ZYPREXA" if substr(medicationname,1,7)=="ZYPREXA"
replace   shortnam = "ZYPREXA" if substr(medicationname,1,10)=="OLANZAPINE"

* generic gabapentin on the mkt, late 2003    
replace   shortnam = "NEURONTIN" if substr(medicationname,1,9)=="NEURONTIN"

*too few obs; other brand (epogen) with same generic name ERYTHROPOIETIN ALFA, EPOETIN ALFA  
replace   shortnam = "PROCRIT" if substr(medicationname,1,7)=="PROCRIT"

** DRUGS 11-20

* 22 rx with generic name
replace   shortnam = "EFFEXOR" if substr(medicationname,1,7)=="EFFEXOR"
replace   shortnam = "EFFEXOR" if substr(medicationname,1,11)=="VENLAFAXINE"

* 15 rx with generic name             
replace   shortnam = "ADVAIR" if substr(medicationname,1,6)=="ADVAIR"
replace   shortnam = "ADVAIR" if substr(medicationname,1,19)=="FLUTICAS/SALMETEROL"
replace   shortnam = "ADVAIR" if substr(medicationname,1,22)=="FLUTICASONE/SALMETEROL"

* generic PAROXETINE on mkt in 2003                
replace   shortnam = "PAXIL" if substr(medicationname,1,5)=="PAXIL"
            
***
* other brand (amvaz -- which doesn't show up in meps) with same generic name AMLODIPINE on mkt in late 2003 (should revisit this one)
replace   shortnam = "NORVASC" if substr(medicationname,1,7)=="NORVASC"
****

* 15 rx with generic name (off patent 2006)         
replace   shortnam = "PRAVACHOL" if substr(medicationname,1,9)=="PRAVACHOL"
replace   shortnam = "PRAVACHOL" if substr(medicationname,1,11)=="PRAVASTATIN"

* 55 rx with generic name           
replace   shortnam = "PLAVIX" if substr(medicationname,1,6)=="PLAVIX"
replace   shortnam = "PLAVIX" if substr(medicationname,1,11)=="CLOPIDOGREL"
    
* 69 rx with generic name      
replace   shortnam = "ALLEGRA" if substr(medicationname,1,7)=="ALLEGRA"
replace   shortnam = "ALLEGRA" if substr(medicationname,1,12)=="FEXOFENADINE"

* spelling error; other brand (Zyban) or generic BUPROPION on the mkt                 
replace   shortnam = "WELLBUTRIN" if substr(medicationname,1,10)=="WELLBUTRIN"
replace   shortnam = "WELLBUTRIN" if substr(medicationname,1,10)=="WELLBURTIN"

* too few obs; generic OXYCODONE on the mkt
replace   shortnam = "OXYCONTIN" if substr(medicationname,1,9)=="OXYCONTIN"
   
* 21 rx with generic name 
replace   shortnam = "FOSAMAX" if substr(medicationname,1,7)=="FOSAMAX"
replace   shortnam = "FOSAMAX" if substr(medicationname,1,11)=="ALENDRONATE"
  
** DRUGS 21-30

* 10 rx with generic name     
replace   shortnam ="VIOXX"       if substr(medicationname,1,5)=="VIOXX"          
replace   shortnam ="VIOXX"       if substr(medicationname,1,9)=="ROFECOXIB"
replace   shortnam ="VIOXX"       if substr(medicationname,1,9)=="ROFECOXIE"

* spelling error; 23 rx with generic name
replace   shortnam = "SINGULAIR" if substr(medicationname,1,9)=="SINGULAIR"
replace   shortnam = "SINGULAIR" if substr(medicationname,1,8)=="SINGULAR"
replace   shortnam = "SINGULAIR" if substr(medicationname,1,11)=="MONTELUKAST"
replace   shortnam = "SINGULAIR" if substr(medicationname,1,11)=="MONTFLUKAST"

* no generic Pantoprazole in meps              
replace   shortnam = "PROTONIX" if substr(medicationname,1,8)=="PROTONIX"
         
* spelling error; 347 rx with generic name (zithromax off patent 2005)
replace   shortnam = "ZITHROMAX" if substr(medicationname,1,9)=="ZITHROMAX"
replace   shortnam = "ZITHROMAX" if substr(medicationname,1,9)=="ZITHROIMA"         
replace   shortnam = "ZITHROMAX" if substr(medicationname,1,12)=="AZITHROMYCIN"

* 2 rx with generic name
replace   shortnam = "ACTOS" if substr(medicationname,1,5)=="ACTOS"
replace   shortnam = "ACTOS" if substr(medicationname,1,12)=="PIOGLITAZONE"               

* spelling error; 73 rx with generic name
replace   shortnam = "RISPERDAL" if substr(medicationname,1,9)=="RISPERDAL"
replace   shortnam = "RISPERDAL" if substr(medicationname,1,9)=="RISPERDOL"         
replace   shortnam = "RISPERDAL" if substr(medicationname,1,11)=="RISPERIDONE"

* 4 rx with generic name
replace   shortnam = "AMBIEN" if substr(medicationname,1,6)=="AMBIEN"
replace   shortnam = "AMBIEN" if substr(medicationname,1,8)=="ZOLPIDEM" 

* 48 rx with generic name (zyrtec off patent 2007)
replace   shortnam = "ZYRTEC" if substr(medicationname,1,6)=="ZYRTEC"
replace   shortnam = "ZYRTEC" if substr(medicationname,1,10)=="CETIRIZINE"
             
* spelling error; other brand and generic Estrogen and Progestin on the mkt
replace   shortnam = "ORTHO" if substr(medicationname,1,5)=="ORTHO"
replace   shortnam = "ORTHO" if substr(medicationname,1,12)=="E-ORTHO EVRA"            

* other brand or generic OMEPRAZOLE on the mkt 
replace   shortnam = "PRILOSEC" if substr(medicationname,1,8)=="PRILOSEC"
       
** DRUGS 31-40
    
* 16 rx with generic name
replace   shortnam = "DIOVAN" if substr(medicationname,1,6)=="DIOVAN" 
replace   shortnam = "DIOVAN" if substr(medicationname,1,9)=="VALSARTAN"             
 
* too few obs; no generic Etanercept Injection in meps            
replace   shortnam = "ENBREL" if substr(medicationname,1,6)=="ENBREL"

* 17 rx with generic name
replace   shortnam = "CELEXA" if substr(medicationname,1,6)=="CELEXA" 
replace   shortnam = "CELEXA" if substr(medicationname,1,10)=="CITALOPRAM" 
            
* 45 rx with generic name (assume "ROSIGLITAZONE" not combo treatment ROSIGLITAZONE/METFORMIN, aka avandamet)
replace   shortnam = "AVANDIA" if substr(medicationname,1,7)=="AVANDIA"
replace   shortnam = "AVANDIA" if substr(medicationname,1,13)=="ROSIGLITAZONE"            

* 224 rx with generic name
replace   shortnam = "ACIPHEX" if substr(medicationname,1,7)=="ACIPHEX"       
replace   shortnam = "ACIPHEX" if substr(medicationname,1,11)=="RABEPRAZOLE"  

* this is a generic 
replace   shortnam = "OMEPRAZOLE" if substr(medicationname,1,10)=="OMEPRAZOLE"       
    
* too few obs; 30 rx with generic name
replace   shortnam = "VIAGRA" if substr(medicationname,1,6)=="VIAGRA"          
replace   shortnam = "VIAGRA" if substr(medicationname,1,10)=="SILDENAFIL"

* spelling error; 12 rx with generic name
replace   shortnam = "SEROQUEL" if substr(medicationname,1,8)=="SEROQUEL"
replace   shortnam = "SEROQUEL" if substr(medicationname,1,8)=="SEROGNEL"           
replace   shortnam = "SEROQUEL" if substr(medicationname,1,10)=="QUETIAPINE"           

* no brand or generic Infliximab Injection in meps
replace   shortnam = "REMICADE" if substr(medicationname,1,8)=="REMICADE"

* too few obs; 1 rx with generic name 
replace   shortnam = "IMITREX" if substr(medicationname,1,7)=="IMITREX"
replace   shortnam = "IMITREX" if substr(medicationname,1,11)=="SUMATRIPTAN"  

** DRUGS 41-50            

* too few obs; other brand or generic Levofloxacin Oral on the mkt
replace   shortnam = "LEVAQUIN" if substr(medicationname,1,8)=="LEVAQUIN"           

* too few obs; no generic Fentanyl Skin Patches in meps
replace   shortnam = "DURAGESIC" if substr(medicationname,1,9)=="DURAGESIC"           

* 42 rx with generic name
replace   shortnam = "DEPAKOTE" if substr(medicationname,1,8)=="DEPAKOTE" 
replace   shortnam = "DEPAKOTE" if substr(medicationname,1,10)=="DIVALPROEX"          
  
* other brand or generic ESTROGEN on the mkt
replace   shortnam = "PREMARIN" if substr(medicationname,1,8)=="PREMARIN"
replace   shortnam = "PREMARIN" if medicationname=="ESTROGENS (PREMARIN)"          
 
*10 rx with generic name  (do not use "METROROLOL" since could be METOPROLOL TARTRATE)
replace   shortnam = "TOPROL" if substr(medicationname,1,6)=="TOPROL"             
replace   shortnam = "TOPROL" if substr(medicationname,1,12)=="METOPROLOL S"  

* 1 rx with generic name
replace   shortnam = "LEXAPRO" if substr(medicationname,1,7)=="LEXAPRO"  
replace   shortnam = "LEXAPRO" if substr(medicationname,1,12)=="ESCITALOPRAM"
        
* no generic Amlodipine/Benazepril in meps
replace   shortnam = "LOTREL" if substr(medicationname,1,6)=="LOTREL"             


* 3 rx with generic name
replace   shortnam = "TOPAMAX" if substr(medicationname,1,7)=="TOPAMAX"           
replace   shortnam = "TOPAMAX" if substr(medicationname,1,10)=="TOPIRAMATE" 

* other brand and generic FLUTICASONE PROPIONATE
replace   shortnam = "FLONASE" if substr(medicationname,1,7)=="FLONASE"           
              
* 1 rx with generic name
replace   shortnam = "BEXTRA" if substr(medicationname,1,6)=="BEXTRA"
replace   shortnam = "BEXTRA" if substr(medicationname,1,10)=="VALDECOXIB"

** DRUGS 51-60  

* no brand or generic PEGFILGRASTIM in meps
replace   shortnam = "NEULASTA" if substr(medicationname,1,8)=="NEULASTA"           

* no brand or generic RITUXIMAB in meps
replace   shortnam = "RITUXAN" if substr(medicationname,1,7)=="RITUXAN"           


* spelling error; this is a generic; note: alt name "Amox Tr-Potassium Clavulanate" 
replace   shortnam = "AMOX" if substr(medicationname,1,23)=="AMOXICILLIN/CLAVULANATE"              
replace   shortnam = "AMOX" if substr(medicationname,1,5)=="AMOX "
replace   shortnam = "AMOX" if medicationname=="GENERIC AUGMENTIN 5"

* no brand or generic INTERFERON BETA 1A in meps
replace   shortnam = "AVONEX" if substr(medicationname,1,6)=="AVONEX"           

* careful, other drugs with same prefix; other brand (ciloxan) and generic CIPROFLOXACIN on the mkt
replace   shortnam = "CIPRO" if substr(medicationname,1,6)=="CIPRO "             

* other brand or generic LEVOTHYROXINE on the mkt
replace   shortnam = "SYNTHROID" if substr(medicationname,1,9)=="SYNTHROID"
replace   shortnam = "SYNTHROID" if medicationname=="LEVOTHYROXINE (SYNTHROID)"
replace   shortnam = "SYNTHROID" if medicationname=="LEVOTHYROXINE NA (SYNTHROID)"          

* no brand or generic DARBEPOETIN ALFA in meps
replace   shortnam = "ARANESP" if substr(medicationname,1,7)=="ARANESP"         

* 2 rx with generic INSULIN LISPRO HUMAN (LISPRO is unique ingredient to HUMALOG; other brand or generic INSULIN on the mkt)
replace   shortnam = "HUMALOG" if substr(medicationname,1,7)=="HUMALOG"            
replace   shortnam = "HUMALOG" if medicationname=="INSULIN LISPRO HUMAN"

* too few obs; other brand or generic Leuprolide on the mkt
replace   shortnam = "LUPRON" if substr(medicationname,1,6)=="LUPRON"             

* 11 rx with generic name
replace   shortnam = "EVISTA" if substr(medicationname,1,6)=="EVISTA"
replace   shortnam = "EVISTA" if substr(medicationname,1,10)=="RALOXIFENE"        
     
** DRUGS 61-70

* no generic ONDANSETRON in meps
replace   shortnam = "ZOFRAN" if substr(medicationname,1,6)=="ZOFRAN"             
 
* no generic DESLORATADINE in meps
replace   shortnam = "CLARINEX" if substr(medicationname,1,8)=="CLARINEX"         
             
* 20 rx with generic name
replace   shortnam = "ALTACE" if substr(medicationname,1,6)=="ALTACE"
replace   shortnam = "ALTACE" if substr(medicationname,1,8)=="RAMIPRIL"
            
* no brand or generic DOCETAXEL in meps
replace   shortnam = "TAXOTERE" if substr(medicationname,1,8)=="TAXOTERE"
  
* other brand or generic INSULIN on the mkt
replace   shortnam = "HUMULIN" if substr(medicationname,1,7)=="HUMULIN"           
  
* too few obs, 3 with generic
replace   shortnam = "VALTREX" if substr(medicationname,1,7)=="VALTREX"   
replace   shortnam = "VALTREX" if substr(medicationname,1,12)=="VALACYCLOVIR"       

* other brand (DEXTROSTAT) or generic DEXTROAMPHETAMINE on the mkt
replace   shortnam = "ADDERALL" if substr(medicationname,1,8)=="ADDERALL"          
   
* 4 rx with generic name
replace   shortnam = "DETROL" if substr(medicationname,1,6)=="DETROL"  
replace   shortnam = "DETROL" if substr(medicationname,1,11)=="TOLTERODINE"  

* 20 rx with generic name; (assume "LOSARTAN" not combo HYDROCHLOROTHIAZIDE/LOSARTAN)
replace   shortnam = "COZAAR" if substr(medicationname,1,6)=="COZAAR"             
replace   shortnam = "COZAAR" if substr(medicationname,1,8)=="LOSARTAN"

*143 rx with generic name (biaxin off patent 2005); (assume "CLARITHROMYCIN" not combo, prevpac: AMOXICILLIN/CLARITHROMYCIN/LANSOPRAZOLE)
replace   shortnam = "BIAXIN" if substr(medicationname,1,6)=="BIAXIN"
replace   shortnam = "BIAXIN" if medicationname=="CLARITHROMYCIN"

** DRUGS 71-80            

* generic FENOFIBRATE on the mkt 
replace   shortnam = "TRICOR" if substr(medicationname,1,6)=="TRICOR"             

* no generic LAMOTRIGINE in meps
replace   shortnam = "LAMICTAL" if substr(medicationname,1,8)=="LAMICTAL"           
 
* spelling error; other brand or generic METFORMIN on the mkt
replace   shortnam = "GLUCOPHAGE" if substr(medicationname,1,10)=="GLUCOPHAGE"        
replace   shortnam = "GLUCOPHAGE" if medicationname=="GLUCOPHAG" 

* other brand and generic METHYLPHENIDATE on the mkt
replace   shortnam = "CONCERTA" if substr(medicationname,1,8)=="CONCERTA"          

* other brand and generic RIBAVIRIN on the mkt
replace   shortnam = "REBETOL" if substr(medicationname,1,7)=="REBETOL"           

* generic AMOXICILLIN/CLAVULANATE on the mkt 
replace   shortnam = "AUGMENTIN" if substr(medicationname,1,9)=="AUGMENTIN"          

* 31 rx with generic name (coreg off patent 2007)
replace   shortnam = "COREG" if substr(medicationname,1,5)=="COREG"  
replace   shortnam = "COREG" if substr(medicationname,1,10)=="CARVEDILOL"            

* 8 rx with generic name
replace   shortnam = "ACCUPRIL" if substr(medicationname,1,8)=="ACCUPRIL"           
replace   shortnam = "ACCUPRIL" if substr(medicationname,1,9)=="QUINAPRIL"

* no generic TERBINAFINE in meps
replace   shortnam = "LAMISIL" if substr(medicationname,1,7)=="LAMISIL"             
  
* 22 rx with generic name
replace   shortnam = "ARICEPT" if substr(medicationname,1,7)=="ARICEPT"          
replace   shortnam = "ARICEPT" if substr(medicationname,1,9)=="DONEPEZIL"

** DRUGS 81-90

* 17 rx with generic name
replace   shortnam = "FLOMAX" if substr(medicationname,1,6)=="FLOMAX"            
replace   shortnam = "FLOMAX" if substr(medicationname,1,10)=="TAMSULOSIN"

* other brand and generic FLUTICASONE on the mkt
replace   shortnam = "FLOVENT" if substr(medicationname,1,7)=="FLOVENT"             
replace   shortnam = "FLOVENT" if medicationname=="FLUTICASONE (FLOVENT)" 

* 11 rx with generic name
replace   shortnam = "ACTONEL" if substr(medicationname,1,7)=="ACTONEL"   
replace   shortnam = "ACTONEL" if substr(medicationname,1,11)=="RISEDRONATE"         

* other brand or generic BUDESONIDE on the mkt
replace   shortnam = "PULMICORT" if substr(medicationname,1,9)=="PULMICORT"           

* no brand or generic FILGRASTIM in meps
replace   shortnam = "NEUPOGEN" if substr(medicationname,1,8)=="NEUPOGEN"           

* other brand or generic ACETAMINOPHEN on the mkt
replace   shortnam = "TYLENOL" if substr(medicationname,1,7)=="TYLENOL"            

* other brand and generic MOMETASONE on the mkt
replace   shortnam = "NASONEX" if substr(medicationname,1,7)=="NASONEX"             
           
* 4 rx with generic name
replace   shortnam = "COMBIVIR" if substr(medicationname,1,8)=="COMBIVIR"
replace   shortnam = "COMBIVIR" if medicationname=="LAMIVUDINE/ZIDOVUDINE"  

* no generic Glatiramer in meps
replace   shortnam = "COPAXONE" if substr(medicationname,1,8)=="COPAXONE"          
 
* no generic Mycophenolate in meps
replace   shortnam = "CELLCEPT" if substr(medicationname,1,8)=="CELLCEPT"

** DRUGS 91-100          
  
* no brand or generic Peginterferon alfa-2b in meps
replace   shortnam = "PEG-INTRON" if substr(medicationname,1,10)=="PEG-INTRON"        

* glucovance is combo Glyburide/Metformin, only the separate ingredients are listed and these correspond to other brands
replace   shortnam = "GLUCOVANCE" if substr(medicationname,1,10)=="GLUCOVANCE"         

* no brand or generic Carboplatin in meps
replace   shortnam = "PARAPLATIN" if substr(medicationname,1,10)=="PARAPLATIN"          
   
***
* spelling error; lisinopril is a generic (pat includes combo hctz/lisinopril in his top 1000 for "lisinopril"-- revisit?)
replace   shortnam = "LISINOPRIL" if substr(medicationname,1,10)=="LISINOPRIL"      
replace   shortnam = "LISINOPRIL" if substr(medicationname,1,10)=="LISONOPRIL"
replace   shortnam = "LISINOPRIL" if substr(medicationname,1,6)=="LISINO"
replace   shortnam = "LISINOPRIL" if medicationname=="HCTZ/LISINOPRIL"
***

* no generic Tacrolimus in meps
replace   shortnam = "PROGRAF" if substr(medicationname,1,7)=="PROGRAF"           
 
* no generic Enoxaparin in meps
replace   shortnam = "LOVENOX" if substr(medicationname,1,7)=="LOVENOX"            

* no generic combo Losartan/Hydrochlorothiazide in meps
replace   shortnam = "HYZAAR" if substr(medicationname,1,6)=="HYZAAR"              

* other brand (DUONEB) or generic ALBUTEROL/IPRATROPIUM on the mkt
replace   shortnam = "COMBIVENT" if substr(medicationname,1,9)=="COMBIVENT"           
* replace   shortnam = "COMBIVENT" if medicationname=="IPRATROP 0.5 / ALBUT 2.5 COM S"
  
* no brand or generic Zoledronic in meps
replace   shortnam = "ZOMETA" if substr(medicationname,1,6)=="ZOMETA"           


* other brand pneumococcal vaccine on mkt
replace   shortnam = "PREVNAR" if substr(medicationname,1,7)=="PREVNAR"

** DRUGS 101-110            

* 11 rx with generic name (off patent in 2004)
replace   shortnam = "DIFLUCAN" if substr(medicationname,1,8)=="DIFLUCAN"
replace   shortnam = "DIFLUCAN" if substr(medicationname,1,11)=="FLUCONAZOLE"           
 
* no generic Ezetimibe in meps
replace   shortnam = "ZETIA" if substr(medicationname,1,5)=="ZETIA"             

* no brand or generic IRINOTECAN in meps
replace   shortnam = "CAMPTOSAR" if substr(medicationname,1,9)=="CAMPTOSAR"          

* 47 rx with generic name (assume "BENAZEPRIL" not combo BENAZEPRIL/AMLODIPINE) 
replace   shortnam = "LOTENSIN" if substr(medicationname,1,8)=="LOTENSIN" 
replace   shortnam = "LOTENSIN" if substr(medicationname,1,10)=="BENAZEPRIL"                      

* no generic Aripiprazole in meps
replace   shortnam = "ABILIFY" if substr(medicationname,1,7)=="ABILIFY"

* 23 rx with generic name
replace   shortnam = "XALATAN" if substr(medicationname,1,7)=="XALATAN"           
replace   shortnam = "XALATAN" if substr(medicationname,1,11)=="LATANOPROST"  

* other brand (sarafem) or generic Fluoxetine on the mkt
replace   shortnam = "PROZAC" if substr(medicationname,1,6)=="PROZAC"          
replace   shortnam = "PROZAC" if medicationname=="FLUOXETINE (PROZAC)"

* other brand (oxytrol) or generic OXYBUTYNIN on the mkt
replace   shortnam = "DITROPAN" if substr(medicationname,1,8)=="DITROPAN"           

* no generic Atomoxetine in meps
replace   shortnam = "STRATTERA" if substr(medicationname,1,9)=="STRATTERA"          
 
* no brand or generic Gemcitabine in meps
replace   shortnam = "GEMZAR" if substr(medicationname,1,6)=="GEMZAR"            

** DRUGS 111-120 

* other brand (canasa) or generic MESALAMINE on the mkt
replace   shortnam = "ASACOL" if substr(medicationname,1,6)=="ASACOL"             

* no generic Fluvastatin in meps
replace   shortnam = "LESCOL" if substr(medicationname,1,6)=="LESCOL"
              
* no generic ARV combo Lamivudine/Abacavir Sulfate/Zidovudine in meps
replace   shortnam = "TRIZIVIR" if substr(medicationname,1,8)=="TRIZIVIR"          
   
* 12 rx with generic name
replace   shortnam = "LANTUS" if substr(medicationname,1,6)=="LANTUS"            
replace   shortnam = "LANTUS" if medicationname=="INSULIN, GLARGINE (LANTUS)"
replace   shortnam = "LANTUS" if medicationname=="INSULIN, GLARGINE, HUMAN" 

* this is a generic
replace   shortnam = "METFORMIN" if substr(medicationname,1,9)=="METFORMIN"         
 
* 8 rx with generic name, ARV combo LOPINAVIR/RITONAVIR
replace   shortnam = "KALETRA" if substr(medicationname,1,7)=="KALETRA"   
replace   shortnam = "KALETRA" if medicationname=="LOPINAVIR-RITONAVIR"        

* no generic Oxcarbazepine in meps
replace   shortnam = "TRILEPTAL" if substr(medicationname,1,9)=="TRILEPTAL"           

* 39 rx with generic name; * note there is a combination product, but assume that if it just says irbesartan then it is avapro
replace   shortnam = "AVAPRO" if substr(medicationname,1,6)=="AVAPRO"
replace   shortnam = "AVAPRO" if substr(medicationname,1,10)=="IRBESARTAN"  

* no brand or generic Imatinib in meps
replace   shortnam = "GLEEVEC" if substr(medicationname,1,7)=="GLEEVEC"            

* no generic Metaxalone in meps
replace   shortnam = "SKELAXIN" if substr(medicationname,1,8)=="SKELAXIN"
            
** DRUGS 121-130
 
* no brand or generic Interferon Beta-1b Injection in meps
replace   shortnam = "BETASERON" if substr(medicationname,1,9)=="BETASERON"        
 
* 12 rx with generic name
replace   shortnam = "VIREAD" if substr(medicationname,1,6)=="VIREAD" 
replace   shortnam = "VIREAD" if substr(medicationname,1,9)=="TENOFOVIR"           
   
* no generic Oxaliplatin in meps
replace   shortnam = "ELOXATIN" if substr(medicationname,1,8)=="ELOXATIN"       
          
* other brand or generic Leuprolide on the mkt
replace   shortnam = "NASACORT" if substr(medicationname,1,8)=="NASACORT"

* 3 rx with generic name
replace   shortnam = "SUSTIVA" if substr(medicationname,1,7)=="SUSTIVA"
replace   shortnam = "SUSTIVA" if substr(medicationname,1,9)=="EFAVIRENZ"
            
* other brand or generic Warfarin on the mkt
replace   shortnam = "COUMADIN" if substr(medicationname,1,8)=="COUMADIN"
replace   shortnam = "COUMADIN" if medicationname=="WARFARIN (COUMADIN)"

* 34 rx with generic name (off patent 2008)
replace   shortnam = "SEREVENT" if substr(medicationname,1,8)=="SEREVENT"            
replace   shortnam = "SEREVENT" if substr(medicationname,1,10)=="SALMETEROL"  

* this is a generic
replace   shortnam = "CIPROFLOXACIN" if substr(medicationname,1,13)=="CIPROFLOXACIN"    

* generic Glipizide available
replace   shortnam = "GLUCOTROL" if substr(medicationname,1,9)=="GLUCOTROL"           

* other brand or generic BUDESONIDE on the mkt
replace   shortnam = "RHINOCORT" if substr(medicationname,1,9)=="RHINOCORT"         

** DRUGS 131-140

* no generic Cefprozil in meps
replace   shortnam = "CEFZIL" if substr(medicationname,1,6)=="CEFZIL"              
 
* no generic Cefdinir in meps
replace   shortnam = "OMNICEF" if substr(medicationname,1,7)=="OMNICEF"            
          
* other brand (propecia) or generic Finasteride on the mkt  
replace   shortnam = "PROSCAR" if substr(medicationname,1,7)=="PROSCAR"
   
* 9 rx with generic name (off patent 2006)
replace   shortnam = "MOBIC" if substr(medicationname,1,5)=="MOBIC"            
replace   shortnam = "MOBIC" if substr(medicationname,1,9)=="MELOXICAM"  
         
* no generic Isotretinoin in meps
replace   shortnam = "ACCUTANE" if substr(medicationname,1,8)=="ACCUTANE"
           
**
* forget this one as it is generic and something of a mess (MD) -- revisit
replace   shortnam = "HYCD/APAP" if substr(medicationname,1,9)=="HYCD/APAP"
replace   shortnam = "HYCD/APAP" if medicationname=="HYDROC/APAP"
replace   shortnam = "HYCD/APAP" if medicationname=="HYDROCO/APAP"
replace   shortnam = "HYCD/APAP" if medicationname=="HYDROCOD/APAP"
replace   shortnam = "HYCD/APAP" if medicationname=="HYDROCODONE APAP"
replace   shortnam = "HYCD/APAP" if medicationname=="HYDROCODONE-APAP"
replace   shortnam = "HYCD/APAP" if medicationname=="HYDROCODONE/APAP"
replace   shortnam = "HYCD/APAP" if medicationname=="APAP/HYDROCODONE"
replace   shortnam = "HYCD/APAP" if substr(medicationname,1,27)=="APAP/HYDROCODONE BITARTRATE"
**

* no brand or generic PARICALCITOL in meps
replace   shortnam = "ZEMPLAR" if substr(medicationname,1,7)=="ZEMPLAR"             
          
* no generic Modafinil in meps
replace   shortnam = "PROVIGIL" if substr(medicationname,1,8)=="PROVIGIL"

* no generic Trastuzumab in meps
replace   shortnam = "HERCEPTIN" if substr(medicationname,1,9)=="HERCEPTIN"           
 
* this is a generic
replace   shortnam = "PAROXETINE" if substr(medicationname,1,10)=="PAROXETINE"
        
** DRUGS 141-150
 
* 12 rx with generic name (assume that if lamivudine alone, it is epivir)
replace   shortnam = "EPIVIR" if substr(medicationname,1,6)=="EPIVIR"  
replace   shortnam = "EPIVIR" if medicationname=="LAMIVUDINE"          

* 3 rx with generic name
replace   shortnam = "MAXALT" if substr(medicationname,1,6)=="MAXALT"           
replace   shortnam = "MAXALT" if substr(medicationname,1,11)=="RIZATRIPTAN"
            
* other brand and generic TESTOSTERONE on the mkt
replace   shortnam = "ANDROGEL" if substr(medicationname,1,8)=="ANDROGEL"
            
* other brand or generic NIACIN on the mkt
replace   shortnam = "NIASPAN" if substr(medicationname,1,7)=="NIASPAN"
         
* no generic Ziprasidone in meps   
replace   shortnam = "GEODON" if substr(medicationname,1,6)=="GEODON"
          
* this is a generic 
replace   shortnam = "FLUOXETINE" if substr(medicationname,1,9)=="FLUOXETIN" & medicationname~="FLUOXETINE (PROZAC)"
             
* no generic Peginterferon alfa-2a in meps
replace   shortnam = "PEGASYS" if substr(medicationname,1,7)=="PEGASYS"
             
* 15 rx with generic name
replace   shortnam = "ATACAND" if substr(medicationname,1,7)=="ATACAND"
replace   shortnam = "ATACAND" if substr(medicationname,1,11)=="CANDESARTAN"           

* generic Fosinopril on the mkt, late 2003
replace   shortnam = "MONOPRIL" if substr(medicationname,1,8)=="MONOPRIL"
   
* no generic Levalbuterol in meps
replace   shortnam = "XOPENEX" if substr(medicationname,1,7)=="XOPENEX"

** DRUGS 151-160
 
* no generic Olopatadine in meps
replace   shortnam = "PATANOL" if substr(medicationname,1,7)=="PATANOL"            
      
* other brand (ultram) or generic Tramadol on the mkt      
replace   shortnam = "ULTRACET" if substr(medicationname,1,8)=="ULTRACET"
            
* other brand (alavert) or generic Loratadine on the mkt
replace   shortnam = "CLARITIN" if substr(medicationname,1,8)=="CLARITIN"
  
* 12 rx with generic name
replace   shortnam = "AMARYL" if substr(medicationname,1,6)=="AMARYL"
replace   shortnam = "AMARYL" if substr(medicationname,1,11)=="GLIMEPIRIDE"           
            
* other brand (SYNTHROID) or generic Levothyroxine on the mkt
replace   shortnam = "LEVOXYL" if substr(medicationname,1,7)=="LEVOXYL"
              
* no generic Fentanyl in meps
replace   shortnam = "ACTIQ" if substr(medicationname,1,5)=="ACTIQ"
        
* other brand or generic ESTROGEN on the mkt    
replace   shortnam = "PREMPRO" if substr(medicationname,1,7)=="PREMPRO"
            
* no generic Bicalutamide in meps
replace   shortnam = "CASODEX" if substr(medicationname,1,7)=="CASODEX"
            
* no generic Levetiracetam in meps
replace   shortnam = "KEPPRA" if substr(medicationname,1,6)=="KEPPRA"

* 12 rx with generic name
replace   shortnam = "VIRACEPT" if substr(medicationname,1,8)=="VIRACEPT"
replace   shortnam = "VIRACEPT" if substr(medicationname,1,10)=="NELFINAVIR"

** DRUGS 161-170            
  
* no generic Adalimumab in meps
replace   shortnam = "HUMIRA" if substr(medicationname,1,6)=="HUMIRA"           
     
* spelling error; this is a generic  
replace   shortnam = "DILTIAZEM" if substr(medicationname,1,9)=="DILTIAZEM"
replace   shortnam = "DILTIAZEM" if medicationname=="DILTIAZ ER(CD)"
replace   shortnam = "DILTIAZEM" if medicationname=="DILITIAZEM"
    
* no brand or generic Palivizumab in meps     
replace   shortnam = "SYNAGIS" if substr(medicationname,1,7)=="SYNAGIS"
      
* no generic Pimecrolimus in meps       
replace   shortnam = "ELIDEL" if substr(medicationname,1,6)=="ELIDEL"
 
* other brand (oxycodone) and generic Acetaminophen/Oxycodone on the mkt
replace   shortnam = "PERCOCET" if substr(medicationname,1,8)=="PERCOCET"           
       
* generic Mirtazapine on the mkt in 2003      
replace   shortnam = "REMERON" if substr(medicationname,1,7)=="REMERON"
 
* spelling error; other brand and generic insulin on the mkt         
replace   shortnam = "NOVOLIN" if substr(medicationname,1,7)=="NOVOLIN"
replace   shortnam = "NOVOLIN" if medicationname=="INSULIN (NOVOLIN)"
replace   shortnam = "NOVOLIN" if medicationname=="INSULIN NOVOLIN"
replace   shortnam = "NOVOLIN" if medicationname=="INSULIN, NOVOLIN N"             

* no generic Moxifloxacin in meps
replace   shortnam = "AVELOX" if substr(medicationname,1,6)=="AVELOX"
      
* this is a generic (careful not to include combo)   
replace   shortnam = "ALBUTEROL" if substr(medicationname,1,9)=="ALBUTEROL" & medicationname~="ALBUTEROL/IPRATROPIUM"
          
* generic Brimonidine on the mkt in late 2003
replace   shortnam = "ALPHAGAN" if substr(medicationname,1,8)=="ALPHAGAN"


** DRUGS 171-180 
  
* no generic Calcitonin in meps
replace   shortnam = "MIACALCIN" if substr(medicationname,1,9)=="MIACALCIN"        
    
* 117 rx with generic name (off patent 2004); assume that "felodipine" is not combo felodipine/enalapril         
replace   shortnam = "PLENDIL" if substr(medicationname,1,7)=="PLENDIL"
replace   shortnam = "PLENDIL" if substr(medicationname,1,10)=="FELODIPINE"  

* no generic Zolmitriptan in meps
replace   shortnam = "ZOMIG" if substr(medicationname,1,5)=="ZOMIG"             
            
* no brand or generic Varicella (Chickenpox) Vaccine in meps
replace   shortnam = "VARIVAX" if substr(medicationname,1,7)=="VARIVAX"

* spelling error; too few obs; other brand and generic Ibuprofen on the mkt
replace   shortnam = "ADVIL" if substr(medicationname,1,5)=="ADVIL"              
replace   shortnam = "ADVIL" if medicationname=="CHILD ADVIL"
      
* other brand and generic Propranolol on the mkt
replace   shortnam = "INDERAL" if substr(medicationname,1,7)=="INDERAL"
 
* no brand or generic Octreotide in meps
replace   shortnam = "SANDOSTATIN" if substr(medicationname,1,11)=="SANDOSTATIN"        
  
* no generic Capecitabine in meps
replace   shortnam = "XELODA" if substr(medicationname,1,6)=="XELODA"           
          
* other brand and generic Estrogen/Progestin on the mkt  
replace   shortnam = "YASMIN" if substr(medicationname,1,6)=="YASMIN"

* no generic Anastrozole in meps
replace   shortnam = "ARIMIDEX" if substr(medicationname,1,8)=="ARIMIDEX"          

** DRUGS 181-190 

* other brand or generic Lidocaine on the mkt
replace   shortnam = "LIDODERM" if substr(medicationname,1,8)=="LIDODERM"            
      
* 5 rx with generic name        
replace   shortnam = "ZERIT" if substr(medicationname,1,5)=="ZERIT"
replace   shortnam = "ZERIT" if medicationname=="STAVUDINE"      
   
* this is a generic
replace   shortnam = "NIFEDIPINE" if substr(medicationname,1,10)=="NIFEDIPINE"
   
* no generic Sevelamer in meps      
replace   shortnam = "RENAGEL" if substr(medicationname,1,7)=="RENAGEL"
     
* other brand or generic Diltiazem on the mkt       
replace   shortnam = "CARTIA" if substr(medicationname,1,6)=="CARTIA"
  
* 2 rx with generic name           
replace   shortnam = "AVALIDE" if substr(medicationname,1,7)=="AVALIDE"
replace   shortnam = "AVALIDE" if medicationname=="HCTZ/IRBESARTAN"              

* no brand or generic Interferon beta-1a Subcutaneous Injection in meps
replace   shortnam = "REBIF" if substr(medicationname,1,5)=="REBIF"
       
* spelling error; other brand or generic MEDROXYPROGESTERONE on the mkt
replace   shortnam = "DEPO-PROVERA" if substr(medicationname,1,12)=="DEPO-PROVERA"
replace   shortnam = "DEPO-PROVERA" if substr(medicationname,1,12)=="DEPO PROVERA"      
        
* no generic Leflunomide in meps
replace   shortnam = "ARAVA" if substr(medicationname,1,5)=="ARAVA"
 
* other brand or generic Ipratropium on the mkt          
replace   shortnam = "ATROVENT" if substr(medicationname,1,8)=="ATROVENT"

** DRUGS 191-200

* other brand or generic Clonidine on the mkt
replace   shortnam = "CATAPRES" if substr(medicationname,1,8)=="CATAPRES"          
      
* 7 rx with generic name       
replace   shortnam = "COSOPT" if substr(medicationname,1,6)=="COSOPT"
replace   shortnam = "COSOPT" if medicationname=="DORZOLAMIDE/TIMOLOL"              

* no generic Famciclovir in meps
replace   shortnam = "FAMVIR" if substr(medicationname,1,6)=="FAMVIR"
          
* other brand and generic Cyclosporine on the mkt  
replace   shortnam = "NEORAL" if substr(medicationname,1,6)=="NEORAL"
replace   shortnam = "NEORAL" if medicationname=="CYCLOSPORINE (NEORAL)"             

***
* no brand or generic Hyalin (not sure if this is the generic name) on the mkt-- revisit
replace   shortnam = "SYNVISC" if substr(medicationname,1,7)=="SYNVISC"
***   
          
* other brand or generic Ranitidine on the mkt
replace   shortnam = "ZANTAC" if substr(medicationname,1,6)=="ZANTAC"
            
* no brand or generic Thalidomide in meps
replace   shortnam = "THALOMID" if substr(medicationname,1,8)=="THALOMID"
            
* other brand or generic DESMOPRESSIN on the mkt
replace   shortnam = "DDAVP" if substr(medicationname,1,5)=="DDAVP"
            
* other brand and generic METROMIDOL on the mkt
replace   shortnam = "METROGEL" if substr(medicationname,1,8)=="METROGEL"
      
* this is a generic      
replace   shortnam = "MORPHINE" if substr(medicationname,1,8)=="MORPHINE"

** DRUGS 201-210

* other brand or generic Diltiazem on the mkt
replace   shortnam = "TIAZAC" if substr(medicationname,1,6)=="TIAZAC"             
       
* no generic Pramipexole in meps
replace   shortnam = "MIRAPEX" if substr(medicationname,1,7)=="MIRAPEX"     
          
* no generic Clindamycin/BENZOYL PEROXIDE in meps
replace   shortnam = "BENZACLIN" if substr(medicationname,1,9)=="BENZACLIN"
          
* other brand or generic Mupirocin on the mkt, late 2003 
replace   shortnam = "BACTROBAN" if substr(medicationname,1,9)=="BACTROBAN"
         
* other brand and generic INSULIN on the mkt
replace   shortnam = "NOVOLOG" if substr(medicationname,1,7)=="NOVOLOG"
      
* no generic Rivastigmine in meps    
replace   shortnam = "EXELON" if substr(medicationname,1,6)=="EXELON"
     
* no generic Dolasetron in meps       
replace   shortnam = "ANZEMET" if substr(medicationname,1,7)=="ANZEMET"
  
* no generic Imiquimod in meps
replace   shortnam = "ALDARA" if substr(medicationname,1,6)=="ALDARA"           
   
* no brand or generic Temozolomide in meps
replace   shortnam = "TEMODAR" if substr(medicationname,1,7)=="TEMODAR"          
             
* no generic FOLLITROPIN in meps
replace   shortnam = "GONAL" if substr(medicationname,1,5)=="GONAL"


** DRUGS 211-220

* 4 rx with generic name
replace   shortnam = "PLETAL" if substr(medicationname,1,6)=="PLETAL"              
replace   shortnam = "PLETAL" if substr(medicationname,1,10)=="CILOSTAZOL"            
 
* other brand (zymar) or generic Gatifloxacin on the mkt
replace   shortnam = "TEQUIN" if substr(medicationname,1,6)=="TEQUIN"
       
* no generic Influenza Vaccine in meps     
replace   shortnam = "FLUVIRIN" if substr(medicationname,1,8)=="FLUVIRIN"
            
* no brand or generic Goserelin in meps
replace   shortnam = "ZOLADEX" if substr(medicationname,1,7)=="ZOLADEX"
        
* this is a generic, no brand or generic Measles, Mumps, and Rubella Vaccines in meps    
replace   shortnam = "M-M-R" if substr(medicationname,1,5)=="M-M-R"
           
* no brand or generic VERTEPORFIN in meps
replace   shortnam = "VISUDYNE" if substr(medicationname,1,8)=="VISUDYNE"

* other brand and generic estrogent/ Methyltestosterone on the mkt
replace   shortnam = "ESTRATEST" if substr(medicationname,1,9)=="ESTRATEST"         

* generic NEFAZODONE on the mkt late 2003
replace   shortnam = "SERZONE" if substr(medicationname,1,7)=="SERZONE"
         
* 1 rx with generic name
replace   shortnam = "DOVONEX" if substr(medicationname,1,7)=="DOVONEX"
replace   shortnam = "DOVONEX" if substr(medicationname,1,13)=="CALCIPOTRIENE"         

* no brand or generic SOMATROPIN in meps
replace   shortnam = "GENOTROPIN" if substr(medicationname,1,10)=="GENOTROPIN"

** DRUGS 221-230

***
* this is a generic (pat includes combo CARBIDOPA/LEVODOPA; combo is only obs in meps) -- revisit
replace   shortnam = "CARBIDOPA" if substr(medicationname,1,9)=="CARBIDOPA"  
***   
   
* 10 rx with generic name 
replace   shortnam = "VIRAMUNE" if substr(medicationname,1,8)=="VIRAMUNE"           
replace   shortnam = "VIRAMUNE" if substr(medicationname,1,10)=="NEVIRAPINE"   

* other brand and generic Tobramycin on the mkt
replace   shortnam = "TOBRADEX" if substr(medicationname,1,8)=="TOBRADEX"         
   
* no generic Abacavir in meps         
replace   shortnam = "ZIAGEN" if substr(medicationname,1,6)=="ZIAGEN"
   
* 3 rx with generic name 
replace   shortnam = "ARTHROTEC" if substr(medicationname,1,9)=="ARTHROTEC"        
replace   shortnam = "ARTHROTEC" if medicationname=="DICLOFENAC NA/MISOPROSTOL"

* no generic Itraconazole in meps
replace   shortnam = "SPORANOX" if substr(medicationname,1,8)=="SPORANOX"           
         
* no combo generic METFORMIN/ROSIGLITAZONE in meps 
replace   shortnam = "AVANDAMET" if substr(medicationname,1,9)=="AVANDAMET"
           
* 1 rx with generic name 
replace   shortnam = "LUMIGAN" if substr(medicationname,1,7)=="LUMIGAN"
replace   shortnam = "LUMIGAN" if substr(medicationname,1,11)=="BIMATOPROST"            

* no brand or generic IRON SUCROSE in meps
replace   shortnam = "VENOFER" if substr(medicationname,1,7)=="VENOFER"
            
* spelling error; this is a generic
replace   shortnam = "WARFARIN" if substr(medicationname,1,8)=="WARFARIN" & medicationname~="WARFARIN (COUMADIN)"
replace   shortnam = "WARFARIN" if medicationname=="WARFIN SODIUM"

** DRUGS 231-240
  
* no generic Colesevelam in meps
replace   shortnam = "WELCHOL" if substr(medicationname,1,7)=="WELCHOL"           
          
* this is a generic
replace   shortnam = "CEFUROXIME" if substr(medicationname,1,10)=="CEFUROXIME"
           
* no generic Adapalene in meps
replace   shortnam = "DIFFERIN" if substr(medicationname,1,8)=="DIFFERIN"
 
* no generic Tegaserod in meps
replace   shortnam = "ZELNORM" if substr(medicationname,1,7)=="ZELNORM"           
           
* other brand (furadantin) or generic NITROFURANTOIN on the mkt
replace   shortnam = "MACROBID" if substr(medicationname,1,8)=="MACROBID"
           
* no generic Isotretinoin in meps
replace   shortnam = "AMNESTEEM" if substr(medicationname,1,9)=="AMNESTEEM"
          
* no generic CHLORPHENIRAMINE POLISTIREX/HYDROCODONE POLISTIREX in meps
replace   shortnam = "TUSSIONEX" if substr(medicationname,1,9)=="TUSSIONEX"
        
* spelling error; this is a generic
replace   shortnam = "LOVASTATIN" if substr(medicationname,1,10)=="LOVASTATIN"
replace   shortnam = "LOVASTATIN" if medicationname=="LOVASTATI"
      
* other brand or generic DILTIAZEM on the mkt 
replace   shortnam = "CARDIZEM" if substr(medicationname,1,8)=="CARDIZEM"
   
* no brand or generic Granisetron in meps
replace   shortnam = "KYTRIL" if substr(medicationname,1,6)=="KYTRIL"

** DRUGS 241-250           
  
* this is a generic
replace   shortnam = "CLINDAMYCIN" if substr(medicationname,1,11)=="CLINDAMYCIN"       
         
* this is a generic
replace   shortnam = "MINOCYCLINE" if substr(medicationname,1,11)=="MINOCYCLINE"
         
* this is a generic -- include all types of potassium, even those not in pat's list? -- revisit
replace   shortnam = "POTASSIUM" if substr(medicationname,1,9)=="POTASSIUM"
            
* no brand or generic Interferon Alfa-2a and Alfa-2b Injection in meps
replace   shortnam = "INTRON" if substr(medicationname,1,6)=="INTRON"
          
* no generic Ceftriaxone in meps
replace   shortnam = "ROCEPHIN" if substr(medicationname,1,8)=="ROCEPHIN"
   
****
* what is generic centrum? -- revisit
replace   shortnam = "CENTRUM" if substr(medicationname,1,7)=="CENTRUM"          
****          
 
* no brand or generic Galantamine in meps
replace   shortnam = "RAZADYNE" if substr(medicationname,1,8)=="RAZADYNE"
           
* other brand (CARBATROL) or generic Carbamazepine on the mkt
replace   shortnam = "TEGRETOL" if substr(medicationname,1,8)=="TEGRETOL"
        
* no generic FOLLITROPIN in meps
replace   shortnam = "FOLLISTIM" if substr(medicationname,1,9)=="FOLLISTIM"
           
* other brand or generic Phenytoin on the mkt
replace   shortnam = "DILANTIN" if substr(medicationname,1,8)=="DILANTIN"

** DRUGS 251-260  

* this is a generic
replace   shortnam = "VERAPAMIL" if substr(medicationname,1,9)=="VERAPAMIL"          
        
* other brand and generic GUAIFENESIN on the mkt
replace   shortnam = "ROBITUSSIN" if substr(medicationname,1,10)=="ROBITUSSIN"
            
* other brand or generic Alprazolam on the mkt
replace   shortnam = "XANAX" if substr(medicationname,1,5)=="XANAX"
         
* this is a generic; careful not to include the combo
replace   shortnam = "AMOXICILLIN" if substr(medicationname,1,11)=="AMOXICILLIN" & substr(medicationname,1,23)~="AMOXICILLIN/CLAVULANATE" 

**
* this is a generic; include all combos like pat? revisit
replace   shortnam = "PROMETHAZINE" if substr(medicationname,1,12)=="PROMETHAZINE"
replace   shortnam = "PROMETHAZINE" if substr(medicationname,1,29)=="DEXTROMETHORPHAN/PROMETHAZINE" 
replace   shortnam = "PROMETHAZINE" if substr(medicationname,1,31)=="MEPERIDINE HCL/PROMETHAZINE HCL"
replace   shortnam = "PROMETHAZINE" if substr(medicationname,1,20)=="CODEINE-PROMETHAZINE"
replace   shortnam = "PROMETHAZINE" if substr(medicationname,1,20)=="CODEINE/PROMETHAZINE"
**        

* this is a generic
replace   shortnam = "TAMOXIFEN" if substr(medicationname,1,9)=="TAMOXIFEN"
          
* no brand or generic Interferon Gamma-1b Injection in meps
replace   shortnam = "ACTIMMUNE" if substr(medicationname,1,9)=="ACTIMMUNE"

* no generic Oseltamivir in meps            
replace   shortnam = "TAMIFLU" if substr(medicationname,1,7)=="TAMIFLU"
          
* no brand or generic Dornase Alfa in meps 
replace   shortnam = "PULMOZYME" if substr(medicationname,1,9)=="PULMOZYME"
              
* other brand (loprox) or generic Ciclopirox on the mkt
replace   shortnam = "PENLAC" if substr(medicationname,1,6)=="PENLAC"

** DRUGS 261-270
 
* other brand and generic Estrogen and Progestin 
replace   shortnam = "APRI" if substr(medicationname,1,4)=="APRI"            
            
* no generic Repaglinide in meps
replace   shortnam = "PRANDIN" if substr(medicationname,1,7)=="PRANDIN"
         
* this is a generic
replace   shortnam = "CEPHALEXIN" if substr(medicationname,1,10)=="CEPHALEXIN"
           
* other brand (OPTIVAR) or generic Azelastine on the mkt 
replace   shortnam = "ASTELIN" if substr(medicationname,1,7)=="ASTELIN"
        
* other brand and generic Ibuprofen on the mkt   
replace   shortnam = "MOTRIN" if substr(medicationname,1,6)=="MOTRIN"
replace   shortnam = "MOTRIN" if medicationname=="IBUPROFEN (MOTRIN)"    
  
* other brand and generic TRIAMCINOLONE on the mkt
replace   shortnam = "AZMACORT" if substr(medicationname,1,8)=="AZMACORT"
        
* other brand (proscar) or generic FINASTERIDE on the mkt
replace   shortnam = "PROPECIA" if substr(medicationname,1,8)=="PROPECIA"
             
* no generic AMOXICILLIN/CLARITHROMYCIN/LANSOPRAZOLE in meps
replace   shortnam = "PREVPAC" if substr(medicationname,1,7)=="PREVPAC"

* 2 rx with generic name
replace   shortnam = "AGGRENOX" if substr(medicationname,1,8)=="AGGRENOX"
replace   shortnam = "AGGRENOX" if medicationname=="ASPIRIN/DIPYRIDAMOLE"         

* no generic Telmisartan in meps
replace   shortnam = "MICARDIS" if substr(medicationname,1,8)=="MICARDIS"

** DRUGS 271-280

* other brand and generic Estrogen and Progestin on the mkt
replace   shortnam = "MICROGESTIN" if substr(medicationname,1,11)=="MICROGESTIN"       
   
* this is a generic
replace   shortnam = "IBUPROFEN" if substr(medicationname,1,9)=="IBUPROFEN"
    
* this is a generic
replace   shortnam = "TIZANIDINE" if substr(medicationname,1,10)=="TIZANIDINE"     
            
* no generic Olmesartan in meps
replace   shortnam = "BENICAR" if substr(medicationname,1,7)=="BENICAR"
           
* no brand rx in meps, but generic Tobramycin on the mkt
replace   shortnam = "TOBI" if substr(medicationname,1,4)=="TOBI"
            
* other brand and generic RIBAVIRIN on the mkt
replace   shortnam = "COPEGUS" if substr(medicationname,1,7)=="COPEGUS"
          
* no generic Sirolimus in meps
replace   shortnam = "RAPAMUNE" if substr(medicationname,1,8)=="RAPAMUNE"

* no brand and generic SODIUM FERRIC GLUCONATE COMPLEX in meps          
replace   shortnam = "FERRLECIT" if substr(medicationname,1,9)=="FERRLECIT"
      
* no generic Orlistat in meps 
replace   shortnam = "XENICAL" if substr(medicationname,1,7)=="XENICAL"
       
* other brand or generic Famotidine on the mkt    
replace   shortnam = "PEPCID" if substr(medicationname,1,6)=="PEPCID"

** DRUGS 281-290

* other brand and generic Pseudoephedrine on the mkt
replace   shortnam = "SUDAFED" if substr(medicationname,1,7)=="SUDAFED"             
 
** 
* spelling error; this is a generic; include all combos like pat? -- revisit   
replace   shortnam = "SPIRONOLACTONE" if substr(medicationname,1,14)=="SPIRONOLACTONE"
replace   shortnam = "SPIRONOLACTONE" if medicationname=="HCTZ/SPIRONOLACTONE"          
replace   shortnam = "SPIRONOLACTONE" if medicationname=="SPIRONO/HCTZ"
replace   shortnam = "SPIRONOLACTONE" if medicationname=="SPIRONOLAC"
replace   shortnam = "SPIRONOLACTONE" if medicationname=="SPIRONOLACT"
replace   shortnam = "SPIRONOLACTONE" if medicationname=="SPIRONOLACT/HCTZ"
replace   shortnam = "SPIRONOLACTONE" if medicationname=="SPIRONOLACTO"
**

* no brand or generic SOMATROPIN in meps
replace   shortnam = "HUMATROPE" if substr(medicationname,1,9)=="HUMATROPE"
      
* no generic Didanosine in meps      
replace   shortnam = "VIDEX" if substr(medicationname,1,5)=="VIDEX"
 
* no generic POLYETHYLENE GLYCOL 3350 in meps
replace   shortnam = "MIRALAX" if substr(medicationname,1,7)=="MIRALAX"          
        
* spelling error; this is a generic
replace   shortnam = "HYDROXYZINE" if substr(medicationname,1,11)=="HYDROXYZINE"
replace   shortnam = "HYDROXYZINE" if medicationname=="HYDROXYZ HCL"
replace   shortnam = "HYDROXYZINE" if medicationname=="HYDROXYZ PAM"            

* other brand (combivent) or generic ALBUTEROL/IPRATROPIUM on the mkt
replace   shortnam = "DUONEB" if substr(medicationname,1,6)=="DUONEB"
           
* no generic Zaleplon in meps
replace   shortnam = "SONATA" if substr(medicationname,1,6)=="SONATA"
       
* this is a generic
replace   shortnam = "AMPHETAMINE" if substr(medicationname,1,11)=="AMPHETAMINE"
        
* spelling error; this is a generic  
replace   shortnam = "RANITIDINE" if substr(medicationname,1,10)=="RANITIDINE"
replace   shortnam = "RANITIDINE" if medicationname=="RANTIDINE"

** DRUGS 291-300

* other brand and generic nifedipine on mkt
replace   shortnam = "NIFEDIAC" if substr(medicationname,1,8)=="NIFEDIAC"            
            
* no generic Linezolid in meps
replace   shortnam = "ZYVOX" if substr(medicationname,1,5)=="ZYVOX"
            
* other brand and generic Estrogen and Progestin
replace   shortnam = "NECON" if substr(medicationname,1,5)=="NECON"
        
* no generic Zonisamide in meps
replace   shortnam = "ZONEGRAN" if substr(medicationname,1,8)=="ZONEGRAN"
         
* this is a generic
replace   shortnam = "ATENOLOL" if substr(medicationname,1,8)=="ATENOLOL"
          
* other brand or generic Acyclovir on the mkt
replace   shortnam = "ZOVIRAX" if substr(medicationname,1,7)=="ZOVIRAX"
           
* other brand (canasa) or generic MESALAMINE on the mkt
replace   shortnam = "PENTASA" if substr(medicationname,1,7)=="PENTASA"
         
* this is a generic   
replace   shortnam = "NAPROXEN" if substr(medicationname,1,8)=="NAPROXEN"
            
* no brand or generic Doxorubicin in meps
replace   shortnam = "DOXIL" if substr(medicationname,1,5)=="DOXIL"

* other brand and generic Epinephrine on the mkt            
replace   shortnam = "EPIPEN" if substr(medicationname,1,6)=="EPIPEN"

** DRUGS 301-310
 
* no brand in meps
replace   shortnam = "LISTERINE" if substr(medicationname,1,9)=="LISTERINE"         
 
* this is a generic
replace   shortnam = "MIRTAZAPINE" if substr(medicationname,1,11)=="MIRTAZAPINE"       
              
* other brand and generic Estrogen and Progestin
replace   shortnam = "AVIANE" if substr(medicationname,1,6)=="AVIANE"
             
* no generic Ofloxacin in meps
replace   shortnam = "FLOXIN" if substr(medicationname,1,6)=="FLOXIN"
            
* no brand in meps; generic Naproxen on the mkt 
replace   shortnam = "ALEVE" if substr(medicationname,1,5)=="ALEVE"

* other brand (VAGIFEM) and generic ESTRADIOL on the mkt
replace   shortnam = "VIVELLE" if substr(medicationname,1,7)=="VIVELLE"             
             
* no generic Nateglinide in meps
replace   shortnam = "STARLIX" if substr(medicationname,1,7)=="STARLIX"

* spelling error; this is a generic
replace   shortnam = "GEMFIBROZIL" if substr(medicationname,1,11)=="GEMFIBROZIL"
replace   shortnam = "GEMFIBROZIL" if substr(medicationname,1,9)=="GEMFIBROZ"             

* other brand (concerta) and generic Methylphenidate on the mkt
replace   shortnam = "RITALIN" if substr(medicationname,1,7)=="RITALIN"
   
* 8 rx with generic name        
replace   shortnam = "MARINOL" if substr(medicationname,1,7)=="MARINOL"
replace   shortnam = "MARINOL" if substr(medicationname,1,10)=="DRONABINOL"

** DRUGS 311-320
          
* other brand and generic Diphenhydramine on the mkt
replace   shortnam = "BENADRYL" if substr(medicationname,1,8)=="BENADRYL"
           
* 5 rx with generic  
replace   shortnam = "ACCOLATE" if substr(medicationname,1,8)=="ACCOLATE"
replace   shortnam = "ACCOLATE" if substr(medicationname,1,11)=="ZAFIRLUKAST"
              
* brand not in meps
replace   shortnam = "VICKS" if substr(medicationname,1,5)=="VICKS"
            
* other brand (cipro) and generic CIPROFLOXACIN on the mkt
replace   shortnam = "CILOXAN" if substr(medicationname,1,7)=="CILOXAN"
          
* no generic MERCAPTOPURINE in meps
replace   shortnam = "PURINETHOL" if substr(medicationname,1,10)=="PURINETHOL"
            
* other brand (prograf) with same generic name TACROLIMUS
replace   shortnam = "PROTOPIC" if substr(medicationname,1,8)=="PROTOPIC"
        
* spelling error; this is a generic; use all combos like pat-- might revisit
replace   shortnam = "PROPOXYPHENE" if substr(medicationname,1,12)=="PROPOXYPHENE"
* many variants -- 'propo' will pick up most of them
replace   shortnam = "PROPOXYPHENE" if substr(medicationname,1,5)=="PROPO"
replace   shortnam = "PROPOXYPHENE" if substr(medicationname,1,17)=="APAP/PROPOXYPHENE"
replace   shortnam = "PROPOXYPHENE" if medicationname=="ASPIRIN/CAFFEINE/PROPOXYPHENE"
  
* no generic Naratriptan in meps            
replace   shortnam = "AMERGE" if substr(medicationname,1,6)=="AMERGE"
            
* no brand or generic Anagrelide in meps
replace   shortnam = "AGRYLIN" if substr(medicationname,1,7)=="AGRYLIN"
               
* other brand (avita) and generic Tretinoin on the mkt
replace   shortnam = "RETIN" if substr(medicationname,1,5)=="RETIN"

** DRUGS 321-330
 
* other brand (prozac) or generic Fluoxetine on the mkt
replace   shortnam = "SARAFEM" if substr(medicationname,1,7)=="SARAFEM"            
        
* other brand and generic Progesterone on the mkt
replace   shortnam = "PROMETRIUM" if substr(medicationname,1,10)=="PROMETRIUM"
          
* no brand in meps; other generic Acetaminophen on the mkt
replace   shortnam = "EXCEDRIN" if substr(medicationname,1,8)=="EXCEDRIN"
              
* other brand and generic Verapamil on the mkt
replace   shortnam ="COVERA" if substr(medicationname,1,6)=="COVERA"
         
* no brand in meps; generic Clozapine on the mkt
replace   shortnam = "CLOZARIL" if substr(medicationname,1,8)=="CLOZARIL"
           
* no generic Gefitinib on the mkt 
replace   shortnam = "IRESSA" if substr(medicationname,1,6)=="IRESSA"

* no generic TAZAROTENE on the mkt             
replace   shortnam = "TAZORAC" if substr(medicationname,1,7)=="TAZORAC"
      
* other brand (penlac) or generic Ciclopirox on the mkt        
replace   shortnam = "LOPROX" if substr(medicationname,1,6)=="LOPROX"
         
* other brand or generic Nifedipine on the mkt
replace   shortnam = "NIFEDICAL" if substr(medicationname,1,9)=="NIFEDICAL"
 
* spelling error; this is a generic          
replace   shortnam = "LORAZEPAM" if substr(medicationname,1,9)=="LORAZEPAM"
replace   shortnam = "LORAZEPAM" if substr(medicationname,1,9)=="LORAZEPAN"

** DRUGS 331-340
  
* no brand in meps; other brand and generic Aspirin on the mkt
replace   shortnam = "BAYER" if substr(medicationname,1,5)=="BAYER"           
         
* this is a generic
replace   shortnam = "OXYCODONE" if substr(medicationname,1,9)=="OXYCODONE"
replace   shortnam = "OXYCODONE" if substr(medicationname,1,14)=="APAP/OXYCODONE"          

* this is a generic
replace   shortnam = "ALPRAZOLAM" if substr(medicationname,1,10)=="ALPRAZOLAM"
         
* this is a generic  
replace   shortnam = "GLYBURIDE" if substr(medicationname,1,9)=="GLYBURIDE"
        
* other brand and generic Albuterol on the mkt   
replace   shortnam = "PROVENTIL" if substr(medicationname,1,9)=="PROVENTIL"
          
* no generic Epirubicin in meps
replace   shortnam = "ELLENCE" if substr(medicationname,1,7)=="ELLENCE"
          
* this is a generic
replace   shortnam = "ENALAPRIL" if substr(medicationname,1,9)=="ENALAPRIL"
             
* no generic Terconazole in meps
replace   shortnam = "TERAZOL" if substr(medicationname,1,7)=="TERAZOL"
            
* no generic Letrozole in meps
replace   shortnam = "FEMARA" if substr(medicationname,1,6)=="FEMARA"
            
* other brand and generic Estrogen and Progestin
replace   shortnam = "LOESTRIN" if substr(medicationname,1,8)=="LOESTRIN"

** DRUGS 341-350
   
* no generic Hepatitis B vaccine in meps
replace   shortnam = "ENGERIX" if substr(medicationname,1,7)=="ENGERIX"          
          
* this is a generic
replace   shortnam = "NABUMETONE" if substr(medicationname,1,10)=="NABUMETONE"
         
* this is a generic 
replace   shortnam = "TRAMADOL" if substr(medicationname,1,8)=="TRAMADOL" & medicationname~="TRAMADOL (ULTRAM)" 
       
* no generic Ropinirole in meps     
replace   shortnam = "REQUIP" if substr(medicationname,1,6)=="REQUIP"

* no generic Indinavir in meps
replace   shortnam = "CRIXIVAN" if substr(medicationname,1,8)=="CRIXIVAN"
  
* spelling error; generic Potassium on the mkt
replace   shortnam = "KLOR-CON" if substr(medicationname,1,8)=="KLOR-CON"         
replace   shortnam = "KLOR-CON" if substr(medicationname,1,8)=="KLOR CON"         
  
****
* not sure what this is? not in databases
replace   shortnam = "HYALGAN" if substr(medicationname,1,7)=="HYALGAN"
****   
         
* no generic Teriparatide in meps 
replace   shortnam = "FORTEO" if substr(medicationname,1,6)=="FORTEO"
  
* no brand or generic Topotecan  in meps         
replace   shortnam = "HYCAMTIN" if substr(medicationname,1,8)=="HYCAMTIN"
         
* other brand and generic Estrogen and Progestin
replace   shortnam = "MIRCETTE" if substr(medicationname,1,8)=="MIRCETTE"

** DRUGS 351-360
 
* other brand (percocet) and generic Acetaminophen/Oxycodone on the mkt
replace   shortnam = "ENDOCET" if substr(medicationname,1,7)=="ENDOCET"           
          
* generic brand or Betamethasone on the mkt
replace   shortnam = "DIPROLENE" if substr(medicationname,1,9)=="DIPROLENE"
             
* no generic Sibutramine
replace   shortnam = "MERIDIA" if substr(medicationname,1,7)=="MERIDIA"
 
* spelling error; this is a generic
replace   shortnam = "HYDROCHLOROTHIAZIDE" if substr(medicationname,1,19)=="HYDROCHLOROTHIAZIDE"
replace   shortnam = "HYDROCHLOROTHIAZIDE" if substr(medicationname,1,12)=="HYDROCHLOROT"
replace   shortnam = "HYDROCHLOROTHIAZIDE" if medicationname=="HYDROCHLORTHIAZIDE"
   
* no brand or generic Pentosan
replace   shortnam = "ELMIRON" if substr(medicationname,1,7)=="ELMIRON"        
  
* spelling error; this is a generic
replace   shortnam = "CLOTRIMAZOLE" if substr(medicationname,1,12)=="CLOTRIMAZOLE"      
replace   shortnam = "CLOTRIMAZOLE" if substr(medicationname,1,7)=="CLOTRIM"
replace   shortnam = "CLOTRIMAZOLE" if medicationname=="BETAMETHASONE/CLOTRIMAZOLE"
       
* spelling error; other brand (VAGIFEM) and generic ESTRADIOL on the mkt
replace   shortnam = "CLIMARA" if substr(medicationname,1,7)=="CLIMARA"
replace   shortnam = "CLIMARA" if medicationname=="CONTRACT CLIMARA"
            
* no generic Travoprost in meps
replace   shortnam = "TRAVATAN" if substr(medicationname,1,8)=="TRAVATAN"

* no generic Atazanavir in meps             
replace   shortnam = "REYATAZ" if substr(medicationname,1,7)=="REYATAZ"
            
* other brand and generic Estrogen and Progestin on the mkt
replace   shortnam = "TRIVORA" if substr(medicationname,1,7)=="TRIVORA"

** DRUGS 361-370

* this is a generic
replace   shortnam = "MEGESTROL" if substr(medicationname,1,9)=="MEGESTROL"          
        
* no brand or generic Hepatitis B Vaccine in meps  
replace   shortnam = "RECOMBIVAX" if substr(medicationname,1,10)=="RECOMBIVAX"
       
* spelling errors; this is a generic
replace   shortnam = "TRIAMTERENE" if substr(medicationname,1,11)=="TRIAMTERENE"
replace   shortnam = "TRIAMTERENE" if substr(medicationname,1,6)=="TRIAMT"
replace   shortnam = "TRIAMTERENE" if medicationname=="HCTZ 50/TRIAMTERENE"
replace   shortnam = "TRIAMTERENE" if medicationname=="HCTZ/TRIAMTERENE"
           
* no brand or generic CABERGOLINE in meps
replace   shortnam = "DOSTINEX" if substr(medicationname,1,8)=="DOSTINEX"
              
* other brand or generic Estrogen and Progestin on the mkt
replace   shortnam = "OVCON" if substr(medicationname,1,5)=="OVCON"
  
* other brand or generic Lisinopril on the mkt         
replace   shortnam = "ZESTRIL" if substr(medicationname,1,7)=="ZESTRIL"
           
* no generic Ofloxacin in meps
replace   shortnam = "OCUFLOX" if substr(medicationname,1,7)=="OCUFLOX"
            
* other brand and generic Estrogen and Progestin on the mkt  
replace   shortnam = "ALESSE" if substr(medicationname,1,6)=="ALESSE"
             
* other brand and generic nifedipine on mkt
replace   shortnam = "ADALAT" if substr(medicationname,1,6)=="ADALAT"
        
* other brand (minocin) and generic Minocycline on the mkt     
replace   shortnam = "DYNACIN" if substr(medicationname,1,7)=="DYNACIN"

** DRUGS 371-380

* other brand and generic Estrogen and Progestin (Hormone Replacement Therapy) on the mkt
replace   shortnam = "FEMHRT" if substr(medicationname,1,6)=="FEMHRT"              
         
* other brand and generic estrogen on the mkt    
replace   shortnam = "ESTRACE" if substr(medicationname,1,7)=="ESTRACE"
        
* no brand or generic diphtheria, hepatitis B, pertussis (acellular), polio, and tetanus vaccine in meps   
replace   shortnam = "PEDIARIX" if substr(medicationname,1,8)=="PEDIARIX"
             
* other brand and generic Verapamil on the mkt
replace   shortnam = "VERELAN" if substr(medicationname,1,7)=="VERELAN"
        
* spelling error; this is a generic
replace   shortnam = "LOW-OGESTREL" if substr(medicationname,1,12)=="LOW-OGESTREL"
replace   shortnam = "LOW-OGESTREL" if substr(medicationname,1,12)=="LOW OGESTREL"           

* this is a generic
replace   shortnam = "TORSEMIDE" if substr(medicationname,1,9)=="TORSEMIDE"

* spelling error; this is a generic      
replace   shortnam = "ERYTHROMYCIN" if substr(medicationname,1,12)=="ERYTHROMYCIN"
replace   shortnam = "ERYTHROMYCIN" if substr(medicationname,1,8)=="ERYTHROM"

* other brand or generic NIACIN on the mkt
replace   shortnam = "ADVICOR" if substr(medicationname,1,7)=="ADVICOR"
             
* no generic Balsalazide in meps
replace   shortnam = "COLAZAL" if substr(medicationname,1,7)=="COLAZAL"
  
* other brand (mykrox) or generic Metolazone on the mkt
replace   shortnam = "ZAROXOLYN" if substr(medicationname,1,9)=="ZAROXOLYN"         

** DRUGS 381-390
            
* other brand or generic MOMETASONE on the mkt
replace   shortnam = "ELOCON" if substr(medicationname,1,6)=="ELOCON"
   
* spelling error; other brand and generic Morphine on the mkt      
replace   shortnam = "MS-CONTIN" if substr(medicationname,1,9)=="MS-CONTIN"
replace   shortnam = "MS-CONTIN" if substr(medicationname,1,9)=="MS CONTIN"       
       
* other brand and generic Doxycycline
replace   shortnam = "DORYX" if substr(medicationname,1,5)=="DORYX"

* no generic Acitretin in meps
replace   shortnam = "SORIATANE" if substr(medicationname,1,9)=="SORIATANE"
 
* no generic Valganciclovir in meps
replace   shortnam = "VALCYTE" if substr(medicationname,1,7)=="VALCYTE"           
            
* generic Ketorolac on the mkt 
replace   shortnam = "ACULAR" if substr(medicationname,1,6)=="ACULAR"
            
* generic Miconazole on the mkt
replace   shortnam = "MONISTAT" if substr(medicationname,1,8)=="MONISTAT"
           
* no brand or generic coagulation factor VII (rFVIIa)
replace   shortnam = "NOVOSEVEN" if substr(medicationname,1,9)=="NOVOSEVEN"
          
* other brand and generic nifedipine on mkt
replace   shortnam = "PROCARDIA" if substr(medicationname,1,9)=="PROCARDIA"

***            
* could be more matches -- revisit  (codeine/acetaminophen=codeine/apap?)
replace   shortnam = "APAP/CD" if substr(medicationname,1,7)=="APAP/CD"
replace   shortnam = "APAP/CD" if substr(medicationname,1,12)=="APAP/CODEINE"
****

** DRUGS 391-400

* this is a generic
replace   shortnam = "PHENYTOIN" if substr(medicationname,1,9)=="PHENYTOIN"     
             
* no brand in meps; other brand and generic Calcium Carbonate on the mkt      
replace   shortnam = "TUMS" if substr(medicationname,1,4)=="TUMS"
           
* no brand in meps
replace   shortnam = "OPTI-FREE" if substr(medicationname,1,9)=="OPTI-FREE"
           
* brand or other generic Carbamazepine on the mkt
replace   shortnam = "CARBATROL" if substr(medicationname,1,9)=="CARBATROL"
            
* spelling error; other brand (ultracet) or generic Tramadol on the mkt 
replace   shortnam = "ULTRAM" if substr(medicationname,1,6)=="ULTRAM"
replace   shortnam = "ULTRAM" if medicationname=="TRAMADOL (ULTRAM)"
             
* no generic Trandolapril in meps
replace   shortnam = "MAVIK" if substr(medicationname,1,5)=="MAVIK"

* other brand and generic Estrogen and Progestin (Hormone Replacement Therapy) in meps
replace   shortnam = "ACTIVELLA" if substr(medicationname,1,9)=="ACTIVELLA"
           
* no generic Entacapone in meps
replace   shortnam = "COMTAN" if substr(medicationname,1,6)=="COMTAN"
             
* no generic PIRBUTEROL ACETATE in meps
replace   shortnam = "MAXAIR" if substr(medicationname,1,6)=="MAXAIR"
             
* other brand and generic DESOGESTREL/ETHINYL ESTRADIOL in meps
replace   shortnam = "KARIVA" if substr(medicationname,1,6)=="KARIVA"

** DRUGS 401-410

* no generic Griseofulvin in meps
replace   shortnam = "GRIFULVIN" if substr(medicationname,1,9)=="GRIFULVIN"        
            
* generic Loperamide on the mkt
replace   shortnam = "IMODIUM" if substr(medicationname,1,7)=="IMODIUM"
          
* this is a generic
replace   shortnam = "FUROSEMIDE" if substr(medicationname,1,10)=="FUROSEMIDE" & medicationname~="FUROSEMIDE (LASIX)"
          
* other brand and generic Estrogen and Progestin on the mkt
replace   shortnam = "ESTROSTEP" if substr(medicationname,1,9)=="ESTROSTEP"
           
* other brand (concerta) and generic Methylphenidate on the mkt
replace   shortnam = "METADATE" if substr(medicationname,1,8)=="METADATE"
        
* no brand in meps; other brand and generic Aspirin on the mkt
replace   shortnam = "ALKA-SELTZER" if substr(medicationname,1,12)=="ALKA-SELTZER"
 
* no brand or generic Hepatitis B Vaccine in meps
replace   shortnam = "COMVAX" if substr(medicationname,1,6)=="COMVAX"             
            
* no generic Fulvestrant in meps
replace   shortnam = "FASLODEX" if substr(medicationname,1,8)=="FASLODEX"
            
* no brand or generic Polio Vaccine
replace   shortnam = "IPOL" if substr(medicationname,1,4)=="IPOL"
          
* no brand in meps
replace   shortnam = "NEUTROGENA" if substr(medicationname,1,10)=="NEUTROGENA"

** DRUGS 411-420
   
* no brand or generic Coagulation Factor IX in meps
replace   shortnam = "BENEFIX" if substr(medicationname,1,7)=="BENEFIX"        
          
* no brand in meps; other brand and generic NICOTINE POLACRILEX 
replace   shortnam = "NICORETTE" if substr(medicationname,1,9)=="NICORETTE"
           
* other brand and generic Betaxolol in meps
replace   shortnam = "BETOPTIC" if substr(medicationname,1,8)=="BETOPTIC"
             
* no brand or generic Ritonavir in meps
replace   shortnam = "NORVIR" if substr(medicationname,1,6)=="NORVIR"
           
* other brand or generic Diazepam in meps  
replace   shortnam = "VALIUM" if substr(medicationname,1,6)=="VALIUM"
            
* no generic Vardenafil in meps
replace   shortnam = "LEVITRA" if substr(medicationname,1,7)=="LEVITRA"
            
* this is a generic
replace   shortnam = "TIMOLOL" if substr(medicationname,1,7)=="TIMOLOL"
            
* other brand and generic Morphine on the mkt 
replace   shortnam = "KADIAN" if substr(medicationname,1,6)=="KADIAN"
           
* no generic Tiagabine in meps
replace   shortnam = "GABITRIL" if substr(medicationname,1,8)=="GABITRIL"
         
* this is a generic
replace   shortnam = "BUSPIRONE" if substr(medicationname,1,9)=="BUSPIRONE"

** DRUGS 421-430

* spelling error; this is a generic  
replace   shortnam = "ISOSORBIDE" if substr(medicationname,1,10)=="ISOSORBIDE"        
replace   shortnam = "ISOSORBIDE" if substr(medicationname,1,7)=="ISOSORB"

* no brand or generic LEVONORGESTREL in meps
replace   shortnam = "MIRENA" if substr(medicationname,1,6)=="MIRENA"
   
* no brand or generic SOMATROPIN in meps 
replace   shortnam = "SEROSTIM" if substr(medicationname,1,8)=="SEROSTIM" 
     
* this is a generic; not in meps
replace   shortnam = "PAMIDRONATE" if substr(medicationname,1,11)=="PAMIDRONATE"
           
* this is a generic
replace   shortnam = "NICOTINE" if substr(medicationname,1,8)=="NICOTINE"
    
* no brand in meps; other brand (canasa) or generic MESALAMINE on the mkt       
replace   shortnam = "ROWASA" if substr(medicationname,1,6)=="ROWASA"
            
* this is a generic
replace   shortnam = "QUININE" if substr(medicationname,1,7)=="QUININE"

* no brand or generic Anakinra in meps
replace   shortnam = "KINERET" if substr(medicationname,1,7)=="KINERET"             
            
* no generic Almotriptan in meps
replace   shortnam = "AXERT" if substr(medicationname,1,5)=="AXERT"
           
* no generic Halobetasol in meps
replace   shortnam = "ULTRAVATE" if substr(medicationname,1,9)=="ULTRAVATE"

** DRUGS 431-440

* this is a generic
replace   shortnam = "NITROGLYCERIN" if substr(medicationname,1,13)=="NITROGLYCERIN"      
            
* other brand (wellbutrin) or generic BUPROPION on the mkt
replace   shortnam = "ZYBAN" if substr(medicationname,1,5)=="ZYBAN"
             
* no generic Trandolapril/Verapamil in meps
replace   shortnam = "TARKA" if substr(medicationname,1,5)=="TARKA"
       
***
* spelling error; this is a generic; include all combos like pat?  revisit    
replace   shortnam = "NEOMYCIN" if substr(medicationname,1,8)=="NEOMYCIN"
replace   shortnam = "NEOMYCIN" if medicationname=="BACITRACIN/HC/NEOMYCIN/POLYMYXIN"
replace   shortnam = "NEOMYCIN" if medicationname=="BACITRACIN-NEO-POLY"
replace   shortnam = "NEOMYCIN" if medicationname=="GRAMICIDIN/NEOMYCIN/POLYMYXIN B"
replace   shortnam = "NEOMYCIN" if medicationname=="HC/NEOMYCIN/POLYMYXIN OTIC"
replace   shortnam = "NEOMYCIN" if medicationname=="HYDROCORTISONE/NEOMYCIN/POLYMYXIN B"
replace   shortnam = "NEOMYCIN" if medicationname=="HC/NEO SULF/POLYMYX OTIC SUSP"  
* not sure if should include these
*replace   shortnam = "NEOMYCIN" if medicationname=="DEXAMETHASONE/NEOMYCIN/POLYMIXIN"
*replace   shortnam = "NEOMYCIN" if medicationname=="DEXAMETHASONE/NEOMYCIN/POLYMYXIN"
*replace   shortnam = "NEOMYCIN" if medicationname=="DEXAMETHASONE/NEOMYCIN/POLYMYXIN (DROP-TAINER)"
***

* other brand and generic METHYLPREDNISOLONE on the mkt
replace   shortnam = "DEPO-MEDROL" if substr(medicationname,1,11)=="DEPO-MEDROL"
         
* no brand or generic Paclitaxel in meps     
replace   shortnam = "TAXOL" if substr(medicationname,1,5)=="TAXOL"
          
* other brand and generic Cyclosporine on the mkt
replace   shortnam = "SANDIMMUNE" if substr(medicationname,1,10)=="SANDIMMUNE"
          
* this is a generic
replace   shortnam = "ETODOLAC" if substr(medicationname,1,8)=="ETODOLAC" & medicationname~="ETODOLAC (LODINE)"
            
* no generic Rosuvastatin in meps
replace   shortnam = "CRESTOR" if substr(medicationname,1,7)=="CRESTOR"
     
* other brand or generic Acetaminophen/Hydrocodone on the mkt       
replace   shortnam = "VICODIN" if substr(medicationname,1,7)=="VICODIN"

** DRUGS 441-450
 
* this is a generic
replace   shortnam = "TRETINOIN" if substr(medicationname,1,9)=="TRETINOIN"         
         
* no brand in meps
replace   shortnam = "ONE-A-DAY" if substr(medicationname,1,9)=="ONE-A-DAY"

* 5 rx with generic
replace   shortnam = "FORADIL" if substr(medicationname,1,7)=="FORADIL"           
replace   shortnam = "FORADIL" if substr(medicationname,1,10)=="FORMOTEROL"           

* other brand or generic Clindamycin on the mkt
replace   shortnam = "CLEOCIN" if substr(medicationname,1,7)=="CLEOCIN"
          
* other brand or generic FLUNISOLIDE on the mkt
replace   shortnam = "AEROBID" if substr(medicationname,1,7)=="AEROBID"
         
* other brand Pneumococcal Polysaccharide Vaccine on the mkt 
replace   shortnam = "PNEUMOVAX" if substr(medicationname,1,9)=="PNEUMOVAX"
        
* generic Hydrocodone Bitartrate/Ibuprofen on the mkt, in 2003
replace   shortnam = "VICOPROFEN" if substr(medicationname,1,10)=="VICOPROFEN"
 
* spelling error; this is a generic
replace   shortnam = "IPRATROPIUM" if substr(medicationname,1,11)=="IPRATROPIUM"      
replace   shortnam = "IPRATROPIUM" if substr(medicationname,1,12)=="IPRATROPRIUM"  

* this is a generic
replace   shortnam = "CYCLOSPORINE" if substr(medicationname,1,12)=="CYCLOSPORINE" & medicationname~="CYCLOSPORINE (NEORAL)"       
            
* other brand and generic Digoxin on the mkt
replace   shortnam = "LANOXIN" if substr(medicationname,1,7)=="LANOXIN"

** DRUGS 451-460
            
* other brand or generic Lisinopril on the mkt
replace   shortnam = "PRINIVIL" if substr(medicationname,1,8)=="PRINIVIL"
          
* other brand and generic Estrogen and Progestin on the mkt
replace   shortnam = "TRIPHASIL" if substr(medicationname,1,9)=="TRIPHASIL"
           
* other brand or generic Sotalol on the mkt
replace   shortnam = "BETAPACE" if substr(medicationname,1,8)=="BETAPACE"
             
* generic Cefuroxime on the mkt
replace   shortnam = "CEFTIN" if substr(medicationname,1,6)=="CEFTIN"
    
* this is a generic
replace   shortnam = "CYCLOBENZAPRINE" if substr(medicationname,1,15)=="CYCLOBENZAPRINE"
         
* this is a generic
replace   shortnam = "PHENTERMINE" if substr(medicationname,1,11)=="PHENTERMINE"
                
* brand not in meps
replace   shortnam = "RENU" if substr(medicationname,1,4)=="RENU"
            
* other brand or generic PREDNISOLONE SODIUM PHOSPHATE  on the mkt
replace   shortnam = "ORAPRED" if substr(medicationname,1,7)=="ORAPRED"
            
* no generic Oxandrolone in meps
replace   shortnam = "OXANDRIN" if substr(medicationname,1,8)=="OXANDRIN"
             
* no brand or generic Sargramostim in meps
replace   shortnam = "LEUKINE" if substr(medicationname,1,7)=="LEUKINE"

** DRUGS 461-470
 
* this is a generic
replace   shortnam = "NYSTATIN" if substr(medicationname,1,8)=="NYSTATIN"           
           
* no generic Psyllium in meps
replace   shortnam = "METAMUCIL" if substr(medicationname,1,9)=="METAMUCIL"
             
* other brand or generic Clobetasol on the mkt   
replace   shortnam = "OLUX" if substr(medicationname,1,4)=="OLUX"
     
* this is a generic
replace   shortnam = "HYDROCORTISONE" if substr(medicationname,1,14)=="HYDROCORTISONE" & medicationname~="HYDROCORTISONE/NEOMYCIN/POLYMYXIN B" 
replace   shortnam = "HYDROCORTISONE" if medicationname=="CVS HYDROCORTISONE"
          
* no generic MITOXANTRONE in meps
replace   shortnam = "NOVANTRONE" if substr(medicationname,1,10)=="NOVANTRONE"
           
* this is a generic
replace   shortnam = "URSODIOL" if substr(medicationname,1,8)=="URSODIOL"
      
* this is a generic
replace   shortnam = "NITROFURANTOIN" if substr(medicationname,1,14)=="NITROFURANTOIN"
    
* no brand or generic Amifostine in meps          
replace   shortnam = "ETHYOL" if substr(medicationname,1,6)=="ETHYOL"
         
* generic MIDODRINE on the mkt, late 2003
replace   shortnam = "PROAMATINE" if substr(medicationname,1,10)=="PROAMATINE"
            
* 6 rx with generic
replace   shortnam = "DYNACIRC" if substr(medicationname,1,8)=="DYNACIRC"
replace   shortnam = "DYNACIRC" if substr(medicationname,1,10)=="ISRADIPINE"

** DRUGS 471-480

* this is a generic
replace   shortnam = "DICLOFENAC" if substr(medicationname,1,10)=="DICLOFENAC" & medicationname~="DICLOFENAC NA/MISOPROSTOL"         
replace   shortnam = "DICLOFENAC" if substr(medicationname,1,8)=="DICLOFEN" & medicationname~="DICLOFENAC NA/MISOPROSTOL"         

* no brand in meps
replace   shortnam = "PREPARATION" if substr(medicationname,1,11)=="PREPARATION"
           
* this is a generic
replace   shortnam = "CLOZAPINE" if substr(medicationname,1,9)=="CLOZAPINE"
   
* brand or generic Enalapril on the mkt         
replace   shortnam = "VASOTEC" if substr(medicationname,1,7)=="VASOTEC"
           
* this is a generic
replace   shortnam = "BACLOFEN" if substr(medicationname,1,8)=="BACLOFEN"
             
* other brand and generic Acetaminophen/Hydrocodone on the mkt
replace   shortnam = "LORTAB" if substr(medicationname,1,6)=="LORTAB"
            
* other brand or generic Ketoconazole on the mkt
replace   shortnam = "NIZORAL" if substr(medicationname,1,7)=="NIZORAL"
      
* other brand and generic TRIAMCINOLONE on the mkt      
replace   shortnam = "KENALOG" if substr(medicationname,1,7)=="KENALOG"
           
* other brand or generic Testosterone
replace   shortnam = "ANDRODERM" if substr(medicationname,1,9)=="ANDRODERM"
  
* this is a generic
replace   shortnam = "KETOCONAZOLE" if substr(medicationname,1,12)=="KETOCONAZOLE"
    
** DRUGS 481-490

* 9 rx with generic name
replace   shortnam = "BENZAMYCIN" if substr(medicationname,1,10)=="BENZAMYCIN" 
replace   shortnam = "BENZAMYCIN" if medicationname=="ERYTHROMYCIN-BENZOYL PEROXIDE"         
  
* no generic Immune Globulin 
replace   shortnam = "GAMIMUNE" if substr(medicationname,1,8)=="GAMIMUNE"          
        
* other brand or generic Beclomethasone on the mkt
replace   shortnam = "BECONASE" if substr(medicationname,1,8)=="BECONASE"
           
* no brand and generic SOMATROPIN in meps
replace   shortnam = "NUTROPIN" if substr(medicationname,1,8)=="NUTROPIN"
          
* other brand or generic Estrogen on the mkt
replace   shortnam = "CENESTIN" if substr(medicationname,1,8)=="CENESTIN"
            
* other brand or generic Estrogen and Progestin
replace   shortnam = "LO/OVRAL" if substr(medicationname,1,8)=="LO/OVRAL"

* other brand or generic Estrogen and Progestin
replace   shortnam = "NORTREL" if substr(medicationname,1,7)=="NORTREL"
            
* no brand or generic Pancrelipase in meps
replace   shortnam = "CREON" if substr(medicationname,1,5)=="CREON"
     
* this is a generic
replace   shortnam = "HYCD/IBUPROFEN" if substr(medicationname,1,14)=="HYCD/IBUPROFEN"
replace   shortnam = "HYCD/IBUPROFEN" if substr(medicationname,1,32)=="HYDROCODONE BITARTRATE/IBUPROFEN"

**
* what is generic name? revisit
replace   shortnam = "REFRESH" if substr(medicationname,1,7)=="REFRESH"            
**

** DRUGS 491-500
     
* other brand or generic Clonazepam on the mkt    
replace   shortnam = "KLONOPIN" if substr(medicationname,1,8)=="KLONOPIN"

* no generic Eletriptan in meps
replace   shortnam = "RELPAX" if substr(medicationname,1,6)=="RELPAX"             
       
* brand or generic Fludarabine in meps
replace   shortnam = "FLUDARA" if substr(medicationname,1,7)=="FLUDARA" & substr(medicationname,1,11)!="FLUDARABINE"

* spelling error; this is a generic
replace   shortnam = "LORATADINE" if substr(medicationname,1,10)=="LORATADINE"         
replace   shortnam = "LORATADINE" if substr(medicationname,1,10)=="LORATIDINE"

* this is a generic
replace   shortnam = "CARISOPRODOL" if substr(medicationname,1,12)=="CARISOPRODOL"
replace   shortnam = "CARISOPRODOL" if substr(medicationname,1,20)=="ASPIRIN/CARISOPRODOL"       
           
* other brand or generic Nitroglycerin on the mkt
replace   shortnam = "NITRO-DUR" if substr(medicationname,1,9)=="NITRO-DUR"
            
* other brand or generic estrogen
replace   shortnam = "VAGIFEM" if substr(medicationname,1,7)=="VAGIFEM"
           
* other brand and generic Morphine on the mkt
replace   shortnam = "AVINZA" if substr(medicationname,1,6)=="AVINZA"
        
* this is a generic; not in meps
replace   shortnam = "VINORELBINE" if substr(medicationname,1,11)=="VINORELBINE"

* other brand or generic DILTIAZEM on the mkt
replace   shortnam = "TAZTIA" if substr(medicationname,1,6)=="TAZTIA"

gen top500 = (shortnam!="")
tab top500, missing

** DRUGS 501-510             
 
replace   shortnam = "ACCURETIC" if substr(medicationname,1,9)=="ACCURETIC"         

* careful with this one b/c there is somavert below
replace   shortnam = "SOMA" if substr(medicationname,1,4)=="SOMA" & substr(medicationname,1,8)!="SOMAVERT"
 
replace   shortnam = "METOPROLOL" if substr(medicationname,1,10)=="METOPROLOL" & substr(medicationname,1,12)~="METOPROLOL S"        
          
replace   shortnam = "BISOPROLOL" if substr(medicationname,1,10)=="BISOPROLOL"
             
replace   shortnam = "AMOXIL" if substr(medicationname,1,6)=="AMOXIL"
          
replace   shortnam = "PREDNISONE" if substr(medicationname,1,10)=="PREDNISONE"
         
replace   shortnam = "LOPRESSOR" if substr(medicationname,1,9)=="LOPRESSOR"
    
replace   shortnam = "CLONIDINE" if substr(medicationname,1,9)=="CLONIDINE"       
          
replace   shortnam = "INFANRIX" if substr(medicationname,1,8)=="INFANRIX"
            
replace   shortnam = "SPRINTEC" if substr(medicationname,1,8)=="SPRINTEC"

** DRUGS 511-520 

replace   shortnam = "MEPRON" if substr(medicationname,1,6)=="MEPRON"              
              
replace   shortnam = "HALLS" if substr(medicationname,1,5)=="HALLS" 
 
replace   shortnam = "URECHOLINE" if substr(medicationname,1,10)=="URECHOLINE"         
            
replace   shortnam = "ELIGARD" if substr(medicationname,1,7)=="ELIGARD"
    
replace   shortnam = "URSO" if substr(medicationname,1,4)=="URSO"           
             
replace   shortnam = "VISINE" if substr(medicationname,1,6)=="VISINE"
  
replace   shortnam = "GLIPIZIDE" if substr(medicationname,1,9)=="GLIPIZIDE"         
           
replace   shortnam = "PANCREASE" if substr(medicationname,1,9)=="PANCREASE"
         
replace   shortnam = "NEOSPORIN" if substr(medicationname,1,9)=="NEOSPORIN"
      
replace   shortnam = "ACETAMINOPHEN" if substr(medicationname,1,13)=="ACETAMINOPHEN"

** DRUGS 521-530 

replace   shortnam = "FLEXERIL" if substr(medicationname,1,8)=="FLEXERIL"            
              
replace   shortnam = "ZOVIA" if substr(medicationname,1,5)=="ZOVIA"
            
replace   shortnam = "DARVOCET" if substr(medicationname,1,8)=="DARVOCET"
            
replace   shortnam = "HYTRIN" if substr(medicationname,1,6)=="HYTRIN"
               
replace   shortnam = "SULAR" if substr(medicationname,1,5)=="SULAR"
 
replace   shortnam = "REGRANEX" if substr(medicationname,1,8)=="REGRANEX"          
     
replace   shortnam = "CHOLESTYRAMINE" if substr(medicationname,1,14)=="CHOLESTYRAMINE"
          
replace   shortnam = "TRAZODONE" if substr(medicationname,1,9)=="TRAZODONE"
        
replace   shortnam = "PROMETHEGAN" if substr(medicationname,1,11)=="PROMETHEGAN"
   
replace   shortnam = "VFEND" if substr(medicationname,1,5)=="VFEND"
            
** DRUGS 531-540 
   
replace   shortnam = "ATIVAN" if substr(medicationname,1,6)=="ATIVAN"           
         
replace   shortnam = "AMIODARONE" if substr(medicationname,1,10)=="AMIODARONE"
               
replace   shortnam = "DUAC" if substr(medicationname,1,4)=="DUAC"
              
replace   shortnam = "PEPTO" if substr(medicationname,1,5)=="PEPTO"
         
replace   shortnam = "LEVOTHROID" if substr(medicationname,1,10)=="LEVOTHROID"
            
replace   shortnam = "GENGRAF" if substr(medicationname,1,7)=="GENGRAF"
         
replace   shortnam = "CLONAZEPAM" if substr(medicationname,1,10)=="CLONAZEPAM"
          
replace   shortnam = "ROXICODONE" if substr(medicationname,1,10)=="ROXICODONE"
        
replace   shortnam = "BENZONATATE" if substr(medicationname,1,11)=="BENZONATATE"
          
replace   shortnam = "PERIOSTAT" if substr(medicationname,1,9)=="PERIOSTAT"

** DRUGS 541-550 
 
replace   shortnam = "ALAVERT" if substr(medicationname,1,7)=="ALAVERT"           
            
replace   shortnam = "RESTASIS" if substr(medicationname,1,8)=="RESTASIS"
            
replace   shortnam = "NICODERM" if substr(medicationname,1,8)=="NICODERM"
              
replace   shortnam = "VAQTA" if substr(medicationname,1,5)=="VAQTA"
        
replace   shortnam = "LOTRISONE" if substr(medicationname,1,9)=="LOTRISONE"
       
replace   shortnam = "FLUVOXAMINE" if substr(medicationname,1,11)=="FLUVOXAMINE"
       
replace   shortnam = "ALLOPURINOL" if substr(medicationname,1,11)=="ALLOPURINOL"
           
replace   shortnam = "NOLVADEX" if substr(medicationname,1,8)=="NOLVADEX"

replace   shortnam = "TRUSOPT" if substr(medicationname,1,7)=="TRUSOPT"             

replace   shortnam = "HYDROXYCHLOROQUINE" if substr(medicationname,1,18)=="HYDROXYCHLOROQUINE"

** DRUGS 551-560
 
replace   shortnam = "LEVORA" if substr(medicationname,1,6)=="LEVORA"           
             
replace   shortnam = "FROVA" if substr(medicationname,1,5)=="FROVA"
        
replace   shortnam = "TERAZOSIN" if substr(medicationname,1,9)=="TERAZOSIN"
         
replace   shortnam = "NIZATIDINE" if substr(medicationname,1,10)=="NIZATIDINE"
            
replace   shortnam = "VELCADE" if substr(medicationname,1,7)=="VELCADE"
           
replace   shortnam = "NUVARING" if substr(medicationname,1,8)=="NUVARING"
   
replace   shortnam = "METHYLPHENIDATE" if substr(medicationname,1,15)=="METHYLPHENIDATE"
       
replace   shortnam = "METHOTREXATE" if substr(medicationname,1,12)=="METHOTREXATE"
              
replace   shortnam = "CARMOL" if substr(medicationname,1,6)=="CARMOL"
            
replace   shortnam = "DIASTAT" if substr(medicationname,1,7)=="DIASTAT"

** DRUGS 561-570
 
replace   shortnam = "PENICILLIN" if substr(medicationname,1,10)=="PENICILLIN"        
            
replace   shortnam = "ULTRASE" if substr(medicationname,1,7)=="ULTRASE"
            
replace   shortnam = "TENORMIN" if substr(medicationname,1,8)=="TENORMIN"
            
replace   shortnam = "SINEMET" if substr(medicationname,1,7)=="SINEMET"
        
replace   shortnam = "ESTRADERM" if substr(medicationname,1,9)=="ESTRADERM"
        
replace   shortnam = "CALCITRIOL" if substr(medicationname,1,10)=="CALCITRIOL"
              
replace   shortnam = "VANTIN" if substr(medicationname,1,6)=="VANTIN"
         
replace   shortnam = "LABETALOL" if substr(medicationname,1,9)=="LABETALOL"
            
replace   shortnam = "FLUZONE" if substr(medicationname,1,7)=="FLUZONE"
             
replace   shortnam = "UNIVASC" if substr(medicationname,1,7)=="UNIVASC"

** DRUGS 571-580

replace   shortnam = "ABREVA" if substr(medicationname,1,6)=="ABREVA"             
             
replace   shortnam = "DIGITEK" if substr(medicationname,1,7)=="DIGITEK"
          
replace   shortnam = "AGENERASE" if substr(medicationname,1,9)=="AGENERASE"

replace   shortnam = "PRIMATENE" if substr(medicationname,1,9)=="PRIMATENE"           
               
replace   shortnam = "ZICAM" if substr(medicationname,1,5)=="ZICAM"
          
replace   shortnam = "FIORICET" if substr(medicationname,1,8)=="FIORICET"
           
replace   shortnam = "HEPARIN" if substr(medicationname,1,7)=="HEPARIN"
            
replace   shortnam = "HAVRIX" if substr(medicationname,1,6)=="HAVRIX"
              
replace   shortnam = "ACEON" if substr(medicationname,1,5)=="ACEON"
     
replace   shortnam = "BUTALB/ASA/CAF/CD" if substr(medicationname,1,17)=="BUTALB/ASA/CAF/CD"

** DRUGS 581-590

replace   shortnam = "DESOGEN" if substr(medicationname,1,7)=="DESOGEN"            
           
replace   shortnam = "ACYCLOVIR" if substr(medicationname,1,9)=="ACYCLOVIR"
  
replace   shortnam = "VOLTAREN" if substr(medicationname,1,8)=="VOLTAREN"         

replace   shortnam = "PROPAFENONE" if substr(medicationname,1,11)=="PROPAFENONE"        
            
replace   shortnam = "ASPIRIN" if substr(medicationname,1,7)=="ASPIRIN" & (medicationname~="ASPIRIN/DIPYRIDAMOLE" & medicationname~="ASPIRIN/CAFFEINE/PROPOXYPHENE" & medicationname~="ASPIRIN/CARISOPRODOL")
         
replace   shortnam = "DIMETAPP" if substr(medicationname,1,8)=="DIMETAPP"
       
replace   shortnam = "DESMOPRESSIN" if substr(medicationname,1,12)=="DESMOPRESSIN"
             
replace   shortnam = "MYCELEX" if substr(medicationname,1,7)=="MYCELEX"

replace   shortnam = "FOLTX" if substr(medicationname,1,5)=="FOLTX"             

replace   shortnam = "RILUTEK" if substr(medicationname,1,7)=="RILUTEK"

** DRUGS 591-600            
             
replace   shortnam = "TROJANS" if substr(medicationname,1,7)=="TROJANS"

replace   shortnam = "PROPOFOL" if substr(medicationname,1,8)=="PROPOFOL"            
           
replace   shortnam = "EFUDEX" if substr(medicationname,1,6)=="EFUDEX"
          
replace   shortnam = "PEDIALYTE" if substr(medicationname,1,9)=="PEDIALYTE"
           
replace   shortnam = "TAMBOCOR" if substr(medicationname,1,8)=="TAMBOCOR"
           
replace   shortnam = "FRAGMIN" if substr(medicationname,1,7)=="FRAGMIN"
            
replace   shortnam = "FUZEON" if substr(medicationname,1,6)=="FUZEON"
            
replace   shortnam = "INVIRASE" if substr(medicationname,1,8)=="INVIRASE"
           
replace   shortnam = "REPRONEX" if substr(medicationname,1,8)=="REPRONEX"
    
replace   shortnam = "FOLIC" if substr(medicationname,1,5)=="FOLIC"

** DRUGS 601-610          
         
replace   shortnam = "METROCREAM" if substr(medicationname,1,10)=="METROCREAM"

replace   shortnam = "TRIAMINIC" if substr(medicationname,1,9)=="TRIAMINIC"          

replace   shortnam = "BUSPAR" if substr(medicationname,1,6)=="BUSPAR"             
             
replace   shortnam = "ACTHIB" if substr(medicationname,1,6)=="ACTHIB"

replace   shortnam = "CUTIVATE" if substr(medicationname,1,8)=="CUTIVATE"           
  
replace   shortnam = "VIGAMOX" if substr(medicationname,1,7)=="VIGAMOX"          
     
replace   shortnam = "AMITRIPTYLINE" if substr(medicationname,1,13)=="AMITRIPTYLINE"
          
replace   shortnam = "PROLEUKIN" if substr(medicationname,1,9)=="PROLEUKIN"
            
replace   shortnam = "UNIPHYL" if substr(medicationname,1,7)=="UNIPHYL"
              
replace   shortnam = "ADOXA" if substr(medicationname,1,5)=="ADOXA"

** DRUGS 611-620
 
replace   shortnam = "PLEXION" if substr(medicationname,1,7)=="PLEXION"           
           
replace   shortnam = "DAYQUIL" if substr(medicationname,1,7)=="DAYQUIL"
          
replace   shortnam = "PHENERGAN" if substr(medicationname,1,9)=="PHENERGAN"
 
replace   shortnam = "FLUMIST" if substr(medicationname,1,7)=="FLUMIST"            
            
replace   shortnam = "PARAGARD" if substr(medicationname,1,8)=="PARAGARD"
         
replace   shortnam = "PACLITAXEL" if substr(medicationname,1,10)=="PACLITAXEL"
           
replace   shortnam = "RETROVIR" if substr(medicationname,1,8)=="RETROVIR"

replace   shortnam = "THERAFLU" if substr(medicationname,1,8)=="THERAFLU"
            
replace   shortnam = "KOGENATE" if substr(medicationname,1,8)=="KOGENATE"

replace   shortnam = "ULTANE" if substr(medicationname,1,6)=="ULTANE"
  
** DRUGS 621-630           

replace   shortnam = "HEPSERA" if substr(medicationname,1,7)=="HEPSERA"            
             
replace   shortnam = "MYLANTA" if substr(medicationname,1,7)=="MYLANTA"
             
replace   shortnam = "ZYMAR" if substr(medicationname,1,5)=="ZYMAR"
          
replace   shortnam = "NAVELBINE" if substr(medicationname,1,9)=="NAVELBINE"

replace   shortnam = "CYTOMEL" if substr(medicationname,1,7)=="CYTOMEL"            
        
replace   shortnam = "FLECAINIDE" if substr(medicationname,1,10)=="FLECAINIDE"
            
replace   shortnam = "AVODART" if substr(medicationname,1,7)=="AVODART"
        
replace   shortnam = "AZATHIOPRINE" if substr(medicationname,1,12)=="AZATHIOPRINE"
            
replace   shortnam = "TRIMOX" if substr(medicationname,1,6)=="TRIMOX"

replace   shortnam = "ZADITOR" if substr(medicationname,1,7)=="ZADITOR"
           
** DRUGS 631-640 

replace   shortnam = "AFRIN" if substr(medicationname,1,5)=="AFRIN"               
           
replace   shortnam = "METAGLIP" if substr(medicationname,1,8)=="METAGLIP"
             
replace   shortnam = "TRIAZ" if substr(medicationname,1,5)=="TRIAZ"
  
replace   shortnam = "DEXTROAMPHETAMINE" if substr(medicationname,1,17)=="DEXTROAMPHETAMINE"
     
replace   shortnam = "ALTOPREV" if substr(medicationname,1,8)=="ALTOPREV"     
            
replace   shortnam = "NULYTELY" if substr(medicationname,1,8)=="NULYTELY" 
            
replace   shortnam = "OCUVITE" if substr(medicationname,1,7)=="OCUVITE"
 
replace   shortnam = "ENTOCORT" if substr(medicationname,1,8)=="ENTOCORT"          
            
replace   shortnam = "SALAGEN" if substr(medicationname,1,7)=="SALAGEN"

replace   shortnam = "TRIAMCINOLONE" if substr(medicationname,1,13)=="TRIAMCINOLONE"

** DRUGS 641-650        
 
replace   shortnam = "SAIZEN" if substr(medicationname,1,6)=="SAIZEN"            
            
replace   shortnam = "CARAFATE" if substr(medicationname,1,8)=="CARAFATE"
   
replace   shortnam = "DEPO-TESTOSTERONE" if substr(medicationname,1,17)=="DEPO-TESTOSTERONE"
 
replace   shortnam = "CARNITOR" if substr(medicationname,1,8)=="CARNITOR"           

replace   shortnam = "BUTALB/ASA/CAF/CD" if substr(medicationname,1,17)=="BUTALB/ASA/CAF/CD"
     
replace   shortnam = "CALTRATE" if substr(medicationname,1,8)=="CALTRATE"     
  
replace   shortnam = "CANASA" if substr(medicationname,1,6)=="CANASA"            

* careful lots of drugs that start with 'tussi'
replace   shortnam = "TUSSI" if substr(medicationname,1,6)=="TUSSI " 
replace   shortnam = "TUSSI" if substr(medicationname,1,6)=="TUSSI-"              

replace   shortnam = "MAALOX" if substr(medicationname,1,6)=="MAALOX"              
 
replace   shortnam = "CALAN" if substr(medicationname,1,5)=="CALAN"
             
** DRUGS 651-660

replace   shortnam = "RESTORIL" if substr(medicationname,1,8)=="RESTORIL"            
          
replace   shortnam = "FAMOTIDINE" if substr(medicationname,1,10)=="FAMOTIDINE"
             
replace   shortnam = "PRECOSE" if substr(medicationname,1,7)=="PRECOSE"
             
replace   shortnam = "AZOPT" if substr(medicationname,1,5)=="AZOPT"
          
replace   shortnam = "DIPRIVAN" if substr(medicationname,1,8)=="DIPRIVAN"
        
replace   shortnam = "IMIPRAMINE" if substr(medicationname,1,10)=="IMIPRAMINE"
            
replace   shortnam = "AXID" if substr(medicationname,1,4)=="AXID"
              
replace   shortnam = "IMDUR" if substr(medicationname,1,5)=="IMDUR"

replace   shortnam = "DOXYCYCLINE" if substr(medicationname,1,11)=="DOXYCYCLINE"         
            
replace   shortnam = "LINDANE" if substr(medicationname,1,7)=="LINDANE"

** DRUGS 661-670
            
replace   shortnam = "ZANAFLEX" if substr(medicationname,1,8)=="ZANAFLEX"
          
replace   shortnam = "PREMPHASE" if substr(medicationname,1,9)=="PREMPHASE"
       
replace   shortnam = "CLOBETASOL" if substr(medicationname,1,10)=="CLOBETASOL"
            
replace   shortnam = "KLARON" if substr(medicationname,1,6)=="KLARON"

replace   shortnam = "METHOCARBAMOL" if substr(medicationname,1,13)=="METHOCARBAMOL"
         
replace   shortnam = "ECONAZOLE" if substr(medicationname,1,9)=="ECONAZOLE"
         
replace   shortnam = "DOXAZOSIN" if substr(medicationname,1,9)=="DOXAZOSIN"

replace   shortnam = "HECTOROL" if substr(medicationname,1,8)=="HECTOROL"
            
replace   shortnam = "CATHFLO" if substr(medicationname,1,7)=="CATHFLO"
       
replace   shortnam = "THEOPHYLLINE" if substr(medicationname,1,12)=="THEOPHYLLINE"

** DRUGS 671-680

replace   shortnam = "CETAPHIL" if substr(medicationname,1,8)=="CETAPHIL"            
            
replace   shortnam = "ADIPEX" if substr(medicationname,1,6)=="ADIPEX"
         
replace   shortnam = "ZESTORETIC" if substr(medicationname,1,10)=="ZESTORETIC"  

replace   shortnam = "NICOTROL" if substr(medicationname,1,8)=="NICOTROL"           
        
replace   shortnam = "PREDNISOLONE" if substr(medicationname,1,12)=="PREDNISOLONE"
            
replace   shortnam = "PARLODEL" if substr(medicationname,1,8)=="PARLODEL"
            
replace   shortnam = "CAMPATH" if substr(medicationname,1,7)=="CAMPATH"
             
replace   shortnam = "LITHIUM" if substr(medicationname,1,7)=="LITHIUM"
        
replace   shortnam = "NORDITROPIN" if substr(medicationname,1,11)=="NORDITROPIN"
        
replace   shortnam = "HALOPERIDOL" if substr(medicationname,1,11)=="HALOPERIDOL"

** DRUGS 681-690
            
replace   shortnam = "CITRACAL" if substr(medicationname,1,8)=="CITRACAL"
           
replace   shortnam = "GLUCAGON" if substr(medicationname,1,8)=="GLUCAGON"
         
replace   shortnam = "AEROCHAMBER" if substr(medicationname,1,11)=="AEROCHAMBER"
            
replace   shortnam = "PHILLIPS" if substr(medicationname,1,8)=="PHILLIPS"
            
replace   shortnam = "LORCET" if substr(medicationname,1,6)=="LORCET"
           
replace   shortnam = "DIP/TET" if substr(medicationname,1,7)=="DIP/TET"
          
replace   shortnam = "FORTOVASE" if substr(medicationname,1,9)=="FORTOVASE"

replace   shortnam = "DURICEF" if substr(medicationname,1,7)=="DURICEF"            
           
replace   shortnam = "CYTOXAN" if substr(medicationname,1,7)=="CYTOXAN"

replace   shortnam = "SMX/TMP" if substr(medicationname,1,7)=="SMX/TMP"           

** DRUGS 691-700
           
replace   shortnam = "BICILLIN" if substr(medicationname,1,8)=="BICILLIN"
               
replace   shortnam = "INTAL" if substr(medicationname,1,5)=="INTAL"
             
replace   shortnam = "INFED" if substr(medicationname,1,5)=="INFED"
       
replace   shortnam = "METROLOTION" if substr(medicationname,1,11)=="METROLOTION"
         
replace   shortnam = "COMBIPATCH" if substr(medicationname,1,10)=="COMBIPATCH"
                
replace   shortnam = "GAS" if substr(medicationname,1,3)=="GAS"

replace   shortnam = "CARBAMAZEPINE" if substr(medicationname,1,13)=="CARBAMAZEPINE"      
          
replace   shortnam = "ESTRADIOL" if substr(medicationname,1,9)=="ESTRADIOL"
            
replace   shortnam = "RYTHMOL" if substr(medicationname,1,7)=="RYTHMOL"
  
replace   shortnam = "BUTALB/ASA/CAF/CD" if substr(medicationname,1,17)=="BUTALB/ASA/CAF/CD"

** DRUGS 701-710    
 
replace   shortnam = "UNIRETIC" if substr(medicationname,1,8)=="UNIRETIC"           
             
replace   shortnam = "THYROID" if substr(medicationname,1,7)=="THYROID"
             
replace   shortnam = "DELSYM" if substr(medicationname,1,6)=="DELSYM"
        
replace   shortnam = "TRI-NORINYL" if substr(medicationname,1,11)=="TRI-NORINYL"

replace   shortnam = "DENAVIR" if substr(medicationname,1,7)=="DENAVIR"            
    
replace   shortnam = "ZIAC" if substr(medicationname,1,4)=="ZIAC"           
         
replace   shortnam = "CEFADROXIL" if substr(medicationname,1,10)=="CEFADROXIL"
           
replace   shortnam = "COLESTID" if substr(medicationname,1,8)=="COLESTID"

replace   shortnam = "MENTAX" if substr(medicationname,1,6)=="MENTAX"             
            
replace   shortnam = "TANAFED" if substr(medicationname,1,7)=="TANAFED"

** DRUGS 711-720   
  
replace   shortnam = "DEXEDRINE" if substr(medicationname,1,9)=="DEXEDRINE"         
            
replace   shortnam = "DEMADEX" if substr(medicationname,1,7)=="DEMADEX"
             
replace   shortnam = "MEVACOR" if substr(medicationname,1,7)=="MEVACOR"

replace   shortnam = "LOCOID" if substr(medicationname,1,6)=="LOCOID"             
            
replace   shortnam = "CYCLESSA" if substr(medicationname,1,8)=="CYCLESSA"
 
replace   shortnam = "ECOTRIN" if substr(medicationname,1,7)=="ECOTRIN"            

replace   shortnam = "EUCERIN" if substr(medicationname,1,7)=="EUCERIN"            
            
replace   shortnam = "FIORINAL" if substr(medicationname,1,8)=="FIORINAL"
          
replace   shortnam = "PRIMIDONE" if substr(medicationname,1,9)=="PRIMIDONE"
             
replace   shortnam = "NORCO" if substr(medicationname,1,5)=="NORCO"

** DRUGS 721-730 
     
replace   shortnam = "LAC-HYDRIN" if substr(medicationname,1,10)=="LAC-HYDRIN"     

replace   shortnam = "CLARAVIS" if substr(medicationname,1,8)=="CLARAVIS"           

replace   shortnam = "MEPROBAMATE" if substr(medicationname,1,11)=="MEPROBAMATE"         

replace   shortnam = "CAMILA" if substr(medicationname,1,6)=="CAMILA"              

replace   shortnam = "BOSTON" if substr(medicationname,1,6)=="BOSTON"              
            
replace   shortnam = "CARDURA" if substr(medicationname,1,7)=="CARDURA" 

replace   shortnam = "LITHOBID" if substr(medicationname,1,8)=="LITHOBID"           
           
replace   shortnam = "DULCOLAX" if substr(medicationname,1,8)=="DULCOLAX"
            
replace   shortnam = "SOTALOL" if substr(medicationname,1,7)=="SOTALOL"

replace   shortnam = "CORTIZONE" if substr(medicationname,1,9)=="CORTIZONE"

** DRUGS 731-740            

replace   shortnam = "ESTRING" if substr(medicationname,1,7)=="ESTRING"             
           
replace   shortnam = "CITRUCEL" if substr(medicationname,1,8)=="CITRUCEL"
           
replace   shortnam = "ESKALITH" if substr(medicationname,1,8)=="ESKALITH"

replace   shortnam = "CIALIS" if substr(medicationname,1,6)=="CIALIS"            
             
replace   shortnam = "LUXIQ" if substr(medicationname,1,5)=="LUXIQ"
             
replace   shortnam = "STADOL" if substr(medicationname,1,6)=="STADOL" 

replace   shortnam = "BUPROPION" if substr(medicationname,1,9)=="BUPROPION"          
 
replace   shortnam = "QVAR" if substr(medicationname,1,4)=="QVAR"            
      
replace   shortnam = "DESOXIMETASONE" if substr(medicationname,1,14)=="DESOXIMETASONE"
  
replace   shortnam = "RENOVA" if substr(medicationname,1,6)=="RENOVA"

** DRUGS 741-750            

replace   shortnam = "PROCTOFOAM" if substr(medicationname,1,10)=="PROCTOFOAM"         
           
replace   shortnam = "PRECARE" if substr(medicationname,1,7)=="PRECARE"
  
replace   shortnam = "CAVERJECT" if substr(medicationname,1,9)=="CAVERJECT"         
           
replace   shortnam = "ROGAINE" if substr(medicationname,1,7)=="ROGAINE"

replace   shortnam = "METHYLPREDNISOLONE" if substr(medicationname,1,18)=="METHYLPREDNISOLONE" 
    
replace   shortnam = "TRI-LEVLEN" if substr(medicationname,1,10)=="TRI-LEVLEN"    
        
replace   shortnam = "CIMETIDINE" if substr(medicationname,1,10)=="CIMETIDINE"

replace   shortnam = "ROBINUL" if substr(medicationname,1,7)=="ROBINUL"            
           
replace   shortnam = "TRIPEDIA" if substr(medicationname,1,8)=="TRIPEDIA" 

replace   shortnam = "DIAZEPAM" if substr(medicationname,1,8)=="DIAZEPAM"

** DRUGS 751-760            

replace   shortnam = "SYNTEST" if substr(medicationname,1,7)=="SYNTEST"             
     
replace   shortnam = "METOCLOPRAMIDE" if substr(medicationname,1,14)=="METOCLOPRAMIDE"
          
replace   shortnam = "VANCOCIN" if substr(medicationname,1,8)=="VANCOCIN"
          
replace   shortnam = "TRANSDERM" if substr(medicationname,1,9)=="TRANSDERM"
           
replace   shortnam = "BREVOXYL" if substr(medicationname,1,8)=="BREVOXYL"
       
replace   shortnam = "METHIMAZOLE" if substr(medicationname,1,11)=="METHIMAZOLE"
             
replace   shortnam = "PERMAX" if substr(medicationname,1,6)=="PERMAX"
 
replace   shortnam = "CALCIUM" if substr(medicationname,1,7)=="CALCIUM"           
  
replace   shortnam = "CEREZYME" if substr(medicationname,1,8)=="CEREZYME"         

replace   shortnam = "BUTORPHANOL" if substr(medicationname,1,11)=="BUTORPHANOL"

** DRUGS 761-770          
    
replace   shortnam = "PENTOXIFYLLINE" if substr(medicationname,1,14)=="PENTOXIFYLLINE"  

replace   shortnam = "PEDIACARE" if substr(medicationname,1,9)=="PEDIACARE"          
            
replace   shortnam = "LOTRIMIN" if substr(medicationname,1,8)=="LOTRIMIN"
            
replace   shortnam = "CRYSELLE" if substr(medicationname,1,8)=="CRYSELLE"
            
replace   shortnam = "RELAFEN" if substr(medicationname,1,7)=="RELAFEN"
 
replace   shortnam = "TEVETEN" if substr(medicationname,1,7)=="TEVETEN"            
             
replace   shortnam = "PEDVAX" if substr(medicationname,1,6)=="PEDVAX"
              
replace   shortnam = "TUSSIN" if substr(medicationname,1,6)=="TUSSIN"
           
replace   shortnam = "ENPRESSE" if substr(medicationname,1,8)=="ENPRESSE"
 
replace   shortnam = "MAXZIDE" if substr(medicationname,1,7)=="MAXZIDE"

** DRUGS 771-780            
 
replace   shortnam = "OS-CAL" if substr(medicationname,1,6)=="OS-CAL"             
              
replace   shortnam = "K-DUR" if substr(medicationname,1,5)=="K-DUR" 
 
replace   shortnam = "NEUMEGA" if substr(medicationname,1,7)=="NEUMEGA"            
            
replace   shortnam = "WINRHO" if substr(medicationname,1,6)=="WINRHO"
              
replace   shortnam = "PHOSLO" if substr(medicationname,1,6)=="PHOSLO"
             
replace   shortnam = "VOLMAX" if substr(medicationname,1,6)=="VOLMAX"

replace   shortnam = "OPTIVAR" if substr(medicationname,1,7)=="OPTIVAR"             
 
replace   shortnam = "INDOMETHACIN" if substr(medicationname,1,12)=="INDOMETHACIN"       
             
replace   shortnam = "PRENATE" if substr(medicationname,1,7)=="PRENATE"
             
replace   shortnam = "PAMELOR" if substr(medicationname,1,7)=="PAMELOR"

** DRUGS 781-790 

replace   shortnam = "LOTEMAX" if substr(medicationname,1,7)=="LOTEMAX"            
            
replace   shortnam = "ANBESOL" if substr(medicationname,1,7)=="ANBESOL"

replace   shortnam = "NORITATE" if substr(medicationname,1,8)=="NORITATE"           
            
replace   shortnam = "NOR-Q.D." if substr(medicationname,1,8)=="NOR-Q.D."  

replace   shortnam = "BROMOCRIPTINE" if substr(medicationname,1,13)=="BROMOCRIPTINE"       
            
replace   shortnam = "NORDETTE" if substr(medicationname,1,8)=="NORDETTE"

replace   shortnam = "PACERONE" if substr(medicationname,1,8)=="PACERONE"           
        
replace   shortnam = "FLUOCINONIDE" if substr(medicationname,1,12)=="FLUOCINONIDE"
           
replace   shortnam = "AROMASIN" if substr(medicationname,1,8)=="AROMASIN"
 
replace   shortnam = "MEDERMA" if substr(medicationname,1,7)=="MEDERMA"
           
** DRUGS 791-800
 
replace   shortnam = "DYAZIDE" if substr(medicationname,1,7)=="DYAZIDE"            
               
replace   shortnam = "BABY" if substr(medicationname,1,4)=="BABY"
          
replace   shortnam = "NITETIME" if substr(medicationname,1,8)=="NITETIME"

replace   shortnam = "METHADONE" if substr(medicationname,1,9)=="METHADONE"           
           
replace   shortnam = "FELBATOL" if substr(medicationname,1,8)=="FELBATOL"
            
replace   shortnam = "BLISTEX" if substr(medicationname,1,7)=="BLISTEX"
           
replace   shortnam = "MOEXIPRIL" if substr(medicationname,1,9)=="MOEXIPRIL"

replace   shortnam = "TEMAZEPAM" if substr(medicationname,1,9)=="TEMAZEPAM"           
          
replace   shortnam = "LIDOCAINE" if substr(medicationname,1,9)=="LIDOCAINE"
         
replace   shortnam = "MYSOLINE" if substr(medicationname,1,8)=="MYSOLINE"

** DRUGS 801-810
    
replace   shortnam = "CEFACLOR" if substr(medicationname,1,8)=="CEFACLOR"       
  
replace   shortnam = "UNISOM" if substr(medicationname,1,6)=="UNISOM"            
               
replace   shortnam = "ONTAK" if substr(medicationname,1,5)=="ONTAK"
            
replace   shortnam = "MUCINEX" if substr(medicationname,1,7)=="MUCINEX"
            
replace   shortnam = "GYNAZOLE" if substr(medicationname,1,8)=="GYNAZOLE"
           
replace   shortnam = "OXAZEPAM" if substr(medicationname,1,8)=="OXAZEPAM"
 
replace   shortnam = "TIMOPTIC" if substr(medicationname,1,8)=="TIMOPTIC"
 
replace   shortnam = "REFACTO" if substr(medicationname,1,7)=="REFACTO"           
            
replace   shortnam = "CIPRODEX" if substr(medicationname,1,8)=="CIPRODEX"
             
replace   shortnam = "ALOCRIL" if substr(medicationname,1,7)=="ALOCRIL"           


** DRUGS 811-820

replace   shortnam = "MALARONE" if substr(medicationname,1,8)=="MALARONE"            
            
replace   shortnam = "TOFRANIL" if substr(medicationname,1,8)=="TOFRANIL"
            
replace   shortnam = "BEN-GAY" if substr(medicationname,1,7)=="BEN-GAY"
              
replace   shortnam = "MUSE" if substr(medicationname,1,4)=="MUSE"
           
replace   shortnam = "LEVLITE" if substr(medicationname,1,7)=="LEVLITE"
  
replace   shortnam = "LORABID" if substr(medicationname,1,7)=="LORABID"         
          
replace   shortnam = "CALCIJEX" if substr(medicationname,1,8)=="CALCIJEX"

replace   shortnam = "SULINDAC" if substr(medicationname,1,8)=="SULINDAC"           
             
replace   shortnam = "EMEND" if substr(medicationname,1,5)=="EMEND"
             
replace   shortnam = "EX-LAX" if substr(medicationname,1,6)=="EX-LAX"

** DRUGS 821-830

replace   shortnam = "CLORAZEPATE" if substr(medicationname,1,11)=="CLORAZEPATE"         
            
replace   shortnam = "LIPRAM" if substr(medicationname,1,6)=="LIPRAM"
        
replace   shortnam = "PROBENECID" if substr(medicationname,1,10)=="PROBENECID"
          
replace   shortnam = "PERGOLIDE" if substr(medicationname,1,9)=="PERGOLIDE"
           
replace   shortnam = "PLAQUENIL" if substr(medicationname,1,9)=="PLAQUENIL"
          
replace   shortnam = "ORAMORPH" if substr(medicationname,1,8)=="ORAMORPH"

replace   shortnam = "THEO-24" if substr(medicationname,1,7)=="THEO-24"             
           
replace   shortnam = "TRANXENE" if substr(medicationname,1,8)=="TRANXENE"

replace   shortnam = "ORA-JEL" if substr(medicationname,1,7)=="ORA-JEL"             
 
replace   shortnam = "PERGONAL" if substr(medicationname,1,8)=="PERGONAL"             


** DRUGS 831-840           
            
replace   shortnam = "LASIX" if substr(medicationname,1,5)=="LASIX"

replace   shortnam = "SENOKOT" if substr(medicationname,1,7)=="SENOKOT"            

replace   shortnam = "DESONIDE" if substr(medicationname,1,8)=="DESONIDE"
            
replace   shortnam = "CARIMUNE" if substr(medicationname,1,8)=="CARIMUNE"
 
replace   shortnam = "CLINDAGEL" if substr(medicationname,1,9)=="CLINDAGEL"
            
replace   shortnam = "DILAUDID" if substr(medicationname,1,8)=="DILAUDID"

replace   shortnam = "GAMMAGARD" if substr(medicationname,1,9)=="GAMMAGARD"
      
replace   shortnam = "DEXAMETHASONE" if substr(medicationname,1,13)=="DEXAMETHASONE"
 
replace   shortnam = "METHADOSE" if substr(medicationname,1,9)=="METHADOSE"         

replace   shortnam = "LEUCOVORIN" if substr(medicationname,1,10)=="LEUCOVORIN"

** DRUGS 841-850          
         
replace   shortnam = "QUINIDINE" if substr(medicationname,1,9)=="QUINIDINE"         

replace   shortnam = "BLEPHAMIDE" if substr(medicationname,1,10)=="BLEPHAMIDE"
              
replace   shortnam = "CEDAX" if substr(medicationname,1,5)=="CEDAX"
           
replace   shortnam = "REMODULIN" if substr(medicationname,1,9)=="REMODULIN"
     
replace   shortnam = "NORTRIPTYLINE" if substr(medicationname,1,13)=="NORTRIPTYLINE"
        
replace   shortnam = "LACLOTION" if substr(medicationname,1,9)=="LACLOTION"
        
replace   shortnam = "CORTISPORIN" if substr(medicationname,1,11)=="CORTISPORIN"
 
replace   shortnam = "CARAC" if substr(medicationname,1,5)=="CARAC"
         
replace   shortnam = "DECLOMYCIN" if substr(medicationname,1,10)=="DECLOMYCIN"

replace   shortnam = "ETOPOSIDE" if substr(medicationname,1,9)=="ETOPOSIDE"


** DRUGS 851-860           

replace   shortnam = "OXYTROL" if substr(medicationname,1,7)=="OXYTROL"            
           
replace   shortnam = "PREVIDENT" if substr(medicationname,1,9)=="PREVIDENT"
    
replace   shortnam = "LUBRIDERM" if substr(medicationname,1,9)=="LUBRIDERM"       
            
replace   shortnam = "DIDREX" if substr(medicationname,1,6)=="DIDREX"
     
replace   shortnam = "DIPHENHYDRAMINE" if substr(medicationname,1,15)=="DIPHENHYDRAMINE"
           
replace   shortnam = "BUPRENEX" if substr(medicationname,1,8)=="BUPRENEX"
 
replace   shortnam = "CLEARASIL" if substr(medicationname,1,9)=="CLEARASIL"          
            
replace   shortnam = "TAGAMET" if substr(medicationname,1,7)=="TAGAMET"          
    
replace   shortnam = "TEARS" if substr(medicationname,1,5)=="TEARS"          

replace   shortnam = "VENTOLIN" if substr(medicationname,1,8)=="VENTOLIN"          

** DRUGS 861-870           
 
replace   shortnam = "UROCIT" if substr(medicationname,1,6)=="UROCIT"             

replace   shortnam = "NORETHINDRONE" if substr(medicationname,1,13)=="NORETHINDRONE"       

replace   shortnam = "CORICIDIN" if substr(medicationname,1,9)=="CORICIDIN"           
           
replace   shortnam = "CONDYLOX" if substr(medicationname,1,8)=="CONDYLOX"
             
replace   shortnam = "DARVON" if substr(medicationname,1,6)=="DARVON"
  
replace   shortnam = "ONXOL" if substr(medicationname,1,5)=="ONXOL"

replace   shortnam = "MICRONASE" if substr(medicationname,1,9)=="MICRONASE"          
 
replace   shortnam = "ALLERGY" if substr(medicationname,1,7)=="ALLERGY"

replace   shortnam = "DIPYRIDAMOLE" if substr(medicationname,1,12)=="DIPYRIDAMOLE"
 
replace   shortnam = "ANALPRAM" if substr(medicationname,1,8)=="ANALPRAM"

** DRUGS 871-880           
           
replace   shortnam = "TRISENOX" if substr(medicationname,1,8)=="TRISENOX"
            
replace   shortnam = "MENEST" if substr(medicationname,1,6)=="MENEST"
 
replace   shortnam = "XYLOCAINE" if substr(medicationname,1,9)=="XYLOCAINE"

replace   shortnam = "PREFEST" if substr(medicationname,1,7)=="PREFEST"             
            
replace   shortnam = "DEMULEN" if substr(medicationname,1,7)=="DEMULEN"             

replace   shortnam = "KETOROLAC" if substr(medicationname,1,9)=="KETOROLAC"          
              
replace   shortnam = "ANUSOL" if substr(medicationname,1,6)=="ANUSOL"

replace   shortnam = "TRI-LUMA" if substr(medicationname,1,8)=="TRI-LUMA"            
           
replace   shortnam = "MINOXIDIL" if substr(medicationname,1,9)=="MINOXIDIL"
  
replace   shortnam = "IMURAN" if substr(medicationname,1,9)=="IMURAN"

** DRUGS 881-890           

replace   shortnam = "FIBERCON" if substr(medicationname,1,8)=="FIBERCON"
 
* what drug is this - too broad
* replace   shortnam = "CLEAR" if substr(medicationname,1,5)=="CLEAR"             
 
replace   shortnam = "MESTINON" if substr(medicationname,1,8)=="MESTINON"   
 
replace   shortnam = "ACTIGALL" if substr(medicationname,1,8)=="ACTIGALL"            
              
replace   shortnam = "OGEN" if substr(medicationname,1,4)=="OGEN"            
 
replace   shortnam = "DIPENTUM" if substr(medicationname,1,8)=="DIPENTUM"
           
replace   shortnam = "CAPTOPRIL" if substr(medicationname,1,9)=="CAPTOPRIL"

replace   shortnam = "CORGARD" if substr(medicationname,1,7)=="CORGARD"      

replace   shortnam = "EVOXAC" if substr(medicationname,1,6)=="EVOXAC"

replace   shortnam = "TARGRETIN" if substr(medicationname,1,9)=="TARGRETIN"

** DRUGS 891-900           

replace   shortnam = "PSORCON" if substr(medicationname,1,7)=="PSORCON"
 
replace   shortnam = "METHYLIN" if substr(medicationname,1,8)=="METHYLIN"           

replace   shortnam = "LACTAID" if substr(medicationname,1,7)=="LACTAID"

replace   shortnam = "NIVEA" if substr(medicationname,1,5)=="NIVEA"              
             
replace   shortnam = "DESYREL" if substr(medicationname,1,7)=="DESYREL"              

replace   shortnam = "VIACTIV" if substr(medicationname,1,7)=="VIACTIV"            

replace   shortnam = "METRONIDAZOLE" if substr(medicationname,1,13)=="METRONIDAZOLE"       
 
* what drug is this - too broad
* replace   shortnam = "ST" if substr(medicationname,1,2)=="ST"                 
  
replace   shortnam = "NASAREL" if substr(medicationname,1,7)=="NASAREL"

replace   shortnam = "MECLIZINE" if substr(medicationname,1,9)=="MECLIZINE"

** DRUGS 901-910          
  
replace   shortnam = "MINITRAN" if substr(medicationname,1,8)=="MINITRAN"
            
replace   shortnam = "VOSPIRE" if substr(medicationname,1,7)=="VOSPIRE"
       
replace   shortnam = "VENOGLOBULIN" if substr(medicationname,1,12)=="VENOGLOBULIN"
              
replace   shortnam = "QUIXIN" if substr(medicationname,1,6)=="QUIXIN"

replace   shortnam = "AMANTADINE" if substr(medicationname,1,10)=="AMANTADINE"
  
replace   shortnam = "VISICOL" if substr(medicationname,1,7)=="VISICOL"
     
replace   shortnam = "COLYTE" if substr(medicationname,1,6)=="COLYTE"

replace   shortnam = "NITROLINGUAL" if substr(medicationname,1,12)=="NITROLINGUAL"
 
* what drugs are these - maybe too broad
* replace   shortnam = "PRENATAL" if substr(medicationname,1,8)=="PRENATAL"     
       
replace   shortnam = "CHLORASEPTIC" if substr(medicationname,1,12)=="CHLORASEPTIC"

** DRUGS 911-920 
      
replace   shortnam = "MIDOL" if substr(medicationname,1,5)=="MIDOL"        
            
replace   shortnam = "LESSINA" if substr(medicationname,1,7)=="LESSINA"        
 
replace   shortnam = "ICY" if substr(medicationname,1,3)=="ICY"           
               
replace   shortnam = "ENTEX" if substr(medicationname,1,5)=="ENTEX"        

replace   shortnam = "SULFASALAZINE" if substr(medicationname,1,13)=="SULFASALAZINE"     

replace   shortnam = "GUAIFENEX" if substr(medicationname,1,9)=="GUAIFENEX"                  
 
replace   shortnam = "BUMETANIDE" if substr(medicationname,1,10)=="BUMETANIDE"        
          
replace   shortnam = "CORDARONE" if substr(medicationname,1,10)=="CORDARONE"        
  
replace   shortnam = "FLUDROCORTISONE" if substr(medicationname,1,15)=="FLUDROCORTISONE"   
 
replace   shortnam = "BUTALB/APAP/CAF/CD" if substr(medicationname,1,18)=="BUTALB/APAP/CAF/CD"   

** DRUGS 921-930 

replace   shortnam = "ALREX" if substr(medicationname,1,5)=="ALREX"              

replace   shortnam = "ASCOMP" if substr(medicationname,1,6)=="ASCOMP"            
 
replace   shortnam = "HYDROMORPHONE" if substr(medicationname,1,13)=="HYDROMORPHONE"     
    
replace   shortnam = "AOSEPT" if substr(medicationname,1,6)=="AOSEPT"         
            
replace   shortnam = "PRINZIDE" if substr(medicationname,1,8)=="PRINZIDE"         

replace   shortnam = "GENTEAL" if substr(medicationname,1,7)=="GENTEAL"             

replace   shortnam = "PROPRANOLOL" if substr(medicationname,1,11)=="PROPRANOLOL"         
           
replace   shortnam = "ACTICIN" if substr(medicationname,1,7)=="ACTICIN"             
 
replace   shortnam = "TESTIM" if substr(medicationname,1,6)=="TESTIM"            

replace   shortnam = "CAPOTEN" if substr(medicationname,1,7)=="CAPOTEN"             

** DRUGS 931-940
              
replace   shortnam = "ERRIN" if substr(medicationname,1,5)=="ERRIN" 

replace   shortnam = "NAFTIN" if substr(medicationname,1,6)=="NAFTIN"

replace   shortnam = "MEFLOQUINE" if substr(medicationname,1,10)=="MEFLOQUINE"

replace   shortnam = "AZELEX" if substr(medicationname,1,6)=="AZELEX"             

replace   shortnam = "ROLAIDS" if substr(medicationname,1,7)=="ROLAIDS"           
              
replace   shortnam = "LEVLEN" if substr(medicationname,1,7)=="LEVLEN"           

replace   shortnam = "DOCUSATE" if substr(medicationname,1,8)=="DOCUSATE"
 
replace   shortnam = "MISOPROSTOL" if substr(medicationname,1,11)=="MISOPROSTOL"

replace   shortnam = "VESANOID" if substr(medicationname,1,8)=="VESANOID"

replace   shortnam = "BACITRACIN" if substr(medicationname,1,10)=="BACITRACIN"
         
** DRUGS 941-950
  
replace   shortnam = "RHOGAM" if substr(medicationname,1,6)=="RHOGAM"            

replace   shortnam = "DOXORUBICIN" if substr(medicationname,1,11)=="DOXORUBICIN"        

replace   shortnam = "NADOLOL" if substr(medicationname,1,7)=="NADOLOL"           
          
replace   shortnam = "CYTOVENE" if substr(medicationname,1,7)=="CYTOVENE"           

replace   shortnam = "BENZOYL" if substr(medicationname,1,7)=="BENZOYL"            
      
replace   shortnam = "SLOW" if substr(medicationname,1,4)=="SLOW"           

replace   shortnam = "BETAMETHASONE" if substr(medicationname,1,13)=="BETAMETHASONE"       
             
replace   shortnam = "NYSTOP" if substr(medicationname,1,6)=="NYSTOP"            
         
replace   shortnam = "METABOLIFE" if substr(medicationname,1,10)=="METABOLIFE"            
                
replace   shortnam = "PRED" if substr(medicationname,1,4)=="PRED"            

** DRUGS 951-960
             
replace   shortnam = "GLYSET" if substr(medicationname,1,6)=="GLYSET"            
 
replace   shortnam = "AMEVIVE" if substr(medicationname,1,7)=="AMEVIVE"           
               
* too broad-- what is this? 
*replace   shortnam = "RID" if substr(medicationname,1,3)=="RID"            
 
replace   shortnam = "SUCRALFATE" if substr(medicationname,1,10)=="SUCRALFATE"         
 
replace   shortnam = "RYNATAN" if substr(medicationname,1,7)=="RYNATAN"                   
 
replace   shortnam = "OXAPROZIN" if substr(medicationname,1,9)=="OXAPROZIN"        
           
replace   shortnam = "FLAGYL" if substr(medicationname,1,6)=="FLAGYL"                   

replace   shortnam = "FOSINOPRIL" if substr(medicationname,1,10)=="FOSINOPRIL"         
 
replace   shortnam = "MOMETASONE" if substr(medicationname,1,10)=="MOMETASONE"         

replace   shortnam = "HUMIBID" if substr(medicationname,1,6)=="HUMIBID"                   
  
** DRUGS 961-970           
           
* careful, other drugs with same prefix  
replace   shortnam = "DILTIA" if substr(medicationname,1,7)=="DILTIA "                   
            
replace   shortnam = "CORZIDE" if substr(medicationname,1,7)=="CORZIDE"                   

replace   shortnam = "RECOMBINATE" if substr(medicationname,1,11)=="RECOMBINATE"       
  
replace   shortnam = "RIFAMPIN" if substr(medicationname,1,8)=="RIFAMPIN"          
           
replace   shortnam = "DERMATOP" if substr(medicationname,1,8)=="DERMATOP"          
          
replace   shortnam = "FLUTAMIDE" if substr(medicationname,1,9)=="FLUTAMIDE"          
         
replace   shortnam = "PENTAZOCINE" if substr(medicationname,1,11)=="PENTAZOCINE"          

replace   shortnam = "FOCALIN" if substr(medicationname,1,7)=="FOCALIN"            
 
replace   shortnam = "AFEDITAB" if substr(medicationname,1,8)=="AFEDITAB"
 
replace   shortnam = "CONTAC" if substr(medicationname,1,6)=="CONTAC"            

** DRUGS 971-980                        

replace   shortnam = "COLACE" if substr(medicationname,1,6)=="COLACE"              
             
replace   shortnam = "TRIPLE" if substr(medicationname,1,6)=="TRIPLE"              
           
replace   shortnam = "ACCUHIST" if substr(medicationname,1,8)=="ACCUHIST"              
              
replace   shortnam = "LOPID" if substr(medicationname,1,5)=="LOPID"              
  
replace   shortnam = "BETIMOL" if substr(medicationname,1,7)=="BETIMOL"           
              
replace   shortnam = "STOOL" if substr(medicationname,1,7)=="STOOL"           
            
replace   shortnam = "ROXICET" if substr(medicationname,1,7)=="ROXICET"           
   
replace   shortnam = "NORPACE" if substr(medicationname,1,7)=="NORPACE"                   
              
replace   shortnam = "CAPEX" if substr(medicationname,1,5)=="CAPEX"                   

replace   shortnam = "DIGOXIN" if substr(medicationname,1,7)=="DIGOXIN"
 
** DRUGS 981-990           
  
* what drug is this - maybe too broad?
* replace   shortnam = "AMMONIUM" if substr(medicationname,1,8)=="AMMONIUM"          
             
replace   shortnam = "D.H.E." if substr(medicationname,1,6)=="D.H.E."
 
replace   shortnam = "NALTREXONE" if substr(medicationname,1,10)=="NALTREXONE"         
            
replace   shortnam = "ERY-TAB" if substr(medicationname,1,7)=="ERY-TAB"
  
replace   shortnam = "BOTOX" if substr(medicationname,1,5)=="BOTOX"
 
replace   shortnam = "FLOLAN" if substr(medicationname,1,6)=="FLOLAN"           
        
replace   shortnam = "DELATESTRYL" if substr(medicationname,1,11)=="DELATESTRYL"         
            
replace   shortnam = "AREDIA" if substr(medicationname,1,6)=="AREDIA"           

replace   shortnam = "SEASONALE" if substr(medicationname,1,9)=="SEASONALE"           
  
replace   shortnam = "KETOPROFEN" if substr(medicationname,1,10)=="KETOPROFEN"           

** DRUGS 991-1000        
 
replace   shortnam = "GAMMAR" if substr(medicationname,1,6)=="GAMMAR"             

replace   shortnam = "MIDAZOLAM" if substr(medicationname,1,9)=="MIDAZOLAM"          
         
replace   shortnam = "MEPERIDINE" if substr(medicationname,1,9)=="MEPERIDINE"          
            
replace   shortnam = "FLEET" if substr(medicationname,1,5)=="FLEET"             
            
replace   shortnam = "VANIQA" if substr(medicationname,1,6)=="VANIQA"             

replace   shortnam = "HEAD & SHOULDERS" if substr(medicationname,1,16)=="HEAD & SHOULDERS"           

replace   shortnam = "SOLARAZE" if substr(medicationname,1,8)=="SOLARAZE"            
          
replace   shortnam = "CLOMIPHENE" if substr(medicationname,1,10)=="CLOMIPHENE"            
            
replace   shortnam = "DEPAKENE" if substr(medicationname,1,8)=="DEPAKENE"            
          
replace   shortnam = "DANTRIUM" if substr(medicationname,1,8)=="DANTRIUM"            
egen totpd_total = sum(pd_total), by(medicationname)
sort medicationname
quietly by medicationname: gen numobs = _N
quietly by medicationname: gen temp = _n

* which relatively high util treatments do we not have shortnam for?

gsort temp - totpd_total
list medicationname totpd_total numobs if temp==1 & _n<=500 & shortnam==""

* replace   shortnam = "" if substr(medicationname,1,)==""

* we'll see what share of scripts for each short name are coded as generic
tab gbo, missing
gen generic = (gbo=="G")
gen brand   = (gbo=="N")

gen mcarpaid = pd_total
replace mcarpaid = 0 if mcarscript!=1

tab mcarscript anymcrpd, missing

sum mcarscript dualscript mcselfscript mcarpaid pd_total generic personwgt if shortnam==""
sum mcarscript dualscript mcselfscript mcarpaid pd_total generic personwgt if shortnam!=""

keep if shortnam!=""
drop medicationname

keep mcarscript dualscript mcselfscript mcarpaid pd_total generic brand personwgt shortnam top500

sort shortnam
quietly by shortnam: gen numscripts = _N

gen wgtpaid = personwgt * pd_total / 1000
egen meps03paid = sum(wgtpaid), by(shortnam)
rename pd_total avgpaid
rename mcarpaid avgmcarpaid

collapse (mean) mcarscript dualscript mcselfscript avgmcarpaid avgpaid generic brand numscripts meps03paid top500 [aw=personwgt], by(shortnam)

rename mcarscript mcar03mepsrx
rename dualscript dual03mepsrx
rename mcselfscript mcself03mepsrx

gen mcar03mepspd = avgmcarpaid / avgpaid

drop avgmcarpaid avgpaid
rename generic gen03meps
rename brand brand03meps
rename numscripts meps03scripts

label var meps03paid "weighted amt paid / 1000"
label var mcar03mepsrx "meps medicare share - weighted script share"
label var dual03mepsrx "dual share - weighted script share"
label var mcself03mepsrx "meps medicare self share - weighted script share"
label var mcar03mepspd "meps medicare share - weighted $ share"
label var gen03meps "fraction of 03 meps scripts generic"
label var brand03meps "fraction of 03 meps scripts brand"
label var meps03scripts "# of scripts in 2003 meps"

sort shortnam
d, fullname
sum

merge shortnam using otc0305
tab _merge
sort _merge
by _merge: sum
rename _merge merge1

label var merge1 "merge of meps 03 to medicaid 03"

sort shortnam
save meps03share
d, fullname
sum

clear

log close

