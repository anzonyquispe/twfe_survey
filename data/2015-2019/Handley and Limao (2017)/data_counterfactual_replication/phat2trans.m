function F = phat2trans( x,k, sig, I_1, b, U_wt, trat_wt ,Uhat_wt, beta,alpha,T,g, omega_h)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

P2_T=x(1);
%P_21=x(2);


%definitions

%upper bound assumptions on domestic omega and little g term;
%omega_h= (P1_T).^(1-sig);

%g      = (P_21).^(sig-1);

% definition of little u
u      = b./g;

% scale parameter for domestic firm u_h relative to little u

u_h=alpha*u;

%definition of U_h
U_h    = ((1+u_h.*omega_h)./(1+u_h)).^(1./(sig-1));


%price equations to solve
F(1)=P2_T^(-k) - (( (I_1*((1-beta^(T+1))*trat_wt+beta^(T+1)*P2_T^(-k+sig-1)*Uhat_wt*(1+u)^(1-k/(sig-1))))+(1-I_1))/(I_1*U_wt*((1+u)^(1-k/(sig-1)))+(1-I_1).*U_h.^(k-sig+1)));
%F(1)=P1_T^(-k) - (I_1*U_wt*((1+u)^(1-k/(sig-1)))+(1-I_1).*U_h.^(k-sig+1));
%F(2)=P_21^(-k) - (( I_1*trat_wt+(1-I_1))/(I_1*U_wt*((1+u)^(1-k/(sig-1)))+(1-I_1).*U_h.^(k-sig+1)));

%F(2)=P_21^(-k) - (( I_1*trat_wt+(1-I_1))/(P1_T^(-k)));



end
