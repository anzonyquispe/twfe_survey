****************************************************************************************************************;
****  This file runs the regressions underlying Table 5 and Figures 3 and 4 of Aaronson, Agarwal, and French;
****  The data is propreitary.  Contact Sumit Agarwal for further details.  
****************************************************************************************************************;


*Create minwage data and regressions;
libname ccdata 'C:\';  
options compress=yes; 

**************************
* Prepare 1995-2008 Data *
**************************;

data minwage2;
	set ccdata.minwage2;

	if income<=20000 then minwage=1; else minwage=0;
	
	* These indicators are not used;
	if 20000<income<=40000 then minwage2=1; else minwage2=0;
	if 40000<income then minwage3=1; else minwage3=0;
	if income=. then delete;
	if income<10 then delete;
	if yearborn<1940 then olddummy=1; else olddummy=0;
	
	
	* Age in 1999;
	AGE=1999-yearborn;

	* Gender;
	if gender_cd in ('F') then female=1; else female=0;
	
	*Married;
	if spouse in ('') then married=0; else married=1;
	
	*Log Income;
	INC  = log(income)-7;
	
	* Probability of Being a Minimum Wage Earner.  The coefficients comes from an analysis of the CPS;
    prob = probnorm(-1.41305 + INC*(-1.71693) + (INC**2)*1.442039 +
           (INC**3)*(-0.3119) + (INC**4)*(-0.02524) +
            AGE*0.277862 + (AGE**2)*(-0.01153) + (AGE**3)*0.000199 +
            (AGE**4)*(-0.00000127) +
            AGE*INC*0.009518 + AGE*(INC**2)*(-0.0013594) + AGE*(INC**3)* 0.0001502 + AGE*(INC**4)*(-0.0000765) +
            FEMALE*(-0.0374138) + MARRIED*0.0627557 + FEMALE*MARRIED*(-0.3456519));

			run;



*Move the monthly payment up by one month so that debt, payments, and purchases align;
data payments;
	set minwage2;
	keep account_number ext_dt cy_pymt_amt;
	by account_number;
	if first.account_number then delete;
	
	
  *Monthly payment date;	
  if ext_dt='199501' then ext_dt='199412'; 
   else if ext_dt='199502' then ext_dt=199501';
   else if ext_dt='199503' then ext_dt=199502';
   else if ext_dt='195504' then ext_dt=195503';
   else if ext_dt='199505' then ext_dt=199504';
   else if ext_dt='199506' then ext_dt=199505';
   else if ext_dt='199507' then ext_dt=199506';
   else if ext_dt='199508' then ext_dt=199507';
   else if ext_dt='199509' then ext_dt=199508';
   else if ext_dt='199510' then ext_dt=199509';
   else if ext_dt='199511' then ext_dt=199510';
   else if ext_dt='199512' then ext_dt=199511';
   else if ext_dt='199601' then ext_dt=199512';
   else if ext_dt='199602' then ext_dt=199601';
   else if ext_dt='199603' then ext_dt=199602';
   else if ext_dt='199604' then ext_dt=199603';
   else if ext_dt='199605' then ext_dt=199604';
   else if ext_dt='199606' then ext_dt=199605';
   else if ext_dt='199607' then ext_dt=199606';
   else if ext_dt='199608' then ext_dt=199607';
   else if ext_dt='199609' then ext_dt=199608';
   else if ext_dt='199610' then ext_dt=199609';
   else if ext_dt='199611' then ext_dt=199610';
   else if ext_dt='199612' then ext_dt=199611';
   else if ext_dt='199701' then ext_dt=199612';
   else if ext_dt='199702' then ext_dt=199701';
   else if ext_dt='199703' then ext_dt=199702';
   else if ext_dt='199704' then ext_dt=199703';
  else if ext_dt='199705' then ext_dt=199704';
  else if ext_dt='199706' then ext_dt=199705';
  else if ext_dt='199707' then ext_dt=199706';
  else if ext_dt='199708' then ext_dt=199707';
  else if ext_dt='199709' then ext_dt=199708';
  else if ext_dt='199710' then ext_dt=199709';
  else if ext_dt='199711' then ext_dt=199710';
  else if ext_dt='199712' then ext_dt=199711';
  else if ext_dt='199801' then ext_dt=199712';
  else if ext_dt='199802' then ext_dt=199801';
  else if ext_dt='199803' then ext_dt=199802';
  else if ext_dt='199804' then ext_dt=199803';
  else if ext_dt='199805' then ext_dt=199804';
  else if ext_dt='199806' then ext_dt=199805';
  else if ext_dt='199807' then ext_dt=199806';
  else if ext_dt='199808' then ext_dt=199807';
  else if ext_dt='199809' then ext_dt=199808';
  else if ext_dt='199810' then ext_dt=199809';
  else if ext_dt='199811' then ext_dt=199810';
  else if ext_dt='199812' then ext_dt=199811';
  else if ext_dt='199901' then ext_dt=199812';
  else if ext_dt='199902' then ext_dt=199901';
  else if ext_dt='199903' then ext_dt=199902';
  else if ext_dt='199904' then ext_dt=199903';
  else if ext_dt='199905' then ext_dt=199904';
  else if ext_dt='199906' then ext_dt=199905';
  else if ext_dt='199907' then ext_dt=199906';
  else if ext_dt='199908' then ext_dt=199907';
  else if ext_dt='199909' then ext_dt=199908';
  else if ext_dt='199910' then ext_dt=199909';
  else if ext_dt='199911' then ext_dt=199910';
  else if ext_dt='199912' then ext_dt=199911';
  else if ext_dt='200001' then ext_dt=199912';
  else if ext_dt='200002' then ext_dt=200001';
  else if ext_dt='200003' then ext_dt=200002';
  else if ext_dt='200004' then ext_dt=200003';
  else if ext_dt='200005' then ext_dt=200004';
  else if ext_dt='200006' then ext_dt=200005';
  else if ext_dt='200007' then ext_dt=200006';
  else if ext_dt='200008' then ext_dt=200007';
  else if ext_dt='200009' then ext_dt=200008';
  else if ext_dt='200010' then ext_dt=200009';
  else if ext_dt='200011' then ext_dt=200010';
  else if ext_dt='200012' then ext_dt=200011';
  else if ext_dt='200101' then ext_dt=200012';
  else if ext_dt='200102' then ext_dt=200101';
  else if ext_dt='200103' then ext_dt=200102';
  else if ext_dt='200104' then ext_dt=200103';
  else if ext_dt='200105' then ext_dt=200104';
  else if ext_dt='200106' then ext_dt=200105';
  else if ext_dt='200107' then ext_dt=200106';
  else if ext_dt='200108' then ext_dt=200107';
  else if ext_dt='200109' then ext_dt=200108';
  else if ext_dt='200110' then ext_dt=200109';
  else if ext_dt='200111' then ext_dt=200110';
  else if ext_dt='200112' then ext_dt=200111';
  else if ext_dt='200201' then ext_dt=200112';
  else if ext_dt='200202' then ext_dt=200201';
  else if ext_dt='200203' then ext_dt=200202';
  else if ext_dt='200204' then ext_dt=200203';
  else if ext_dt='200205' then ext_dt=200204';
  else if ext_dt='200206' then ext_dt=200205';
  else if ext_dt='200207' then ext_dt=200206';
  else if ext_dt='200208' then ext_dt=200207';
  else if ext_dt='200209' then ext_dt=200208';
  else if ext_dt='200210' then ext_dt=200209';
  else if ext_dt='200211' then ext_dt=200210';
  else if ext_dt='200212' then ext_dt=200211';
  else if ext_dt='200301' then ext_dt=200212';
  else if ext_dt='200302' then ext_dt=200301';
  else if ext_dt='200303' then ext_dt=200302';
  else if ext_dt='200304' then ext_dt=200303';
  else if ext_dt='200305' then ext_dt=200304';
  else if ext_dt='200306' then ext_dt=200305';
  else if ext_dt='200307' then ext_dt=200306';
  else if ext_dt='200308' then ext_dt=200307';
  else if ext_dt='200309' then ext_dt=200308';
  else if ext_dt='200310' then ext_dt=200309';
  else if ext_dt='200311' then ext_dt=200310';
  else if ext_dt='200312' then ext_dt=200311';
  else if ext_dt='200401' then ext_dt=200312';
  else if ext_dt='200402' then ext_dt=200401';
  else if ext_dt='200403' then ext_dt=200402';
  else if ext_dt='200404' then ext_dt=200403';
  else if ext_dt='200405' then ext_dt=200404';
  else if ext_dt='200406' then ext_dt=200405';
  else if ext_dt='200407' then ext_dt=200406';
  else if ext_dt='200408' then ext_dt=200407';
  else if ext_dt='200409' then ext_dt=200408';
  else if ext_dt='200410' then ext_dt=200409';
  else if ext_dt='200411' then ext_dt=200410';
  else if ext_dt='200412' then ext_dt=200411';
  else if ext_dt='200501' then ext_dt=200412';
  else if ext_dt='200502' then ext_dt=200501';
  else if ext_dt='200503' then ext_dt=200502';
  else if ext_dt='200504' then ext_dt=200503';
  else if ext_dt='200505' then ext_dt=200504';
  else if ext_dt='200506' then ext_dt=200505';
  else if ext_dt='200507' then ext_dt=200506';
  else if ext_dt='200508' then ext_dt=200507';
  else if ext_dt='200509' then ext_dt=200508';
  else if ext_dt='200510' then ext_dt=200509';
  else if ext_dt='200511' then ext_dt=200510';
  else if ext_dt='200512' then ext_dt=200511';
  else if ext_dt='200601' then ext_dt=200512';
  else if ext_dt='200602' then ext_dt=200601';
  else if ext_dt='200603' then ext_dt=200602';
  else if ext_dt='200604' then ext_dt=200603';
  else if ext_dt='200605' then ext_dt=200604';
  else if ext_dt='200606' then ext_dt=200605';
  else if ext_dt='200607' then ext_dt=200606';
  else if ext_dt='200608' then ext_dt=200607';
  else if ext_dt='200609' then ext_dt=200608';
  else if ext_dt='200610' then ext_dt=200609';
  else if ext_dt='200611' then ext_dt=200610';
  else if ext_dt='200612' then ext_dt=200611';
  else if ext_dt='200701' then ext_dt=200612';
  else if ext_dt='200702' then ext_dt=200701';
  else if ext_dt='200703' then ext_dt=200702';
  else if ext_dt='200704' then ext_dt=200703';
  else if ext_dt='200705' then ext_dt=200704';
  else if ext_dt='200706' then ext_dt=200705';
  else if ext_dt='200707' then ext_dt=200706';
  else if ext_dt='200708' then ext_dt=200707';
  else if ext_dt='200709' then ext_dt=200708';
  else if ext_dt='200710' then ext_dt=200709';
  else if ext_dt='200711' then ext_dt=200710';
  else if ext_dt='200712' then ext_dt=200711';
  else if ext_dt='200801' then ext_dt=200712';
  else if ext_dt='200802' then ext_dt=200801';
  else if ext_dt='200803' then ext_dt=200802';
  else if ext_dt='200804' then ext_dt=200803';
  else if ext_dt='200805' then ext_dt=200804';
  else if ext_dt='200806' then ext_dt=200805';
  else if ext_dt='200807' then ext_dt=200806';
  else if ext_dt='200808' then ext_dt=200807';
  else if ext_dt='200809' then ext_dt=200808';
  else if ext_dt='200810' then ext_dt=200809';
  else if ext_dt='200811' then ext_dt=200810';
  else if ext_dt='200812' then ext_dt=200811';

run;


*Merge Monthly Payment Associated with Month's Spending Back in To Main Dataset;
data minwage21; 
 merge minwage2 (in=ina) payments (in=inb); 
  by account_number ext_dt;
 if ina and inb;
run;

* Get income, debt, line, etc. from 1st month of data;
data util (keep=account_number ourbal1 ofbal1 cr_ln1 debt1 income1 acct_age_use fico1 beh1);
 set minwage21;
 by account_number;

 if first.account_number;
 
 * allow for income growth of 5% since time of application;
 * as below, use balances only if data is valid;
 
 **** Generate "Good Account" Indicator ****;
 if int_st_cd=' ' then intd=1; else intd=0;
 if ext_st_cd=' ' then extd=1; else extd=0;
 if coff_reas_cd=0 then cofd=1; else cofd=0;
 if behav_scor>20 then behd=1; else behd=0;
 if cpd_no_days=>30 then daysd=0;  
 else if cpd_no_days=0 then daysd=0; else daysd=1; 
  
 if intd=1 and extd=1 and cofd=1 and behd=1 and daysd=1 then goodacct=1; 
 else goodacct=0;
 
 * Credit Line in First Month;
 cr_ln1=cr_ln;
 
 * Income in First Month;
 income1=income;
 
 * Credit Card Balance;
 if goodacct=1 then newbal = ls_bal;
 if cy_pymt_amt=0 or cy_pymt_amt=. then debt1=newbal/100; 
 else debt1=(newbal/100)+(cy_pymt_amt/100);

 ourbal1=cur_bal/100;
 ofbal1=ofrut_t_bal;
 
 * Use accounts younger than 12 (months?) ;
 if acct_age<12 then acct_age_use=1; else acct_age_use=0;
 
 *FICO and behaviro score;
 fico1=fico_score;
 beh1=behav_scor;

 run;

* Merge initial measures from above back in to the data;
data minwage22;
 merge minwage21 util; 
 by account_number;
run;

data minwage3;
 
 set minwage22;
 format ssdummy 2.;
 ssdummy=ssnrand;
 curryear=substr(ext_dt,9,2);
 currmth=substr(ext_dt,11,2);
 
 * nb: use the following criteria to exclude 'bad' account-months;
 if int_st_cd=' ' then intd=1; else intd=0;
 
 * the few with int_st=zero are set to bad, since zero isn't an allowed value;
 if ext_st_cd=' ' then extd=1; else extd=0;
 if coff_reas_cd=0 then cofd=1; else cofd=0;
 
 * those with chargeoff reason = . set to bad;
 if behav_scor>20 then behd=1; else behd=0;
 
 * scores less than 20 mean the card hasn't been activated;
 if cpd_no_days=>30 then daysd=0;  
 else if cpd_no_days=0 then daysd=0; else daysd=1; 
 
 * if days is either greater than 31 or 0 then daysd is set to zero;
 * this allows accounts overdue by only 1-30 days as valid;
 
 if intd=1 and extd=1 and cofd=1 and behd=1 and daysd=1 then goodacct=1; 
 else goodacct=0;

 year=substr(ext_dt,7,4);
 

 ******************************************
 * minimum wage history, 1981-2008
 *  note for lags -- 1981 all states are at the federal level of $3.35
 ******************************************;
 year_num = input(year,4);
 month = substr(ext_dt,5,2);
 month = input(month,2);

* federal level;
 usmw = 4.25;
 if (year_num>1996 or (ext_dt in ('199610' '199611' '199612' ))) then usmw = 4.75; 
 else if (year_num>1997 or (ext_dt in ('199709' '199710' '199711' '199712'))) then usmw = 5.15; 
 else if ext_dt in ('200708' '200709' '200710' '200711' '200712' '200801' '200802' '200803' '200804' '200805' '200806' '200807') then usmw = 5.85; 
 else if ext_dt in ('200808' '200809' '200810' '200811' '200812') then usmw = 6.55; 

 mw=usmw;
 
* states -- check codes are right on states . ie same in ce as in cps;
* alaska;
 if state in ('AK') then mw = usmw+0.50;
 if state in ('AK') and year_num>2002 then mw = 7.15;

* arizona;
 if state in ('AZ') and year_num>2006 then mw = 6.75; 
  * cpi adjustment;
 if state in ('AZ') and year_num=2008 then mw = 6.90; 
 if state in ('AZ') and year_num=2009 then mw = 7.25; 

* arkansas;
 if state in ('AR') and year_num=2006 and month>9 then mw =6.25; 
 if state in ('AR') and year_num>2006  then mw =6.25; 
 if state in ('AR') and ((year_num=2008 and month>7) or (year_num=2009 and month<8)) then mw = 6.55; 
 if state in ('AR') and (year_num=2009 and month>7)  then mw = 7.25; 

* calif;
 if state in ('CA') and (year_num>1988 or (year_num=1988 and month>6)) then mw =4.25;
 if state in ('CA') and (year_num>1996 or (year_num=1996 and month>9)) then mw =4.75;
 if state in ('CA') and year_num=1997 and (month>2 and month<9) then mw =5.00;
 if state in ('CA') and ((year_num=1997 and month>8) or (year_num=1998 and month<3)) then mw =5.15;
 if state in ('CA') and year_num=1998 and month>2 then mw =5.75;
 if state in ('CA') and year_num>1998 and year_num<2001 then mw =5.75;
 if state in ('CA') and year_num=2001 then mw =6.25;
 if state in ('CA') and year_num>2001 then mw =6.75;
 if state in ('CA') and year_num=2007 then mw =7.50;
 if state in ('CA') and year_num>2007 then mw =8.00;

* colorado;
 if state in ('CO') and year_num=2007 then mw =6.85;
 * cpi adjustment;
 if state in ('CO') and year_num=2008 then mw =7.02;
 if state in ('CO') and year_num=2009 then mw = 7.28;

* connecticut;
 if state in ('CT') and (year_num>1991 or (year_num=1991 and month>3)) then mw=4.27;
 if state in ('CT') and year_num=1996 and month>9 then mw=4.77;
 if state in ('CT') and year_num=1997 and month<3 then mw=4.77;
 if state in ('CT') and year_num=1997 and (month>2 and month<9) then mw=5.00;
 if state in ('CT') and year_num=1997 and month>8 then mw=5.18;
 if state in ('CT') and year_num=1998 then mw=5.18;
 if state in ('CT') and year_num=1999 then mw=5.65;
 if state in ('CT') and year_num=2000 then mw=6.15;
 if state in ('CT') and year_num=2001 then mw=6.40;
 if state in ('CT') and year_num=2002 then mw=6.70;
 if state in ('CT') and year_num=2003 then mw=6.90;
 if state in ('CT') and year_num>2003 and year_num<2006 then mw=7.10;
 if state in ('CT') and year_num=2006 then mw=7.40;
 if state in ('CT') and year_num=2007 then mw=7.65;
 if state in ('CT') and year_num=2008 then mw=7.65;

* delaware;
 if state in ('DE') and year_num=1999 and month>4 then mw=5.65;
 if state in ('DE') and year_num=2000 and month<10 then mw=5.65;
 if state in ('DE') and year_num=2000 and month>9 then mw=6.15;
 if state in ('DE') and year_num>2000 then mw=6.15;
 if state in ('DE') and year_num=2007 then mw=6.65;
 if state in ('DE') and (year_num=2008 or (year_num=2009 and month<8)) then mw=7.15;
 if state in ('DE') and (year_num=2009 and month>7)  then mw = 7.25;

* florida;
  * cpi adjustment;
 if state in ('FL') and year_num=2006 then mw=6.40;
 if state in ('FL') and year_num=2007 then mw=6.67;
 if state in ('FL') and year_num=2008 then mw=6.79;
 if state in ('FL') and year_num=2009 and month<8 then mw=7.21;
 if state in ('FL') and (year_num=2009 and month>7) then mw = 7.25;

* hawaii;
 if state in ('HI') and year_num>1987 then mw=3.85;
 if state in ('HI') and ((year_num=1992 and month<4) or (year_num=1991 and month>3)) then mw=4.25;
 if state in ('HI') and (year_num=1992 and month>3) then mw=4.75;
 if state in ('HI') and year_num>1992 then mw=5.25;
 if state in ('HI') and year_num=2002 then mw=5.75;
 if state in ('HI') and year_num>2002 and year_num<2006 then mw=6.25;
 if state in ('HI') and year_num=2006 then mw=6.75;
 if state in ('HI') and year_num=2007 and month<7 then mw=7.25;
 if state in ('HI') and year_num>2006 then mw=7.25;

* Illinois ;
 if state in ('IL') and year_num=2004 then mw=5.5;
 if state in ('IL') and year_num>=2005 and year_num<2007 then mw=6.5;
 if state in ('IL') and year_num=2007 and month<7 then mw=6.5;
 if state in ('IL') and ((year_num=2007 and month>6) or (year_num=2008 and  month<7))  then mw=7.5;
 if state in ('IL') and ((year_num=2008 and month>6) or (year_num=2009 and month<7)) then mw=7.75;
 if state in ('IL') and year_num=2009 and month>6 then mw=8;

* Iowa;
 if state in ('IA') and year_num=1990 then mw=3.85;
 if state in ('IA') and year_num=1991 then mw=4.25;
 if state in ('IA') and (year_num>1991 and year_num<1996) then mw=4.65;
 if state in ('IA') and year_num=1996 and month<10 then mw=4.65;
 if state in ('IA') and (year_num=2007 and month>3)  then mw=6.20;
 if state in ('IA') and year_num>2007 then mw = 7.25;

* kentucky;
 if state in ('KY') and year_num=2007 and month>5 then mw=5.85;
 if state in ('KY') and year_num=2008 and month<8 then mw=5.85;
 if state in ('KY') and ((year_num=2008 and month>7) or (year_num=2009 and month<8))  then mw = 6.55;
 if state in ('KY') and (year_num=2009 and month>7)  then mw = 7.25;

* Maine;
 if state in ('ME') and year_num=1985 then mw=3.45;
 if state in ('ME') and year_num=1986 then mw=3.55;
 if state in ('ME') and (year_num=1987 or year_num=1988) then mw=3.65;
 if state in ('ME') and year_num=1989 then mw=3.75;
 if state in ('ME') and year_num=1990 then mw=3.85;
 if state in ('ME') and (year_num=1991 and month<4) then mw=3.85;
 if state in ('ME') and year_num=2002 then mw=5.75;
 if state in ('ME') and year_num=2003 then mw=6.25;
 if state in ('ME') and year_num=2004 then mw=6.25;
 if state in ('ME') and year_num=2005 then mw=6.35;
 if state in ('ME') and year_num=2006 and month<10 then mw=6.50;
 if state in ('ME') and year_num=2006 and month>9 then mw=6.75;
 if state in ('ME') and year_num=2007 and month<10 then mw=6.75;
 if state in ('ME') and ((year_num=2007 and month>9) or (year_num=2008 and month<10)) then mw=7;
 if state in ('ME') and ((year_num=2008 and month>9) or year_num=2009) then mw = 7.25;
 if state in ('ME') and (year_num=2009 and month>9) then mw = 7.5;
* cpi adjustments at least starting in 2009, probably earlier;


* maryland;
 if state in ('MD') and (year_num=2007 or (year_num=2008 and month<8)) then mw=6.15;
 if state in ('MD') and ((year_num=2008 and month>7) or (year_num=2009 and month<8))  then mw = 6.55;
 if state in ('MD') and (year_num=2009 and month>7)  then mw = 7.25; 


* Massachusetts;
 if state in ('MA') and ((year_num=1986 and month>6) or (year_num=1987 and month<7)) then mw=3.55; 
 if state in ('MA') and ((year_num=1987 and month>6) or (year_num=1988 and month<7)) then mw=3.65; 
 if state in ('MA') and ((year_num=1988 and month>6) or (year_num=1989) or (year_num=1990 and month<4)) then mw=3.75; 
 if state in ('MA') and year_num=1996 then mw=4.75; 
 if state in ('MA') and (year_num>1996 and year_num<2000) then mw=5.25; 
 if state in ('MA') and year_num=2000 then mw=6.00; 
 if state in ('MA') and year_num>2000 and year_num<2007 then mw=6.75; 
 if state in ('MA') and year_num=2007 then mw=7.50; 
 if state in ('MA') and year_num>2007 then mw=8.00; 

* michigan;
 if state in ('MI') and year_num=2006 and month>9 then mw=6.95; 
 if state in ('MI') and year_num=2007 and month<7 then mw=6.95; 
 if state in ('MI') and year_num=2007 and month>6 then mw=7.15; 
 if state in ('MI') and year_num=2008 and month<7 then mw=7.15; 
 if state in ('MI') and ((year_num=2008 and month>6) or year_num=2009) then mw=7.40; 

* Minnesota;
 if state in ('MN') and year_num=1988 then mw=3.55; 
 if state in ('MN') and year_num=1989 then mw=3.85; 
 if state in ('MN') and year_num=1990 then mw=3.95; 
 if state in ('MN') and year_num=1991 then mw=4.25; 
 if state in ('MN') and year_num=2005 and month>7 then mw=6.15; 
 if state in ('MN') and year_num>2005 and year_num<2008 then mw=6.15; 
 if state in ('MN') and year_num=2008 and month<8 then mw=6.15; 
 if state in ('MN') and ((year_num=2008 and month>7) or (year_num=2009 and month<8))  then mw = 6.55; 
 if state in ('MN') and (year_num=2009 and month>7)  then mw = 7.25; 

* missouri;
 if state in ('MO') and year_num=2007 then mw=6.5; 
   * cpi adjustment;
 if state in ('MO') and year_num=2008 then mw = 6.65; 
 if state in ('MO') and (year_num=2009 and month<8) then mw= 7.05; 
 if state in ('MO') and (year_num=2009 and month>7)  then mw = 7.25; 


* montana;
 if state in ('MT') and (year_num=2007 or (year_num=2008 and month<8)) then mw=6.15; 
 if state in ('MT') and ((year_num=2008 and month>7) or (year_num=2009 and month<8))  then mw = 6.55; 
 * cpi adjustment;
 if state in ('MT') and (year_num=2009 and month<8) then mw = 6.90; 
 if state in ('MT') and (year_num=2009 and month>7) then mw = 7.25; 

* nevada;
  * cpi adjustment;
 if state in ('NV') and year_num=2006 and month>10 then mw=6.15; 
 if state in ('NV') and (year_num=2007 or (year_num=2008 and month<8)) then mw=6.33; 
 if state in ('NV') and ((year_num=2008 and month>7) or (year_num=2009 and month<8)) then mw = 6.55;  
 if state in ('NV') and (year_num=2009 and month>7) then mw = 7.25;  

* New Hampshire ;
 if state in ('NH') and year_num=1987 then mw=3.45; 
 if state in ('NH') and year_num=1988 then mw=3.55; 
 if state in ('NH') and year_num=1989 then mw=3.65; 
 if state in ('NH') and year_num=1990 and month<4 then mw=3.75; 
 if state in ('NH') and year_num=1991 and month<4 then mw=3.85; 
 if state in ('NH') and ((year_num=2007 and month>8) or (year_num=2008 and month<8)) then mw=6.5; 
 if state in ('NH') and ((year_num=2008 and month>8) or year_num=2009)  then mw = 7.25; 
* note --- increased to $7.55 if do not receive paid health benefits.;


* New Jersey;
 if state in ('NJ') and ((year_num>1992 and year_num<1997) or (year_num=1992 and month>3)) then mw=5.05; 
 if state in ('NJ') and (year_num=1997 and month<9) then mw=5.05; 
 if state in ('NJ') and ((year_num=2005 and month>9) or (year_num=2006 and month<10)) then mw=6.15; 
 if state in ('NJ') and (year_num=2006 and month>9) then mw=7.15; 
 if state in ('NJ') and (year_num=2007 or year_num=2008 or (year_num=2009 and month<8)) then mw=7.15; 
 if state in ('NJ') and (year_num=2009 and month>7)  then mw = 7.25; 

* New Mexico;
 if state in ('NM') and year_num=2008 and month<8 then mw = 6.5; 
 if state in ('NM') and year_num=2008 and month>7 then mw = 6.55; 
 if state in ('NM') and year_num=2009 then mw = 7.5; 


* New York;
 if state in ('NY') and year_num=2005 then mw=6.00; 
 if state in ('NY') and year_num=2006 then mw=6.75; 
 if state in ('NY') and (year_num=2007 or year_num=2008 or (year_num=2009 and month<8)) then mw=7.15; 
 if state in ('NY') and (year_num=2009 and month>7)  then mw = 7.25; 


* north carolina;
 if state in ('NC') and (year_num=2007 or (year_num=2008 and month<8)) then mw=6.15; 
 if state in ('NC') and ((year_num=2008 and month>7) or (year_num=2009 and month<8))  then mw = 6.55; 
 if state in ('NC') and (year_num=2009 and month>7)  then mw = 7.25; 


* north dakota;
 if state in ('ND') and ((year_num=2007 and month>6) or (year_num=2008 and month<8))  then mw=5.85; 
 if state in ('ND') and ((year_num=2008 and month>7) or (year_num=2009 and month<8))  then mw = 6.55; 
 if state in ('ND') and (year_num=2009 and month>7)  then mw = 7.25; 


* ohio;
 if state in ('OH') and year_num>2006 and year_num<2008 then mw=6.85; 
  * cpi adjustment;
 if state in ('OH') and year_num=2008 then mw=7.00; 
 if state in ('OH') and year_num=2009 then mw=7.30; 


* Oregon ;
 if state in ('OR') and (year_num=1989 and month>8) then mw=3.85; 
 if state in ('OR') and year_num=1990 then mw=4.25; 
 if state in ('OR') and (year_num>1990 and year_num<1997) then mw=4.75; 
 if state in ('OR') and year_num=1997 then mw=5.50; 
 if state in ('OR') and year_num=1998 then mw=6.00; 
 if state in ('OR') and year_num>1998 and year_num<2003 then mw=6.50; 
 if state in ('OR') and year_num=2003 then mw=6.90; 
 if state in ('OR') and year_num=2004 then mw=7.05; 
 if state in ('OR') and year_num=2005 then mw=7.25; 
 if state in ('OR') and year_num=2006 then mw=7.50; 
 if state in ('OR') and year_num=2007 then mw=7.80; 
 if state in ('OR') and year_num=2008 then mw=7.95; 
 if state in ('OR') and year_num=2009 then mw=8.40; 


* Pennsylvania ;
 if state in ('PA') and ((year_num=1989 and month>1) or (year_num=1990 and  month<4)) then mw=3.70; 
 if state in ('PA') and year_num=2007 and month<7 then mw=6.25; 
 if state in ('PA') and year_num=2007 and month>6 then mw=7.15; 
 if state in ('PA') and (year_num=2008 or (year_num=2009 and month<8)) then mw=7.15; 
 if state in ('PA') and (year_num=2009 and month>7)  then mw = 7.25; 

* Rhode Island ;
 if state in ('RI') and ((year_num=1986 and month>6) or (year_num=1987 and month<7)) then mw=3.55; 
 if state in ('RI') and ((year_num=1987 and month>6) or (year_num=1988 and month<7)) then mw=3.65; 
 if state in ('RI') and ((year_num=1988 and month>6) or (year_num=1989 and month<8)) then mw=4.00; 
 if state in ('RI') and ((year_num=1989 and month>7) or (year_num=1990) or (year_num=1991 and month<4)) then mw=4.25; 
 if state in ('RI') and ((year_num=1991 and month>3) or (year_num>1991 and year_num<1996)) then mw=4.45; 
 if state in ('RI') and year_num=1996 and month<10 then mw=4.45; 
 if state in ('RI') and year_num=1999 and month>6 then mw=5.65; 
 if state in ('RI') and year_num=2000 and month<9 then mw=5.65; 
 if state in ('RI') and year_num=2000 and month>8 then mw=6.15; 
 if state in ('RI') and year_num>2000 and year_num<2004 then mw=6.15; 
 if state in ('RI') and year_num>2003 and year_num<2007 then mw=6.75; 
 if state in ('RI') and year_num=2006 and month<3 then mw=6.75; 
 if state in ('RI') and year_num=2006 and month>2 then mw=7.10; 
 if state in ('RI') and year_num>2006 then mw=7.40; 


* south dakota;
 if state in ('SD') and ((year_num=2007 and month>6) or (year_num=2008 and month<8))  then mw = 5.85; 
 if state in ('SD') and ((year_num=2008 and month>7) or (year_num=2009 and month<8))  then mw = 6.55;
 if state in ('SD') and (year_num=2009 and month>7)  then mw = 7.25; 


* Vermont ;
 if state in ('VT') and ((year_num=1986 and month>6) or (year_num=1987 and month<7)) then mw=3.45; 
 if state in ('VT') and ((year_num=1987 and month>6) or (year_num=1988 and month<7)) then mw=3.55; 
 if state in ('VT') and ((year_num=1988 and month>6) or (year_num=1989 and month<7)) then mw=3.65; 
 if state in ('VT') and ((year_num=1989 and month>6) or (year_num=1990 and month<4)) then mw=3.75; 
 if state in ('VT') and ((year_num=1990 and month>3) or (year_num=1991 and month<4)) then mw=3.85; 
 if state in ('VT') and year_num=1995 then mw=4.50; 
 if state in ('VT') and year_num=1996 then mw=4.75; 
 if state in ('VT') and year_num=1997 and month>6 and month<10 then mw=5.15; 
 if state in ('VT') and year_num=1997 and month>9 then mw=5.25; 
 if state in ('VT') and year_num=1998 then mw=5.25; 
 if state in ('VT') and year_num=1999 and month<10 then mw=5.25; 
 if state in ('VT') and year_num=1999 and month>9 then mw=5.75; 
 if state in ('VT') and year_num=2000 then mw=5.75; 
 if state in ('VT') and year_num=2001 then mw=6.25; 
 if state in ('VT') and year_num=2002 then mw=6.25; 
 if state in ('VT') and year_num=2003 then mw=6.25; 
 if state in ('VT') and year_num=2004 then mw=6.75; 
 if state in ('VT') and year_num=2005 then mw=7.00; 
 if state in ('VT') and year_num=2006 then mw=7.25; 
 if state in ('VT') and year_num=2007 then mw=7.53; 
 if state in ('VT') and year_num=2008 then mw=7.68; 
 if state in ('VT') and year_num=2009 then mw=8.06; 

* Washington ;
 if state in ('WA') and year_num=1989 then mw=3.85 ; 
 if state in ('WA') and (year_num=1990 or year_num=1991) then mw=4.25 ; 
 if state in ('WA') and (year_num>1993 and year_num<1997) then mw=4.90 ; 
 if state in ('WA') and year_num=1997 and month<9 then mw=4.90 ; 
 if state in ('WA') and year_num=1999 then mw=5.70 ; 
 if state in ('WA') and year_num=2000 then mw=6.50 ; 
* cpi adjusted from here on out;
 if state in ('WA') and year_num=2001 then mw=6.72 ; 
 if state in ('WA') and year_num=2002 then mw=6.90 ; 
 if state in ('WA') and year_num=2003 then mw=7.01 ; 
 if state in ('WA') and year_num=2004 then mw=7.16 ; 
 if state in ('WA') and year_num=2005 then mw=7.35 ; 
 if state in ('WA') and year_num=2006 then mw=7.63 ; 
 if state in ('WA') and year_num=2007 then mw=7.93 ; 
 if state in ('WA') and year_num=2008 then mw=8.07 ; 
 if state in ('WA') and year_num=2009 then mw=8.55 ; 


* west virginia;
 if state in ('WV') and year_num=2006 and month>6 then mw=5.85 ; 
 if state in ('WV') and year_num=2007 and month<7 then mw=5.85 ; 
 if state in ('WV') and ((year_num=2007 and month>6) or (year_num=2008 and month<7)) then mw=6.55 ; 
 if state in ('WV') and ((year_num=2008 and month>6) or year_num=2009) then mw = 7.25; 


* wisconsin;
 if state in ('WI') and year_num=2005 and month>5 then mw=5.70; 
 if state in ('WI') and year_num=2006 and month<6 then mw=5.70; 
 if state in ('WI') and ((year_num=2006 and month>5) or year_num=2007) then mw=6.50; 
 if state in ('WI') and year_num=2008 and month<8 then mw=6.50; 
 if state in ('WI') and ((year_num=2008 and month>7) or (year_num=2009 and month<8)) then mw = 6.55; 
 if state in ('WI') and (year_num=2009 and month>7)  then mw = 7.25; 


 if goodacct=0 or ls_bal=. then mw=.;
 mw=mw*prob;
 
 * distinguish singles (sflag) and couples (cflag);
 if spouse=' '  then cflag=0; else cflag=1;
 if cflag=0 then sflag=1; else sflag=0;
 
 ***************************************************************
 * Create the main LHS variables, measures of account activity *
 ***************************************************************;
 * Many purchases and payments are falsely set to missing when they should be zero;
 
 if cy_pur_amt=. then purd=1; else purd=0;
 if cy_pymt_amt=. then pymtd=1; else pymtd=0;
 if cy_csh_amt=. then cshd=1; else cshd=0;
 
 ************
 * Spending *
 ************;
 if cy_pur_amt=0 or cy_pur_amt=. then spending=0;
  else spending=cy_pur_amt/100;
 
 ******************
 * Payment Amount *
 ******************;
 if cy_pymt_amt=0 or cy_pymt_amt=. then payment=0; 
  else payment=-(cy_pymt_amt/100);
 
 ***************
 * Cash amount *
 ***************;
 if cy_csh_amt=0 or cy_csh_amt=. then cash=0; 
  else cash=cy_csh_amt/100;
 
 ********************
 * Credit Card Debt *
 ********************; 
 if goodacct=1 then newbal = ls_bal;
 if cy_pymt_amt=0 or cy_pymt_amt=. then debt=newbal/100; 
  else debt=(newbal/100)+(cy_pymt_amt/100);

 **************************************************************
 * Set Variables to Missing if Bad Account or Missing Balance *
 **************************************************************;
 if goodacct=0 or ls_bal=. then spending=.;
 if goodacct=0 or ls_bal=. then payment=.;
 if goodacct=0 or ls_bal=. then cash=.;
 if goodacct=0 or ls_bal=. then debt=.;

 ******************************
 * Change in Credit Card Debt *
 ******************************;
 ldebt=lag(debt);
 ddebt=debt-ldebt;
 if ddebt=. then ddebt=0;
 
 *********************************
 * Change in Credit Card Balance *
 *********************************;
 lnewbal=lag(newbal);
 dnewbal=newbal-lnewbal;
 
 ************
 * Residual *
 ************;
 lpayment=lag(payment);
 resid=(newbal/100)-(lnewbal/100)+lpayment-spending-cash;
 
 *******************************************
 * Set Variables to Missing if Bad Account *
 *******************************************;
 if goodacct=0 then ddebt=.;
 if goodacct=0 then resid=.;
 
 ****************************
 * Instition's Card Balance *
 ****************************;
 newbal2 = cur_bal;
 if newbal2=. then newbal2=0; 
 if goodacct=0 or ls_bal=. then newbal2=.;
 ourbal=newbal2/100;
 lourbal=lag(ourbal);
 dourbal=ourbal-lourbal;
 if goodacct=0 or ls_bal=. then dourbal=.;
 
 ******************************************
 * Percent of Credit Limit Being Utilized *
 ******************************************;
 * cur_bal, newbal, and ourbal refer to balances (not debt) at the end of the calendar month (ls_bal is balances at the end of the cycle);
 
 utilx=100*((debt)/cr_ln);
 utily=100*((ourbal)/cr_ln);
 utila=100*((dourbal)/cr_ln);
 utilb=100*((ddebt)/cr_ln);
 
 if goodacct=0 or ls_bal=. then utila=.;
 if goodacct=0 or ls_bal=. then utilb=.;
 if goodacct=0 or ls_bal=. then utilx=.;
 if goodacct=0 or ls_bal=. then utily=.;
 
 *******************
 * Remaining limit *
 *******************;
 remlimit=cr_ln1-debt1;
 spendratio=(spending/remlimit);
 if spending<0 then spendratio=.;
 if remlimit<10 then spendratio=.;
 if spendratio<0 then spendratio=.;

 ******************************
 * Additional Spending Ratios *
 ******************************;
 spending2=spending/cr_ln1;
 spending3=spending/income1;

 if goodacct=0 or ls_bal=. then spendratio=.;
 if goodacct=0 or ls_bal=. then spending2=.;
 if goodacct=0 or ls_bal=. then spending3=.;
 
 ************************
 * Lags of Credit Limit *
 ************************;
 lcr_ln=lag(cr_ln); 
 l2cr_ln=lag(lcr_ln); 
 l3cr_ln=lag(l2cr_ln); 
 l4cr_ln=lag(l3cr_ln); 
 l5cr_ln=lag(l4cr_ln); 
 l6cr_ln=lag(l5cr_ln); 
 l7cr_ln=lag(l6cr_ln); 
 l8cr_ln=lag(l7cr_ln); 
 l9cr_ln=lag(l8cr_ln); 
 
 ***************************
 * Credit bureau variables *
 ***************************;
 ofbal=ofrut_t_bal;
 
 * Average Mortgage Balance Over Quarter;
 mtgbal=mtg_tot_bal/3;
 
 * Average Home Equity Balance Over Quarter ; 
 helbal=hmeq_tot_bal/3;

 * Average Auto Loan Balance Over Quarter ;
 autobal=bal_auto/3;
 
 * Total Loan Balance + New Credit Card Debt: This is not divided by 3 because above measures each of its components already are;
 allbal=ddebt+mtgbal+helbal+autobal;

 * Total Balance Less Mortgage Debt;
 allbal_nomtg = ddebt+helbal+autobal;
 
 
 * Lags of Total Loan Balance;
 lallbal=lag(allbal);
 l2allbal=lag(lallbal);
 l3allbal=lag(l2allbal);
 
 * Lags of Credit Bureau Balance;
 lofbal=lag(ofbal);
 l2ofbal=lag(lofbal);
 l3ofbal=lag(l2ofbal);
 
 * Lags of Auto Balances ;
 lautobal=lag(autobal);
 l2autobal=lag(lautobal);
 l3autobal=lag(l2autobal);
 
 * Lags of Mortgage Balance;
 lmtgbal=lag(mtgbal);
 l2mtgbal=lag(lmtgbal);
 l3mtgbal=lag(l2mtgbal);
 
 * Lags of Home Equity Loan Balances;
 lhelbal=lag(helbal);
 l2helbal=lag(lhelbal);
 l3helbal=lag(l2helbal);
 
 * Change in Balances ;
 dallbal=(allbal-l3allbal)/3;
 dofbal=(ofbal-l3ofbal)/3;
 dmtgbal=(mtgbal-l3mtgbal)/3;
 dhelbal=(helbal-l3helbal)/3;
 dautobal=(autobal-l3autobal)/3;
 dallbal=(allbal-l3allbal)/3;

 ************************************************************
 * Set Changes to Missing if Bad Account of Missing Balance *
 ************************************************************;
 if goodacct=0 or ls_bal=. then dallbal=.;
 if goodacct=0 or ls_bal=. then dofbal=.;
 if goodacct=0 or ls_bal=. then dmtgbal=.;
 if goodacct=0 or ls_bal=. then dhelbal=.;
 if goodacct=0 or ls_bal=. then dautobal=.;
 if goodacct=0 or ls_bal=. then cr_ln=.;

 * State dummies ;
 if state in ('AL') then st1=1 ;
  else st1 = 0;
 if state in ('AK') then st2=1 ;
   else st2 = 0;
 if state in ('AZ') then st3=1 ;
   else st3 = 0;
 if state in ('AR') then st4=1 ;
   else st4 = 0;
 if state in ('CA') then st5=1 ;
   else st5 = 0;
 if state in ('CO') then st6=1 ;
   else st6 = 0;
 if state in ('CT') then st7=1 ;
   else st7 = 0;
 if state in ('DE') then st8=1 ;
   else st8 = 0;
 if state in ('DC') then st9=1 ;
   else st9 = 0;
 if state in ('FL') then st10=1 ;
   else st10 = 0;
 if state in ('GA') then st11=1 ;
   else st11 = 0;
 if state in ('HI') then st12=1 ;
   else st12 = 0;
 if state in ('ID') then st13=1 ;
   else st13 = 0;
 if state in ('IL') then st14=1 ;
   else st14 = 0;
 if state in ('IN') then st15=1 ;
   else st15 = 0;
 if state in ('IA') then st16=1 ;
   else st16 = 0;
 if state in ('KS') then st17=1 ;
   else st17 = 0;
 if state in ('KY') then st18=1 ;
   else st18 = 0;
 if state in ('LA') then st19=1 ;
   else st19 = 0;
 if state in ('ME') then st20=1 ;
   else st20 = 0;
 if state in ('MD') then st21=1 ;
   else st21 = 0;
 if state in ('MA') then st22=1 ;
   else st22 = 0;
 if state in ('MI') then st23=1 ;
   else st23 = 0;
 if state in ('MN') then st24=1 ;
   else st24 = 0;
 if state in ('MS') then st25=1 ;
   else st25 = 0;
 if state in ('MO') then st26=1 ;
   else st26 = 0;
 if state in ('MT') then st27=1 ;
   else st27 = 0;
 if state in ('NE') then st28=1 ;
   else st28 = 0;
 if state in ('NV') then st29=1 ;
   else st29 = 0;
 if state in ('NH') then st30=1 ;
   else st30 = 0;
 if state in ('NJ') then st31=1 ;
   else st31 = 0;
 if state in ('NM') then st32=1 ;
   else st32 = 0;
 if state in ('NY') then st33=1 ;
   else st33 = 0;
 if state in ('NC') then st34=1 ;
   else st34 = 0;
 if state in ('ND') then st35=1 ;
   else st35 = 0;
 if state in ('OH') then st36=1 ;
   else st36 = 0;
 if state in ('OK') then st37=1 ;
   else st37 = 0;
 if state in ('OR') then st38=1 ;
   else st38 = 0;
 if state in ('PA') then st39=1 ;
   else st39 = 0;
 if state in ('RI') then st40=1 ;
   else st40 = 0;
 if state in ('SC') then st41=1 ;
   else st41 = 0;
 if state in ('SD') then st42=1 ;
   else st42 = 0;
 if state in ('TN') then st43=1 ;
   else st43 = 0;
 if state in ('TX') then st44=1 ;
   else st44 = 0;
 if state in ('UT') then st45=1 ;
   else st45 = 0;
 if state in ('VT') then st46=1 ;
   else st46 = 0;
 if state in ('VA') then st47=1 ;
   else st47 = 0;
 if state in ('WA') then st48=1 ;
   else st48 = 0;
 if state in ('WV') then st49=1 ;
   else st49 = 0;
 if state in ('WI') then st50=1 ;
   else st50 = 0;
 if state in ('WY') then st51=1 ;
   else st51 = 0;
  
 * Month-Year Dummies;
 if ext_dt='199501' then md9501=1; else md9501=0;
 if ext_dt='199502' then md9502=1; else md9502=0;
 if ext_dt='199503' then md9503=1; else md9503=0;
 if ext_dt='199504' then md9504=1; else md9504=0;
 if ext_dt='199505' then md9505=1; else md9505=0;
 if ext_dt='199506' then md9506=1; else md9506=0;
 if ext_dt='199507' then md9507=1; else md9507=0;
 if ext_dt='199508' then md9508=1; else md9508=0;
 if ext_dt='199509' then md9509=1; else md9509=0;
 if ext_dt='199510' then md9510=1; else md9510=0;
 if ext_dt='199511' then md9511=1; else md9511=0;
 if ext_dt='199512' then md9512=1; else md9512=0;
 if ext_dt='199601' then md9601=1; else md9601=0;
 if ext_dt='199602' then md9602=1; else md9602=0;
 if ext_dt='199603' then md9603=1; else md9603=0;
 if ext_dt='199604' then md9604=1; else md9604=0;
 if ext_dt='199605' then md9605=1; else md9605=0;
 if ext_dt='199606' then md9606=1; else md9606=0;
 if ext_dt='199607' then md9607=1; else md9607=0;
 if ext_dt='199608' then md9608=1; else md9608=0;
 if ext_dt='199609' then md9609=1; else md9609=0;
 if ext_dt='199610' then md9610=1; else md9610=0;
 if ext_dt='199611' then md9611=1; else md9611=0;
 if ext_dt='199612' then md9612=1; else md9612=0;
 if ext_dt='199701' then md9701=1; else md9701=0;
 if ext_dt='199702' then md9702=1; else md9702=0;
 if ext_dt='199703' then md9703=1; else md9703=0;
 if ext_dt='199704' then md9704=1; else md9704=0;
 if ext_dt='199705' then md9705=1; else md9705=0;
 if ext_dt='199706' then md9706=1; else md9706=0;
 if ext_dt='199707' then md9707=1; else md9707=0;
 if ext_dt='199708' then md9708=1; else md9708=0;
 if ext_dt='199709' then md9709=1; else md9709=0;
 if ext_dt='199710' then md9710=1; else md9710=0;
 if ext_dt='199711' then md9711=1; else md9711=0;
 if ext_dt='199712' then md9712=1; else md9712=0;
 if ext_dt='199801' then md9801=1; else md9801=0;
 if ext_dt='199802' then md9802=1; else md9802=0;
 if ext_dt='199803' then md9803=1; else md9803=0;
 if ext_dt='199804' then md9804=1; else md9804=0;
 if ext_dt='199805' then md9805=1; else md9805=0;
 if ext_dt='199806' then md9806=1; else md9806=0;
 if ext_dt='199807' then md9807=1; else md9807=0;
 if ext_dt='199808' then md9808=1; else md9808=0;
 if ext_dt='199809' then md9809=1; else md9809=0;
 if ext_dt='199810' then md9810=1; else md9810=0;
 if ext_dt='199811' then md9811=1; else md9811=0;
 if ext_dt='199812' then md9812=1; else md9812=0;
 if ext_dt='199901' then md9901=1; else md9901=0;
 if ext_dt='199902' then md9902=1; else md9902=0;
 if ext_dt='199903' then md9903=1; else md9903=0;
 if ext_dt='199904' then md9904=1; else md9904=0;
 if ext_dt='199905' then md9905=1; else md9905=0;
 if ext_dt='199906' then md9906=1; else md9906=0;
 if ext_dt='199907' then md9907=1; else md9907=0;
 if ext_dt='199908' then md9908=1; else md9908=0;
 if ext_dt='199909' then md9909=1; else md9909=0;
 if ext_dt='199910' then md9910=1; else md9910=0;
 if ext_dt='199911' then md9911=1; else md9911=0;
 if ext_dt='199912' then md9912=1; else md9912=0;
 if ext_dt='200001' then md0001=1; else md0001=0;
 if ext_dt='200002' then md0002=1; else md0002=0;
 if ext_dt='200003' then md0003=1; else md0003=0;
 if ext_dt='200004' then md0004=1; else md0004=0;
 if ext_dt='200005' then md0005=1; else md0005=0;
 if ext_dt='200006' then md0006=1; else md0006=0;
 if ext_dt='200007' then md0007=1; else md0007=0;
 if ext_dt='200008' then md0008=1; else md0008=0;
 if ext_dt='200009' then md0009=1; else md0009=0;
 if ext_dt='200010' then md0010=1; else md0010=0;
 if ext_dt='200011' then md0011=1; else md0011=0;
 if ext_dt='200012' then md0012=1; else md0012=0;
 if ext_dt='200101' then md0101=1; else md0101=0;
 if ext_dt='200102' then md0102=1; else md0102=0;
 if ext_dt='200103' then md0103=1; else md0103=0;
 if ext_dt='200104' then md0104=1; else md0104=0;
 if ext_dt='200105' then md0105=1; else md0105=0;
 if ext_dt='200106' then md0106=1; else md0106=0;
 if ext_dt='200107' then md0107=1; else md0107=0;
 if ext_dt='200108' then md0108=1; else md0108=0;
 if ext_dt='200109' then md0109=1; else md0109=0;
 if ext_dt='200110' then md0110=1; else md0110=0;
 if ext_dt='200111' then md0111=1; else md0111=0;
 if ext_dt='200112' then md0112=1; else md0112=0;
 if ext_dt='200201' then md0201=1; else md0201=0;
 if ext_dt='200202' then md0202=1; else md0202=0;
 if ext_dt='200203' then md0203=1; else md0203=0;
 if ext_dt='200204' then md0204=1; else md0204=0;
 if ext_dt='200205' then md0205=1; else md0205=0;
 if ext_dt='200206' then md0206=1; else md0206=0;
 if ext_dt='200207' then md0207=1; else md0207=0;
 if ext_dt='200208' then md0208=1; else md0208=0;
 if ext_dt='200209' then md0209=1; else md0209=0;
 if ext_dt='200210' then md0210=1; else md0210=0;
 if ext_dt='200211' then md0211=1; else md0211=0;
 if ext_dt='200212' then md0212=1; else md0212=0;
 if ext_dt='200301' then md0301=1; else md0301=0;
 if ext_dt='200302' then md0302=1; else md0302=0;
 if ext_dt='200303' then md0303=1; else md0303=0;
 if ext_dt='200304' then md0304=1; else md0304=0;
 if ext_dt='200305' then md0305=1; else md0305=0;
 if ext_dt='200306' then md0306=1; else md0306=0;
 if ext_dt='200307' then md0307=1; else md0307=0;
 if ext_dt='200308' then md0308=1; else md0308=0;
 if ext_dt='200309' then md0309=1; else md0309=0;
 if ext_dt='200310' then md0310=1; else md0310=0;
 if ext_dt='200311' then md0311=1; else md0311=0;
 if ext_dt='200312' then md0312=1; else md0312=0;
 if ext_dt='200401' then md0401=1; else md0401=0;
 if ext_dt='200402' then md0402=1; else md0402=0;
 if ext_dt='200403' then md0403=1; else md0403=0;
 if ext_dt='200404' then md0404=1; else md0404=0;
 if ext_dt='200405' then md0405=1; else md0405=0;
 if ext_dt='200406' then md0406=1; else md0406=0;
 if ext_dt='200407' then md0407=1; else md0407=0;
 if ext_dt='200408' then md0408=1; else md0408=0;
 if ext_dt='200409' then md0409=1; else md0409=0;
 if ext_dt='200410' then md0410=1; else md0410=0;
 if ext_dt='200411' then md0411=1; else md0411=0;
 if ext_dt='200412' then md0412=1; else md0412=0;
 if ext_dt='200501' then md0501=1; else md0501=0;
 if ext_dt='200502' then md0502=1; else md0502=0;
 if ext_dt='200503' then md0503=1; else md0503=0;
 if ext_dt='200504' then md0504=1; else md0504=0;
 if ext_dt='200505' then md0505=1; else md0505=0;
 if ext_dt='200506' then md0506=1; else md0506=0;
 if ext_dt='200507' then md0507=1; else md0507=0;
 if ext_dt='200508' then md0508=1; else md0508=0;
 if ext_dt='200509' then md0509=1; else md0509=0;
 if ext_dt='200510' then md0510=1; else md0510=0;
 if ext_dt='200511' then md0511=1; else md0511=0;
 if ext_dt='200512' then md0512=1; else md0512=0;
 if ext_dt='200601' then md0601=1; else md0601=0;
 if ext_dt='200602' then md0602=1; else md0602=0;
 if ext_dt='200603' then md0603=1; else md0603=0;
 if ext_dt='200604' then md0604=1; else md0604=0;
 if ext_dt='200605' then md0605=1; else md0605=0;
 if ext_dt='200606' then md0606=1; else md0606=0;
 if ext_dt='200607' then md0607=1; else md0607=0;
 if ext_dt='200608' then md0608=1; else md0608=0;
 if ext_dt='200609' then md0609=1; else md0609=0;
 if ext_dt='200610' then md0610=1; else md0610=0;
 if ext_dt='200611' then md0611=1; else md0611=0;
 if ext_dt='200612' then md0612=1; else md0612=0;
 if ext_dt='200701' then md0701=1; else md0701=0;
 if ext_dt='200702' then md0702=1; else md0702=0;
 if ext_dt='200703' then md0703=1; else md0703=0;
 if ext_dt='200704' then md0704=1; else md0704=0;
 if ext_dt='200705' then md0705=1; else md0705=0;
 if ext_dt='200706' then md0706=1; else md0706=0;
 if ext_dt='200707' then md0707=1; else md0707=0;
 if ext_dt='200708' then md0708=1; else md0708=0;
 if ext_dt='200709' then md0709=1; else md0709=0;
 if ext_dt='200710' then md0710=1; else md0710=0;
 if ext_dt='200711' then md0711=1; else md0711=0;
 if ext_dt='200712' then md0712=1; else md0712=0;
 if ext_dt='200801' then md0801=1; else md0801=0;
 if ext_dt='200802' then md0802=1; else md0802=0;
 if ext_dt='200803' then md0803=1; else md0803=0;
 if ext_dt='200804' then md0804=1; else md0804=0;
 if ext_dt='200805' then md0805=1; else md0805=0;
 if ext_dt='200806' then md0806=1; else md0806=0;
 if ext_dt='200807' then md0807=1; else md0807=0;
 if ext_dt='200808' then md0808=1; else md0808=0;
 if ext_dt='200809' then md0809=1; else md0809=0;
 if ext_dt='200810' then md0810=1; else md0810=0;
 if ext_dt='200811' then md0811=1; else md0811=0;
 if ext_dt='200812' then md0812=1; else md0812=0;

 * Time Trend;
  if ext_dt='199501' then time = 0
 else if ext_dt='199502' then time = 1
 else if ext_dt='199503' then time = 2
 else if ext_dt='199504' then time = 3
 else if ext_dt='199505' then time = 4
 else if ext_dt='199506' then time = 5
 else if ext_dt='199507' then time = 6
 else if ext_dt='199508' then time = 7
 else if ext_dt='199509' then time = 8
 else if ext_dt='199510' then time = 9
 else if ext_dt='199511' then time = 10
 else if ext_dt='199512' then time = 11
 else if ext_dt='199601' then time = 12
 else if ext_dt='199602' then time = 13
 else if ext_dt='199603' then time = 14
 else if ext_dt='199604' then time = 15
 else if ext_dt='199605' then time = 16
 else if ext_dt='199606' then time = 17
 else if ext_dt='199607' then time = 18
 else if ext_dt='199608' then time = 19
 else if ext_dt='199609' then time = 20
 else if ext_dt='199610' then time = 21
 else if ext_dt='199611' then time = 22
 else if ext_dt='199612' then time = 23
 else if ext_dt='199701' then time = 24
 else if ext_dt='199702' then time = 25
 else if ext_dt='199703' then time = 26
 else if ext_dt='199704' then time = 27
 else if ext_dt='199705' then time = 28
 else if ext_dt='199706' then time = 29
 else if ext_dt='199707' then time = 30
 else if ext_dt='199708' then time = 31
 else if ext_dt='199709' then time = 32
 else if ext_dt='199710' then time = 33
 else if ext_dt='199711' then time = 34
 else if ext_dt='199712' then time = 35
 else if ext_dt='199801' then time = 36
 else if ext_dt='199802' then time = 37
 else if ext_dt='199803' then time = 38
 else if ext_dt='199804' then time = 39
 else if ext_dt='199805' then time = 40
 else if ext_dt='199806' then time = 41
 else if ext_dt='199807' then time = 42
 else if ext_dt='199808' then time = 43
 else if ext_dt='199809' then time = 44
 else if ext_dt='199810' then time = 45
 else if ext_dt='199811' then time = 46
 else if ext_dt='199812' then time = 47
 else if ext_dt='199901' then time = 48
 else if ext_dt='199902' then time = 49
 else if ext_dt='199903' then time = 50
 else if ext_dt='199904' then time = 51
 else if ext_dt='199905' then time = 52
 else if ext_dt='199906' then time = 53
 else if ext_dt='199907' then time = 54
 else if ext_dt='199908' then time = 55
 else if ext_dt='199909' then time = 56
 else if ext_dt='199910' then time = 57
 else if ext_dt='199911' then time = 58
 else if ext_dt='199912' then time = 59
 else if ext_dt='200001' then time = 60
 else if ext_dt='200002' then time = 61
 else if ext_dt='200003' then time = 62
 else if ext_dt='200004' then time = 63
 else if ext_dt='200005' then time = 64
 else if ext_dt='200006' then time = 65
 else if ext_dt='200007' then time = 66
 else if ext_dt='200008' then time = 67
 else if ext_dt='200009' then time = 68
 else if ext_dt='200010' then time = 69
 else if ext_dt='200011' then time = 70
 else if ext_dt='200012' then time = 71
 else if ext_dt='200101' then time = 72
 else if ext_dt='200102' then time = 73
 else if ext_dt='200103' then time = 74
 else if ext_dt='200104' then time = 75
 else if ext_dt='200105' then time = 76
 else if ext_dt='200106' then time = 77
 else if ext_dt='200107' then time = 78
 else if ext_dt='200108' then time = 79
 else if ext_dt='200109' then time = 80
 else if ext_dt='200110' then time = 81
 else if ext_dt='200111' then time = 82
 else if ext_dt='200112' then time = 83
 else if ext_dt='200201' then time = 84
 else if ext_dt='200202' then time = 85
 else if ext_dt='200203' then time = 86
 else if ext_dt='200204' then time = 87
 else if ext_dt='200205' then time = 88
 else if ext_dt='200206' then time = 89
 else if ext_dt='200207' then time = 90
 else if ext_dt='200208' then time = 91
 else if ext_dt='200209' then time = 92
 else if ext_dt='200210' then time = 93
 else if ext_dt='200211' then time = 94
 else if ext_dt='200212' then time = 95
 else if ext_dt='200301' then time = 96
 else if ext_dt='200302' then time = 97
 else if ext_dt='200303' then time = 98
 else if ext_dt='200304' then time = 99
 else if ext_dt='200305' then time = 100
 else if ext_dt='200306' then time = 101
 else if ext_dt='200307' then time = 102
 else if ext_dt='200308' then time = 103
 else if ext_dt='200309' then time = 104
 else if ext_dt='200310' then time = 105
 else if ext_dt='200311' then time = 106
 else if ext_dt='200312' then time = 107
 else if ext_dt='200401' then time = 108
 else if ext_dt='200402' then time = 109
 else if ext_dt='200403' then time = 110
 else if ext_dt='200404' then time = 111
 else if ext_dt='200405' then time = 112
 else if ext_dt='200406' then time = 113
 else if ext_dt='200407' then time = 114
 else if ext_dt='200408' then time = 115
 else if ext_dt='200409' then time = 116
 else if ext_dt='200410' then time = 117
 else if ext_dt='200411' then time = 118
 else if ext_dt='200412' then time = 119
 else if ext_dt='200501' then time = 120
 else if ext_dt='200502' then time = 121
 else if ext_dt='200503' then time = 122
 else if ext_dt='200504' then time = 123
 else if ext_dt='200505' then time = 124
 else if ext_dt='200506' then time = 125
 else if ext_dt='200507' then time = 126
 else if ext_dt='200508' then time = 127
 else if ext_dt='200509' then time = 128
 else if ext_dt='200510' then time = 129
 else if ext_dt='200511' then time = 130
 else if ext_dt='200512' then time = 131
 else if ext_dt='200601' then time = 132
 else if ext_dt='200602' then time = 133
 else if ext_dt='200603' then time = 134
 else if ext_dt='200604' then time = 135
 else if ext_dt='200605' then time = 136
 else if ext_dt='200606' then time = 137
 else if ext_dt='200607' then time = 138
 else if ext_dt='200608' then time = 139
 else if ext_dt='200609' then time = 140
 else if ext_dt='200610' then time = 141
 else if ext_dt='200611' then time = 142
 else if ext_dt='200612' then time = 143
 else if ext_dt='200701' then time = 144
 else if ext_dt='200702' then time = 145
 else if ext_dt='200703' then time = 146
 else if ext_dt='200704' then time = 147
 else if ext_dt='200705' then time = 148
 else if ext_dt='200706' then time = 149
 else if ext_dt='200707' then time = 150
 else if ext_dt='200708' then time = 151
 else if ext_dt='200709' then time = 152
 else if ext_dt='200710' then time = 153
 else if ext_dt='200711' then time = 154
 else if ext_dt='200712' then time = 155
 else if ext_dt='200801' then time = 156
 else if ext_dt='200802' then time = 157
 else if ext_dt='200803' then time = 158
 else if ext_dt='200804' then time = 159
 else if ext_dt='200805' then time = 160
 else if ext_dt='200806' then time = 161
 else if ext_dt='200807' then time = 162
 else if ext_dt='200808' then time = 163
 else if ext_dt='200809' then time = 164
 else if ext_dt='200810' then time = 165
 else if ext_dt='200811' then time = 166
 else if ext_dt='200812' then time = 167

 time2 = time*time
 
 * Year Dummies;
 if curryear=95 then yd95=1; else yd95=0;
 if curryear=96 then yd96=1; else yd96=0;
 if curryear=97 then yd97=1; else yd97=0;
 if curryear=98 then yd98=1; else yd98=0;
 if curryear=99 then yd98=1; else yd99=0;
 if curryear=00 then yd00=1; else yd00=0;
 if curryear=01 then yd01=1; else yd01=0;
 if curryear=02 then yd02=1; else yd02=0;
 if curryear=03 then yd03=1; else yd03=0;
 if curryear=04 then yd04=1; else yd04=0;
 if curryear=05 then yd05=1; else yd05=0;
 if curryear=06 then yd06=1; else yd06=0;
 if curryear=07 then yd07=1; else yd07=0;
 if curryear=08 then yd08=1; else yd08=0; 

 *Month Dummies;
 if currmth=01 then md01=1; else md01=0;
 if currmth=02 then md02=1; else md02=0;
 if currmth=03 then md03=1; else md03=0;
 if currmth=04 then md04=1; else md04=0;
 if currmth=05 then md05=1; else md05=0;
 if currmth=06 then md06=1; else md06=0;
 if currmth=07 then md07=1; else md07=0;
 if currmth=08 then md08=1; else md08=0;
 if currmth=09 then md09=1; else md09=0;
 if currmth=10 then md10=1; else md10=0;
 if currmth=11 then md11=1; else md11=0;

 *Other information about the account ;
 seas=acct_age; lseas=lag(seas); 
 stmt_dt=substr(last_stmt_dt,5,6);
 curr_dt=substr(ext_dt,7,6);
 month=substr(ext_dt,11,2); 

 * Convert monetary variables that we use to real values ;
 pce = 0;
 if year_num = 1995 then pce = 0.8204 ;
  else if year_num = 1996 then pce = 0.8383 ;
  else if year_num = 1997 then pce = 0.8539 ;
  else if year_num = 1998 then pce = 0.8621 ;
  else if year_num = 1999 then pce = 0.8760 ;
  else if year_num = 2000 then pce = 0.8978 ;
  else if year_num = 2001 then pce = 0.9149 ;
  else if year_num = 2002 then pce = 0.9274 ;
  else if year_num = 2003 then pce = 0.9462 ;
  else if year_num = 2004 then pce = 0.9710 ;
  else if year_num = 2005 then pce = 1.0000 ;
  else if year_num = 2006 then pce = 1.0275 ;
  else if year_num = 2007 then pce = 1.0550 ;
  else if year_num = 2008 then pce = 1.0903 ;
 
 mw_nominal = mw;
 autobal_nominal = autobal ;
 helbal_nominal = helbal ;
 mtgbal_nominal = mtgbal ;
 debt_nominal = debt ;
 ddebt_nominal = ddebt ;
 allbal_nominal = allbal ;
 allbal_nomtg_nominal = allbal_nomtg ;
 income_nominal = income ;
 
 mw  = mw / pce;
 autobal = autobal / pce;
 helbal = helbal / pce;
 mtgbal = mtgbal / pce;
 debt = debt / pce;
 ddebt = ddebt / pce ;
 allbal = allbal / pce ;
 allbal_nomtg = allbal_nomtg / pce ;
 income = income / pce;


 ****************
 * Minwage Lags *
 ****************;
 
 * We always limit variable to valid data before lagging the variable;
 lmw=lag(mw); 
 l2mw=lag(lmw); 
 l3mw=lag(l2mw); 
 l4mw=lag(l3mw); 
 l5mw=lag(l4mw); 
 l6mw=lag(l5mw); 
 l7mw=lag(l6mw); 
 l8mw=lag(l7mw); 
 l9mw=lag(l8mw); 
 l10mw=lag(l9mw); 
 l11mw=lag(l10mw); 
 l12mw=lag(l11mw); 
 l13mw=lag(l12mw); 
 l14mw=lag(l13mw); 
 l15mw=lag(l14mw); 
 l16mw=lag(l15mw); 
 l17mw=lag(l16mw); 
 l18mw=lag(l17mw); 
 l19mw=lag(l18mw); 
 l20mw=lag(l19mw); 
 l21mw=lag(l20mw); 
 l22mw=lag(l21mw); 
 l23mw=lag(l22mw); 
 l24mw=lag(l23mw); 
 l25mw=lag(l24mw); 
 l26mw=lag(l25mw); 
 l27mw=lag(l26mw); 
 l28mw=lag(l27mw); 
 l29mw=lag(l28mw); 

 
run;


************************
* Create Minwage Leads *
************************;
data minwage4;
  merge minwage3 minwage3(firstobs=2 rename=(mw=mwlead) keep=mw);
  if mw=mwlead then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead=mwlead2) keep=mwlead);
  if mwlead=mwlead2 then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead2=mwlead3) keep=mwlead2);
  if mwlead2=mwlead3 then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead3=mwlead4) keep=mwlead3);
  if mwlead3=mwlead4 then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead4=mwlead5) keep=mwlead4);
  if mwlead4=mwlead5 then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead5=mwlead6) keep=mwlead5);
  if mwlead5=mwlead6 then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead6=mwlead7) keep=mwlead6);
  if mwlead6=mwlead7 then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead7=mwlead8) keep=mwlead7);
  if mwlead7=mwlead8 then match='YES';
  else match='NO';
run;

data minwage4;
  merge minwage4 minwage4(firstobs=2 rename=(mwlead8=mwlead9) keep=mwlead8);
  if mwlead8=mwlead9 then match='YES';
  else match='NO';
run;

*********************** Samples for Analysis ********************;

*******************
* Table 5 Samples *
*******************;
* Sample with inc <= $20,000;
data minwage_less20k;
 set minwage4;
 if income > 20000 then delete;
run; 
proc means; run;

proc sort data=minwage_less20k;
  by account_number state; 
run;

* Sample with inc > $20,000;
data minwage_more20k;
 set minwage4;
 if income le 20000 then delete;
run; 

proc sort data=minwage_more20k;
  by account_number state; 
run;


********************
* Figure 3 Samples *
********************;
data minwage_figure3_more20k;
 set minwage_0004; * Hypothetical 4 year panel sample;
 if income le 20000 then delete;
run; 

proc sort data=minwage_figure3_more20k; 
 by account_number state; 
run;

data minwage_figure3_less20k;
 set minwage_0004; * Hypothetical 4 year panel sample;
 if income > 20000 then delete;
run; 

proc sort data=minwage_figure3_less20k; 
 by account_number state; 
run;


*****************
* Figure 4 Data *
*****************;

%let fig4_varlist =  mw s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 
     s18 s19 s20 s21 s22  s23 s24 s25 s26 s27 s28 s29 s30 s31 s32 s33 s34 s35 s36 s37  
	 s38 s39 s40 s41 s42  s43 s44 s45 s46 s47 s48 s49 s50 s51 time time2;


*Means of variables for "fixed effect";
proc means data = minwage_less20k noprint;
 by account_number;
 var %fig4_varlist;
 out=fig4_less20k_mean mean / autoname ; 
run; 

proc sort data = minwage_less20k ;
 by account_number ext_dt;
run;

proc sort data = fig4_less20k_mean ;
 by account_number  ext_dt;
run;

data fig4_less20k; 
  merge minwage_less20k(in=a) fig4_less20k_mean(in=b);
  by account_number ext_dt;
  if a;
  
  *Demean variables;
  fe_allbal_nomtg = allbal_nomtg - allbal_nomtg_mean; *Need to check what names the autoname option gave the variables;
  
  %do i = 1 %to %wordcount(&fig4_varlist) ;
    %let var = %scan(&fig4_varlist,&i);
	fe_&var = &var - &var_mean;
  %end;
run;

proc means data = minwage_more20k noprint;
 by account_number;
 var %fig4_varlist;
 out=fig4_less20k_mean mean / autoname ; 
run; 

proc sort data = minwage_more20k ;
 by account_number ext_dt;
run;

proc sort data = fig4_more20k_mean ;
 by account_number  ext_dt;
run;


data fig4_more20k; 
  merge minwage_more20k(in=a) fig4_more20k_mean(in=b);
  by account_number  ext_dt;
  if a;
  
  *Demean variables;
  fe_allbal_nomtg = allbal_nomtg - allbal_nomtg_mean; *Need to check what names the autoname option gave the variables;
  
  %do i = 1 %to %wordcount(&fig4_varlist) ;
    %let var = %scan(&fig4_varlist,&i);
	fe_&var = &var - &var_mean;
  %end;
run;


***********************
* Table 5 Regressions *
***********************;

%let varlist = md9501 md9502 md9503 md9504 md9505 md9506 md9507 md9508 md9509 md9510 md9511 md9512
               md9601 md9602 md9603 md9604 md9605 md9606 md9607 md9608 md9609 md9610 md9611 md9612
               md9701 md9702 md9703 md9704 md9705 md9706 md9707 md9708 md9709 md9710 md9711 md9712
               md9801 md9802 md9803 md9804 md9805 md9806 md9807 md9808 md9809 md9810 md9811 md9812
               md9901 md9902 md9903 md9904 md9905 md9906 md9907 md9908 md9909 md9910 md9911 md9912
               md0001 md0002 md0003 md0004 md0005 md0006 md0007 md0008 md0009 md0010 md0011 md0012
               md0101 md0102 md0103 md0104 md0105 md0106 md0107 md0108 md0109 md0110 md0111 md0112
               md0201 md0202 md0203 md0204 md0205 md0206 md0207 md0208 md0209 md0210 md0211 md0212
               md0301 md0302 md0303 md0304 md0305 md0306 md0307 md0308 md0309 md0310 md0311 md0312
               md0401 md0402 md0403 md0404 md0405 md0406 md0407 md0408 md0409 md0410 md0411 md0412
               md0501 md0502 md0503 md0504 md0505 md0506 md0507 md0508 md0509 md0510 md0511 md0512
               md0601 md0602 md0603 md0604 md0605 md0606 md0607 md0608 md0609 md0610 md0611 md0612
               md0701 md0702 md0703 md0704 md0705 md0706 md0707 md0708 md0709 md0710 md0711 md0712
               md0801 md0802 md0803 md0804 md0805 md0806 md0807 md0808 md0809 md0810 md0811 md0812;

*************
* Auto Debt *
*************;

* >= $20,000;
* proc surveyreg will give clustered standard errors;
proc surveyreg data=minwage_more20k;
 class account_number state;
 cluster account_number;
 model autobal = %varlist mw;
run; 

proc glm data=minwage_more20k; 
 model autobal = %varlist mw;
 absorb account_number state;
run;

* < $20,000;
proc surveyreg data=minwage_less20k;
 class account_number state;
 cluster account_number;
 model autobal = %varlist mw;
run; 

proc glm data=minwage_less20k; 
 model autobal = %varlist mw;
 absorb account_number state;
run;


********************
* Home Equity Debt *
********************;
* >= $20,000;
proc surveyreg data=minwage_more20k;
 class account_number state;
 cluster account_number;
 model helbal = %varlist mw;
run; 

* < $20,000;
proc surveyreg data=minwage_less20k;
 class account_number state;
 cluster account_number;
 model helbal = %varlist mw;
run; 


*****************
* Mortgage Debt *
*****************;
* >= $20,000;
proc surveyreg data=minwage_more20k;
 class account_number state;
 cluster account_number;
 model mtgbal = %varlist mw;
run; 

* < $20,000;
proc surveyreg data=minwage_less20k;
 class account_number state;
 cluster account_number;
 model mtgbal = %varlist mw;
run; 

********************
* Credit Card Debt *
********************;

* >= $20,000;
proc surveyreg data=minwage_more20k;
 class account_number state;
 cluster account_number;
 model ddebt = %varlist mw;
run; 

* < $20,000;
proc surveyreg data=minwage_less20k;
 class account_number state;
 cluster account_number;
 model ddebt = %varlist mw;
run; 

**************
* Total Debt *
**************;
* >= $20,000;
proc surveyreg data=minwage_more20k;
 class account_number state;
 cluster account_number;
 model allbal = %varlist mw;
run; 

* < $20,000;
proc surveyreg data=minwage_less20k;
 class account_number state;
 cluster account_number;
 model allbal = %varlist mw;
run; 

*********************************
* Total Debt Less Mortgage Debt *
*********************************;
* >= $20,000;
proc surveyreg data=minwage_more20k;
 class account_number state;
 cluster account_number;
 model allbal_nomtg = %varlist mw;
run; 

* < $20,000;
proc surveyreg data=minwage_less20k;
 class account_number state;
 cluster account_number;
 model allbal_nomtg = %varlist mw;
run; 


********************
* Create Figure 3  *
* Use 4 year panel *
********************;

************************
* Figure 3 Regressions *
************************;


* Every month from 2000 to 2003;
%let varlist = md0001 md0002 md0003 md0004 md0005 md0006 md0007 md0008 md0009 md0010 md0011 md0012
               md0101 md0102 md0103 md0104 md0105 md0106 md0107 md0108 md0109 md0110 md0111 md0112
               md0201 md0202 md0203 md0204 md0205 md0206 md0207 md0208 md0209 md0210 md0211 md0212
               md0301 md0302 md0303 md0304 md0305 md0306 md0307 md0308 md0309 md0310 md0311 md0312;


			   
proc surveyreg data=figure3_less20k; 
 class account_number state;
 cluster account_number;

 model allbal_nomtg = %varlist  mwlead9 mwlead8 mwlead7 mwlead6 mwlead5 mwlead4 mwlead3 mwlead2 mwlead mw lmw l2mw l3mw l4mw l5mw l6mw l7mw l8mw 
                      l9mw l10mw l11mw l12mw l13mw l14mw l15mw l16mw l17mw l18mw l19mw l20mw l21mw l22mw l23mw l24mw l25mw l26mw l27mw l28mw l29mw  ;

  *3 Quarters before minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 ;
 
 *2 Quarters before minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1  ;
 
  *1 Quarter before minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1  ;
 
 *Quarter of minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1  l2mw 1  ;
 
 *1 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 ;
 
 *2 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 ;
 
 *3 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 ;
 
 *4 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1  ;
 
  *5 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 ;
 
  *6 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1  ;
 
 *7 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1 l21mw 1 l22mw 1 l23mw 1 ;

 
 *8 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1 l21mw 1 l22mw 1 l23mw 1 l24mw 1 l25mw 1 l26mw 1  ;
				 
 *9 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1 l21mw 1 l22mw 1 l23mw 1 l24mw 1 l25mw 1 l26mw 1 
				 l27mw 1 l28mw 1 l29mw 1 	;
				 
 run;



proc surveyreg data=figure3_more20k; 
 class account_number state;
 cluster account_number;

 model allbal_nomtg = %varlist  mwlead9 mwlead8 mwlead7 mwlead6 mwlead5 mwlead4 mwlead3 mwlead2 mwlead mw lmw l2mw l3mw l4mw l5mw l6mw l7mw l8mw 
                      l9mw l10mw l11mw l12mw l13mw l14mw l15mw l16mw l17mw l18mw l19mw l20mw l21mw l22mw l23mw l24mw l25mw l26mw l27mw l28mw l29mw  ;

  *3 Quarters before minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 ;
 
 *2 Quarters before minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1  ;
 
  *1 Quarter before minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1  ;
 
 *Quarter of minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1  l2mw 1  ;
 
 *1 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 ;
 
 *2 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 ;
 
 *3 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 ;
 
 *4 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1  ;
 
  *5 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 ;
 
  *6 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1  ;
 
 *7 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1 l21mw 1 l22mw 1 l23mw 1 ;

 
 *8 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1 l21mw 1 l22mw 1 l23mw 1 l24mw 1 l25mw 1 l26mw 1  ;
				 
 *9 quarters after minimum wage increase;
 estimate 'cum2' mwlead9 1 mwlead8 1 mwlead7 1 mwlead6 1 mwlead5 1 mwlead4 1 mwlead3 1 mwlead2 1 mwlead 1 mw 1 lmw 1 
				 l2mw 1 l3mw 1 l4mw 1 l5mw 1 l6mw 1 l7mw 1 l8mw 1 l9mw 1 l10mw 1 l11mw 1 l12mw 1 l13mw 1 l14mw 1 l15mw 1 
				 l16mw 1 l17mw 1 l18mw 1 l19mw 1 l20mw 1 l21mw 1 l22mw 1 l23mw 1 l24mw 1 l25mw 1 l26mw 1 
				 l27mw 1 l28mw 1 l29mw 1 	;
				 
 run;



************
* Figure 4 *
************

%let fig4_covariates = fe_s1 fe_s2 fe_s3 fe_s4 fe_s5 fe_s6 fe_s7 fe_s8 fe_s9 fe_s10 fe_s11 fe_s12 fe_s13 fe_s14 fe_s15 fe_s16 fe_s17 
     fe_s18 fe_s19 fe_s20 fe_s21 fe_s22  fe_s23 fe_s24 fe_s25 fe_s26 fe_s27 fe_s28 fe_s29 fe_s30 fe_s31 fe_s32 fe_s33 fe_s34 fe_s35 fe_s36 fe_s37  
	 fe_s38 fe_s39 fe_s40 fe_s41 fe_s42  fe_s43 fe_s44 fe_s45 fe_s46 fe_s47 fe_s48 fe_s49 fe_s50 fe_s51 
	 fe_time fe_time2 ;

proc quantreg data=fig4_less20k;
 model fe_allbal_nomtg = fe_mw %fig4_covariates 
     / quantile = 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 0.98 ;
run;	 

proc quantreg data=fig4_more20k;
 model fe_allbal_nomtg = fe_mw %fig4_covariates 
     / quantile = 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 0.98 ;
run;	 