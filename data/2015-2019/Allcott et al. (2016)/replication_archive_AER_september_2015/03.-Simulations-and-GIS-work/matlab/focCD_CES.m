function res=focCD_CES(X,alpha_m,alpha_l,alpha_k,alpha_e,OMEGA,K,p,p_m,p_l,p_e_g,p_e_s,delta,sigma)
% First order conditions: CES model, with cobb-douglas

% The first-order conditions of the model are given by $\frac{\partial \Pi_{it}}{M_{it\tau}}=0$ yielding: 
% \frac{1}{\sigma} Y_{it} ^\frac{ \frac{1}{\sigma} -1}{\frac{1}{\sigma}} \alpha_M (1-\gamma) \frac{Y_{it\tau}}{M_{it\tau}} = p^M
% 
% and the first-order condition for labor is given by $\frac{\partial \Pi_{it}}{L_{it}}=0$ yielding: 
%
% \frac{1}{\sigma} Y_{it} ^\frac{ \frac{1}{\sigma} -1}{\frac{1}{\sigma}} \alpha_M \left [ (1-\delta) (1-\gamma^G) \frac{Y^G _{it\tau}}{M^G _{it\tau}} + \delta (1-\gamma^S) \frac{Y^S _{it\tau}}{M^S _{it\tau}} \right]= p^L
% 
% where $Y^G _{it\tau}=\Omega L^{\alpha_L} (M^G)^{\alpha_M} K^{\alpha_K}$ and  $Y^S _{it\tau}=\Omega L^{\alpha_L} (M^S)^{\alpha_M} K^{\alpha_K}$.
% 



Y_ittau_G=p*OMEGA*exp(X(1))^alpha_l * exp(X(2))^alpha_m * K^alpha_k*exp(X(4))^alpha_e;
Y_ittau_S=p*OMEGA*exp(X(1))^alpha_l * exp(X(3))^alpha_m * K^alpha_k*exp(X(5))^alpha_e;

Yit= [delta*(Y_ittau_S)^sigma+(1-delta)*Y_ittau_G^sigma]^(1/sigma);

exponenter=(1/sigma-1)/(1/sigma);

% NON-CES FOCS
% foc_e_g =(alpha_e *p *OMEGA*exp(X(1))^alpha_l * exp(X(2))^(alpha_m-1)*exp(X(4))^alpha_e *K^alpha_k -p_e_g);
% foc_e_s= (alpha_e *p *OMEGA*exp(X(1))^alpha_l * exp(X(3))^(alpha_m-1)*exp(X(5))^alpha_e *K^alpha_k -p_e_s);
% foc_m_g =(alpha_m *p *OMEGA*exp(X(1))^alpha_l * exp(X(2))^(alpha_m-1)*exp(X(4))^alpha_e *K^alpha_k -p_m);
% foc_m_s= (alpha_m *p *OMEGA*exp(X(1))^alpha_l * exp(X(3))^(alpha_m-1)*exp(X(5))^alpha_e *K^alpha_k -p_m);
% foc_l=((1-delta) * alpha_l *p*OMEGA*exp(X(2))^alpha_m * exp(X(1))^(alpha_l-1) *exp(X(4))^alpha_e*K^alpha_k+delta*alpha_l* *p*OMEGA*exp(X(3))^alpha_m *exp(X(1))^(alpha_l-1)*exp(X(5))^alpha_e *K^alpha_k-p_l);

foc_m_g = ((1/sigma)*Yit^exponenter *sigma*alpha_m * Y_ittau_G.^sigma / exp(X(2)) -p_m);
foc_m_s = ((1/sigma)*Yit^exponenter *(sigma*alpha_m * Y_ittau_S.^sigma / exp(X(3))) -p_m);
foc_e_g = ((1/sigma)*Yit^exponenter *sigma*alpha_e * Y_ittau_G.^sigma / exp(X(4)) -p_e_g);
foc_e_s = ((1/sigma)*Yit^exponenter *(sigma*alpha_e * Y_ittau_S.^sigma / exp(X(5))) -p_e_s);
foc_l= ((1/sigma)*Yit^exponenter *((1-delta) *(sigma* alpha_l) * Y_ittau_G.^sigma /exp(X(1))...
+delta*alpha_l*sigma *Y_ittau_S.^sigma/exp(X(1)))-p_l);
res=[foc_m_g foc_m_s foc_e_g foc_e_s foc_l];
end

