

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This MATLAB code estimates the hedonic price model and reports standard errors in                             %           
%[A Rational Expectations Approach to Hedonic Price Regressions with Time-Varying Unobserved Product Attributes% 
%:The Price of Pollution]  by Patrick Bajari, Jane Cooley, Kyoo il Kim, and Chris Timmins                      % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

%Load data
load data.txt;


%Years of the 1st and the 2nd transaction
yr2=data(:,2); %2nd transaction
yr1=data(:,7); %1st transaction

%yr1=1 1990
%yr1=2 1991
%:
%yr1=16 2005

%yr2=2 1991
%yr2=3 1992
%:
%yr2=17 2006


%Defining period dummies

dyear1_1 = (yr1<6);
dyear1_2 = (yr1>5).*(yr1<12);
dyear1_3 = (yr1>11);

dyear2_1 = (yr2<6);
dyear2_2 = (yr2>5).*(yr2<12);
dyear2_3 = (yr2>11);


indicate=dyear2_3.*dyear1_2+dyear2_2.*dyear1_1+dyear2_3.*dyear1_1;


%Dropping observations with null values

data=data(indicate~=0,:);

[n,m]=size(data);

%Defining variables

id=data(:,1); %house id #
price2=data(:,3); %price at the 2nd transaction
pmc2=data(:,4); %level of PM10 at the 2nd transaction
soc2=data(:,5); %level of SO2 at the 2nd transaction
ozc2=data(:,6); %level of O3 at the 2nd transaction
price1=data(:,8); %price at the 1st transaction
pmc1=data(:,9); %level of PM10 at the 1st transaction
soc1=data(:,10); %level of SO2 at the 1st transaction
ozc1=data(:,11); %level of O3 at the 1st transaction
built=data(:,12); % year of house built
lotsize=data(:,13); %lot size
sqft=data(:,14); % square footage
baths=data(:,15); % number of bathrooms
bed=data(:,16); % number of bedrooms
room=data(:,17); % number of rooms
county=data(:,18); %county code
tract=data(:,19); %tract code

yr2=data(:,2); %year of the 2nd transaction
yr1=data(:,7); %year of the 1st transaction

%Defining period dummies

dyear1_1 = (yr1<6);
dyear1_2 = (yr1>5).*(yr1<12);
dyear1_3 = (yr1>11);

dyear2_1 = (yr2<6);
dyear2_2 = (yr2>5).*(yr2<12);
dyear2_3 = (yr2>11);


%Renaming pollutant variables

xa1=pmc1;
xa2=pmc2;
xb1=soc1;
xb2=soc2;
xd1=ozc1;
xd2=ozc2;

%Generating county dummies
county1=(county==1);
county2=(county==2);
county3=(county==3);
county4=(county==4);
county5=(county==5);
county6=(county==6);

%Defining differenced polluant variables between two transactions

dxa=xa2-xa1;
dxb=xb2-xb1;
dxd=xd2-xd1;



%Generating year dummies
dya1 = (yr1==1); %1990
dya2 = (yr1==2); %1991
dya3 = (yr1==3);
dya4 = (yr1==4);
dya5 = (yr1==5);
dya6 = (yr1==6);
dya7 = (yr1==7);
dya8 = (yr1==8);
dya9 = (yr1==9);
dya10 = (yr1==10);
dya11 = (yr1==11);
dya12 = (yr1==12);
dya13 = (yr1==13);
dya14 = (yr1==14);
dya15 = (yr1==15);
dya16 = (yr1==16); %2005

dyb1 = (yr2==1); %1990
dyb2 = (yr2==2); %1991
dyb3 = (yr2==3);
dyb4 = (yr2==4);
dyb5 = (yr2==5);
dyb6 = (yr2==6);
dyb7 = (yr2==7);
dyb8 = (yr2==8);
dyb9 = (yr2==9);
dyb10 = (yr2==10);
dyb11 = (yr2==11);
dyb12 = (yr2==12);
dyb13 = (yr2==13);
dyb14 = (yr2==14);
dyb15 = (yr2==15);
dyb16 = (yr2==16); 
dyb17 = (yr2==17); %2006


%Generating log prices
lp1 = log(price1);
lp2 = log(price2);

%Generating the difference of log prices
dlp = lp2-lp1;

%Generating period dummies
y32=dyear2_3.*dyear1_2;
y21=dyear2_2.*dyear1_1;
y31=dyear2_3.*dyear1_1;


%Generating census tract codes
tractgroup=zeros(n,1);
tractgroup(tract<38)=1;
tractgroup(tract>37 & tract<97)=2;
tractgroup(tract>96 & tract<121)=3;
tractgroup(tract>120 & tract<131)=4;
tractgroup(tract>130 & tract<135)=5;
tractgroup(tract>134 & tract<153)=6;
tractgroup(tract>152 & tract<172)=7;
tractgroup(tract>171 & tract<189)=8;
tractgroup(tract>188 & tract<203)=9;
tractgroup(tract>202 & tract<225)=10;
tractgroup(tract>224 & tract<256)=11;
tractgroup(tract>255 & tract<277)=12;
tractgroup(tract>276 & tract<293)=13;
tractgroup(tract>292 & tract<303)=14;
tractgroup(tract>302 & tract<315)=15;
tractgroup(tract>314 & tract<319)=16;
tractgroup(tract>318 & tract<412)=17;
tractgroup(tract>411 & tract<417)=18;
tractgroup(tract>416 & tract<471)=19;
tractgroup(tract>470 & tract<541)=20;
tractgroup(tract>540 & tract<593)=21;
tractgroup(tract>592 & tract<625)=22;
tractgroup(tract>624 & tract<879)=23;
tractgroup(tract>878 & tract<952)=24;
tractgroup(tract>951 & tract<1060)=25;
tractgroup(tract>1059 & tract<1107)=26;
tractgroup(tract==1107)=2;
tractgroup(tract==1108)=4;
tractgroup(tract==1109)=3;
tractgroup(tract==1110)=23;
tractgroup(tract==1111)=23;
tractgroup(tract==1112)=21;
tractgroup(tract==1113)=21;

%creating dummy tract in larger group
tract_ind=dummyvar(tractgroup);
tract_ind=tract_ind(:,1:25);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Two stage nonlinear least squares%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%First step estimation

%%%%%%%%%%%%%
%   PM10    % 
%%%%%%%%%%%%%

%equations that predict second observation pollution levels given first observation pollution and other variables%



% Note dyb1 to dyb4 are all zero. Dummy starts from dyb6

Xa=[ones(n,1) xa1.*y32 xa1.*y31 xa1.*y21 xb1.*y32 xb1.*y31 xb1.*y21 xd1.*y32 xd1.*y31 xd1.*y21 lp1.*y32 lp1.*y31 lp1.*y21 dyb7 dyb8 dyb9 dyb10 dyb11 dyb12 dyb13 dyb14 dyb15 dyb16 dyb17];
Xa=[Xa county2.*y32 county2.*y31 county2.*y21];
Xa=[Xa county3.*y32 county3.*y31 county3.*y21];
Xa=[Xa county4.*y32 county4.*y31 county4.*y21];
Xa=[Xa county5.*y32 county5.*y31 county5.*y21];
Xa=[Xa county6.*y32 county6.*y31 county6.*y21];
Xa=[Xa lotsize.*y32 lotsize.*y31 lotsize.*y21];
Xa=[Xa sqft.*y32 sqft.*y31 sqft.*y21];
Xa=[Xa baths.*y32 baths.*y31 baths.*y21];
Xa=[Xa bed.*y32 bed.*y31 bed.*y21];
Xa=[Xa room.*y32 room.*y31 room.*y21];
Xa=[Xa built.*y32 built.*y31 built.*y21];

[nx,mx]=size(Xa);

aa=Xa\xa2;

%Fitted values
fxa2=Xa*aa;

%Fitted errors
fva=xa2-fxa2;

%Heteroskedasticiy robust variance-covariance for the first step estimators

V0=(Xa'*Xa)/n;
V1=(Xa.*(fva*ones(1,mx)))'*(Xa.*(fva*ones(1,mx)))/n;
Var_a=inv(V0)*V1*inv(V0);

%Clustered robust variance by tract

mtr=max(tract); % # of tracts

V0cl=zeros(mx,mx);
for tr=1:mtr
V0cl=V0cl+(Xa(tract==tr,:)'*Xa(tract==tr,:))/n;
end

V1cl=zeros(mx,mx);
for tr=1:mtr
V1cl=V1cl+Xa(tract==tr,:)'*fva(tract==tr,:)*fva(tract==tr,:)'*Xa(tract==tr,:)/n;
end


Var_acl=inv(V0cl)*V1cl*inv(V0cl);



%First step estimation

%%%%%%%%%%%%
%   SO2    %
%%%%%%%%%%%%

Xb=[ones(n,1) xb1.*y32 xb1.*y31 xb1.*y21 xd1.*y32 xd1.*y31 xd1.*y21 lp1.*y32 lp1.*y31 lp1.*y21 dyb7 dyb8 dyb9 dyb10 dyb11 dyb12 dyb13 dyb14 dyb15 dyb16 dyb17];
Xb=[Xb county2.*y32 county2.*y31 county2.*y21];
Xb=[Xb county3.*y32 county3.*y31 county3.*y21];
Xb=[Xb county4.*y32 county4.*y31 county4.*y21];
Xb=[Xb county5.*y32 county5.*y31 county5.*y21];
Xb=[Xb county6.*y32 county6.*y31 county6.*y21];
Xb=[Xb lotsize.*y32 lotsize.*y31 lotsize.*y21];
Xb=[Xb sqft.*y32 sqft.*y31 sqft.*y21];
Xb=[Xb baths.*y32 baths.*y31 baths.*y21];
Xb=[Xb bed.*y32 bed.*y31 bed.*y21];
Xb=[Xb room.*y32 room.*y31 room.*y21];
Xb=[Xb built.*y32 built.*y31 built.*y21];

[nx,mx]=size(Xb);

ab=Xb\xb2;

%fitted values
fxb2=Xb*ab;

%fitted errors
fvb=xb2-fxb2;

%Heteroskedasticiy robust variance-covariance for the first step estimators

V0=(Xb'*Xb)/n;
V1=(Xb.*(fvb*ones(1,mx)))'*(Xb.*(fvb*ones(1,mx)))/n;
Var_b=inv(V0)*V1*inv(V0);



%Clustered robust variance by tract


V0cl=zeros(mx,mx);
for tr=1:mtr
V0cl=V0cl+(Xb(tract==tr,:)'*Xb(tract==tr,:))/n;
end

V1cl=zeros(mx,mx);
for tr=1:mtr
V1cl=V1cl+Xb(tract==tr,:)'*fvb(tract==tr,:)*fvb(tract==tr,:)'*Xb(tract==tr,:)/n;
end

Var_bcl=inv(V0cl)*V1cl*inv(V0cl);





%First step estimation

%%%%%%%%%
%   O3  %
%%%%%%%%%

Xd=[ones(n,1) xd1.*y32 xd1.*y31 xd1.*y21 xa1.*y32 xa1.*y31 xa1.*y21 xb1.*y32 xb1.*y31 xb1.*y21 lp1.*y32 lp1.*y31 lp1.*y21 dyb7 dyb8 dyb9 dyb10 dyb11 dyb12 dyb13 dyb14 dyb15 dyb16 dyb17];
Xd=[Xd county2.*y32 county2.*y31 county2.*y21];
Xd=[Xd county3.*y32 county3.*y31 county3.*y21];
Xd=[Xd county4.*y32 county4.*y31 county4.*y21];
Xd=[Xd county5.*y32 county5.*y31 county5.*y21];
Xd=[Xd county6.*y32 county6.*y31 county6.*y21];
Xd=[Xd lotsize.*y32 lotsize.*y31 lotsize.*y21];
Xd=[Xd sqft.*y32 sqft.*y31 sqft.*y21];
Xd=[Xd baths.*y32 baths.*y31 baths.*y21];
Xd=[Xd bed.*y32 bed.*y31 bed.*y21];
Xd=[Xd room.*y32 room.*y31 room.*y21];
Xd=[Xd built.*y32 built.*y31 built.*y21];



ad=Xd\xd2;

%fitted values
fxd2=Xd*ad;

%fitted errors
fvd=xd2-fxd2;

[nx,mx]=size(Xd);

%Heteroskedasticiy robust variance-covariance for the first step estimators

V0=(Xd'*Xd)/n;
V1=(Xd.*(fvd*ones(1,mx)))'*(Xd.*(fvd*ones(1,mx)))/n;
Var_d=inv(V0)*V1*inv(V0);


%Clustered robust variance by tract


V0cl=zeros(mx,mx);
for tr=1:mtr
V0cl=V0cl+(Xd(tract==tr,:)'*Xd(tract==tr,:))/n;
end

V1cl=zeros(mx,mx);
for tr=1:mtr
V1cl=V1cl+Xd(tract==tr,:)'*fvd(tract==tr,:)*fvd(tract==tr,:)'*Xd(tract==tr,:)/n;
end

Var_dcl=inv(V0cl)*V1cl*inv(V0cl);



clear Xd11 Xd22 Xd33 Xd44 Xd55 Xd66 Xd77 Xd88 fvd11 fvd22 fvd33 fvd44 fvd55 fvd66 fvd77 fvd88 V11cl V22cl V33cl V44cl V55cl V66cl V77cl V88cl





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main estimation: 2nd stage%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%All 3 pollutants together a, b, and d


global n lotsize sqft bed room baths built lp2 lp1 fxa2 xa1 fxb2 xb1 fxd2 xd1 dyear1_1 dyear1_2 dyear1_3 dyear2_1 dyear2_2 dyear2_3 county2 county3 county4 county5 county6

%initial values for estimation 
theta0=zeros(42,1);


%implementing nonlinear LS
theta=lsqnonlin('secondstepall_2sls_fullgamma_obj',theta0);

%obtaining estimates
ba=theta(1);
bb=theta(2);
bd=theta(3);
d1_32=theta(4);
d2_32=theta(5);
d3_32=theta(6);
d4_32=theta(7);
d5_32=theta(8);
d6_32=theta(9);
d7_32=theta(10);
d8_32=theta(11);
d9_32=theta(12);
d10_32=theta(13);
d11_32=theta(14);
d1_31=theta(15);
d2_31=theta(16);
d3_31=theta(17);
d4_31=theta(18);
d5_31=theta(19);
d6_31=theta(20);
d7_31=theta(21);
d8_31=theta(22);
d9_31=theta(23);
d10_31=theta(24);
d11_31=theta(25);
d1_21=theta(26);
d2_21=theta(27);
d3_21=theta(28);
d4_21=theta(29);
d5_21=theta(30);
d6_21=theta(31);
d7_21=theta(32);
d8_21=theta(33);
d9_21=theta(34);
d10_21=theta(35);
d11_21=theta(36);
h32=theta(37);
h31=theta(38);
h21=theta(39);
g32=theta(40);
g31=theta(41);
g21=theta(42);



%fitted residuals
fit32_all=(lp2 - (h32+g32*lp1-g32*ba*xa1+ba*xa2-g32*bb*xb1+bb*xb2-g32*bd*xd1+bd*xd2+d1_32*lotsize+d2_32*sqft+d3_32*bed+d4_32*room+d5_32*baths+d6_32*county2+d7_32*county3+d8_32*county4+d9_32*county5+d10_32*county6+d11_32*built));
fit31_all=(lp2 - (h31+g31*lp1-g31*ba*xa1+ba*xa2-g31*bb*xb1+bb*xb2-g31*bd*xd1+bd*xd2+d1_31*lotsize+d2_31*sqft+d3_31*bed+d4_31*room+d5_31*baths+d6_31*county2+d7_31*county3+d8_31*county4+d9_31*county5+d10_31*county6+d11_31*built));
fit21_all=(lp2 - (h21+g21*lp1-g21*ba*xa1+ba*xa2-g21*bb*xb1+bb*xb2-g21*bd*xd1+bd*xd2+d1_21*lotsize+d2_21*sqft+d3_21*bed+d4_21*room+d5_21*baths+d6_21*county2+d7_21*county3+d8_21*county4+d9_21*county5+d10_21*county6+d11_21*built));
fit_all=(fit32_all.*dyear2_3.*dyear1_2+fit31_all.*dyear2_3.*dyear1_1+fit21_all.*dyear2_2.*dyear1_1);

resid_all=fit_all;
        
%Calulating derivatives to obtain Var-Cov Matrix

G_all_1=(-g32*xa1+fxa2).*dyear2_3.*dyear1_2+(-g31*xa1+fxa2).*dyear2_3.*dyear1_1+(-g21*xa1+fxa2).*dyear2_2.*dyear1_1;
G_all_2=(-g32*xb1+fxb2).*dyear2_3.*dyear1_2+(-g31*xb1+fxb2).*dyear2_3.*dyear1_1+(-g21*xb1+fxb2).*dyear2_2.*dyear1_1;
G_all_3=(-g32*xd1+fxd2).*dyear2_3.*dyear1_2+(-g31*xd1+fxd2).*dyear2_3.*dyear1_1+(-g21*xd1+fxd2).*dyear2_2.*dyear1_1;
G_all_4=lotsize.*y32;
G_all_5=sqft.*y32;
G_all_6=bed.*y32;
G_all_7=room.*y32;
G_all_8=baths.*y32;
G_all_9=county2.*y32;
G_all_10=county3.*y32;
G_all_11=county4.*y32;
G_all_12=county5.*y32;
G_all_13=county6.*y32;
G_all_14=built.*y32;
G_all_15=lotsize.*y31;
G_all_16=sqft.*y31;
G_all_17=bed.*y31;
G_all_18=room.*y31;
G_all_19=baths.*y31;
G_all_20=county2.*y31;
G_all_21=county3.*y31;
G_all_22=county4.*y31;
G_all_23=county5.*y31;
G_all_24=county6.*y31;
G_all_25=built.*y31;
G_all_26=lotsize.*y21;
G_all_27=sqft.*y21;
G_all_28=bed.*y21;
G_all_29=room.*y21;
G_all_30=baths.*y21;
G_all_31=county2.*y21;
G_all_32=county3.*y21;
G_all_33=county4.*y21;
G_all_34=county5.*y21;
G_all_35=county6.*y21;
G_all_36=built.*y21;
G_all_37=1*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_all_38=0*dyear2_3.*dyear1_2+1*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_all_39=0*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+1*dyear2_2.*dyear1_1;


G_all_40=(lp1-ba*xa1-bb*xb1-bd*xd1).*dyear2_3.*dyear1_2;
G_all_41=(lp1-ba*xa1-bb*xb1-bd*xd1).*dyear2_3.*dyear1_1;
G_all_42=(lp1-ba*xa1-bb*xb1-bd*xd1).*dyear2_2.*dyear1_1;

G_all=[G_all_1 G_all_2 G_all_3 G_all_4 G_all_5 G_all_6 G_all_7 G_all_8 G_all_9 G_all_10 G_all_11 G_all_12 G_all_13 G_all_14 G_all_15];
G_all=[G_all G_all_16 G_all_17 G_all_18 G_all_19 G_all_20 G_all_21 G_all_22 G_all_23 G_all_24 G_all_25 G_all_26 G_all_27 G_all_28 G_all_29 G_all_30];
G_all=[G_all G_all_31 G_all_32 G_all_33 G_all_34 G_all_35 G_all_36 G_all_37 G_all_38 G_all_39 G_all_40 G_all_41 G_all_42];

clear G_all_1 G_all_2 G_all_3 G_all_4 G_all_5 G_all_6 G_all_7 G_all_8 G_all_9 G_all_10 G_all_11 G_all_12 G_all_13 G_all_14 G_all_15
clear G_all_16 G_all_17 G_all_18 G_all_19 G_all_20 G_all_21 G_all_22 G_all_23 G_all_24 G_all_25 G_all_26 G_all_27 G_all_28 G_all_29 G_all_30
clear G_all_31 G_all_32 G_all_33 G_all_34 G_all_35 G_all_36 G_all_37 G_all_38 G_all_39 G_all_40 G_all_41 G_all_42



Gamma_a=ba*Xa;
Gamma_b=bb*Xb;
Gamma_d=bd*Xd;



Omega_all=(G_all.*(resid_all*ones(1,42)))'*(G_all.*(resid_all*ones(1,42)))/n;
Q0=G_all'*G_all/n;
Q1_a=G_all'*Gamma_a/n;
Q1_b=G_all'*Gamma_b/n;
Q1_d=G_all'*Gamma_d/n;

Sigma_all=inv(Q0)*(Omega_all+Q1_a*Var_a*Q1_a'+Q1_b*Var_b*Q1_b'+Q1_d*Var_d*Q1_d')*inv(Q0);

%Heteroskedasticity robust standard errors

SE_all=sqrt(diag(Sigma_all)/n);

%t statistics
t_all=theta./SE_all;



%Cluster robust standard errors by tract

[G_alln,G_allm]=size(G_all);


Omega_allcl=zeros(G_allm, G_allm);

for tr=1:mtr
Omega_allcl=Omega_allcl+G_all(tract==tr,:)'*resid_all(tract==tr,:)*resid_all(tract==tr,:)'*G_all(tract==tr,:)/n;
end


Sigma_allcl=inv(Q0)*(Omega_allcl+Q1_a*Var_acl*Q1_a'+Q1_b*Var_bcl*Q1_b'+Q1_d*Var_dcl*Q1_d')*inv(Q0);

SE_allcl=sqrt(diag(Sigma_allcl)/n);

%t statistics
t_allcl=theta./SE_allcl;



%R-squared
RSS_all=(resid_all)'*(resid_all);
TSS_all=(lp2-mean(lp2))'*(lp2-mean(lp2));
R2_all=1-RSS_all/TSS_all;


clear G_all Gamma_a Gamma_b Gamma_d Q1_a Q1_b Q1_d RSS_all TSS_all

clear global fxa2
clear fxa2



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Estimation using each pollutant at a time%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%
% PM10 only % 
%%%%%%%%%%%%%

%first stage

% Note dyb1 to dyb4 are all zero. Dummy starts from dyb6

Xa=[ones(n,1) xa1.*y32 xa1.*y31 xa1.*y21 lp1.*y32 lp1.*y31 lp1.*y21 dyb7 dyb8 dyb9 dyb10 dyb11 dyb12 dyb13 dyb14 dyb15 dyb16 dyb17];
Xa=[Xa county2.*y32 county2.*y31 county2.*y21];
Xa=[Xa county3.*y32 county3.*y31 county3.*y21];
Xa=[Xa county4.*y32 county4.*y31 county4.*y21];
Xa=[Xa county5.*y32 county5.*y31 county5.*y21];
Xa=[Xa county6.*y32 county6.*y31 county6.*y21];
Xa=[Xa lotsize.*y32 lotsize.*y31 lotsize.*y21];
Xa=[Xa sqft.*y32 sqft.*y31 sqft.*y21];
Xa=[Xa baths.*y32 baths.*y31 baths.*y21];
Xa=[Xa bed.*y32 bed.*y31 bed.*y21];
Xa=[Xa room.*y32 room.*y31 room.*y21];
Xa=[Xa built.*y32 built.*y31 built.*y21];

[nx,mx]=size(Xa);

aa=Xa\xa2;

%fitted values
fxa2=Xa*aa;

%fitted errors
fva=xa2-fxa2;

%Heteroskedasticiy robust variance-covariance for the first step estimators


V0=(Xa'*Xa)/n;
V1=(Xa.*(fva*ones(1,mx)))'*(Xa.*(fva*ones(1,mx)))/n;
Var_a=inv(V0)*V1*inv(V0);


%Clustered robust variance by tract

mtr=max(tract); % # of tracts

V0cl=zeros(mx,mx);
for tr=1:mtr
V0cl=V0cl+(Xa(tract==tr,:)'*Xa(tract==tr,:))/n;
end

V1cl=zeros(mx,mx);
for tr=1:mtr
V1cl=V1cl+Xa(tract==tr,:)'*fva(tract==tr,:)*fva(tract==tr,:)'*Xa(tract==tr,:)/n;
end


Var_acl=inv(V0cl)*V1cl*inv(V0cl);




%second stage


theta_a0=[zeros(40,1)];

global n lotsize sqft bed room baths built lp2 lp1 fxa2 xa1 fxb2 xb1 fxd2 xd1 dyear1_1 dyear1_2 dyear1_3 dyear2_1 dyear2_2 dyear2_3 county2 county3 county4 county5 county6

theta_a=lsqnonlin('secondstepa_2sls_fullgamma_obj',theta_a0);


ba=theta_a(1);
d1_32=theta_a(2);
d2_32=theta_a(3);
d3_32=theta_a(4);
d4_32=theta_a(5);
d5_32=theta_a(6);
d6_32=theta_a(7);
d7_32=theta_a(8);
d8_32=theta_a(9);
d9_32=theta_a(10);
d10_32=theta_a(11);
d11_32=theta_a(12);
d1_31=theta_a(13);
d2_31=theta_a(14);
d3_31=theta_a(15);
d4_31=theta_a(16);
d5_31=theta_a(17);
d6_31=theta_a(18);
d7_31=theta_a(19);
d8_31=theta_a(20);
d9_31=theta_a(21);
d10_31=theta_a(22);
d11_31=theta_a(23);
d1_21=theta_a(24);
d2_21=theta_a(25);
d3_21=theta_a(26);
d4_21=theta_a(27);
d5_21=theta_a(28);
d6_21=theta_a(29);
d7_21=theta_a(30);
d8_21=theta_a(31);
d9_21=theta_a(32);
d10_21=theta_a(33);
d11_21=theta_a(34);
h32=theta_a(35);
h31=theta_a(36);
h21=theta_a(37);
g32=theta_a(38);
g31=theta_a(39);
g21=theta_a(40);

%fitted values
fit32_a=(lp2 - (h32+g32*lp1-g32*ba*xa1+ba*xa2+d1_32*lotsize+d2_32*sqft+d3_32*bed+d4_32*room+d5_32*baths+d6_32*county2+d7_32*county3+d8_32*county4+d9_32*county5+d10_32*county6+d11_32*built));
fit31_a=(lp2 - (h31+g31*lp1-g31*ba*xa1+ba*xa2+d1_31*lotsize+d2_31*sqft+d3_31*bed+d4_31*room+d5_31*baths+d6_31*county2+d7_31*county3+d8_31*county4+d9_31*county5+d10_31*county6+d11_31*built));
fit21_a=(lp2 - (h21+g21*lp1-g21*ba*xa1+ba*xa2+d1_21*lotsize+d2_21*sqft+d3_21*bed+d4_21*room+d5_21*baths+d6_21*county2+d7_21*county3+d8_21*county4+d9_21*county5+d10_21*county6+d11_21*built));
fit_a=(fit32_a.*dyear2_3.*dyear1_2+fit31_a.*dyear2_3.*dyear1_1+fit21_a.*dyear2_2.*dyear1_1);

resid_a=fit_a;
        
%Calulating derivatives to obtain Var-Cov Matrix


G_a_1=(-g32*xa1+fxa2).*dyear2_3.*dyear1_2+(-g31*xa1+fxa2).*dyear2_3.*dyear1_1+(-g21*xa1+fxa2).*dyear2_2.*dyear1_1;
G_a_4=lotsize.*y32;
G_a_5=sqft.*y32;
G_a_6=bed.*y32;
G_a_7=room.*y32;
G_a_8=baths.*y32;
G_a_9=county2.*y32;
G_a_10=county3.*y32;
G_a_11=county4.*y32;
G_a_12=county5.*y32;
G_a_13=county6.*y32;
G_a_14=built.*y32;
G_a_15=lotsize.*y31;
G_a_16=sqft.*y31;
G_a_17=bed.*y31;
G_a_18=room.*y31;
G_a_19=baths.*y31;
G_a_20=county2.*y31;
G_a_21=county3.*y31;
G_a_22=county4.*y31;
G_a_23=county5.*y31;
G_a_24=county6.*y31;
G_a_25=built.*y31;
G_a_26=lotsize.*y21;
G_a_27=sqft.*y21;
G_a_28=bed.*y21;
G_a_29=room.*y21;
G_a_30=baths.*y21;
G_a_31=county2.*y21;
G_a_32=county3.*y21;
G_a_33=county4.*y21;
G_a_34=county5.*y21;
G_a_35=county6.*y21;
G_a_36=built.*y21;
G_a_37=1*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_a_38=0*dyear2_3.*dyear1_2+1*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_a_39=0*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+1*dyear2_2.*dyear1_1;


G_a_40=(lp1-ba*xa1).*dyear2_3.*dyear1_2;
G_a_41=(lp1-ba*xa1).*dyear2_3.*dyear1_1;
G_a_42=(lp1-ba*xa1).*dyear2_2.*dyear1_1;



G_a=[G_a_1 G_a_4 G_a_5 G_a_6 G_a_7 G_a_8 G_a_9 G_a_10 G_a_11 G_a_12 G_a_13 G_a_14 G_a_15];
G_a=[G_a G_a_16 G_a_17 G_a_18 G_a_19 G_a_20 G_a_21 G_a_22 G_a_23 G_a_24 G_a_25 G_a_26 G_a_27 G_a_28 G_a_29 G_a_30];

G_a=[G_a G_a_31 G_a_32 G_a_33 G_a_34 G_a_35 G_a_36 G_a_37 G_a_38 G_a_39 G_a_40 G_a_41 G_a_42];
    

clear G_a_1 G_a_4 G_a_5 G_a_6 G_a_7 G_a_8 G_a_9 G_a_10 G_a_11 G_a_12 G_a_13 G_a_14 G_a_15
clear G_a_16 G_a_17 G_a_18 G_a_19 G_a_20 G_a_21 G_a_22 G_a_23 G_a_24 G_a_25 G_a_26 G_a_27 G_a_28 G_a_29 G_a_30
clear G_a_31 G_a_32 G_a_33 G_a_34 G_a_35 G_a_36 G_a_37 G_a_38 G_a_39 G_a_40 G_a_41 G_a_42

Gamma_a=ba*Xa;



Omega_a=(G_a.*(resid_a*ones(1,40)))'*(G_a.*(resid_a*ones(1,40)))/n;
Q0=G_a'*G_a/n;
Q1_a=G_a'*Gamma_a/n;

Sigma_a=inv(Q0)*(Omega_a+Q1_a*Var_a*Q1_a')*inv(Q0);

%Heteroskedasticity robust standard errors

SE_a=sqrt(diag(Sigma_a)/n);

%t statistics
t_a=theta_a./SE_a;






%Cluster robust standard errors by tract

[G_an,G_am]=size(G_a);


Omega_acl=zeros(G_am, G_am);

for tr=1:mtr
Omega_acl=Omega_acl+G_a(tract==tr,:)'*resid_a(tract==tr,:)*resid_a(tract==tr,:)'*G_a(tract==tr,:)/n;
end

Sigma_acl=inv(Q0)*(Omega_acl+Q1_a*Var_acl*Q1_a')*inv(Q0);

SE_acl=sqrt(diag(Sigma_acl)/n);
t_acl=theta_a./SE_acl;



%R-squared
RSS_a=(resid_a)'*(resid_a);
TSS_a=(lp2-mean(lp2))'*(lp2-mean(lp2));
R2_a=1-RSS_a/TSS_a;



clear G_a Gamma_a Q1_a RSS_a TSS_a



clear global fxb2
clear fxb2


%%%%%%%%%%%%
% SO2 only %
%%%%%%%%%%%%

%first stage

Xb=[ones(n,1) xb1.*y32 xb1.*y31 xb1.*y21 lp1.*y32 lp1.*y31 lp1.*y21 dyb7 dyb8 dyb9 dyb10 dyb11 dyb12 dyb13 dyb14 dyb15 dyb16 dyb17];
Xb=[Xb county2.*y32 county2.*y31 county2.*y21];
Xb=[Xb county3.*y32 county3.*y31 county3.*y21];
Xb=[Xb county4.*y32 county4.*y31 county4.*y21];
Xb=[Xb county5.*y32 county5.*y31 county5.*y21];
Xb=[Xb county6.*y32 county6.*y31 county6.*y21];
Xb=[Xb lotsize.*y32 lotsize.*y31 lotsize.*y21];
Xb=[Xb sqft.*y32 sqft.*y31 sqft.*y21];
Xb=[Xb baths.*y32 baths.*y31 baths.*y21];
Xb=[Xb bed.*y32 bed.*y31 bed.*y21];
Xb=[Xb room.*y32 room.*y31 room.*y21];
Xb=[Xb built.*y32 built.*y31 built.*y21];

[nx,mx]=size(Xb);

ab=Xb\xb2;

%fitted values
fxb2=Xb*ab;

%fitted errors
fvb=xb2-fxb2;

%Heteroskedasticiy robust variance-covariance for the first step estimators

V0=(Xb'*Xb)/n;
V1=(Xb.*(fvb*ones(1,mx)))'*(Xb.*(fvb*ones(1,mx)))/n;
Var_b=inv(V0)*V1*inv(V0);



%Clustered robust variance by tract


V0cl=zeros(mx,mx);
for tr=1:mtr
V0cl=V0cl+(Xb(tract==tr,:)'*Xb(tract==tr,:))/n;
end

V1cl=zeros(mx,mx);
for tr=1:mtr
V1cl=V1cl+Xb(tract==tr,:)'*fvb(tract==tr,:)*fvb(tract==tr,:)'*Xb(tract==tr,:)/n;
end

Var_bcl=inv(V0cl)*V1cl*inv(V0cl);






%second stage
theta_b0=[zeros(40,1)];

global n lotsize sqft bed room baths built lp2 lp1 fxa2 xa1 fxb2 xb1 fxd2 xd1 dyear1_1 dyear1_2 dyear1_3 dyear2_1 dyear2_2 dyear2_3 county2 county3 county4 county5 county6

theta_b=lsqnonlin('secondstepb_2sls_fullgamma_obj',theta_b0);


bb=theta_b(1);
d1_32=theta_b(2);
d2_32=theta_b(3);
d3_32=theta_b(4);
d4_32=theta_b(5);
d5_32=theta_b(6);
d6_32=theta_b(7);
d7_32=theta_b(8);
d8_32=theta_b(9);
d9_32=theta_b(10);
d10_32=theta_b(11);
d11_32=theta_b(12);
d1_31=theta_b(13);
d2_31=theta_b(14);
d3_31=theta_b(15);
d4_31=theta_b(16);
d5_31=theta_b(17);
d6_31=theta_b(18);
d7_31=theta_b(19);
d8_31=theta_b(20);
d9_31=theta_b(21);
d10_31=theta_b(22);
d11_31=theta_b(23);
d1_21=theta_b(24);
d2_21=theta_b(25);
d3_21=theta_b(26);
d4_21=theta_b(27);
d5_21=theta_b(28);
d6_21=theta_b(29);
d7_21=theta_b(30);
d8_21=theta_b(31);
d9_21=theta_b(32);
d10_21=theta_b(33);
d11_21=theta_b(34);
h32=theta_b(35);
h31=theta_b(36);
h21=theta_b(37);
g32=theta_b(38);
g31=theta_b(39);
g21=theta_b(40);

%fitted values
fit32_b=(lp2 - (h32+g32*lp1-g32*bb*xb1+bb*xb2+d1_32*lotsize+d2_32*sqft+d3_32*bed+d4_32*room+d5_32*baths+d6_32*county2+d7_32*county3+d8_32*county4+d9_32*county5+d10_32*county6+d11_32*built));
fit31_b=(lp2 - (h31+g31*lp1-g31*bb*xb1+bb*xb2+d1_31*lotsize+d2_31*sqft+d3_31*bed+d4_31*room+d5_31*baths+d6_31*county2+d7_31*county3+d8_31*county4+d9_31*county5+d10_31*county6+d11_31*built));
fit21_b=(lp2 - (h21+g21*lp1-g21*bb*xb1+bb*xb2+d1_21*lotsize+d2_21*sqft+d3_21*bed+d4_21*room+d5_21*baths+d6_21*county2+d7_21*county3+d8_21*county4+d9_21*county5+d10_21*county6+d11_21*built));
fit_b=(fit32_b.*dyear2_3.*dyear1_2+fit31_b.*dyear2_3.*dyear1_1+fit21_b.*dyear2_2.*dyear1_1);

resid_b=fit_b;
        
%Calulating derivatives to obtain Var-Cov Matrix


G_b_2=(-g32*xb1+fxb2).*dyear2_3.*dyear1_2+(-g31*xb1+fxb2).*dyear2_3.*dyear1_1+(-g21*xb1+fxb2).*dyear2_2.*dyear1_1;
G_b_4=lotsize.*y32;
G_b_5=sqft.*y32;
G_b_6=bed.*y32;
G_b_7=room.*y32;
G_b_8=baths.*y32;
G_b_9=county2.*y32;
G_b_10=county3.*y32;
G_b_11=county4.*y32;
G_b_12=county5.*y32;
G_b_13=county6.*y32;
G_b_14=built.*y32;
G_b_15=lotsize.*y31;
G_b_16=sqft.*y31;
G_b_17=bed.*y31;
G_b_18=room.*y31;
G_b_19=baths.*y31;
G_b_20=county2.*y31;
G_b_21=county3.*y31;
G_b_22=county4.*y31;
G_b_23=county5.*y31;
G_b_24=county6.*y31;
G_b_25=built.*y31;
G_b_26=lotsize.*y21;
G_b_27=sqft.*y21;
G_b_28=bed.*y21;
G_b_29=room.*y21;
G_b_30=baths.*y21;
G_b_31=county2.*y21;
G_b_32=county3.*y21;
G_b_33=county4.*y21;
G_b_34=county5.*y21;
G_b_35=county6.*y21;
G_b_36=built.*y21;
G_b_37=1*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_b_38=0*dyear2_3.*dyear1_2+1*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_b_39=0*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+1*dyear2_2.*dyear1_1;


G_b_40=(lp1-bb*xb1).*dyear2_3.*dyear1_2;
G_b_41=(lp1-bb*xb1).*dyear2_3.*dyear1_1;
G_b_42=(lp1-bb*xb1).*dyear2_2.*dyear1_1;


G_b=[G_b_2 G_b_4 G_b_5 G_b_6 G_b_7 G_b_8 G_b_9 G_b_10 G_b_11 G_b_12 G_b_13 G_b_14 G_b_15];
G_b=[G_b G_b_16 G_b_17 G_b_18 G_b_19 G_b_20 G_b_21 G_b_22 G_b_23 G_b_24 G_b_25 G_b_26 G_b_27 G_b_28 G_b_29 G_b_30];
G_b=[G_b G_b_31 G_b_32 G_b_33 G_b_34 G_b_35 G_b_36 G_b_37 G_b_38 G_b_39 G_b_40 G_b_41 G_b_42];

clear G_b_2 G_b_4 G_b_5 G_b_6 G_b_7 G_b_8 G_b_9 G_b_10 G_b_11 G_b_12 G_b_13 G_b_14 G_b_15
clear G_b_16 G_b_17 G_b_18 G_b_19 G_b_20 G_b_21 G_b_22 G_b_23 G_b_24 G_b_25 G_b_26 G_b_27 G_b_28 G_b_29 G_b_30
clear G_b_31 G_b_32 G_b_33 G_b_34 G_b_35 G_b_36 G_b_37 G_b_38 G_b_39 G_b_40 G_b_41 G_b_42


Gamma_b=bb*Xb;

Omega_b=(G_b.*(resid_b*ones(1,40)))'*(G_b.*(resid_b*ones(1,40)))/n;
Q0=G_b'*G_b/n;
Q1_b=G_b'*Gamma_b/n;

Sigma_b=inv(Q0)*(Omega_b+Q1_b*Var_b*Q1_b')*inv(Q0);

SE_b=sqrt(diag(Sigma_b)/n);
t_b=theta_b./SE_b;




%Cluster robust standard errors by tract

[G_bn,G_bm]=size(G_b);


Omega_bcl=zeros(G_bm, G_bm);

for tr=1:mtr
Omega_bcl=Omega_bcl+G_b(tract==tr,:)'*resid_b(tract==tr,:)*resid_b(tract==tr,:)'*G_b(tract==tr,:)/n;
end


Sigma_bcl=inv(Q0)*(Omega_bcl+Q1_b*Var_bcl*Q1_b')*inv(Q0);

SE_bcl=sqrt(diag(Sigma_bcl)/n);
t_bcl=theta_b./SE_bcl;



%R-squared
RSS_b=(resid_b)'*(resid_b);
TSS_b=(lp2-mean(lp2))'*(lp2-mean(lp2));
R2_b=1-RSS_b/TSS_b;



clear G_b Gamma_b Q1_b RSS_b TSS_b




clear global fxd2
clear fxd2



%%%%%%%%%%%
% O3 only %
%%%%%%%%%%%

%first stage

Xd=[ones(n,1) xd1.*y32 xd1.*y31 xd1.*y21 lp1.*y32 lp1.*y31 lp1.*y21 dyb7 dyb8 dyb9 dyb10 dyb11 dyb12 dyb13 dyb14 dyb15 dyb16 dyb17];
Xd=[Xd county2.*y32 county2.*y31 county2.*y21];
Xd=[Xd county3.*y32 county3.*y31 county3.*y21];
Xd=[Xd county4.*y32 county4.*y31 county4.*y21];
Xd=[Xd county5.*y32 county5.*y31 county5.*y21];
Xd=[Xd county6.*y32 county6.*y31 county6.*y21];
Xd=[Xd lotsize.*y32 lotsize.*y31 lotsize.*y21];
Xd=[Xd sqft.*y32 sqft.*y31 sqft.*y21];
Xd=[Xd baths.*y32 baths.*y31 baths.*y21];
Xd=[Xd bed.*y32 bed.*y31 bed.*y21];
Xd=[Xd room.*y32 room.*y31 room.*y21];
Xd=[Xd built.*y32 built.*y31 built.*y21];



ad=Xd\xd2;

%fitted values
fxd2=Xd*ad;

%fitted errors
fvd=xd2-fxd2;

[nx,mx]=size(Xd);

%Heteroskedasticiy robust variance-covariance for the first step estimators

V0=(Xd'*Xd)/n;
V1=(Xd.*(fvd*ones(1,mx)))'*(Xd.*(fvd*ones(1,mx)))/n;
Var_d=inv(V0)*V1*inv(V0);


%Clustered robust variance by tract


V0cl=zeros(mx,mx);
for tr=1:mtr
V0cl=V0cl+(Xd(tract==tr,:)'*Xd(tract==tr,:))/n;
end

V1cl=zeros(mx,mx);
for tr=1:mtr
V1cl=V1cl+Xd(tract==tr,:)'*fvd(tract==tr,:)*fvd(tract==tr,:)'*Xd(tract==tr,:)/n;
end

Var_dcl=inv(V0cl)*V1cl*inv(V0cl);



clear Xd11 Xd22 Xd33 Xd44 Xd55 Xd66 Xd77 Xd88 fvd11 fvd22 fvd33 fvd44 fvd55 fvd66 fvd77 fvd88 V11cl V22cl V33cl V44cl V55cl V66cl V77cl V88cl









%second stage
theta_d0=[zeros(40,1)];

global n lotsize sqft bed room baths built lp2 lp1 fxa2 xa1 fxb2 xb1 fxd2 xd1 dyear1_1 dyear1_2 dyear1_3 dyear2_1 dyear2_2 dyear2_3 county2 county3 county4 county5 county6

theta_d=lsqnonlin('secondstepd_2sls_fullgamma_obj',theta_d0);


bd=theta_d(1);
d1_32=theta_d(2);
d2_32=theta_d(3);
d3_32=theta_d(4);
d4_32=theta_d(5);
d5_32=theta_d(6);
d6_32=theta_d(7);
d7_32=theta_d(8);
d8_32=theta_d(9);
d9_32=theta_d(10);
d10_32=theta_d(11);
d11_32=theta_d(12);
d1_31=theta_d(13);
d2_31=theta_d(14);
d3_31=theta_d(15);
d4_31=theta_d(16);
d5_31=theta_d(17);
d6_31=theta_d(18);
d7_31=theta_d(19);
d8_31=theta_d(20);
d9_31=theta_d(21);
d10_31=theta_d(22);
d11_31=theta_d(23);
d1_21=theta_d(24);
d2_21=theta_d(25);
d3_21=theta_d(26);
d4_21=theta_d(27);
d5_21=theta_d(28);
d6_21=theta_d(29);
d7_21=theta_d(30);
d8_21=theta_d(31);
d9_21=theta_d(32);
d10_21=theta_d(33);
d11_21=theta_d(34);
h32=theta_d(35);
h31=theta_d(36);
h21=theta_d(37);
g32=theta_d(38);
g31=theta_d(39);
g21=theta_d(40);

%fitted values
fit32_d=(lp2 - (h32+g32*lp1-g32*bd*xd1+bd*xd2+d1_32*lotsize+d2_32*sqft+d3_32*bed+d4_32*room+d5_32*baths+d6_32*county2+d7_32*county3+d8_32*county4+d9_32*county5+d10_32*county6+d11_32*built));
fit31_d=(lp2 - (h31+g31*lp1-g31*bd*xd1+bd*xd2+d1_31*lotsize+d2_31*sqft+d3_31*bed+d4_31*room+d5_31*baths+d6_31*county2+d7_31*county3+d8_31*county4+d9_31*county5+d10_31*county6+d11_31*built));
fit21_d=(lp2 - (h21+g21*lp1-g21*bd*xd1+bd*xd2+d1_21*lotsize+d2_21*sqft+d3_21*bed+d4_21*room+d5_21*baths+d6_21*county2+d7_21*county3+d8_21*county4+d9_21*county5+d10_21*county6+d11_21*built));
fit_d=(fit32_d.*dyear2_3.*dyear1_2+fit31_d.*dyear2_3.*dyear1_1+fit21_d.*dyear2_2.*dyear1_1);

resid_d=fit_d;
        
%Calulating derivatives to obtain Var-Cov Matrix


G_d_3=(-g32*xd1+fxd2).*dyear2_3.*dyear1_2+(-g31*xd1+fxd2).*dyear2_3.*dyear1_1+(-g21*xd1+fxd2).*dyear2_2.*dyear1_1;
G_d_4=lotsize.*y32;
G_d_5=sqft.*y32;
G_d_6=bed.*y32;
G_d_7=room.*y32;
G_d_8=baths.*y32;
G_d_9=county2.*y32;
G_d_10=county3.*y32;
G_d_11=county4.*y32;
G_d_12=county5.*y32;
G_d_13=county6.*y32;
G_d_14=built.*y32;
G_d_15=lotsize.*y31;
G_d_16=sqft.*y31;
G_d_17=bed.*y31;
G_d_18=room.*y31;
G_d_19=baths.*y31;
G_d_20=county2.*y31;
G_d_21=county3.*y31;
G_d_22=county4.*y31;
G_d_23=county5.*y31;
G_d_24=county6.*y31;
G_d_25=built.*y31;
G_d_26=lotsize.*y21;
G_d_27=sqft.*y21;
G_d_28=bed.*y21;
G_d_29=room.*y21;
G_d_30=baths.*y21;
G_d_31=county2.*y21;
G_d_32=county3.*y21;
G_d_33=county4.*y21;
G_d_34=county5.*y21;
G_d_35=county6.*y21;
G_d_36=built.*y21;
G_d_37=1*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_d_38=0*dyear2_3.*dyear1_2+1*dyear2_3.*dyear1_1+0*dyear2_2.*dyear1_1;
G_d_39=0*dyear2_3.*dyear1_2+0*dyear2_3.*dyear1_1+1*dyear2_2.*dyear1_1;

G_d_40=(lp1-bd*xd1).*dyear2_3.*dyear1_2;
G_d_41=(lp1-bd*xd1).*dyear2_3.*dyear1_1;
G_d_42=(lp1-bd*xd1).*dyear2_2.*dyear1_1;


G_d=[G_d_3 G_d_4 G_d_5 G_d_6 G_d_7 G_d_8 G_d_9 G_d_10 G_d_11 G_d_12 G_d_13 G_d_14 G_d_15];
G_d=[G_d G_d_16 G_d_17 G_d_18 G_d_19 G_d_20 G_d_21 G_d_22 G_d_23 G_d_24 G_d_25 G_d_26 G_d_27 G_d_28 G_d_29 G_d_30];
G_d=[G_d G_d_31 G_d_32 G_d_33 G_d_34 G_d_35 G_d_36 G_d_37 G_d_38 G_d_39 G_d_40 G_d_41 G_d_42];


Gamma_d=bd*Xd;

clear G_d_3 G_d_4 G_d_5 G_d_6 G_d_7 G_d_8 G_d_9 G_d_10 G_d_11 G_d_12 G_d_13 G_d_14 G_d_15
clear G_d_16 G_d_17 G_d_18 G_d_19 G_d_20 G_d_21 G_d_22 G_d_23 G_d_24 G_d_25 G_d_26 G_d_27 G_d_28 G_d_29 G_d_30
clear G_d_31 G_d_32 G_d_33 G_d_34 G_d_35 G_d_36 G_d_37 G_d_38 G_d_39 G_d_40 G_d_41 G_d_42



Omega_d=(G_d.*(resid_d*ones(1,40)))'*(G_d.*(resid_d*ones(1,40)))/n;
Q0=G_d'*G_d/n;
Q1_d=G_d'*Gamma_d/n;

Sigma_d=inv(Q0)*(Omega_d+Q1_d*Var_d*Q1_d')*inv(Q0);

SE_d=sqrt(diag(Sigma_d)/n);

t_d=theta_d./SE_d;



%Cluster robust standard errors by tract

[G_dn,G_dm]=size(G_d);


Omega_dcl=zeros(G_dm, G_dm);

for tr=1:mtr
Omega_dcl=Omega_dcl+G_d(tract==tr,:)'*resid_d(tract==tr,:)*resid_d(tract==tr,:)'*G_d(tract==tr,:)/n;
end



Sigma_dcl=inv(Q0)*(Omega_dcl+Q1_d*Var_dcl*Q1_d')*inv(Q0);

SE_dcl=sqrt(diag(Sigma_dcl)/n);
t_dcl=theta_d./SE_dcl;


%R-squared
RSS_d=(resid_d)'*(resid_d);
TSS_d=(lp2-mean(lp2))'*(lp2-mean(lp2));
R2_d=1-RSS_d/TSS_d;


clear G_d Gamma_d Q1_d


%save estimation results

save bckt_hedonic_2snls n theta theta_a theta_b theta_d SE_all SE_a SE_b SE_d t_a t_b t_d t_all SE_allcl SE_acl SE_bcl SE_dcl t_acl t_bcl t_dcl t_allcl R2_all R2_a R2_b R2_d