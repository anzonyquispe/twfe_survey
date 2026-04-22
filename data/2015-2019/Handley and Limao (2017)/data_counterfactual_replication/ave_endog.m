function F = ave_endog( trat,x, k, sig, I_1)
%EQUATION system for endogenous entry relative prices, import penetration
% and domestic uncertainty.
% 
%P_1=x(1);
R_hat=x(1);
Entry_hat=x(2);
P1_hat=x(3);
P1_hat=x(4);
HmR_hat=x(5);
HmEntry_hat=x(6);
HmEmp_hat=x(7);
ChPin=x(8);

%definitions

%upper bound assumptions on domestic omega and little g term;
%omega_h= (P_1).^(1-sig);

%g      = (P_21).^(sig-1);

% definition of little u
%u      = b./g;

% scale parameter for domestic firm u_h relative to little u

%u_h=alpha*u;

%definition of U_h
%U_h    = ((1+u_h.*omega_h)./(1+u_h)).^(1./(sig-1));


%equations to solve
Phat=( I_1.*trat.^(1-k*sig/(sig-1))+(1-I_1)).^(-1/k);



F(1)=R_hat - (trat(1)^(-k*sig/(sig-1))/(Phat(1))^(-k));
F(2)=Entry_hat - (trat(2)^(-k*sig/(sig-1))/(Phat(2))^(-k));
F(3)=P1_hat^(-k)-( I_1.*trat(3)^(1-k*sig/(sig-1))+(1-I_1));
F(4)=P1_hat^(-k)-( I_1.*trat(4)^(1-k*sig/(sig-1))+(1-I_1));
F(5)=HmR_hat - Phat(5)^k;
F(6)=HmEntry_hat - Phat(6)^k;
F(7)=HmEmp_hat - Phat(7)^(k-1);
%F(8)=ChPin - trat(8)*((trat(8))^(-(sig/(sig-1)))*((I_1*trat(8)^(1-((sig*k)/(sig-1)))+(1-I_1))^(-1/k)))^(1-(k/(sig-1)))
F(8)=ChPin - trat(8)*((trat(8))^(-(sig/(sig-1)))*(Phat(8)))^(1-(k/(sig-1)))

end
