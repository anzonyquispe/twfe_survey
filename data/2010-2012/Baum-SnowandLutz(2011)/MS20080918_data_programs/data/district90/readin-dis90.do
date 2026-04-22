/** readin-dis90.do
Reads in Common Core of Data for 1989-1990 School Year
**/

clear
set mem 100m
set more off


#delimit ;
infix
  STATECD      1 -  2                                                          
  AGENCYNO     3 -  7                                                          
str14  STID89      8 - 21                                                          
str30  NAME89     22 - 51                                                          
str25  STREET89  52 - 76                                                          
str18  CITY89     77 - 94                                                          
str2  ST89       95 - 96                                                          
  ZIP89       97 -101                                                          
str4  ZIP4      102 -105                                                          
  AREA89     106 -108                                                          
str7  NUMBER89  109 -115                                                          
  TYPE89     116 -116                                                          
  UNION89    117 -119                                                          
  STNUM89    120 -121                                                          
  CONUM89    122 -124                                                          
str25  CONAME89  125 -149                                                          
  CMSA89     150 -155                                                          
  MSC89      156 -156                                                          
str2  GSLO89    157 -158                                                          
str2  GSHI89    159 -160                                                          
  SCH89      161 -165                                                          
  TEACH89    166 -171                                                          
  UG89       172 -177                                                          
  PK12       178 -183                                                          
  MEMBER89   184 -190                                                          
  SPECED89   191 -196                                                          
  REGDIP89   197 -202                                                          
  OTHDIP89   203 -208                                                          
  HSREC89    209 -214                                                          
  OTHCOM89   215 -220                                                          
str1  IDFLAG    221 -221                                                          
using district90-Data.txt ;                                                                             
#delimit cr                                                                               

label variable  STATECD  "NCES assigned ID for each agency"                                
label variable  AGENCYNO "FIPS State number"                                               
label variable  STID89   "STATE AGENCY ID"                                                 
label variable  NAME89   "NAME OF EDUCATION AGENCY"                                        
label variable  STREET89 "MAILING ADDRESS"                                                 
label variable  CITY89   "CITY NAME OF MAILING ADDRESS"                                    
label variable  ST89     "USPS STATE ABBREVIATION"                                         
label variable  ZIP89    "5-DIGIT ZIP CODE"                                                
label variable  ZIP4     "ZIP+4 IF ASSIGNED"                                               
label variable  AREA89   "AREA CODE OF AGENCY"                                             
label variable  NUMBER89 "EXCHANGE AND NUMBER OF AGENCY"                                   
label variable  TYPE89   "TYPE OF AGENCY CODE"                                             
label variable  UNION89  "SUPERVISORY UNION NUMBER"                                        
label variable  STNUM89  "FIPS STATE NUMBER"                                               
label variable  CONUM89  "FIPS COUNTY NUMBER (FIPST+COUNTY)"                               
label variable  CONAME89 "COUNTY NAME"                                                     
label variable  CMSA89   "CMSA/PMSA/MSA CODE"                                              
label variable  MSC89    "METRO STATUS CODE"                                               
label variable  GSLO89   "LOW GRADE SPAN (SCHOOL UNIV)"                                    
label variable  GSHI89   "HIGH GRADE SPAN (SCHOOL UNIV)"                                   
label variable  SCH89    "NUMBER OF SCHOOLS (SCHOOL UNIV)"                                 
label variable  TEACH89  "TOTAL CLASSROOM TEACHERS (SCHOOL)"                               
label variable  UG89     "COUNT OF UNGRADED STUDENTS"                                      
label variable  PK12     "COUNT OF PK THRU 12 STUDENTS"                                    
label variable  MEMBER89 "TOTAL STUDENTS (C01+C02)"                                        
label variable  SPECED89 "COUNT OF SPECIAL ED IEP STUDENTS"                                
label variable  REGDIP89 "COUNT OF REGULAR DIPLOMA GRADUATE"                               
label variable  OTHDIP89 "COUNT OF OTHER DIPLOMA GRADUATES"                                
label variable  HSREC89  "COUNT OF H.S. EQUIV. RECIPIENTS"                                 
label variable  OTHCOM89 "COUNT OF OTHER HS COMPLETERS"                                    
label variable  IDFLAG   "NEW ID FLAG"                                                     

compress

rename STATECD statefips
rename CONUM89 cntyfips
gen str1 type = ""
replace type = "S" if GSHI89=="12"
replace type = "E" if real(GSHI89)~=. & real(GSHI89)<12
replace type = "U" if type=="S" & GSLO89=="KG"|GSLO89=="PK"|GSLO89=="00"|GSLO89=="01"
replace type = "" if TYPE89>2

label variable type "Type of district: Elementary, Secondary or Unified"

save district90.dta, replace


