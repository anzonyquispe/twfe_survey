function [Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output_CD_CES(alpha_m,alpha_l,alpha_k,alpha_e,sigma,OMEGA,K,p,p_m,p_l,p_e_g,p_e_s,delta,no_generator)
% Optimal Production with and without shortages...
% First Order condition for materials and labor
% For the case with imperfect substitution.
% Production Function 
% y_{it}=[\int_\tau y_{it\tau}^\sigma d\tau]^\frac{1}{\sigma}

options=optimset('Display','off');
% Optimal Production with and without shortages...

%------------------------------------------
% No Shortages

% Analytic Solution: Constant flow looks like sigma=1 version...
% xs(1) materials xs(2) labor xs(3) electricity 
xs(1)=(p*OMEGA*K^alpha_k*((alpha_l/p_l)^alpha_l)*((alpha_e/p_e_g)^alpha_e)*((alpha_m/p_m)^(1-alpha_l-alpha_e)))^(1/(1-alpha_l-alpha_m-alpha_e));
xs(2)=xs(1)*(p_m*alpha_l)/(p_l*alpha_m);
xs(3)=xs(1)*(p_m*alpha_e)/(p_e_g*alpha_m);

Y_no_shortage=p*OMEGA*xs(3)^alpha_e*xs(1)^alpha_m * xs(2)^alpha_l *K^alpha_k;
L_no_shortage=xs(2);
M_no_shortage=xs(1);

E_grid_no_shortage=xs(3);
E_self_no_shortage=0;


%------------------------------------------
% shut down during shortages
if (no_generator==1)

% Analytic Solution
x0=log([xs(1) xs(2) xs(3)]);
foc=@(X) focCD_CES_shutdown(X,alpha_m,alpha_l,alpha_k,alpha_e,OMEGA,K,p,p_m,p_l,p_e_g,delta,sigma);
[x, fval, exitflag] = fsolve(foc,x0,options);
x=exp(x);

Y_ittau_G=p*OMEGA*x(1)^alpha_l * x(2)^alpha_m * K^alpha_k*x(3)^alpha_e;

Yit= [(1-delta)*(Y_ittau_G^sigma)]^(1/sigma);
Y_shortage=Yit;
L_shortage=x(1);
M_shortage=x(2)*(1-delta);

E_self_shortage=x(3)*(1-delta);
E_grid_shortage=0;
end



%------------------------------------------
% always produce: sometimes grid, sometimes generator
if (no_generator==0)

% starting value from no shortage analytic solution
options=optimset('Display','off');

x0=log([xs(1) xs(2) xs(3) xs(1) xs(3)]);
foc=@(X) focCD_CES(X,alpha_m,alpha_l,alpha_k,alpha_e,OMEGA,K,p,p_m,p_l,p_e_g,p_e_s,delta,sigma);
[x, fval, exitflag] = fsolve(foc,x0,options);
x=exp(x);
x_ces=x;
Y_ittau_G=p*OMEGA*x(1)^alpha_l * x(2)^alpha_m * K^alpha_k*x(4)^alpha_e;
Y_ittau_S=p*OMEGA*x(1)^alpha_l * x(3)^alpha_m * K^alpha_k*x(5)^alpha_e;

Yit= [delta*(Y_ittau_S^sigma)+(1-delta)*(Y_ittau_G^sigma)]^(1/sigma);
Y_shortage=Yit;
L_shortage=x(1);
M_shortage=x(2)*(1-delta)+x(3)*delta;

E_self_shortage=x(4)*(1-delta);
E_grid_shortage=x(5)*delta;
end

end














