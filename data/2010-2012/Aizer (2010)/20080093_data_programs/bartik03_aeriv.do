#delimit;
cap log close;
clear;
log using bartik03_aeriv.log,replace;
set mem 550m;


/* update through 2003 - create ratioemp which is the ratio of female tomale employment growth to use as an IV 
for wage growth*/


use naics90.dta;

local x=91;
while `x'<=103 {;
append using naics`x'.dta;
local x=`x'+1;
};

sort fips year;
merge fips year using censusraceyr.dta;
tab _merge;
drop _merge;


sort year;
merge year using naicsca03.dta;
tab _merge;
drop _merge;


/* need to generate weekly wages*/

gen femhs_55=0;
gen malehs_55=0;


/* california employment*/

/* malewage <=HS males in LF*/

gen 
maleemp_hs=malehs_11*(empca11-emp11)+
malehs_21*(empca21-emp21) +
malehs_22*(empca22-emp22)+ 
malehs_23*(empca23-emp23) + 
malehs_31*(empca31-emp31) +
malehs_42*(empca42-emp42)+ 
malehs_44*(empca44-emp44) +
malehs_48*(empca48-emp48)+ 
malehs_51*(empca51-emp51) +
malehs_52*(empca52-emp52)+ 
malehs_53*(empca53-emp53) + 
malehs_54*(empca54-emp54) +
malehs_55*(empca55-emp55) + 
malehs_56*(empca56-emp56) + 
malehs_61*(empca61-emp61) +
malehs_62*(empca62-emp62) + 
malehs_71*(empca71-emp71)+
malehs_72*(empca72-emp72) +
malehs_81*(empca81-emp81) + 
malehs_92*(empca92-emp92);

label var maleemp_hs "Male employment in all counties but focal";

/* femwage_hs <= HS females in LF*/

gen 
fememp_hs=femhs_11*(empca11-emp11)+
femhs_21*(empca21-emp21) +
femhs_22*(empca22-emp22)+ 
femhs_23*(empca23-emp23) + 
femhs_31*(empca31-emp31) +
femhs_42*(empca42-emp42)+ 
femhs_44*(empca44-emp44) +
femhs_48*(empca48-emp48)+ 
femhs_51*(empca51-emp51) +
femhs_52*(empca52-emp52)+ 
femhs_53*(empca53-emp53) + 
femhs_54*(empca54-emp54) +
femhs_55*(empca55-emp55) + 
femhs_56*(empca56-emp56) + 
femhs_61*(empca61-emp61) +
femhs_62*(empca62-emp62) + 
femhs_71*(empca71-emp71)+
femhs_72*(empca72-emp72) +
femhs_81*(empca81-emp81) + 
femhs_92*(empca92-emp92);


/* county wages*/

gen femwagecty=femhs_11*wklywage11+femhs_21*wklywage21 + 
femhs_22*wklywage22+
femhs_23*wklywage23 + femhs_31*wklywage31 + femhs_42*wklywage42+
femhs_44*wklywage44 + femhs_48*wklywage48+femhs_51*wklywage51 +
femhs_52*wklywage52+femhs_53*wklywage53 + femhs_54*wklywage54 +
femhs_55*wklywage55 + femhs_56*wklywage56 + femhs_61*wklywage61 +
femhs_62*wklywage62 + femhs_71*wklywage71+femhs_72*wklywage72 +
femhs_81*wklywage81 + femhs_92*wklywage92;

gen malewagecty=malehs_11*wklywage11 + malehs_21*wklywage21 + 
malehs_22*wklywage22
+ malehs_23*wklywage23 + malehs_31*wklywage31 + malehs_42*wklywage42+
malehs_44*wklywage44 + malehs_48*wklywage48 + malehs_51*wklywage51 +
malehs_52*wklywage52 + malehs_53*wklywage53 + malehs_54*wklywage54 +
malehs_55*wklywage55 + malehs_56*wklywage56 + malehs_61*wklywage61 +
malehs_62*wklywage62 + malehs_71*wklywage71 + malehs_72*wklywage72 +
malehs_81*wklywage81 + malehs_92*wklywage92;

label var femwagecty "female wage - county level";
label var malewagecty "male wage - county level";



keep fips year femwagecty fememp malewagecty maleemp race;

sort year;
merge year using cpi.dta;
keep if _merge==3;
drop _merge;


replace femwagecty=femwagecty*100/cpi;
replace malewagecty=malewagecty*100/cpi;
gen difwcty=malewagecty-femwagecty;
gen ratiowcty=femwagecty/malewagecty;


/*label vars*/

gen ratioemp=fememp/maleemp;
label var ratioemp "Female/male employment";
gen lratioemp=ln(fememp)/ln(maleemp);
label var lratioemp "Ln(female)/Ln(male) employment";

keep ratioemp lratioemp ratiowcty difwcty fips race year femwagecty 
malewagecty fememp_hs maleemp_hs;
sort fips year race;
save bartik03_aeriv.dta,replace;





