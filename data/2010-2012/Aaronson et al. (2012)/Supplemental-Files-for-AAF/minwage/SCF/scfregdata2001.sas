* All CPI values and minwage values given by e-mail from Dan Aaronson;

libname scftestr 'C:\research\minwage\SCF\real2007';
libname scfout 'C:\research\minwage\SCF';


data temp;
  set scftestr.scfp2001;

  if x4113 = 18 then rinc = x4112 ; /* unit of pay is hourly */
  if x4713 = 18 then sinc = x4712 ; /* unit of pay is hourly */

  if x4113 = 1 then rinc = (x4112*5)/x4110; /* unit of pay is daily, assume 5 days per week and divide by hours per week */
  if x4713 = 1 then sinc = (x4712*5)/x4710 ; /* unit of pay is daily, assume 5 days per week and divide by hours per week */

  if x4113 = 2 then rinc = x4112/x4110; /* unit of pay is weekly, divide by hours per week */
  if x4713 = 2 then sinc = x4712/x4710; /* unit of pay is weekly, divide by hours per week */

  if x4113 = 3 then rinc = (x4112/2)/x4110; /* unit of pay is every 2 weeks, divide by weeks and then hours per week */
  if x4713 = 3 then sinc = (x4712/2)/x4710; /* unit of pay is every 2 weeks, divide by weeks and then hours per week */

  if x4113 = 4 then rinc = (x4112/4.3)/x4110; /* unit of pay is monthly, divide by 4.3 weeks per month, then hours per week */
  if x4713 = 4 then sinc = (x4712/4.3)/x4710; /* unit of pay is monthly, divide by 4.3 weeks per month, then hours per week */

  if x4113 = 5 then rinc = (x4112/13)/x4110; /* unit of pay is quarterly, divide by 13 weeks per quarter, then hours per week */
  if x4713 = 5 then sinc = (x4712/13)/x4710; /* unit of pay is quarterly, divide by 13 weeks per quarter, then hours per week */

  if x4113 = 6 then rinc = (x4112/x4111)/x4110; /* unit of pay is yearly, divide by weeks per year (x4111) then hours per week */
  if x4713 = 6 then sinc = (x4712/x4711)/x4710; /* unit of pay is yearly, divide by weeks per year (x4711) then hours per week */

  if x4113 = 8 then rinc = (x4112/x4111)/x4110; /* unit of pay is lump sum, treat as yearly */
  if x4713 = 8 then sinc = (x4712/x4711)/x4710; /* unit of pay is lump sum, treat as yearly */

  if x4113 = 11 then rinc = (x4112/(x4111/2))/x4110; /* unit of pay is twice per year, modify yearly method */
  if x4713 = 11 then sinc = (x4712/(x4711/2))/x4710; /* unit of pay is twice per year, modify yearly method */

  if x4113 = 18 then rinc = (x4112/8.6)/x4110; /* unit of pay is every two months */
  if x4713 = 18 then sinc = (x4712/8.6)/x4710; /* unit of pay is every two months */
  
  /* 14 = by the job, give up for the moment (luckily we have zero incidents of this atm) */
  /* 22 = varies, give up for the moment (luckily we have zero incidents of this atm) */

  if x4113 = 31 then rinc = (x4112/2.15)/x4110; /* unit of pay is twice a month */
  if x4713 = 31 then sinc = (x4712/2.15)/x4710; /* unit of pay is twice a month */




  if x4132 = 18 then rsinc = x4131 ; /* unit of pay is hourly */
  if x4732 = 18 then ssinc = x4731 ; /* unit of pay is hourly */

  if x4132 = 1 then rsinc = (x4131*5)/x4110; /* unit of pay is daily, assume 5 days per week and divide by hours per week */
  if x4732 = 1 then ssinc = (x4731*5)/x4710 ; /* unit of pay is daily, assume 5 days per week and divide by hours per week */

  if x4132 = 2 then rsinc = x4131/x4110; /* unit of pay is weekly, divide by hours per week */
  if x4732 = 2 then ssinc = x4731/x4710; /* unit of pay is weekly, divide by hours per week */

  if x4132 = 3 then rsinc = (x4131/2)/x4110; /* unit of pay is every 2 weeks, divide by weeks and then hours per week */
  if x4732 = 3 then ssinc = (x4731/2)/x4710; /* unit of pay is every 2 weeks, divide by weeks and then hours per week */

  if x4132 = 4 then rsinc = (x4131/4.3)/x4110; /* unit of pay is monthly, divide by 4.3 weeks per month, then hours per week */
  if x4732 = 4 then ssinc = (x4731/4.3)/x4710; /* unit of pay is monthly, divide by 4.3 weeks per month, then hours per week */

  if x4132 = 5 then rsinc = (x4131/13)/x4110; /* unit of pay is quarterly, divide by 13 weeks per quarter, then hours per week */
  if x4732 = 5 then ssinc = (x4731/13)/x4710; /* unit of pay is quarterly, divide by 13 weeks per quarter, then hours per week */

  if x4132 = 6 then rsinc = (x4131/x4111)/x4110; /* unit of pay is yearly, divide by weeks per year (x4111) then hours per week */
  if x4732 = 6 then ssinc = (x4731/x4711)/x4710; /* unit of pay is yearly, divide by weeks per year (x4711) then hours per week */

  if x4132 = 8 then rsinc = (x4131/x4111)/x4110; /* unit of pay is lump sum, treat as yearly */
  if x4732 = 8 then ssinc = (x4731/x4711)/x4710; /* unit of pay is lump sum, treat as yearly */

  if x4132 = 11 then rsinc = (x4131/(x4111/2))/x4110; /* unit of pay is twice per year, modify yearly method */
  if x4732 = 11 then ssinc = (x4731/(x4711/2))/x4710; /* unit of pay is twice per year, modify yearly method */

  if x4132 = 12 then rsinc = (x4131/8.6)/x4110; /* unit of pay is every two months */
  if x4732 = 12 then ssinc = (x4731/8.6)/x4710; /* unit of pay is every two months */
  
  /* 14 = by the job, give up for the moment (luckily we have zero incidents of this atm) */
  /* 22 = varies, give up for the moment (luckily we have zero incidents of this atm) */

  if x4132 = 31 then rsinc = (x4131/2.15)/x4110; /* unit of pay is twice a month */
  if x4732 = 31 then ssinc = (x4731/2.15)/x4710; /* unit of pay is twice a month */

  if rsinc = . then rsinc = 0;
  if ssinc = . then ssinc = 0;

  if rinc = . then rinc = 0;
  if sinc = . then sinc = 0;
  tinc = sinc + rinc + rsinc + ssinc;
  *tinc = sinc + rinc;
  
  salaryr = (rinc + rsinc) * x4110 * x4111;
  salarys = (sinc + ssinc) * x4710 * x4711;
  salaryt = salaryr + salarys;
  
  * Use the simple average of minwage across the states. Weight the months, if minwage changed midyear;
  *gapr = (5.50 - rinc - rsinc) / 5.50;
  *gaps = (5.50 - sinc - ssinc) / 5.50;
  gapr = (rinc + rsinc - 5.36) / 5.36;
  gaps = (sinc + ssinc - 5.36) / 5.36;

  gap1r = 0;
  if gapr > -.6 and gapr < .2 then gap1r = 1;
  *if gapr >= -.2 then gap1r = 1;
  *if gapr < -.2 then gap1r = 0;
  *if gapr = . then gap1r = 0;

  gap1s = 0;
  if gaps > -.6 and gaps < .2 then gap1s = 1;
  *if gaps >= -.2 then gap1s = 1;
  *if gaps < -.2 then gap1s = 0;
  *if gaps = . then gap1s = 0;

  * I'm setting the total salary on these guys to zero which will remove them. ;
  if gapr > 39 then salaryt = 0;
  if gapr < -.6 and gapr ~= -1 then salaryt = 0;
  if gaps > 39 then salaryt = 0;
  if gaps < -.6 and gaps ~= -1 then salaryt = 0;

  *if gapr > .6 and gapr ~= 1 then salaryt = 0;
  *if gapr < -39 then salaryt = 0;
  *if gaps > .6 and gaps ~= 1 then salaryt = 0;
  *if gaps < -39 then salaryt = 0;

  if salaryt~=0 then do;
    sharemw02 = (salaryr * gap1r + salarys * gap1s) / salaryt;
  end;
  
  minwage = 0;
  if sharemw02 > .2 then minwage = 1;
  if salaryt = 0 then minwage = 0;

  havecc=0;
  if x410=1 then havecc=1;

  minwageworker = 0;
  if gap1r = 1 or gap1s = 1 then minwageworker = 1;

  singlePEU=0;
  if x7020=1 then singlePEU=1;

  rincnz = rinc;
  if rincnz = 0 then rincnz = .;
  sincnz = sinc;
  if sincnz = 0 then sincnz = .;
  tincnz = tinc;
  if tincnz = 0 then tincnz = .;

  *if ((ssinc +sinc) < 1 and (ssinc + sinc) > 0) then somethingcrazy = 1 ;
  if ((rinc +rsinc) < 1 and (rinc + rsinc) > 0) then somethingcrazy = 1 ;

  * Note: we don't have information on number of children living at home, age jumps, or family composition changes, so I can't mirror the construction from the other file.;

  if (rinc+rsinc) < 6 then countinc = 1;
  if X5702 < 20000 then counttax = 1;
  if tinc > 0 then nzinc = 1;
  if x5702 > 0 then nztax = 1;
  *if X5702 < 20000; /* labor wage income */
  if age >= 18;
  if age <= 64;
  if x4106 ~= 2; /*not self employed */
  *if networth < 150000;
  *if networth > -150000;
  housedebt = houses - HOMEEQ;
  vehicleeq = vehic - VEH_INST;
  *if vehic ~= 0; /* temporary subset to answer a question for dan*/
  
  *Change to 2005 dollars;
  pceconvert = 1/.9149;

  year = 2001;
run;

proc means data=temp;
var rinc rsinc sinc ssinc tinc X5702 minwage salarys salaryr salaryt gapr gaps;
where minwage =1;
*where x5702 < 20000;
*where somethingcrazy = 1;
*var tinc x5702 rinc sinc nztax nzinc rincnz sincnz tincnz countinc counttax;
*weight wgt;
run;

/*
proc univariate data=temp;
var NETWORTH;
weight wgt;
run;*/
/*
proc univariate data=temp;
var NETWORTH;
histogram networth / HREF=0;
/* weight wgt;
run;*/
/*
proc insight data=temp;
hist NETWORTH;
run;
*/
/*
PROC GCHART data=temp; 
VBAR networth/ Freq= wgt ;
RUN;
*/
/*
*this is what I use for dan's graphs, remarked out so the run doens't hang.;
proc insight data=temp;
dist vehic / Weight=wgt;
title "value of vehicle";
*tables;
run;
*/


data scfout.regressiondata01;
  set temp;
  keep wageincome financialassets durabledebt financialdebt housedebt homeeq wgt minwage 
       educationdebt creditcard havecc veh_inst minwageworker singlePEU 
       totaldebt totalassets nonfinancialassets vehicles otherinstall otherassets salaryt age year;

  wageincome = X5702;
  vehicles = vehic;
  financialassets = fin;
  durabledebt = install -edn_inst;
  financialdebt = odebt;  
  educationdebt = edn_inst;
  creditcard = ccbal;
  otherassets = OTHNFIN;
  
  salaryt = salaryt*pceconvert;
  totaldebt = DEBT * pceconvert;
  totalassets = ASSET * pceconvert;
  nonfinancialassets = NFIN * pceconvert;

  otherassets = otherassets * pceconvert;
  housedebt = housedebt * pceconvert;
  vehicleeq = vehicleeq * pceconvert;
  homeeq = homeeq * pceconvert;
  wageincome = wageincome * pceconvert;
  durables = durables * pceconvert;
  financialassets = financialassets * pceconvert;
  durabledebt = durabledebt * pceconvert;
  financialdebt = financialdebt * pceconvert;
  educationdebt = educationdebt * pceconvert;
  creditcard =  creditcard * pceconvert;
  veh_inst = veh_inst * pceconvert;
  otherinstall = (install - veh_inst - EDN_INST) * pceconvert;

  
  
run;

PROC EXPORT DATA=scfout.regressiondata01
            OUTFILE="C:\research\minwage\SCF\scfregdata01.csv"
            DBMS=csv REPLACE;
RUN;


/*

CCBAL -> Credit Card Balance
Install -> Installment Debt
EDN_INST -> eduction loan
Veh_inst -> Vehicle installment loan
OUTMARG -> Margin loan (X3932)
FIN-> financial assests 
VEHIC-> value of all vehicles
*   other debts (loans against pensions, loans against life insurance,
    margin loans, miscellaneous);
    ODEBT=OUTPEN1+OUTPEN2+OUTPEN3+OUTPEN4+OUTPEN5+OUTPEN6
      +MAX(0,X4010)+MAX(0,X4032)+OUTMARG;

*/;
