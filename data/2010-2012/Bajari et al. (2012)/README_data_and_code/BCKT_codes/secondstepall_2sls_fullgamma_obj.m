function obj = secondstepall(theta)

global n lotsize sqft bed room baths built lp2 lp1 fxa2 xa1 fxb2 xb1 fxd2 xd1 dyear1_1 dyear1_2 dyear1_3 dyear2_1 dyear2_2 dyear2_3 county2 county3 county4 county5 county6




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





obj32=(lp2 - (h32+g32*lp1-g32*ba*xa1+ba*fxa2-g32*bb*xb1+bb*fxb2-g32*bd*xd1+bd*fxd2+d1_32*lotsize+d2_32*sqft+d3_32*bed+d4_32*room+d5_32*baths+d6_32*county2+d7_32*county3+d8_32*county4+d9_32*county5+d10_32*county6+d11_32*built));
obj31=(lp2 - (h31+g31*lp1-g31*ba*xa1+ba*fxa2-g31*bb*xb1+bb*fxb2-g31*bd*xd1+bd*fxd2+d1_31*lotsize+d2_31*sqft+d3_31*bed+d4_31*room+d5_31*baths+d6_31*county2+d7_31*county3+d8_31*county4+d9_31*county5+d10_31*county6+d11_31*built));
obj21=(lp2 - (h21+g21*lp1-g21*ba*xa1+ba*fxa2-g21*bb*xb1+bb*fxb2-g21*bd*xd1+bd*fxd2+d1_21*lotsize+d2_21*sqft+d3_21*bed+d4_21*room+d5_21*baths+d6_21*county2+d7_21*county3+d8_21*county4+d9_21*county5+d10_21*county6+d11_21*built));

obj=(obj32.*dyear2_3.*dyear1_2+obj31.*dyear2_3.*dyear1_1+obj21.*dyear2_2.*dyear1_1);
%obj=sum(obj_all.*obj_all)/(2*n);