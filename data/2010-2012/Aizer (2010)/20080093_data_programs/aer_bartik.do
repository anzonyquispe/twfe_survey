#delimit;
cap log close;
clear;
log using aer_bartik.log,replace;
set mem 550m;

/* update through 2003*/


use ../naics/naics90.dta;

local x=91;
while `x'<=103 {;
append using ../naics/naics`x'.dta;
local x=`x'+1;
};

sort fips year;
merge fips year using censusraceyr.dta;
tab _merge;
drop _merge;


sort year;
merge year using ../naics/naicsca03.dta;
tab _merge;
drop _merge;


/* need to generate weekly wages*/

gen femhs_55=0;
gen malehs_55=0;
gen femhs2_55=0;
gen malehs2_55=0;

/* malewage <=HS males in LF*/

gen 
malewage_hs=malehs_11*(annwageca11-annwage11)/(empca11-emp11)+
malehs_21*(annwageca21-annwage21)/(empca21-emp21) +
malehs_22*(annwageca22-annwage22)/(empca22-emp22)+ 
malehs_23*(annwageca23-annwage23)/(empca23-emp23) + 
malehs_31*(annwageca31-annwage31)/(empca31-emp31) +
malehs_42*(annwageca42-annwage42)/(empca42-emp42)+ 
malehs_44*(annwageca44-annwage44)/(empca44-emp44) +
malehs_48*(annwageca48-annwage48)/(empca48-emp48)+ 
malehs_51*(annwageca51-annwage51)/(empca51-emp51) +
malehs_52*(annwageca52-annwage52)/(empca52-emp52)+ 
malehs_53*(annwageca53-annwage53)/(empca53-emp53) + 
malehs_54*(annwageca54-annwage54)/(empca54-emp54) +
malehs_55*(annwageca55-annwage55)/(empca55-emp55) + 
malehs_56*(annwageca56-annwage56)/(empca56-emp56) + 
malehs_61*(annwageca61-annwage61)/(empca61-emp61) +
malehs_62*(annwageca62-annwage62)/(empca62-emp62) + 
malehs_71*(annwageca71-annwage71)/(empca71-emp71)+
malehs_72*(annwageca72-annwage72)/(empca72-emp72) +
malehs_81*(annwageca81-annwage81)/(empca81-emp81) + 
malehs_92*(annwageca92-annwage92)/(empca92-emp92);

replace malewage_hs=malewage_hs/52;
summ malewage_hs;

/* femwage_hs <= HS females in LF*/

gen 
femwage_hs=femhs_11*(annwageca11-annwage11)/(empca11-emp11)+
femhs_21*(annwageca21-annwage21)/(empca21-emp21) +
femhs_22*(annwageca22-annwage22)/(empca22-emp22)+ 
femhs_23*(annwageca23-annwage23)/(empca23-emp23) + 
femhs_31*(annwageca31-annwage31)/(empca31-emp31) +
femhs_42*(annwageca42-annwage42)/(empca42-emp42)+ 
femhs_44*(annwageca44-annwage44)/(empca44-emp44) +
femhs_48*(annwageca48-annwage48)/(empca48-emp48)+ 
femhs_51*(annwageca51-annwage51)/(empca51-emp51) +
femhs_52*(annwageca52-annwage52)/(empca52-emp52)+ 
femhs_53*(annwageca53-annwage53)/(empca53-emp53) + 
femhs_54*(annwageca54-annwage54)/(empca54-emp54) +
femhs_55*(annwageca55-annwage55)/(empca55-emp55) + 
femhs_56*(annwageca56-annwage56)/(empca56-emp56) + 
femhs_61*(annwageca61-annwage61)/(empca61-emp61) +
femhs_62*(annwageca62-annwage62)/(empca62-emp62) + 
femhs_71*(annwageca71-annwage71)/(empca71-emp71)+
femhs_72*(annwageca72-annwage72)/(empca72-emp72) +
femhs_81*(annwageca81-annwage81)/(empca81-emp81) + 
femhs_92*(annwageca92-annwage92)/(empca92-emp92);

replace femwage_hs=femwage_hs/52;
summ femwage_hs;

/* malewage <=HS males in LF no military*/

gen 
malewage2_hs=malehs2_11*(annwageca11-annwage11)/(empca11-emp11)+
malehs2_21*(annwageca21-annwage21)/(empca21-emp21) +
malehs2_22*(annwageca22-annwage22)/(empca22-emp22)+ 
malehs2_23*(annwageca23-annwage23)/(empca23-emp23) + 
malehs2_31*(annwageca31-annwage31)/(empca31-emp31) +
malehs2_42*(annwageca42-annwage42)/(empca42-emp42)+ 
malehs2_44*(annwageca44-annwage44)/(empca44-emp44) +
malehs2_48*(annwageca48-annwage48)/(empca48-emp48)+ 
malehs2_51*(annwageca51-annwage51)/(empca51-emp51) +
malehs2_52*(annwageca52-annwage52)/(empca52-emp52)+ 
malehs2_53*(annwageca53-annwage53)/(empca53-emp53) + 
malehs2_54*(annwageca54-annwage54)/(empca54-emp54) +
malehs2_55*(annwageca55-annwage55)/(empca55-emp55) + 
malehs2_56*(annwageca56-annwage56)/(empca56-emp56) + 
malehs2_61*(annwageca61-annwage61)/(empca61-emp61) +
malehs2_62*(annwageca62-annwage62)/(empca62-emp62) + 
malehs2_71*(annwageca71-annwage71)/(empca71-emp71)+
malehs2_72*(annwageca72-annwage72)/(empca72-emp72) +
malehs2_81*(annwageca81-annwage81)/(empca81-emp81) + 
malehs2_92*(annwageca92-annwage92)/(empca92-emp92);

replace malewage2_hs=malewage2_hs/52;
summ malewage_hs malewage2_hs;

/* femwage_hs <= HS females in LF*/

gen 
femwage2_hs=femhs2_11*(annwageca11-annwage11)/(empca11-emp11)+
femhs2_21*(annwageca21-annwage21)/(empca21-emp21) +
femhs2_22*(annwageca22-annwage22)/(empca22-emp22)+ 
femhs2_23*(annwageca23-annwage23)/(empca23-emp23) + 
femhs2_31*(annwageca31-annwage31)/(empca31-emp31) +
femhs2_42*(annwageca42-annwage42)/(empca42-emp42)+ 
femhs2_44*(annwageca44-annwage44)/(empca44-emp44) +
femhs2_48*(annwageca48-annwage48)/(empca48-emp48)+ 
femhs2_51*(annwageca51-annwage51)/(empca51-emp51) +
femhs2_52*(annwageca52-annwage52)/(empca52-emp52)+ 
femhs2_53*(annwageca53-annwage53)/(empca53-emp53) + 
femhs2_54*(annwageca54-annwage54)/(empca54-emp54) +
femhs2_55*(annwageca55-annwage55)/(empca55-emp55) + 
femhs2_56*(annwageca56-annwage56)/(empca56-emp56) + 
femhs2_61*(annwageca61-annwage61)/(empca61-emp61) +
femhs2_62*(annwageca62-annwage62)/(empca62-emp62) + 
femhs2_71*(annwageca71-annwage71)/(empca71-emp71)+
femhs2_72*(annwageca72-annwage72)/(empca72-emp72) +
femhs2_81*(annwageca81-annwage81)/(empca81-emp81) + 
femhs2_92*(annwageca92-annwage92)/(empca92-emp92);

replace femwage2_hs=femwage2_hs/52;
summ femwage2_hs;



/*label vars*/
label var femwage2_hs "female wage <=HS women in LF";
label var malewage2_hs "male wage <=HS men in LF";

label var femwage_hs "female wage <=HS women in LF no military";
label var malewage_hs "male wage <=HS men in LF no military";


save tempbartik.dta,replace;

keep fips year femwage* malewage* race;

sort year;
merge year using ../naics/cpi.dta;
keep if _merge==3;
drop _merge;


replace femwage_hs=femwage_hs*100/cpi;
replace malewage_hs=malewage_hs*100/cpi;

gen difw_hs=malewage_hs-femwage_hs;
gen ratiow_hs=femwage_hs/malewage_hs;

label var difw_hs "malewage-femwage <=HS LFPs no military";
label var ratiow_hs "femwage/malewage <=HS LFPs no military";

replace femwage2_hs=femwage2_hs*100/cpi;
replace malewage2_hs=malewage2_hs*100/cpi;

gen difw2_hs=malewage2_hs-femwage2_hs;
gen ratiow2_hs=femwage2_hs/malewage2_hs;

label var difw2_hs "malewage-femwage <=HS LFPs";
label var ratiow2_hs "femwage/malewage <=HS LFPs";


sort fips year race;
save bartik03_aer.dta,replace;





