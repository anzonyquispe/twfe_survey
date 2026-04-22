function obj = secondstepb(theta_b)



global n lotsize sqft bed room baths built lp2 lp1 fxa2 xa1 fxb2 xb1 fxc2 xc1 fxd2 xd1 dyear1_1 dyear1_2 dyear1_3 dyear2_1 dyear2_2 dyear2_3 county2 county3 county4 county5 county6


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



obj32=(lp2 - (h32+g32*lp1-g32*bb*xb1+bb*fxb2+d1_32*lotsize+d2_32*sqft+d3_32*bed+d4_32*room+d5_32*baths+d6_32*county2+d7_32*county3+d8_32*county4+d9_32*county5+d10_32*county6+d11_32*built));
obj31=(lp2 - (h31+g31*lp1-g31*bb*xb1+bb*fxb2+d1_31*lotsize+d2_31*sqft+d3_31*bed+d4_31*room+d5_31*baths+d6_31*county2+d7_31*county3+d8_31*county4+d9_31*county5+d10_31*county6+d11_31*built));
obj21=(lp2 - (h21+g21*lp1-g21*bb*xb1+bb*fxb2+d1_21*lotsize+d2_21*sqft+d3_21*bed+d4_21*room+d5_21*baths+d6_21*county2+d7_21*county3+d8_21*county4+d9_21*county5+d10_21*county6+d11_21*built));

obj=(obj32.*dyear2_3.*dyear1_2+obj31.*dyear2_3.*dyear1_1+obj21.*dyear2_2.*dyear1_1);
%obj=sum(obj_b.*obj_b)/(2*n);