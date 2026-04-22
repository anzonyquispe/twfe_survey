% Function for computing optimal output
% Cobb-Douglas Version
%
% Allan Collard-Wexler
% November 4 2014
%


function [Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,...
    E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output2(alpha_e,alpha_m,alpha_l,alpha_k,OMEGA,K,p,p_m,p_l,p_e_g,p_e_s,delta,no_generator)
% Optimal Production with and without shortages...

%------------------------------------------
% No Shortages

% Analytic Solution
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
xs(1)=(OMEGA*K^alpha_k*([(1-delta)*alpha_l/p_l]^alpha_l)*((alpha_e/p_e_g)^alpha_e)*((alpha_m/p_m)^[1-alpha_l-alpha_e]))^(1/(1-alpha_l-alpha_m-alpha_e));
xs(2)=xs(1)*(1-delta)*(p_m*alpha_l/(p_l*alpha_m));
xs(3)=xs(1)*(p_m*alpha_e/(p_e_g*alpha_m));

Y_shortage=(1-delta)*p*OMEGA*xs(3)^alpha_e*xs(1)^alpha_m * xs(2)^alpha_l *K^alpha_k;
L_shortage=xs(2);
M_shortage=(1-delta)*xs(1);

E_grid_shortage=(1-delta)*xs(3);
E_self_shortage=0;
exitflag=0;
end



%------------------------------------------
% always produce: sometimes grid, sometimes generator
if (no_generator==0)

% starting value from no shortage analytic solution
options=optimset('Display','off');

x0=log([xs(1) xs(2) xs(3) xs(1) xs(3)]);
%focns=@(X) focs_cd(X,alpha_e,alpha_m,alpha_l,alpha_k,OMEGA,K,p,p_m,p_l,p_e_g,p_e_s,0);
%focns(log(x0))

foc=@(X) focs_cd(X,alpha_e,alpha_m,alpha_l,alpha_k,OMEGA,K,p,p_m,p_l,p_e_g,p_e_s,delta);
[x, fval, exitflag] = fsolve(foc,x0,options);
x=exp(x);
Y_shortage=(1-delta) *p*OMEGA*x(3)^alpha_e*x(1)^alpha_m * x(2)^alpha_l *K^alpha_k+delta*p*OMEGA*x(5)^alpha_e*x(4)^alpha_m *x(2)^alpha_l *K^alpha_k;
L_shortage=x(2);
M_shortage=x(1)*(1-delta)+x(4)*delta;


E_self_shortage=delta*x(5);
E_grid_shortage=(1-delta)*x(3);
end

end
