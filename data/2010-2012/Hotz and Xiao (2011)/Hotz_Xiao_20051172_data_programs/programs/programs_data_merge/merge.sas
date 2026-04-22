/* last updated: Aug 19th; by Mo Xiao */

/* step 1: concatenate 82, 92, and 97 Census data. firms linked by CFN through years.
Note: 1) EIN and EINssl are not unique to an establishment. 
CFN is unique so I use CFN to sort.
Suspect EIN is firm ID instead of establishment ID. 
 2) over years the definition for EIN and EINssl seem to change. 
in 92 some EIN only have 8 digit (that is, without leading zero).  So later
if we need to identify establishments under the same firm, we better use EINssl. */

data base1987na (drop=C002 C079);
 set data_csr.base1987na;
 /*change C002,C079 from character to numeric: a numeric operation will do so */
 month_op=C002+0;
 n_estab=C079+0;
 tmp=EINssl+0;

/*proc freq;
 tables C005 C004;
proc means;
proc print data=base1987na(firstobs=1010 obs=1025); */

data base1992na;
 set data_csr.base1992na;
 rename C002=month_op;
 rename C079=n_estab;
 tmp=EINssl+0;
 
/*proc freq;
 tables C005 C004; 
proc means;
proc print data=base1992na(firstobs=1010 obs=1025); */

data base1997na (drop=C002);
 set data_csr.base1997na;
 /*change C002 from character to numeric*/ 
 month_op=C002+0;
 rename C079=n_estab;
 tmp=EINssl+0;

/*proc freq;
 tables C005 C004;
proc means;
proc print data=base1997na(firstobs=1010 obs=1025);*/
 
data data_csr.census (drop=TKB tmp HASFORM PAP ZIP9BASE LFO PPN);
	/*PPN is not an identifier so I drop it. */ 
 set base1987na base1997na base1992na; /*concatenating*/
 
 if C040>C010+100000 then C040=.; 
 /* if expense exceeds revenue by 100 million, choose not to trust the data.
 expense data seem not trustworthy. lots of zeros. */
 
 if C004=2 then C004=0; /* recode tax-exmept status */
 if length(trim(left(ZIP5)))=4 then ZIP5="0"||trim(left(ZIP5)); 
 /* put leading zeroes in for 4-digit zip codes */
 
 rename C003=LFObase;
 rename C004=tax_xmpt;
 rename C005=non_pft;
 rename C010=revenue;
 rename C030=payroll;
 rename C031=payroll_q1;
 rename C032=n_employ;
 rename C040=expense;
 rename LFO1=type_o;
 rename ZIP=ZIP9;
 label n_estab='# of establishments';
 
 /*Annual Payroll: the gross earnings paid during the calendar year to all employees.
 Legal Form of Organization: individual proprietorship(=1), partnership(=2), misc like gov't(=3 or 4 not sure here)
 corporation(no form of coopreative association=0; corporate or no-corporate=8), 
 or other business entity(=9).
 tax_xmpt: exempt(=1); not exempt(=0)
 non_pft: not for profit(=1); for profit(=2); =0 (show up in 87 only, need to read 87 questionaire?)
     =missing (suspect this is equivalent to 0 in 87)
 Type of Organization: ? think this doesn't matter as will use LFObase */       
   
proc sort; by CFN year EINssl; 

proc contents;
proc means;
proc freq;
 tables tax_xmpt non_pft LFObase; /*need to do some cross checking */
proc print data=data_csr.census(firstobs=1 obs=50);
proc print data=data_csr.census(firstobs=10900 obs=10950);


proc sort; by ZIP9 year;

run;

/*step 2: merge in NAEYC data. Not finished. Error Message*/

data naeyc 
	(keep=naeyc_id naeycname1 naeycname2 naeyc_ad1 naeyc_ad2 naeyc_level naeyc_city naeyc_ST 
	naeyc_ZIP5 ZIP9 naeyc_CTY CNTRY AFFILIATION CLOSE_DATE 
	applic_date visit_date init_accredit valid_until extend_until merit_extend lapse_from lapse_to 
	a_status prog_type length_day LISENSED N_CHILDREN N_GROUPS N_STAFF N_SITES special_service);
 set data_out.naeyc;
 
 if CNTRY=" "; if ST="PR" then delete; /* only keep US observations */
 
 /* need to furthur clean NAEYC data:
 1) determine establishments who did not apply at all 
 2) get rid of all the duplicate records */
 
 rename name1=naeycname1;
 rename name2=naeycname2;
 rename ADDRESS_1=naeyc_ad1;
 rename ADDRESS_2=naeyc_ad2;
 rename LEVEL=naeyc_level;
 rename CITY=naeyc_city;
 rename ST=naeyc_ST;
 rename COUNTY=naeyc_cty;
 rename accredit_status=a_status;
 rename LAPSE_PER__From=lapse_from;
 rename TO=lapse_to;
 
 length naeyc_ZIP5 $5 ZIP9 $9;
 naeyc_ZIP5=substr(LEFT(ZIP),1,5);
 if substr(LEFT(ZIP),7,4)~=" " then ZIP9=naeyc_ZIP5||substr(LEFT(ZIP),7,4);
 /* only a small portion of NAEYC obs have 9 digits zip codes */
 
proc sort; by ZIP9; 

/* matching using 9 digit zip codes */
data zip9match;
 merge naeyc (in=NAEYC) data_csr.census (in=CSR); by ZIP9; 
 /*note: 1) what if ZIP9 is missing in both datasets? will SAS match them? I suspect YES
 2) what if establishment change addresses over years?
 a 1992 establishment might be matched, but its 87 counterpart not.
 3) zip codes may change over time*/
 
 if (ZIP9~=" " & NAEYC=1 & CSR=1) then output zip9match;
 /* output matched obs to zip9match */
 
 proc contents data=zip9match;
 proc print data=zip9match(firstobs=1 obs=30);

data naeyc;
  set naeyc;
  rename naeyc_ZIP5=ZIP5;
  rename ZIP9=naeyc_ZIP9;
  
proc sort data=naeyc; by ZIP5;
proc sort data=data_csr.census; by ZIP5;

/* matching using street adress */
data ad_match rest;
 merge naeyc data_csr.census; by ZIP5;
 if substr(LEFT(naeyc_ad1),1,3)=substr(LEFT(STREET),1,3) 
 	/*& substr(LEFT(naeycname1),1,4)=substr(LEFT(NAME1),1,4)*/
	then output ad_match;
 else output rest;
 
proc print data=ad_match (firstobs=1 obs=15); 

proc print data=rest (firstobs=1 obs=30); 
