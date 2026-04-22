function res=focs_and_shutdown(X,gamma_g,alpha_m,alpha_l,alpha_k,OMEGA,K,p,p_m,p_l,delta)
% First order conditions: including shutdown decision
foc_m_g =(alpha_m *(1-gamma_g)*p *OMEGA*exp(X(1))^alpha_l * exp(X(2))^(alpha_m-1) *K^alpha_k -p_m);
foc_l=(1-delta) * alpha_l *(1-gamma_g) *p*OMEGA*exp(X(2))^alpha_m * exp(X(1))^(alpha_l-1) *K^alpha_k-p_l;
res=[foc_m_g foc_l];
end

