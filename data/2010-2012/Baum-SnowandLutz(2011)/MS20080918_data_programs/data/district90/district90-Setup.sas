/*              SAS DATA DEFINITION STATEMENTS FOR ICPSR 2427                  
       COMMON CORE OF DATA: PUBLIC EDUCATION AGENCY UNIVERSE, 1989-1990        
                          1ST ICPSR VERSION                                    
                             AUGUST, 1999                                      
                                                                               
 DATA:  begins a SAS data step and names an output SAS data set.               
                                                                               
 INFILE:  identifies the input file to be read with the input statement.       
 Users must replace the "physical-filename" with host computer specific        
 input file specifications.                                                    
                                                                               
 INPUT:  assigns the name, type, decimal specification (if any), and           
 specifies the beginning and ending column locations for each variable         
 in the data file.                                                             
                                                                               
 LABEL:  assigns descriptive labels to all variables.  Variable labels and     
 variable names may be identical for some variables.                           
                                                                               
 These data definition statements have been tested for compatability           
 with SAS Release 6.11 for UNIX and/or SAS Release 6.11 for Windows. */        
                                                                               
data;                                                                          
infile "physical-filename" lrecl=221 missover pad;                             
missing M N;                                                                   
input                                                                          
  STATECD      1 -  2                                                          
  AGENCYNO     3 -  7                                                          
  STID89   $   8 - 21                                                          
  NAME89   $  22 - 51                                                          
  STREET89 $  52 - 76                                                          
  CITY89   $  77 - 94                                                          
  ST89     $  95 - 96                                                          
  ZIP89       97 -101                                                          
  ZIP4     $ 102 -105                                                          
  AREA89     106 -108                                                          
  NUMBER89 $ 109 -115                                                          
  TYPE89     116 -116                                                          
  UNION89    117 -119                                                          
  STNUM89    120 -121                                                          
  CONUM89    122 -124                                                          
  CONAME89 $ 125 -149                                                          
  CMSA89     150 -155                                                          
  MSC89      156 -156                                                          
  GSLO89   $ 157 -158                                                          
  GSHI89   $ 159 -160                                                          
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
  IDFLAG   $ 221 -221                                                          
 ;                                                                             
                                                                               
LABEL                                                                          
  STATECD  = "NCES assigned ID for each agency"                                
  AGENCYNO = "FIPS State number"                                               
  STID89   = "STATE AGENCY ID"                                                 
  NAME89   = "NAME OF EDUCATION AGENCY"                                        
  STREET89 = "MAILING ADDRESS"                                                 
  CITY89   = "CITY NAME OF MAILING ADDRESS"                                    
  ST89     = "USPS STATE ABBREVIATION"                                         
  ZIP89    = "5-DIGIT ZIP CODE"                                                
  ZIP4     = "ZIP+4 IF ASSIGNED"                                               
  AREA89   = "AREA CODE OF AGENCY"                                             
  NUMBER89 = "EXCHANGE AND NUMBER OF AGENCY"                                   
  TYPE89   = "TYPE OF AGENCY CODE"                                             
  UNION89  = "SUPERVISORY UNION NUMBER"                                        
  STNUM89  = "FIPS STATE NUMBER"                                               
  CONUM89  = "FIPS COUNTY NUMBER (FIPST+COUNTY)"                               
  CONAME89 = "COUNTY NAME"                                                     
  CMSA89   = "CMSA/PMSA/MSA CODE"                                              
  MSC89    = "METRO STATUS CODE"                                               
  GSLO89   = "LOW GRADE SPAN (SCHOOL UNIV)"                                    
  GSHI89   = "HIGH GRADE SPAN (SCHOOL UNIV)"                                   
  SCH89    = "NUMBER OF SCHOOLS (SCHOOL UNIV)"                                 
  TEACH89  = "TOTAL CLASSROOM TEACHERS (SCHOOL)"                               
  UG89     = "COUNT OF UNGRADED STUDENTS"                                      
  PK12     = "COUNT OF PK THRU 12 STUDENTS"                                    
  MEMBER89 = "TOTAL STUDENTS (C01+C02)"                                        
  SPECED89 = "COUNT OF SPECIAL ED IEP STUDENTS"                                
  REGDIP89 = "COUNT OF REGULAR DIPLOMA GRADUATE"                               
  OTHDIP89 = "COUNT OF OTHER DIPLOMA GRADUATES"                                
  HSREC89  = "COUNT OF H.S. EQUIV. RECIPIENTS"                                 
  OTHCOM89 = "COUNT OF OTHER HS COMPLETERS"                                    
  IDFLAG   = "NEW ID FLAG"                                                     
 ;                                                                             
