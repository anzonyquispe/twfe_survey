function [F,Phat] = ave_endog( trat,x, k, sig, I_1)
%EQUATION system for exog entry AVEs

%P_1=x(1);
R_hat=x(1);
Entry_hat=x(2);
P1_hat=x(3);
P1_hat=x(4);
HmR_hat=x(5);
HmEntry_hat=x(6);
HmEmp_hat=x(7);

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
%Phat=( I_1.*Phat.^(k-sig+1).*trat.^(1-k*sig/(sig-1))+(1-I_1)).^(1/(1-sig));


%because Phat is implicity have to solve for AVE tariff within 
%the function and use that solution in the subequent vector of AVEs
%defined below by the vectdor F.
Phat=fsolve(@(Phat) Phat.^(1-sig)-( I_1.*Phat.^(k-sig+1).*trat.^(1-k*sig/(sig-1))+(1-I_1)),1.03*ones(1,7));


F(1)=R_hat - (trat(1)^(-k*sig/(sig-1))/(Phat(1))^(-k));
F(2)=Entry_hat - (trat(2)^(-k*sig/(sig-1))/(Phat(2))^(-k));
F(3)=P1_hat^(1-sig)-( I_1.*P1_hat.^(k-sig+1).*trat(3)^(1-k*sig/(sig-1))+(1-I_1));
F(4)=P1_hat^(1-sig)-( I_1.*P1_hat.^(k-sig+1).*trat(4)^(1-k*sig/(sig-1))+(1-I_1));
F(5)=HmR_hat - Phat(5)^k;
F(6)=HmEntry_hat - Phat(6)^k;
F(7)=HmEmp_hat - Phat(7)^(k-1);

end
