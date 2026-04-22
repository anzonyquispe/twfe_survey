function F = export_ave( trat,x, k, sig, I_1)
%EQUATION system for endogenous entry relative prices, import penetration
% and domestic uncertainty.
% 
%P_1=x(1);
R_hat=x(1);


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


%price equations to solve
%F(1)=P_1^(-k) - (I_1*U_wt*((1+u)^(1-k/(sig-1)))+(1-I_1).*U_h.^(k-sig+1));
%F(2)=P_21^(-k) - (( I_1*trat_wt+(1-I_1))/(I_1*U_wt*((1+u)^(1-k/(sig-1)))+(1-I_1).*U_h.^(k-sig+1)));
Phat=( I_1*trat^(1-k*sig/(sig-1))+(1-I_1))^(-1/k);
%F(1)=R_hat - (trat^(-k*sig/(sig-1))/( I_1*trat^(1-k*sig/(sig-1))+(1-I_1))^(-k));

F(1)=R_hat - (trat^(-k*sig/(sig-1))/(Phat)^(-k));


end
