#delimit;

local x=1;
while `x'<=4 {;

gen uburn`x'=(ecode`x'==8920);
replace uburn`x'=(ecode`x'>=8900 & ecode`x'<=8920);
replace uburn`x'=(ecode`x'>=8930 & ecode`x'<=8990);
replace uburn`x'=ecode`x'>=9240 & ecode`x'<=9249;

gen ucut`x'=ecode`x'>=9200 & ecode`x'<=9209;

gen udrown`x'=ecode`x'>=8300 & ecode`x'<=8309;
replace udrown`x'=1 if ecode`x'>=8320 & ecode`x'<=8329;
replace udrown`x'=1 if ecode`x'>=9100 & ecode`x'<=9109;

gen ufall`x'=ecode`x'>=8800 & ecode`x'<=8880;
gen ugun`x'=ecode`x'>=9220 & ecode`x'<=9229;

gen mvdriver`x'=ecode`x'>=8100 & ecode`x'<=8199;

gen mvped`x'=ecode`x'>=8000 & ecode`x'<=8079;
replace  mvped`x'=1 if ecode`x'>=8200 & ecode`x'<=8299;
replace  mvped`x'=1 if ecode`x'>=8310 & ecode`x'<=8319;
replace  mvped`x'=1 if ecode`x'>=8330 & ecode`x'<=8459;

gen upoison`x'=ecode`x'>=8500 & ecode`x'<=8699;
gen ustruck`x'=ecode`x'>=9160 & ecode`x'<=9179;
gen usuffocate`x'=ecode`x'>=9110 & ecode`x'<=9139;
gen uother`x'=ecode`x'>=8460 & ecode`x'<=8480;
replace uother`x'=1 if ecode`x'==8870 | ecode`x'==9180 | ecode`x'==9225;
replace uother`x'=1 if ecode`x'>=9140 & ecode`x'<=9150;
replace uother`x'=1 if ecode`x'>=9210 & ecode`x'<=9219;
replace uother`x'=1 if ecode`x'>=9230 & ecode`x'<=9239;
replace uother`x'=1 if ecode`x'>=9250 & ecode`x'<=9269;
replace uother`x'=1 if ecode`x'==9283 | ecode`x'==9288 | ecode`x'==9289;


gen suicide`x'=ecode`x'>=9500 & ecode`x'<9600;

/*
gen aassault`x'=1 if ecode`x'>=9600 & ecode`x'<=9601;
replace aassault`x'=ecode`x'==9610;
replace aassault`x'=1 if ecode`x'>=9620 & ecode`x'<9629;
replace aassault`x'=1 if ecode`x'>=9630 & ecode`x'<=9649;
replace aassault`x'=1 if ecode`x'>=9650 & ecode`x'<=9660;
replace aassault`x'=1 if ecode`x'>=9670 & ecode`x'<=9689;
replace aassault`x'=1 if ecode`x'>=9790 & ecode`x'<=9799;
*/


gen aassault`x'=1 if ecode`x'>=9600 & ecode`x'<9700;

gen fight`x'=1 if ecode`x'>=9600 & ecode`x'<9610;

gen poison`x'=1 if ecode`x'>=9610 & ecode`x'<9630;

gen strang`x'=1 if ecode`x'>=9630 & ecode`x'<9640;

gen drown`x'=1 if ecode`x'>=9640 & ecode`x'<9650;

gen gun`x'=1 if ecode`x'>=9650 & ecode`x'<9660;

gen cut`x'=1 if ecode`x'>=9660 & ecode`x'<9670;

gen batter`x'=1 if ecode`x'>=9670 & ecode`x'<9680;

gen othassault`x'=1 if ecode`x'>=9680 & ecode`x'<9690;

local x=`x'+1;
};


egen unint=rsum(uburn1 ucut1 udrown1 ufall1 ugun1 upoison1 ustruck1
usuffocate1);

replace unint=1 if unint>1 & unint<.;

local x=1;
while `x'<=4 {;
drop uburn`x' ucut`x' ufall`x' ugun`x' upoison`x' ustruck`x' 
usuffocate`x';  
local x=`x'+1;
};




gen anyinj=0;
replace anyinj=1 if ecode1~=.;

gen assault=aassault1;
replace assault=1 if aassault2==1 | aassault3==1 | aassault4==1;

gen assaultng=assault;
replace assaultng=0 if gun1==1 | gun2==1 | gun3==1 | gun4==1; 

gen gun=0;
replace gun=1 if gun1==1 | gun2==1 | gun3==1 | gun4==1;

gen cut=0;
replace cut=1 if cut1==1 | cut2==1 | cut3==1 | cut4==1;

gen fight=0;
replace fight=1 if fight1==1 | fight2==1 | fight3==1 | fight4==1;

gen strang=0;
replace strang=1 if strang1==1 | strang2==1 | strang3==1 | strang4==1;

gen batter=0;
replace batter=1 if batter1==1 | batter2==1 | batter3==1 | batter4==1;

gen poison=0;
replace poison=1 if poison1==1 | poison2==1 | poison3==1 | poison4==1;

gen drown=0;
replace drown=1 if drown1==1 | drown2==1 | drown3==1 | drown4==1;

gen othassault=0;
replace othassault=1 if othassault1==1 | othassault2==1 | othassault3==1 | 
othassault4==1;



gen suicide=suicide1;
gen mvdriver=mvdriver1;
gen mvped=mvped1;

replace mvdriver=0 if suicide==1;
replace mvdriver=0 if assault==1;

replace mvped=0 if suicide==1;
replace mvped=0 if assault==1;

replace unint=0 if assault==1 | suicide==1;
replace suicide=0 if assault==1;





local x=1;
while `x'<=4 {;
drop aassault`x' suicide`x' batter`x' mvdriver`x' mvped`x' uother`x' 
gun`x' strang`x' drown`x' cut`x' batter`x' fight`x' othassault`x' 
poison`x';
local x=`x'+1;
};

