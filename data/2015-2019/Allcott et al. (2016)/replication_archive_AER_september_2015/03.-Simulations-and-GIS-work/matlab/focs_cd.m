% Cobb-Douglas FOCs

function res=focs_cd(X,alpha_e,alpha_m,alpha_l,alpha_k,OMEGA,K,p,p_m,p_l,p_e_g,p_e_s,delta)
% First order conditions: including shutdown decision
foc_l=(1-delta) * alpha_l *p*OMEGA*exp(X(1))^alpha_m * exp(X(3))^alpha_e * exp(X(2))^(alpha_l-1) *K^alpha_k...
    +delta*alpha_l *p*OMEGA*exp(X(4))^alpha_m * exp(X(5))^alpha_e * exp(X(2))^(alpha_l-1) *K^alpha_k-p_l;

foc_m_g =alpha_m*p*OMEGA*exp(X(2))^alpha_l * exp(X(1))^(alpha_m-1)*  exp(X(3))^alpha_e *K^alpha_k -p_m;
foc_m_s =alpha_m*p*OMEGA*exp(X(2))^alpha_l * exp(X(4))^(alpha_m-1)*  exp(X(5))^alpha_e *K^alpha_k -p_m;

foc_e_g =alpha_e*p*OMEGA*exp(X(2))^alpha_l * exp(X(1))^alpha_m * exp(X(3))^(alpha_e-1) *K^alpha_k -p_e_g;
foc_e_s =alpha_e*p*OMEGA*exp(X(2))^alpha_l * exp(X(4))^alpha_m * exp(X(5))^(alpha_e-1) *K^alpha_k -p_e_s;

res=[foc_m_g  foc_l foc_e_g foc_m_s  foc_e_s ];
end

