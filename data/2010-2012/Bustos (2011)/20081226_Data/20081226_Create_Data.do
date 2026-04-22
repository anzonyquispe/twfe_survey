
/*
Trade Liberalization, Exports and Technology Upgrading: Evidence on the Impact of MERCOSUR on Argentinean Firms
This stata .do file inputs the dataset Firm_0.dta that contains the ENIT firm-level data set, 
matched to the corresponding 4-digit-ISIC tariffs,measures of capital and skill intensity, 
demand elasticity and industry-level exports from Argentina to Brazil described in the Readme file 
and outputs the dataset used to generate the results in the paper: Firm_1.dta 

This program has the following steps

1 Generate Industry Identifiers
2 Generate Tariff Variables
3 Generate Industry Capital and Skill Intensity in the U.S.  
4 Keep sample of firms to be analyzed 
5 Data cleaning and definition of variables
6 Save Firm-level and Industry-level datasets

*/


**0 Preliminaries 

clear
set mem 80m
set more off

use Firm_0.dta

**1 Generate Industry Identifiers

/* The variable lrama indicates main 5-digit-ISIC industry for each firm */ 

gen sectorIV=int(lrama/10)
gen sectorII=int(sectorIV/100)
xi: reg m201c1 i.sectorII
global ssII "_IsectorII_*"


**2 Generate Tariff Variables

/* Variable definitions: 
tbw1991: Level of Brazil's tariffs for each 4-digit-ISIC-industry in 1991 in percent terms (9-digit-HS-products within each 4-digit-SIC-industry weighted by exports from Argentina) 
tbw1992: Level of Brazil's tariffs for each 4-digit-ISIC-industry in 1992 in percent terms (products weighted by exports from Argentina)
Targbraw92: Level of Argentina's tariffs for each 4-digit-ISIC-industry in 1992 in percent terms (products weighted by imports from Brazil) 
Targworldw1992: Level of Argentina's tariffs for each 4-digit-ISIC-industry in 1992 in percent terms (products weighted by imports from the world)
Targworldw1996: Level of Argentina's tariffs for each 4-digit-ISIC-industry in 1996 in percent terms (products weighted by imports from the world)
tab1992_inputs: Level of Argentina's input tariffs for each 4-digit-ISIC-industry in 1992 in percent terms (products weighted by imports from Brazil)
taw1992_inputs:Level of Argentina's input tariffs for each 4-digit-ISIC-industry in 1992 in percent terms (products weighted by imports from the world)
taw1996_inputs:Level of Argentina's input tariffs for each 4-digit-ISIC-industry in 1996 in percent terms (products weighted by imports from the world)
*/


replace tbw1992=tbw1992/100
gen dtbw1992=-tbw1992
replace tbw1991=tbw1991/100
replace Targworldw1996=Targworldw1996/100
replace Targworldw1992=Targworldw1992/100
gen DTWAw= Targworldw1996-Targworldw1992
replace Targbraw92=Targbraw92/100
gen DTargbraw92=-Targbraw92
gen dtab1992_inputs=-tab1992_inputs
gen dtaw_inputs=taw1996_inputs-taw1992_inputs

**3 Generate Industry Capital and Skill Intensity in the U.S.  

/* Variable Definitions: 
K_L_us_avg80: Capital Intensity in the corresponding 4-digit-ISIC Industry in the U.S.
Ls_L_us_avg80: Skill Intensity in the corresponding 4-digit-ISIC Industry in the U.S.
*/  

gen log_K_L_us_avg80=log(K_L_us_avg80)
gen log_Ls_L_us_avg80=log(Ls_L_us_avg80)

**4 Keep sample of firms to be analyzed

*Keep only the sample of firms with positive sales and employment in 1992 and 1996 

gen S=1 if m201c1 ~=. & m201c2~=. & m217a1~=. &  m217a2~=.
drop if S~=1

*Keep only the sample of firms belonging to 4-digit-ISIC industries with information on Brazil's Tariffs in 1992

gen ST=1 if S==1 & tbw1992~=.
drop if ST~=1


**5  Firm-level data cleaning and definition of variables


*CLEANING SPENDING IN TECHNOLOGY VARIABLES

/* Variable Definitions:

m208g6-m208g10: TOTAL SPENDING IN COMPUTERS IN THOUSAND PESOS
m209e1-m209e5: Total spending in software including training courses
m209d1-m209d5: Software Training courses
m301f1-m301f9:  Total spending in domestic licenses, patents and technology transfers
m301f2-m301f10: Total spending in imported licenses, patents and technology transfers
m403k1-m403k5: Total spending on workers dedicated to innovation activities
which includes basic and applied research, development and adaptation of products 
and production process, technical asisstance for production, proyect engeneering,
administrative reorganization, commercialization of new products and other 
m404k1-m404k5: Total spending on equipment and material related to innovation activities 
(excluding capital goods and computers reported in m206 and m208) 
*/

for Y in num 92/96 \ X in num 6/10: gen CompY=m208gX 
gen Comp=Comp92 +Comp93 +Comp94 +Comp95 +Comp96
gen Comp_m201c1=Comp/m201c1
list nloc m208* if Comp_m201c1 >1 & Comp_m201c1~=.
* correct three observations where prices of personal computers appear to have been written in pesos instead of thousand pesos 
for X in num 92/96: replace CompX=CompX/1000 if Comp_m201c1 >1 & Comp_m201c1~=.
replace Comp=Comp92 +Comp93 +Comp94 +Comp95 +Comp96
replace Comp_m201c1=Comp/m201c1

*in nlocal==756036 total software spending for 1992 is 1000 times bigger than the sum of its parts, thus the total appears to be in pesos instead of thousand pesos 
replace m209e1= m209a1+m209b1+m209c1+m209d1 if nlocal==756036
for Y in num 92/96 \ X in num 1/5: gen SoftY=m209eX-m209dX
gen Soft= Soft92+ Soft93+ Soft94 +Soft95 +Soft96
gen  Soft_m201c1 = Soft/m201c1
gen Soft_Comp= Soft/Comp
for X in num 92/96: list nloc SoftX Soft_Comp if Soft_m201c1>0.2 
*correct 18 observations where spending in software appears to have been written in pesos instead of thousand pesos
for X in num 92/96: replace SoftX=SoftX/1000 if Soft_m201c1>0.2 & Soft_Comp>10
replace Soft=Soft/1000 if Soft_m201c1>0.2 & Soft_Comp>10
replace Soft_m201c1=Soft/m201c1 if Soft_m201c1>0.2 & Soft_Comp>10

for Y in num 92/96 \ X in num 1 3 5 7 9: gen TechNY=m301fX
for Y in num 92/96 \ X in num 2 4 6 8 10: gen TechMY=m301fX
* in 301f totals coincide with dissagregation and there are no evidently wrong observations

for Y in num 92/96 \  X in num 1/5: gen WLiaY=m403kX
* in m403kX totals coincide with dissagregation and there are no evidently wrong observations

for Y in num 92/96 \  X in num 1/5: gen  SiaY=m404kX
* in m404k totals coincide  with dissagregation and there are no evidently wrong observations

* GENERATE SPENDING IN TECHNOLOGY VARIABLES (SIA)

for X in num 92 93 94 95 96: gen SIAX= CompX +SoftX +TechNX+ TechMX +SiaX + WLiaX 
gen SIA1= SIA92
gen SIA2= (SIA93+SIA94+SIA95+SIA96)/4
gen log_SIA2=log(SIA2)
gen log_SIA1=log(SIA1)
gen log_SIA2_log_SIA1=log_SIA2-log_SIA1


* GENERATE PRODUCT (pHpd) AND PROCESS (pHpc) INNOVATION INDEXES

/* Variable Definitions:
product innovation: m413a1-m413e2
process innovation: m414a1-m414d2
*/ 


gen m413a=1 if m413a1==1 & m413a2==.
replace m413a=0 if m413a1==. & m413a2==2
gen m413b=1 if m413b1==1 & m413b2==.
replace m413b=0 if m413b1==. & m413b2==2
gen m413c=1 if m413c1==1 & m413c2==.
replace m413c=0 if m413c1==. & m413c2==2
gen m413d=1 if m413d1==1 & m413d2==.
replace m413d=0 if m413d1==. & m413d2==2
gen m413e=1 if m413e1==1 & m413e2==.
replace m413e=0 if m413e1==. & m413e2==2
gen m414a=1 if m414a1==1 & m414a2==.
replace m414a=0 if m414a1==. & m414a2==2
gen m414b=1 if m414b1==1 & m414b2==.
replace m414b=0 if m414b1==. & m414b2==2
gen m414c=1 if m414c1==1 & m414c2==.
replace m414c=0 if m414c1==. & m414c2==2
gen m414d=1 if m414d1==1 & m414d2==.
replace m414d=0 if m414d1==. & m414d2==2


gen pHpd= (m413a+m413b+m413c+m413d+m413e)/5
gen pHpc= (m414a+m414b+m414c+m414d)/4
gen pHpdpc=(pHpd+pHpc)/2

* GENERATE EMPLOYMENT by EDUCATION VARIABLES

/* Variable Definitions:
Lc is college 
Lt is tertiary
Lh is higschool
Lb is primary and below
*/ 

gen Lc1=m213a1+m214a1+m215a1+m213b1+m214b1+m215b1
gen Lt1=m213c1+m214c1+m215c1
gen Lh1=0.46274*(m213d1+m214d1+m215d1)+ m216a1
gen Lb1=(1-0.46274)*(m213d1+m214d1+m215d1) + m213e1

gen Lc2=m213a2+m214a2+m215a2+m213b2+m214b2+m215b2
gen Lt2=m213c2+m214c2+m215c2
gen Lh2=0.46274*(m213d2+m214d2+m215d2)+ m216a2
gen Lb2=(1-0.46274)*(m213d2+m214d2+m215d2) + m213e2


* GENERATE SKILLED AND UNSKILLED LABOR VARIABLES

gen Ls1=Lc1+Lt1/1.233
gen Lu1=Lh1*1.307+Lb1
gen Ls2=Lc2+Lt2/1.233
gen Lu2= Lh2*1.307 + Lb2

* GENERATE EMPLOYMENT IN EFFICIENCY UNITS

gen Lef1 = Ls1*2.014 + Lu1
gen Lef2 = Ls2*2.014 + Lu2


gen log_Lef1=log(Lef1)
gen log_Lef2=log(Lef2)
gen log_Lef2_log_Lef1=log_Lef2-log_Lef1

/* Note:
Ls1 in college equivalents
Lu1 in less than high school equivalents
Lef1 in less than high school equivalents
I aggregate workers of different educational attainment using wage premia:
College to less than high school wage is wc/wb=2.014. 
College to tertiary wage is wc/wt=1.233
Highschool to less than highschool wage: wh/wb=1.307 
Estimate for wc/wb obtained from Galiani and Porto (forthcoming): returns to college relative to
less than high school in the industrial sector in 1992 is 0.7. Estimates for returns 
to tertiary and higschool degrees are not available for the industrial sector, then 
I used the estimates for the whole economy in Gasparini et al. (2005). I use their 
estimates of the returns to incomplete college as the returns to tertiary degrees. As the
estimate of returns to college education in the whole economy reported in Gasparini et al.
are 32% smaller than the estimates for the industrial sector in Galeani and Porto (2008), 
I reduce  estimates of incomplete college and highschool returns in the same proportion. 
*/ 

* GENERATE SKILL INTENSITY 

gen Ls1_Lef1=(Ls1*2.014/Lef1)*100
gen Ls2_Lef2=(Ls2*2.014/Lef2)*100
gen DLs_Lef=Ls2_Lef2-Ls1_Lef1


* GENERATE SALES PER WORKER

gen log_Ptivc1=log(m201c1)-log(Lef1)
gen log_Ptivc1_sq=log_Ptivc1*log_Ptivc1


* GENERATE SPENDING IN TECHNOLOGY PER WORKER

gen SIA1_Lef1=SIA1/Lef1
gen SIA2_Lef2=SIA2/Lef2
gen log_SIA1_Lef1 =log(SIA1/Lef1) 
gen log_SIA2_Lef2 =log(SIA2/Lef2)
gen Dlog_SIA_Lef=log(SIA2/Lef2)-log(SIA1/Lef1)


* GENERATE  INVESTMENT IN CAPITAL GOODS: m206a1-m206d1

gen Sk1=m206a1+ m206b1+m206c1+m206d1
gen Sk1_Lef1= Sk1/Lef1


* GENERATE EXPORT STATUS: based on export sales m202e1-m202e2

gen X1=1 if m202e1>0 
replace X1=0 if m202e1==0 
gen X2=1 if m202e2>0 
replace X2=0 if m202e2==0 
gen X2_X1=X2-X1
gen EE=1 if X1==1 & X2==1 
replace EE=0 if EE==. 
gen NE=1 if X1==0 & X2==1 
replace NE=0 if NE==. 
gen EN=1 if X1==1 & X2==0 
replace EN=0 if EN==. 


* Identify and drop extreme observations: change in main variables bigger than 8 standard deviations from the mean

# delimit ;
for X in var log_m201c2_log_m201c1  log_Lef2_log_Lef1 log_SIA2_log_SIA1 DLs_Lef:
egen m_X=mean(X)
\ egen s_X=sd(X)
\ gen z_X= (X-m_X)/s_X
\sum z_X
\drop if z_X>8 & z_X~=.
\drop if z_X<-8 & z_X~=.;

# delimit cr

* GENERATE SIZE MEASURE: employment in efficiency units relative to 4-digit-industry mean

areg log_Lef1, a(sectorIV)
predict log_Lef1d4, r


* GENERATE QUARTILES

xtile log_Lef1d4Q = log_Lef1d4, nquantiles(4)
tabulate log_Lef1d4Q, gen(log_Lef1d4QD)

* GENERATE INTERACTIONS OF QUARTILES AND TARIFFS 

gen dtbw1992_log_Lef1d4QD1=dtbw1992*log_Lef1d4QD1
gen dtbw1992_log_Lef1d4QD2=dtbw1992*log_Lef1d4QD2
gen dtbw1992_log_Lef1d4QD3=dtbw1992*log_Lef1d4QD3
gen dtbw1992_log_Lef1d4QD4=dtbw1992*log_Lef1d4QD4


gen DTargbraw92_log_Lef1d4QD1=DTargbraw92*log_Lef1d4QD1
gen DTargbraw92_log_Lef1d4QD2=DTargbraw92*log_Lef1d4QD2
gen DTargbraw92_log_Lef1d4QD3=DTargbraw92*log_Lef1d4QD3
gen DTargbraw92_log_Lef1d4QD4=DTargbraw92*log_Lef1d4QD4


gen dtab1992_inputs_log_Lef1d4QD1=dtab1992_inputs*log_Lef1d4QD1
gen dtab1992_inputs_log_Lef1d4QD2=dtab1992_inputs*log_Lef1d4QD2
gen dtab1992_inputs_log_Lef1d4QD3=dtab1992_inputs*log_Lef1d4QD3
gen dtab1992_inputs_log_Lef1d4QD4=dtab1992_inputs*log_Lef1d4QD4


gen DTWAw_log_Lef1d4QD1=DTWAw*log_Lef1d4QD1
gen DTWAw_log_Lef1d4QD2=DTWAw*log_Lef1d4QD2
gen DTWAw_log_Lef1d4QD3=DTWAw*log_Lef1d4QD3
gen DTWAw_log_Lef1d4QD4=DTWAw*log_Lef1d4QD4


gen dtaw_inputs_log_Lef1d4QD1=dtaw_inputs*log_Lef1d4QD1
gen dtaw_inputs_log_Lef1d4QD2=dtaw_inputs*log_Lef1d4QD2
gen dtaw_inputs_log_Lef1d4QD3=dtaw_inputs*log_Lef1d4QD3
gen dtaw_inputs_log_Lef1d4QD4=dtaw_inputs*log_Lef1d4QD4


* GENERATE INTERACTIONS OF QUARTILES AND CAPITAL, SKILL INTENSITY AND ELASTICITY OF DEMAND (sigma) 


gen log_K_L_us_log_Lef1d4QD1=log_K_L_us_avg80*log_Lef1d4QD1
gen log_K_L_us_log_Lef1d4QD2=log_K_L_us_avg80*log_Lef1d4QD2
gen log_K_L_us_log_Lef1d4QD3=log_K_L_us_avg80*log_Lef1d4QD3
gen log_K_L_us_log_Lef1d4QD4=log_K_L_us_avg80*log_Lef1d4QD4


gen log_Ls_L_us_log_Lef1d4QD1=log_Ls_L_us_avg80*log_Lef1d4QD1
gen log_Ls_L_us_log_Lef1d4QD2=log_Ls_L_us_avg80*log_Lef1d4QD2
gen log_Ls_L_us_log_Lef1d4QD3=log_Ls_L_us_avg80*log_Lef1d4QD3
gen log_Ls_L_us_log_Lef1d4QD4=log_Ls_L_us_avg80*log_Lef1d4QD4


gen sigma_log_Lef1d4QD1=sigma*log_Lef1d4QD1
gen sigma_log_Lef1d4QD2=sigma*log_Lef1d4QD2
gen sigma_log_Lef1d4QD3=sigma*log_Lef1d4QD3
gen sigma_log_Lef1d4QD4=sigma*log_Lef1d4QD4


* GENERATE DOMESTIC SALES


gen DS1=m201c1-m202e1
gen DS2=m201c2-m202e2
gen log_DS2_log_DS1=log(DS2)-log(DS1)

**6 Save Datasets

* SAVE FINAL Firm-level DATASET 

save Firm_1.dta, replace

* SAVE FINAL Industry-level DATASET 

collapse sectorII tbw1991 tbw1992  Targbraw92 tab1992_inputs dtbw1992 DTWAw DTargbraw92 dtaw_inputs dtab1992_inputs sigma log_K_L_us_avg80 log_Ls_L_us_avg80 xb1992 xb1996, by(sectorIV)

* Generate export sales from Argentina to Brazil variables

/* Variable definitions:
xb1996: exports from Argentina to Brazil in current thousand dollars in 1996
xb1992:idem for 1992
*/

gen log_xb_96= log(xb1996)
gen log_xb_92= log(xb1992)
gen dlog_xb_9692= log(xb1996)-log(xb1992)

* Set two extreme observations to missing (exports in 1996 are more than 400 times exports in 1992)
replace dlog_xb_9692=. if dlog_xb_9692>6

save Industry.dta, replace
