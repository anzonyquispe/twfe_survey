/* last modified: Aug 19th, 2004; by Mo Xiao*/

/*Step 1: merge 87 base file with 87 ssel (both single unit and multiple unit) by CFN*/

data base1987
	(keep=C002 C003 C004 C005 C010 C030 C031 C032 C040 MSA C079 
	CFN EIN HASFORM PAP STGEO ZIP5 TKB TABFLG PPN);
  set raw_csr.csr1987base;
   if TKB='835100' & TABFLG<100; 
   /* extract childcare centers by TKB code(=MSIC); obs with TABFLG<100 are valid*/
 rename ZIP=ZIP5;
/*in 87 base file, ZIP is the 5 digit Zip*/

proc sort; by CFN;   
/*proc contents;
proc print data=base1987(firstobs=20 obs=29);*/

/* MSIC: 6 digit SIC code.  Seems composed of 4 digit SIC code plus '00';   */ 
    
 data ssl1987su
 (keep=CFN CTYGEO EINssl LFO LFO1 NAME1 NAME2 PLCE PPLCE PST PSTREET PZIP ST STREET ZIP);
  set raw_ssl.ssl1987suna;
  rename EIN=EINssl;

proc sort; by CFN;  

 data ssl1987mu
 (keep=CFN CTYGEO EINssl LFO LFO1 NAME1 NAME2 NAME2A PLCE ST STREET ZIP);
  set raw_ssl.ssl1987muna;
  rename EIN=EINssl;

proc sort; by CFN;  

data base1987na;
 merge base1987 ssl1987su; by CFN;
 if TKB='835100';
 
data data_csr.base1987na;
 merge base1987na ssl1987mu; by CFN;
 if TKB='835100';
 drop TABFLG;
 YEAR=1987;

proc contents; 


/*Step 2: merge 92 base file with 92 ssel by CFN*/   
data base1992
	(keep=C002 C003 C004 C005 C010 C030 C031 C032 C040 MSA C079 
	CFN EIN STGEO ZIP5 ZIP9base TKB TABFLG PPN);
  set raw_csr.csr1992base;
	if TKB='835100' & TABFLG<100; 
	rename ZIP=ZIP9base;
/* in 92 basefile, ZIP is the 9 digit zip */	

/* 1992 and 1997 base files do not have exactly the same variables as the 1987 one */ 

proc sort; by CFN;  
/*proc contents;
proc print data=base1992(firstobs=1020 obs=1029); */
 
data ssl1992su
 (keep=CFN CTYGEO EINssl LFO LFO1 NAME1 NAME2 PLCE PPLCE PST PSTREET PZIP ST STREET ZIP);
  set raw_ssl.ssl1992suna;
  rename EIN=EINssl;
  
proc sort; by CFN; 

 data ssl1992mu
 (keep=CFN CTYGEO EINssl LFO LFO1 NAME1 NAME2 NAME2A PLCE ST STREET ZIP);
  set raw_ssl.ssl1992muna;
  rename EIN=EINssl;

proc sort; by CFN;  

data base1992na;
 merge base1992 ssl1992su; by CFN;
 if TKB='835100';
 
 data data_csr.base1992na;
 merge base1992na ssl1992mu; by CFN;
 if TKB='835100';
 drop TABFLG;
 YEAR=1992;

proc contents; 
 
/*Step 3: merge 97 base file with 97 ssel by CFN*/    
data base1997
	(keep=C002 C003 C004 C005 C010 C030 C031 C032 C040 MSA C079
	 CFN EIN STGEO ZIP5 TKB TABFLG PPN);
  set raw_csr.csr1997base;
if TKB='835100' & TABFLG<100; 
   
/*proc contents;
proc print data=base1997(firstobs=20 obs=29); */
   
data ssl1997su
 (keep=CFN CTYGEO EINssl LFO LFO1 NAME1 NAME2 PLCE PPLCE PST PSTREET PZIP ST STREET ZIP);
  set raw_ssl.ssl1997suna;
 rename EIN=EINssl;

/*proc contents;  */

 data ssl1997mu
 (keep=CFN CTYGEO EINssl LFO LFO1 NAME1 NAME2 NAME2A PLCE ST STREET ZIP);
  set raw_ssl.ssl1997muna;
  rename EIN=EINssl;

proc sort; by CFN;  

data base1997na;
 merge base1997 ssl1997su; by CFN;
 if TKB='835100';
 
data data_csr.base1997na;
 merge base1997na ssl1997mu; by CFN;
 if TKB='835100';
 drop TABFLG;
 YEAR=1997;

proc contents;  

run;