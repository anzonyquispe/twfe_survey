/* Last updated: July 7, 2007, by Mo Xiao */

capture log close
clear
set mem 100m

log using C:\work\thesis\daycare\ccrdc\popcensus\census_clean.log, replace
# delimit ;

/* Clean Census 2000 data */

use "C:\work\thesis\daycare\ccrdc\popcensus\census2000.dta", clear;

replace zipcode=substr(zipcode,-5,5);

*******************************************************************************************************
/* 2007 revision: census zipcodes are tabulation areas; shouldn't have special address zipcodes */
*drop if pop==0;   /*for zip codes with 0 population, it's most likely a zipcode for a special address */
drop if  substr(zip,4,2)=="XX" | substr(zip,4,2)=="HH" ; 
duplicates drop zipcode, force ; /* delete duplicate zip codes */
replace arealand=arealand/2589990; /*  arealand is measured in sq meters.  sq meters/2589990=#sq miles*/
************************************************************************************************************

drop if state_no>56;  /*drop observations from outside US, such as Puerto Rico */

gen pct_rural=pop_rural/pop_sf3;
gen pct_black=black/pop;
gen pct_hisp=hispanic/pop;
gen under5=m_under5+f_under5;
gen n_infant=m_under1+f_under1;
gen n_toddler=m_age1+m_age2+m_age3+f_age1+f_age2+f_age3;
gen n_presch=m_age4+m_age5+f_age4+f_age5;
gen age_1_2=m_age1+m_age2+f_age1+f_age2; 
gen age_3_4=m_age3+m_age4+f_age3+f_age4; 
gen n_schage=m_age6+m_age7+m_age8+m_age9+m_age10+m_age11+m_age12+m_age13+
f_age6+f_age7+f_age8+f_age9+f_age10+f_age11+f_age12+f_age13;
gen pct_freign=foreign/pop_sf3;
gen mobility=diff_state/pop_over5;
gen pct_fh_c=f_head_child/n_hhold;
gen pct_over60=hh_over60/n_hhold;
gen long_comm=(commute30_34+commute35_39+commute40_44+commute45_59+commute60_89+commute__90)/work_over16;
gen pct_whome=work_home/work_over16;
gen pct_nursery=(m_nursery+f_nursery)/pop_over3;
gen pct_kdgarden=(m_kindergarten+f_kindergarten)/pop_over3;
gen college=(m_college_under1+m_college_over1+m_college+f_college_under1+f_college_over1+f_college)/pop_over25;
gen pct_unemploy=(m_unemply+f_unemply)/(m_labor+f_labor);
gen pct_nolabor=(pop_over16-m_labor-f_labor)/pop_over16;
gen f_parttime=f_work_1_14/f_over16;
gen pct_f_nwork=f_notwork/f_over16;
gen pct_pvty=below_pvty/pop_sf3;

rename state state_no;


/*gen AL=state_no==1 
gen AK=state_no==2 
gen AZ=state_no==4 
gen AR=state_no==5 
gen CA=state_no==6 
gen CO=state_no==8 
gen CT=state_no==9 
gen DE=state_no==10
gen DC=state_no==11
gen FL=state_no==12
gen GA=state_no==13
gen HI=state_no==15
gen ID=state_no==16
gen IL=state_no==17
gen IN=state_no==18
gen IA=state_no==19
gen KS=state_no==20
gen KY=state_no==21
gen LA=state_no==22
gen ME=state_no==23
gen MD=state_no==24
gen MA=state_no==25
gen MI=state_no==26
gen MN=state_no==27
gen MS=state_no==28
gen MO=state_no==29
gen MT=state_no==30
gen NE=state_no==31
gen NV=state_no==32
gen NH=state_no==33
gen NJ=state_no==34
gen NM=state_no==35
gen NY=state_no==36
gen NC=state_no==37
gen ND=state_no==38
gen OH=state_no==39
gen OK=state_no==40
gen OR=state_no==41
gen PA=state_no==42
gen RI=state_no==44
gen SC=state_no==45
gen SD=state_no==46
gen TN=state_no==47
gen TX=state_no==48
gen UT=state_no==49
gen VT=state_no==50
gen VA=state_no==51
gen WA=state_no==53
gen WV=state_no==54
gen WI=state_no==55
gen WY=state_no==56 */

keep zipcode state_no arealand pop pct_rural pct_black pct_hisp under5 n_infant n_toddler n_presch age_1_2 age_3_4 n_schage 
hh_size pct_fh_c pct_over60 pct_freign mobility long_comm pct_whome pct_nursery pct_kdgarden college 
pct_unemploy pct_nolabor f_parttime pct_f_nwork m_income pct_pvty;

su;
su pop under5 pct_black pct_hisp hh_size m_income pct_pvty college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural;
su arealand, detail;

save C:\work\thesis\daycare\ccrdc\popcensus\c2000_clean.dta, replace;


/* Clean Census 1990 data */

use "C:\work\thesis\daycare\ccrdc\popcensus\census1990.dta", clear;

duplicates drop zip, force ; /*drop duplicated zipcodes. Only keep the first in rank */

*******************************************************************************************************
/* 2007 revision: census zipcodes are tabulation areas; shouldn't have special address zipcodes */
*drop if pop==0;   /*for zip codes with 0 population, it's most likely a zipcode for a special address */
************************************************************************************************************

/* Need to make zipcode a string variable.  Fill in all the leading zeros*/;

gen pct_rural=(pop_rural_farm+pop_rural_nonfarm)/pop;
gen pct_black=black/pop;
gen pct_hisp=hispanic_orgin/pop;
gen under5=age_under1+age_1_2+age_3_4;
gen n_infant=age_under1;
gen n_schage=age_6+age_7_9+age_10_11+age_12_13;

gen pop_over5=pop-age_under1-age_1_2-age_3_4;
gen pop_over16=pop_over5-age_5-age_6-age_7_9-age_10_11-age_12_13-age_14-age_15;
gen pop_over25=pop_over16-age_16-age_17-age_18-age_19-age_20-age_21-age_22_24;
gen work_over16=commute__5+commute5_9+commute10_14+commute15_19+commute20_24+commute25_29+commute30_34+commute35_39
+commute40_44+commute45_59+commute60_89+commute__90+work_home;

gen f_over16=f_work_15_34h_50_52w+f_work_15_34h_48_492w+f_work_15_34h_40_47w+f_work_15_34h_27_39w+f_work_15_34h_14_26w+
f_work_15_34h_1_13w+f_work_15_34h_50_52w1+f_work_15_34h_48_49w+f_work_15_34h_40_47w1+f_work_15_34h_27_39w1+
f_work_15_34h_14_26w1+f_work_15_34h_1_13w1+f_work_1_13h_50_52w+f_work_1_13h_48_49w+f_work_1_13h_40_47w+
f_work_1_13h_27_39w+f_work_1_13h_14_26w+f_work_1_13h_1_13w+f_notwork;

gen hh_size=pop/n_hhold;
egen mean_hhsz=median(hh_size);
replace hh_size=mean_hhsz if hh_size>15;
gen pct_fh_c=f_head_child/n_hhold;
gen pct_over55=(hh_55_64+hh_65_74+hh_o75)/n_hhold;

/* the definition of foreign is too broad here.  mean too high */
gen pct_freign=(foreign_natural_u18+foreign_nocitizen_u18+foreign_natural_o18+foreign_nocitizen_o18)/pop;
gen mobility=(diff_state_northwest+diff_state_midwest+diff_state_south+diff_state_west)/pop_over5;
gen long_comm=(commute30_34+commute35_39+commute40_44+commute45_59+commute60_89+commute__90)/work_over16;
gen pct_whome=work_home/work_over16;

gen college=(pop_college_nondegree+pop_college)/pop_over25;
gen pct_unemploy=(m_unemply+f_unemply)/(pop_over16-m_notlabor-f_notlabor);
gen pct_nolabor=(m_notlabor+f_notlabor)/pop_over16;
gen f_parttime=(f_work_1_13h_1_13w+f_work_1_13h_14_26w+f_work_1_13h_27_39w+f_work_1_13h_40_47w+f_work_1_13h_50_52w)/f_over16;
gen pct_f_nwork=f_notwork/f_over16;

gen pct_pvty=(b_pvty_under5+b_pvty_5+b_pvty_6_11+b_pvty_12_17+b_pvty_18_24+b_pvty_25_34+b_pvty_35_44+b_pvty_45_54+
b_pvty_55_59+b_pvty_60_64+b_pvty_65_74+b_pvty__75)/pop;

rename state state_no;

/* drop if state_no>56;  1990 state definition is very different. drop observations from outside US, such as Puerto Rico */


keep zipcode state_no pop pct_rural pct_black pct_hisp under5 n_infant age_1_2 age_3_4 n_schage 
hh_size pct_fh_c pct_over55 pct_freign mobility long_comm pct_whome college 
pct_unemploy pct_nolabor f_parttime pct_f_nwork m_income pct_pvty;

su;
su pop under5 pct_black pct_hisp hh_size m_income pct_pvty college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural;

save C:\work\thesis\daycare\ccrdc\popcensus\c1990_clean.dta, replace;

log close;

