function res=focs2(X,gamma_g,gamma_s,alpha_m,alpha_l,alpha_k,OMEGA,K,p,p_m,p_l,delta)
% First order conditions
foc_m_g =(alpha_m *(1-gamma_g)*p *OMEGA*exp(X(1))^alpha_l * exp(X(2))^(alpha_m-1) *K^alpha_k -p_m);
foc_m_s= (alpha_m *(1-gamma_s)*p *OMEGA*exp(X(1))^alpha_l * exp(X(3))^(alpha_m-1) *K^alpha_k -p_m);
foc_l=((1-delta) * alpha_l *(1-gamma_g) *p*OMEGA*exp(X(2))^alpha_m * exp(X(1))^(alpha_l-1) *K^alpha_k+delta*alpha_l*(1-gamma_s) *p*OMEGA*exp(X(3))^alpha_m *exp(X(1))^(alpha_l-1) *K^alpha_k-p_l);
res=[foc_m_g foc_m_s foc_l];
end

