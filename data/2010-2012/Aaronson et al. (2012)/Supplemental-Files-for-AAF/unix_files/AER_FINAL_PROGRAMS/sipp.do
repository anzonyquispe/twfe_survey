***********************************************************************
* Program to replicate Aaronson, Agarwal, French Minimum Wage Results *
* that use the Survey of Income and Program Participation             *
***********************************************************************

clear all
set mem 5g 
capture log close

log using rep_sipp_cleandata.log, replace
use rep_sipp1.dta

*********************
* Identify Families *
*********************

*Generate family id*
* See Chapter 10 of SIPP users guide for details
sort spanel su_id hh_add rfid lgtmon 
egen famid = group(spanel su_id hh_add rfid lgtmon)
  
*Generate Family Size*
sort famid 
by famid: egen temp_famsize = seq()
by famid: egen famsize = max(temp_famsize)
count if missing(famsize) & ~missing(temp_famsize)
drop temp_famsize
tab famsize
tab famsize spanel	

gen kid = 1 if age<18
gen adult = 1 if age>=18
by famid: egen kids=count(kid)
by famid: egen adults=count(adult)
drop kid adult

* Generate Female Indicator
gen female = .
replace female = 0 if sex==1
replace female = 1 if sex==2
 
**************************************
* Identify Household Head and Spouse *
**************************************

gen head = 1 if rrp==1 | rrp==2
gen spouse = 1 if rrp== 3 | rrp==10 // 10 is unmarried partner of reference person

by famid: egen nheads = count(head)
by famid: egen nspouses = count(spouse)
tab nheads
tab nspouses

replace head = . if rrp==2 & nheads==2
drop nheads
by famid: egen nheads = count(head)
tab nheads 
drop nheads nspouses

sort spanel su_id lgtmon
by spanel su_id lgtmon: egen nheads=count(head)
by spanel su_id lgtmon: egen nspouses=count(spouse)
tab nheads
tab nspouses

destring pp_pnum, replace
by spanel su_id lgtmon: egen minpnum = min(pp_pnum) if head==1 & nheads>1 & nheads<.
by spanel su_id lgtmon: egen minpnum2 = min(pp_pnum) if spouse==1 & nspouses>1 & nspouses<.
replace head = . if pp_pnum~=minpnum & head==1 & nheads>1 & nheads<.
replace spouse  = . if pp_pnum~=minpnum2 & spouse==1 & nspouses>1 & nspouses<.

drop nheads nspouses
by spanel su_id lgtmon: egen nheads=count(head)
by spanel su_id lgtmon: egen nspouses=count(spouse)
tab nheads
tab nspouses

sort spanel su_id lgtmon
by spanel su_id : egen firsthead = min(lgtmon) if head==1
by spanel su_id : egen firstspouse = min(lgtmon) if spouse==1

gen thehead = 1 if head==1 & lgtmon==firsthead 
gen thespouse = 1 if spouse==1 & lgtmon==firstspouse 

sort spanel su_id pp_entry pp_pnum lgtmon
by spanel su_id pp_entry pp_pnum : egen _head  = min(thehead)
by spanel su_id pp_entry pp_pnum : egen _spouse  = min(thespouse)

gen person = .
replace person = 1 if _head==1
replace person = 2 if _spouse==1


save rep_sipp1p5.dta, replace

use rep_sipp1p5.dta

* Family Income Less Property Income
replace ff_pro = . if ff_pro == -9
su ff_pro
gen finc = ff_inc - ff_pro

***************************
* First Set of Exclusions *
***************************

* Self-Employed
gen selfemp = 0
replace selfemp = 1 if se_hr1>0 & se_hr1<. | se_hr2>0 & se_hr2<. | se_am1>0 & se_am1<. | se_am2>0 & se_am2<.
bysort spanel su_id: egen selfempfam = max(selfemp)
drop selfemp

* 4 Reference Months Per Wave
sort spanel wave su_id pp_entry pp_pnum
by spanel wave su_id pp_entry pp_pnum: egen survcnt = seq()
by spanel wave su_id pp_entry pp_pnum: egen maxsurv = max(survcnt)
drop if maxsurv~=4
drop maxsurv survcnt

* Only keep 4th Reference Month
keep if mod(lgtmon,4)==0

* Waves are Chronological
sort spanel su_id pp_entry pp_pnum wave
by spanel su_id pp_entry pp_pnum: gen gap = wave-wave[_n-1]
by spanel su_id pp_entry pp_pnum: egen maxgap = max(gap)
tab gap
tab maxgap

**********************************************************
* Reshape Data in to One Observation Per Family Per Wave *
**********************************************************

* Limit sample to two observations per family
keep if head==1 | spouse==1
drop if selfempfam == 1 
drop if state==0 | state>55 | state==11
drop if person==.
drop if selfempfam==1

sort spanel su_id wave
by spanel su_id wave: egen npersons = count(person)

drop se_am* se_hr* calmn  minpnum minpnum2


*2 Families with duplicate spouses
gen head1 = 1 if person==1
gen spouse1 = 1 if person==2
bysort spanel su_id pp_entry pp_pnum: egen nwaves = count(spouse1)
bysort spanel su_id: egen most_spouse = max(nwaves)
drop if person==2 & most_spouse~=nwaves
drop nwaves most_spouse 

drop nheads nspouses
sort spanel su_id wave
by spanel su_id: egen nheads= count(head1)
by spanel su_id: egen nspouses = count(spouse1)
tab nheads, missing
tab nspouses, missing
drop head1 spouse1

save rep_sipp_prereshape.dta, replace

reshape wide pp_entry pp_pnum rot hh_add  firsthead firstspouse thehead thespouse _head _spouse pp_mis eppintvw sex rrp age rfid pp_inc pp_ear ff_inc ff_pro ernam1 ernam2 hrrat1 hrrat2 state famid famsize kids adults head spouse finc gap maxgap female, i(spanel su_id wave) j(person)

save rep_sipp_wide.dta, replace

log close
log using rep_sipp_postreshape.log, replace

use rep_sipp_wide.dta

*Check if reference person and spouse are from same family
count if famid1==famid2 & famid1~=. & famid2~=.
count if famid1~=famid2 & famid1~=. & famid2~=.
count if famid1~=. & famid2==.
count if famid1==. & famid2~=.

gen cat = .
replace cat = 1 if famid1==famid2 & famid1~=. & famid2~=.
replace cat = 2 if famid1~=. & famid2==.
replace cat = 3 if famid1==. & famid2~=.
replace cat = 4 if famid1~=famid2 & famid1~=. & famid2~=.


foreach var in famsize adults kids female age state finc {
 gen `var' = .
 replace `var' = `var'1 if `var'1==`var'2
 replace `var' = `var'1 if `var'1~=. & `var'2==.
 replace `var' = `var'1 if `var'1~=`var'2 & `var'1~=. & `var'2~=.
 replace `var' = `var'2 if `var'1==. & `var'2~=.
}

keep if (age>=18 & age<=64)

sort spanel su_id wave
by spanel su_id: gen firstwave = wave[1]
by spanel su_id: gen lastwave = wave[_N]
drop if firstwave==lastwave

by spanel su_id: gen firstfamsize = famsize[1]
by spanel su_id: gen firstadults = adults[1]
by spanel su_id: gen firstkids = kids[1]

by spanel su_id: gen lastfamsize = famsize[_N]
by spanel su_id: gen lastadults = adults[_N]
by spanel su_id: gen lastkids = kids[_N]

by spanel su_id: gen firstfem=female[1]
by spanel su_id: gen lastfem=female[_N]

by spanel su_id: gen firstage1=age[1]
by spanel su_id: gen lastage1=age[_N]

by spanel su_id: gen firstwage1 = hrrat11[1]
by spanel su_id: gen firstwage2 = hrrat21[1]
by spanel su_id: gen lastwage1  = hrrat11[_N]
by spanel su_id: gen lastwage2  = hrrat21[_N]


****************************
* Second Set of Exclusions *
****************************
count if pp_ear1<0 
count if pp_ear2<0

gen drop = .

*Heads Age Changes by More than 4 Years
gen dage = lastage1-firstage1
replace drop = 1 if (dage<0 | dage>4 ) & dage~=.

*Heads Gender Changes
gen dfem = lastfem-firstfem
tab dfem, missing
replace drop = 1 if dfem==1 | dfem==-1

*Number of Adults Changes by More than 2
gen dadults = lastadults-firstadults
replace drop = 1 if dadults>2 & dadults<. | dadults<-2

*Number of kids changes by more than 2
gen dkids = lastkids-firstkids
replace drop = 1 if dkids>2 & dkids<. | dkids<-2

*Change in log hourly wages between the initial and last survey >1.5
gen lfirstwage1=log(firstwage1)
gen lfirstwage2=log(firstwage2)
gen llastwage1=log(lastwage1)
gen llastwage2=log(lastwage2)
gen dwage1 = llastwage1-lfirstwage1
gen dwage2 = llastwage2-lfirstwage2
replace drop = 1 if (dwage1>1.5 & dwage1<.) | dwage1<-1.5 
replace drop = 1 if ((dwage2>1.5 & dwage2<.) | dwage2<-1.5) & (famid1==famid2 & famid1~=. | famid1==. & famid2~=.)

sort spanel su_id wave
by spanel su_id wave: egen _drop=min(drop)
drop if _drop==1
drop _drop drop

count 
count if wave==firstwave

sort state year month 
merge state year month using mw7909a
tab _m
keep if _m==3

************* GENERATE S *****************
* The share of income coming from jobs   *
* paying less than 120% of minimum wage. *
******************************************

gen cat2 = .
replace cat2 = 1 if finc1==finc2 & finc1~=.
replace cat2 = 2 if finc1~=. & finc2==.
replace cat2 = 3 if finc1==. & finc2~=.
replace cat2 = 4 if finc1~=finc2 & finc1~=. & finc2~=.
tab cat cat2, missing

sort spanel su_id wave
foreach var of varlist finc ernam11 ernam21 ernam12 ernam22 {
 by spanel su_id: gen first`var' = `var'[1]
}

replace hrrat11 = hrrat11/100 if spanel==2008
replace hrrat21 = hrrat21/100 if spanel==2008
replace hrrat12 = hrrat12/100 if spanel==2008
replace hrrat22 = hrrat22/100 if spanel==2008

gen percentminwage1a = (hrrat11/minwage)
gen percentminwage1b = (hrrat21/minwage)
gen percentminwage2a = (hrrat12/minwage)
gen percentminwage2b = (hrrat22/minwage)

gen earnmw1a = .
replace earnmw1a = 1 if percentminwage1a>=0.6 & percentminwage1a<=1.2
replace earnmw1a = 0 if percentminwage1a>1.2 & percentminwage1a<.

gen earnmw1b = .
replace earnmw1b = 1 if percentminwage1b>=0.6 & percentminwage1b<=1.2
replace earnmw1b = 0 if percentminwage1b>1.2 & percentminwage1b<.

gen earnmw2a = .
replace earnmw2a = 1 if percentminwage2a>=0.6 & percentminwage2a<=1.2
replace earnmw2a = 0 if percentminwage2a>1.2 & percentminwage2a<.

gen earnmw2b = .
replace earnmw2b = 1 if percentminwage2b>=0.6 & percentminwage2b<=1.2
replace earnmw2b = 0 if percentminwage2b>1.2 & percentminwage2b<.

* Make sure we drop spouses who are no longer in same family as household head
replace earnmw2a = . if famid1~=famid2 & famid1~=. & famid2~=.
replace earnmw2b = . if famid1~=famid2 & famid1~=. & famid2~=.
replace ernam12 = . if famid1~=famid2 & famid1~=. & famid2~=.
replace ernam22 = . if famid1~=famid2 & famid1~=. & famid2~=.

gen earnprofile = 1*(earnmw1a~=. & ernam11>0 & ernam11<.)+2*(earnmw1b~=. & ernam21>0 & ernam21<.)+4*(earnmw2a~=. & ernam12>0 & ernam12<.)+8*(earnmw2b~=. & ernam22>0 & ernam22<.)
*gen earnprofile = 1*(ernam11>0 & ernam11<.)+2*(ernam21>0 & ernam21<.)+4*(ernam12>0 & ernam12<.)+8*(ernam22>0 & ernam22<.)
*tab earnprofile earnprofile_old, missing
tab earnprofile

* Numerator of S
gen num = .
replace num = (earnmw1a*ernam11) if earnprofile==1
replace num = (earnmw1b*ernam21) if earnprofile==2
replace num = ((earnmw1a*ernam11)+(earnmw1b*ernam21)) if earnprofile==3
replace num = ((earnmw2a*ernam12)) if earnprofile==4
replace num = ((earnmw1a*ernam11)+(earnmw2a*ernam12)) if earnprofile==5
replace num = ((earnmw1b*ernam21)+(earnmw2a*ernam12)) if earnprofile==6
replace num = ((earnmw1a*ernam11)+(earnmw1b*ernam21)+(earnmw2a*ernam12)) if earnprofile==7
replace num = (earnmw2b*ernam22) if earnprofile==8
replace num = ((earnmw1a*ernam11)+(earnmw2b*ernam22)) if earnprofile==9
replace num = ((earnmw1b*ernam21)+(earnmw2b*ernam22)) if earnprofile==10
replace num = ((earnmw1a*ernam11)+(earnmw1b*ernam21)+(earnmw2b*ernam22)) if earnprofile==11
replace num = ((earnmw2a*ernam12)+(earnmw2b*ernam22)) if earnprofile==12
replace num = ((earnmw1a*ernam11)+(earnmw2a*ernam12)+(earnmw2b*ernam22)) if earnprofile==13
replace num = ((earnmw1b*ernam21)+(earnmw2a*ernam12)+(earnmw2b*ernam22)) if earnprofile==14
replace num = ((earnmw1a*ernam11)+(earnmw1b*ernam21)+(earnmw2a*ernam12)+(earnmw2b*ernam22)) if earnprofile==15

gen sharemw = num / finc
 replace sharemw = 1 if num>0 & num<. & finc<=0
 replace sharemw = 0 if num==0 & finc<=0
drop num 
  
sort spanel su_id wave
by spanel su_id: gen firstsharemw = sharemw[1]

su firstsharemw, d
count 
count if firstsharemw==0
count if firstsharemw>0 & firstsharemw<.
count if firstsharemw>=0.2 & firstsharemw<.

************* GENERATE S' *****************
* The share of income coming from jobs    *
* paying 120-300% of minimum wage.        *
*******************************************

gen earnmw1a_120300 = .
replace earnmw1a_120300 = 1 if percentminwage1a>1.2 & percentminwage1a<=3
replace earnmw1a_120300 = 0 if percentminwage1a>3 & percentminwage1a<.

gen earnmw1b_120300 = .
replace earnmw1b_120300 = 1 if percentminwage1b>1.2 & percentminwage1b<=3
replace earnmw1b_120300 = 0 if percentminwage1b>3 & percentminwage1b<.

gen earnmw2a_120300 = .
replace earnmw2a_120300 = 1 if percentminwage2a>1.2 & percentminwage2a<=3
replace earnmw2a_120300 = 0 if percentminwage2a>3 & percentminwage2a<.

gen earnmw2b_120300 = .
replace earnmw2b_120300 = 1 if percentminwage2b>1.2 & percentminwage2b<=3
replace earnmw2b_120300 = 0 if percentminwage2b>3 & percentminwage2b<.

* Make sure we drop spouses who are no longer in same family as household head
replace earnmw2a_120300 = . if famid1~=famid2 & famid1~=. & famid2~=.
replace earnmw2b_120300 = . if famid1~=famid2 & famid1~=. & famid2~=.


gen earnprofile_120300 = 1*(earnmw1a_120300~=. & ernam11>0 & ernam11<.)+2*(earnmw1b_120300~=. & ernam21>0 & ernam21<.)+4*(earnmw2a_120300~=. & ernam12>0 & ernam12<.)+8*(earnmw2b_120300~=. & ernam22>0 & ernam22<.)
*gen earnprofile_120300 = earnprofile if sharemw==0
 replace earnprofile_120300 = 0 if sharemw>0 & sharemw<.
tab earnprofile_120300

*Numerator of S'
gen num = .
replace num = (earnmw1a_120300*ernam11) if earnprofile_120300==1
replace num = (earnmw1b_120300*ernam21) if earnprofile_120300==2
replace num = ((earnmw1a_120300*ernam11)+(earnmw1b_120300*ernam21)) if earnprofile_120300==3
replace num = ((earnmw2a_120300*ernam12)) if earnprofile_120300==4
replace num = ((earnmw1a_120300*ernam11)+(earnmw2a_120300*ernam12)) if earnprofile_120300==5
replace num = ((earnmw1b_120300*ernam21)+(earnmw2a_120300*ernam12)) if earnprofile_120300==6
replace num = ((earnmw1a_120300*ernam11)+(earnmw1b_120300*ernam21)+(earnmw2a_120300*ernam12)) if earnprofile_120300==7
replace num = (earnmw2b_120300*ernam22) if earnprofile_120300==8
replace num = ((earnmw1a_120300*ernam11)+(earnmw2b_120300*ernam22)) if earnprofile_120300==9
replace num = ((earnmw1b_120300*ernam21)+(earnmw2b_120300*ernam22)) if earnprofile_120300==10
replace num = ((earnmw1a_120300*ernam11)+(earnmw1b_120300*ernam21)+(earnmw2b_120300*ernam22)) if earnprofile_120300==11
replace num = ((earnmw2a_120300*ernam12)+(earnmw2b_120300*ernam22)) if earnprofile_120300==12
replace num = ((earnmw1a_120300*ernam11)+(earnmw2a_120300*ernam12)+(earnmw2b_120300*ernam22)) if earnprofile_120300==13
replace num = ((earnmw1b_120300*ernam21)+(earnmw2a_120300*ernam12)+(earnmw2b_120300*ernam22)) if earnprofile_120300==14
replace num = ((earnmw1a_120300*ernam11)+(earnmw1b_120300*ernam21)+(earnmw2a_120300*ernam12)+(earnmw2b_120300*ernam22)) if earnprofile_120300==15

gen sharemw_120300 = num / finc
 replace sharemw_120300 = 1 if num>0 & num<. & finc<=0
 replace sharemw_120300 = 0 if num==0 & finc<=0
drop num 
  
sort spanel su_id wave
by spanel su_id: gen firstsharemw_120300 = sharemw_120300[1]

count if firstsharemw==0
count if firstsharemw_120300==0
count if firstsharemw_120300>0 & firstsharemw_120300<.

************* GENERATE S'' *****************
* The share of income coming from jobs    *
* paying 120-200% of minimum wage.        *
*******************************************

gen earnmw1a_120200 = .
replace earnmw1a_120200 = 1 if percentminwage1a>1.2 & percentminwage1a<=2
replace earnmw1a_120200 = 0 if percentminwage1a>2 & percentminwage1a<.

gen earnmw1b_120200 = .
replace earnmw1b_120200 = 1 if percentminwage1b>1.2 & percentminwage1b<=2
replace earnmw1b_120200 = 0 if percentminwage1b>2 & percentminwage1b<.

gen earnmw2a_120200 = .
replace earnmw2a_120200 = 1 if percentminwage2a>1.2 & percentminwage2a<=2
replace earnmw2a_120200 = 0 if percentminwage2a>2 & percentminwage2a<.

gen earnmw2b_120200 = .
replace earnmw2b_120200 = 1 if percentminwage2b>1.2 & percentminwage2b<=2
replace earnmw2b_120200 = 0 if percentminwage2b>2 & percentminwage2b<.

* Make sure we drop spouses who are no longer in same family as household head
replace earnmw2a_120200 = . if famid1~=famid2 & famid1~=. & famid2~=.
replace earnmw2b_120200 = . if famid1~=famid2 & famid1~=. & famid2~=.

gen earnprofile_120200 = 1*(earnmw1a_120200~=. & ernam11>0 & ernam11<.)+2*(earnmw1b_120200~=. & ernam21>0 & ernam21<.)+4*(earnmw2a_120200~=. & ernam12>0 & ernam12<.)+8*(earnmw2b_120200~=. & ernam22>0 & ernam22<.)
*gen earnprofile_120200 = earnprofile if sharemw~=0
 replace earnprofile_120200 = 0 if sharemw>0 & sharemw<.
tab earnprofile_120200

*Numerator of S''
gen num = .
replace num = (earnmw1a_120200*ernam11) if earnprofile_120200==1
replace num = (earnmw1b_120200*ernam21) if earnprofile_120200==2
replace num = ((earnmw1a_120200*ernam11)+(earnmw1b_120200*ernam21)) if earnprofile_120200==3
replace num = ((earnmw2a_120200*ernam12)) if earnprofile_120200==4
replace num = ((earnmw1a_120200*ernam11)+(earnmw2a_120200*ernam12)) if earnprofile_120200==5
replace num = ((earnmw1b_120200*ernam21)+(earnmw2a_120200*ernam12)) if earnprofile_120200==6
replace num = ((earnmw1a_120200*ernam11)+(earnmw1b_120200*ernam21)+(earnmw2a_120200*ernam12)) if earnprofile_120200==7
replace num = (earnmw2b_120200*ernam22) if earnprofile_120200==8
replace num = ((earnmw1a_120200*ernam11)+(earnmw2b_120200*ernam22)) if earnprofile_120200==9
replace num = ((earnmw1b_120200*ernam21)+(earnmw2b_120200*ernam22)) if earnprofile_120200==10
replace num = ((earnmw1a_120200*ernam11)+(earnmw1b_120200*ernam21)+(earnmw2b_120200*ernam22)) if earnprofile_120200==11
replace num = ((earnmw2a_120200*ernam12)+(earnmw2b_120200*ernam22)) if earnprofile_120200==12
replace num = ((earnmw1a_120200*ernam11)+(earnmw2a_120200*ernam12)+(earnmw2b_120200*ernam22)) if earnprofile_120200==13
replace num = ((earnmw1b_120200*ernam21)+(earnmw2a_120200*ernam12)+(earnmw2b_120200*ernam22)) if earnprofile_120200==14
replace num = ((earnmw1a_120200*ernam11)+(earnmw1b_120200*ernam21)+(earnmw2a_120200*ernam12)+(earnmw2b_120200*ernam22)) if earnprofile_120200==15

gen sharemw_120200 = num / finc
 replace sharemw_120200 = 1 if num>0 & num<. & finc<=0
 replace sharemw_120200 = 0 if num==0 & finc<=0
drop num 
  
sort spanel su_id wave
by spanel su_id: gen firstsharemw_120200 = sharemw_120200[1]


************* GENERATE S'' *****************
* The share of income coming from jobs    *
* paying 200-300% of minimum wage.        *
*******************************************

gen earnmw1a_200300 = .
replace earnmw1a_200300 = 1 if percentminwage1a>2 & percentminwage1a<=3
replace earnmw1a_200300 = 0 if percentminwage1a>3 & percentminwage1a<.

gen earnmw1b_200300 = .
replace earnmw1b_200300 = 1 if percentminwage1b>2 & percentminwage1b<=3
replace earnmw1b_200300 = 0 if percentminwage1b>3 & percentminwage1b<.

gen earnmw2a_200300 = .
replace earnmw2a_200300 = 1 if percentminwage2a>2 & percentminwage2a<=3
replace earnmw2a_200300 = 0 if percentminwage2a>3 & percentminwage2a<.

gen earnmw2b_200300 = .
replace earnmw2b_200300 = 1 if percentminwage2b>2 & percentminwage2b<=3
replace earnmw2b_200300 = 0 if percentminwage2b>3 & percentminwage2b<.

* Make sure we drop spouses who are no longer in same family as household head
replace earnmw2a_200300 = . if famid1~=famid2 & famid1~=. & famid2~=.
replace earnmw2b_200300 = . if famid1~=famid2 & famid1~=. & famid2~=.

gen earnprofile_200300 = 1*(earnmw1a_200300~=. & ernam11>0 & ernam11<.)+2*(earnmw1b_200300~=. & ernam21>0 & ernam21<.)+4*(earnmw2a_200300~=. & ernam12>0 & ernam12<.)+8*(earnmw2b_200300~=. & ernam22>0 & ernam22<.)
 replace earnprofile_200300 = 0 if (sharemw>0 & sharemw<.) | (sharemw_120200>0 & sharemw_120200<.)
tab earnprofile_200300

gen num = .
replace num = (earnmw1a_200300*ernam11) if earnprofile_200300==1
replace num = (earnmw1b_200300*ernam21) if earnprofile_200300==2
replace num = ((earnmw1a_200300*ernam11)+(earnmw1b_200300*ernam21)) if earnprofile_200300==3
replace num = ((earnmw2a_200300*ernam12)) if earnprofile_200300==4
replace num = ((earnmw1a_200300*ernam11)+(earnmw2a_200300*ernam12)) if earnprofile_200300==5
replace num = ((earnmw1b_200300*ernam21)+(earnmw2a_200300*ernam12)) if earnprofile_200300==6
replace num = ((earnmw1a_200300*ernam11)+(earnmw1b_200300*ernam21)+(earnmw2a_200300*ernam12)) if earnprofile_200300==7
replace num = (earnmw2b_200300*ernam22) if earnprofile_200300==8
replace num = ((earnmw1a_200300*ernam11)+(earnmw2b_200300*ernam22)) if earnprofile_200300==9
replace num = ((earnmw1b_200300*ernam21)+(earnmw2b_200300*ernam22)) if earnprofile_200300==10
replace num = ((earnmw1a_200300*ernam11)+(earnmw1b_200300*ernam21)+(earnmw2b_200300*ernam22)) if earnprofile_200300==11
replace num = ((earnmw2a_200300*ernam12)+(earnmw2b_200300*ernam22)) if earnprofile_200300==12
replace num = ((earnmw1a_200300*ernam11)+(earnmw2a_200300*ernam12)+(earnmw2b_200300*ernam22)) if earnprofile_200300==13
replace num = ((earnmw1b_200300*ernam21)+(earnmw2a_200300*ernam12)+(earnmw2b_200300*ernam22)) if earnprofile_200300==14
replace num = ((earnmw1a_200300*ernam11)+(earnmw1b_200300*ernam21)+(earnmw2a_200300*ernam12)+(earnmw2b_200300*ernam22)) if earnprofile_200300==15

gen sharemw_200300 = num / finc
 replace sharemw_200300 = 1 if num>0 & num<. & finc<=0
 replace sharemw_200300 = 0 if num==0 & finc<=0
drop num 
  
sort spanel su_id wave
by spanel su_id: gen firstsharemw_200300 = sharemw_200300[1]


******************************
* Deflate Monetary Variables *
******************************

gen pce = 0
 replace pce=0.5362 if year == 1982
 replace pce=0.5592 if year == 1983
 replace pce=0.5804 if year == 1984
 replace pce=0.5994 if year == 1985
 replace pce=0.6140 if year == 1986
 replace pce=0.6359 if year == 1987
 replace pce=0.6612 if year == 1988
 replace pce=0.6899 if year == 1989
 replace pce=0.7215 if year == 1990
 replace pce=0.7476 if year == 1991
 replace pce=0.7695 if year == 1992
 replace pce=0.7864 if year == 1993
 replace pce=0.8027 if year == 1994
 replace pce=0.8204 if year == 1995
 replace pce=0.8383 if year == 1996
 replace pce=0.8539 if year == 1997
 replace pce=0.8621 if year == 1998
 replace pce=0.8760 if year == 1999
 replace pce=0.8978 if year == 2000
 replace pce=0.9149 if year == 2001
 replace pce=0.9274 if year == 2002
 replace pce=0.9462 if year == 2003
 replace pce=0.9710 if year == 2004
 replace pce=1.0000 if year == 2005
 replace pce=1.0275 if year == 2006
 replace pce=1.0550 if year == 2007
 replace pce=1.0903 if year == 2008
 replace pce=1.0926 if year == 2009
 
replace finc = finc / pce
replace minwage = minwage / pce
replace ernam11 = ernam11 / pce
replace ernam21 = ernam21 / pce
replace ernam12 = ernam12 / pce
replace ernam22 = ernam22 / pce

********************
* Bring in Weights *
********************

gen pp_entry = ""
replace pp_entry = pp_entry1 if famid1==famid2
replace pp_entry = pp_entry1 if famid1~=. & famid2==.
replace pp_entry = pp_entry1 if famid1~=famid2 & famid1~=. & famid2~=.
replace pp_entry = pp_entry2 if famid1==. & famid2~=.
replace pp_entry = substr(pp_entry,2,.) if spanel==1992

gen pp_pnum = .
replace pp_pnum = pp_pnum1 if famid1==famid2
replace pp_pnum = pp_pnum1 if famid1~=. & famid2==.
replace pp_pnum = pp_pnum1 if famid1~=famid2 & famid1~=. & famid2~=.
replace pp_pnum = pp_pnum2 if famid1==. & famid2~=.
tostring pp_pnum, replace
sort spanel su_id pp_entry pp_pnum wave
merge spanel su_id pp_entry pp_pnum wave using rep_sipp_weights, _merge(_mergeWeights)
tab _mergeWeights
drop if _mergeWeights==2

replace wffinwgt = wffinwgt / 10000 if spanel==2008

sort spanel su_id wave
by spanel su_id: gen weight = wffinwgt[1] // First family weight

************
* Analysis *
************
tab year, gen(y)
tab month, gen(m)

save rep_sipp2.dta, replace


use rep_sipp2.dta

keep if year<=2007
egen id = group(spanel su_id)

xtset id wave

keep if weight>0 & weight<.

*Multiply finc by 3 to make "quarterly" income
replace finc = finc*3

count if ~missing(firstsharemw) & ~missing(finc)
count if wave==firstwave & ~missing(firstsharemw) & ~missing(finc)

log close
log using sipp_table1.log, replace
***********
* Table 1 *
***********
*Column 3
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw==0, fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 6 - 120-300
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_120300==0, fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_120300>0 & firstsharemw_120300<., fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_120300>=0.2 & firstsharemw_120300<., fe cluster(id)

* Regressions not in tables, but mentioned in discussion about table. *

*120-200, referenced on page 11.
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_120200==0, fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_120200>0 & firstsharemw_120200<., fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_120200>=0.2 & firstsharemw_120200<., fe cluster(id)

*200-300, referenced on page 11.
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_200300==0, fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_200300>0 & firstsharemw_200300<., fe cluster(id)
xtreg finc minwage m2-m12 y2-y24 adults kids if firstsharemw_200300>=0.2 & firstsharemw_200300<., fe cluster(id)

log close


log using sipp_mw_dynamics.log, replace
***********************************************************
* Probability of remaining a MW worker after 1 or 2 years *
***********************************************************

gen earnmw1a_120 = percentminwage1a<=1.2 & hrrat11>0 & hrrat11<. 
gen earnmw1b_120 = percentminwage1b<=1.2 & hrrat21>0 & hrrat21<. 

gen earnmw_120 = earnmw1a_120==1 | earnmw1b_120==1 if earnmw1a_120~=. | earnmw1b_120~=.

sort id wave
by id: gen f12earnmw1a = earnmw1a[_n+3]
by id: gen f24earnmw1a = earnmw1a[_n+6]
by id: egen first=min(wave)

su f12earnmw1a f24earnmw1a if wave==first & earnmw1a==1 [w=weight]

*by id: gen f12earnmw1a = earnmw1a_120[_n+3]
*by id: gen f24earnmw1a = earnmw1a_120[_n+6]
*by id: gen f12earnmw = earnmw_120[_n+3]
*by id: gen f24earnmw = earnmw_120[_n+6]

*su f12earnmw1a f24earnmw1a if wave==first & earnmw1a_120==1 [w=weight]
*su f12earnmw f24earnmw if wave==first & earnmw_120==1 [w=weight]
log close

log using sipp_tableA1.log, replace
************
* Table A1 *
************

* Note: Our sample only includes hourly wage workers. If we 
* include salaried workers, either by assuming they are not minimum wage workers
* or by imputing a wage using income/hours, the income measure would be about 
* 20% higher for the S=0 group.

gen unitsurvey = 1 if firstwave==wave

tab finc spanel if finc<0

*Now make family income annual (already quarterly)
replace finc = finc*4

replace weight=round(weight)
su finc firstsharemw age adults kids unitsurvey  if firstsharemw==0 & finc~=. [w=weight]
su finc firstsharemw age adults kids unitsurvey  if firstsharemw>=0.2 & firstsharemw<. & finc~=. [w=weight]


log close

clear

exit
