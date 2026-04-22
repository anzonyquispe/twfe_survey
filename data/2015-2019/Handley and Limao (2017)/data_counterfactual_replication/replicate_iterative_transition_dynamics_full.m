%%

clear all
%iterative equilibrium solution for steady state and transition dynamics


diary off
delete replicate_iterative_transition_dynamics_full.log
diary  replicate_iterative_transition_dynamics_full.log

%% Bring in params from estimation and setup options for solver

%import and define params from estimation

%qparams=dlmread('C:\Users\handleyk\Dropbox\ChinaMFN\estimation\aer_rr\quant_params_new.txt','\t',1,1)
qparams=dlmread('quant_params_new.txt','\t',1,1)

% pareto shape param
k=qparams(16)

% EOS
sig=3;

% Import penetration 2005
I_init=0.045;

% estimated portion of u term
b=qparams(26)

% weight and unweighted power mean values of uncertainty measure and tariff ratio
trat_wt=qparams(13)
U_wt=qparams(9)
Uhat_wt=qparams(10)
U_unwt=qparams(21)
rat_sig_unwt=qparams(24)
rat_sig_wt=qparams(25)
b_ols=qparams(14)
k_ols=qparams(15)

u_entry_wt=qparams(11)
u_entry_unwt=qparams(23)
u_min=qparams(17)
u_max=qparams(18)


% set death rate
beta_f=.85;
beta_h=.9;

x0 = [1.01 1.01  ]           % Make a starting guess at the solution



% set scale for alpha

lam2=0.5;
alpha_wto_cf=((1-lam2)/lam2)*(beta_h/beta_f)*(1-beta_f)/(1-beta_h)

alpha=[0 alpha_wto_cf 2 4 6 ];

% set options for numerical optimization
options=optimset('Display', 'off', 'MaxFunEvals',1000, 'MaxIter',1000,'TolX',1e-8,'TolFun',1e-8 );   % Option to display output

%set time periods
T=[0:250];


%create matrix to save output

out=zeros(size(alpha,2),13);
HomePhat=zeros(size(alpha,2),1);
ChImpPhat=zeros(size(alpha,2),1);
out(:,1)=alpha';


converge=99*ones(size(alpha,2),1);

%adjust import pen to 2000

tauhat_exp_wt=qparams(2);
tauhat_p_wt=qparams(3);
P_mean=(I_init*tauhat_p_wt+(1-I_init))^(-1/k)
Rhatmean=tauhat_exp_wt*P_mean^k

I_1=I_init*Rhatmean


%set to tau0 wt relative to 2005;

tau0rat_wt=qparams(12);
D=(I_1*tau0rat_wt+(1-I_1))^(-1/k);

for i=1:size(alpha,2)

%% Step 1: solve for steady states using upper bounds


[x,fval] = fsolve(@( x) pindex( x,k,sig,I_1,b,U_wt,trat_wt,alpha(i),tau0rat_wt),x0,options );  % Call solver

% set upper bounds
omega_h= (x(1)).^(1-sig);
g      = (x(2)).^(sig-1);
P2inf=x(2);
P1inf=x(1);

display('Upper bound 1st step of omega and g')
g
omega_h
 
%% Step 2a: compute P1 transition dynamics with given upper bounds (from SS in 1st round, updated thereafter)

%Pupdate=x;
%P=3*ones(2,1);
%diffT=1;
g_update=g;
omega_h_update=omega_h;

%set initial guess so loop runs on first iteration
g=2;
omega_h=2;

%loop repeats as long as norm of g terms exceeds tolerance
while (norm(g-g_update,omega_h-omega_h_update)>.000001)

p0=1
P1=zeros(1,size(T,2));
for t=1:size(T,2);
[P1T,fval]=fsolve(@(x) phat1trans( x,k, sig, I_1, b, U_wt, trat_wt ,beta_h,alpha(i),T(t),g_update, omega_h_update,tau0rat_wt),p0,options);

P1(t)=P1T;
end;

%% Step 2b: compute P2 transition dynamics with with given upper bounds (from SS in 1st round, updated thereafter)



P2=zeros(1,size(T,2));
for t=1:size(T,2);
 [P2T,fval]=fsolve(@(x) phat2trans( x,k, sig, I_1, b, U_wt, trat_wt ,Uhat_wt, beta_f,alpha(i),T(t),g_update, omega_h_update),p0,options);
 
  P2(t)=P2T;
end;

%% Step 3: update upper bounds on g and omega_h
pseries1=0;
pseries2=0;
maxT=max(T);
for t=1:size(T,2)
pt2=beta_f^T(t)*P2(t)^(sig-1);
pseries2=pseries2+pt2;

pt1=beta_h^T(t)*P1(t)^(sig-1);
pseries1=pseries1+pt1;

end

display('Starting values of omega and g for this step')

g=g_update
omega_h=omega_h_update



display('Updated values of omega and g for this step')

g_update=(1-beta_f)*(pseries2+beta_f^(maxT+1)*P2T^(sig-1)/(1-beta_f))
omega_h_update=(1-beta_h)*(pseries1+beta_h^(maxT+1)*P1T^(sig-1)/(1-beta_h))


%save prices price vector from previous step


%update the price vector
[Pupdate,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,b,U_wt,trat_wt,alpha(i),g_update,omega_h_update),x0,options );  % Call solver



end;

g=g_update;
omega_h=omega_h_update

[x,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,b,U_wt,trat_wt,alpha(i),g,omega_h),x0,options );  % Call solver



%check convergence: difference between SS prices and transition prices at
%capital T

diffT=[x(1)/D-1/P1T,x(2)-P2T]


%flag if converged, converge==99 implies did not converge
if norm(diffT)<0.0001
    converge(i)=1;
end;





out(i,2)=x(1);
out(i,3)=x(2);

%assign P1/P0 deterministic  to matrix
out(i,4)=P_mean;

out(i,5)=g;
out(i,6)=omega_h;

%total price change WTO, state 0, to uncertainty state 1
out(i,7)=x(1)*P_mean;

%partial Agg OLS
out(i,10)=1/exp(b_ols*(1-rat_sig_wt));



%compute total GE change in exports from params and mean of term in
%numerator from weighted U term and updated price index

%GE Agg Rhat Model
RhatAggGE=U_wt*(1+b/g)^(1-k/(sig-1))*x(1)^(k)

RhatMeanGE=U_unwt*(1+b/g)^(1-k/(sig-1))*x(1)^(k);

%assign values to matrix

out(i,11)=RhatAggGE;
%Partial Mean OLS
out(i,8)=1/exp(b_ols*(1-rat_sig_unwt));

%Agg Mean Model
out(i,9)=RhatMeanGE;

%Partial Model based
%mean
out(i,12)=U_unwt*(1+b/g)^(1-k/(sig-1));
%aggregate wgt mean
out(i,13)=U_wt*(1+b/g)^(1-k/(sig-1))

%Domestic and Foreign Componenent of Price index changes
u=b/g;
u_h=alpha(i)*u;
%entry terms in U
wt_entry_U1=u_entry_wt/(1+u).^(1/(sig-1));
%unwt_entry_U1=u_entry_unwt/(1+u).^(1/(sig-1));

%omega_h=out(i,6)
U_h    = ((1+u_h.*out(i,6))./(1+u_h)).^(1./(sig-1));

%Home Goods Price Change
HomePhat(i)=(out(i,2)*U_h)^(1-k/(sig-1));

%Chinese Import Price Change
ChImpPhat(i)=(out(i,2).*wt_entry_U1)^(1-k/(sig-1))

end;
%% output results to file




%check convergence, generate warning
if mean(converge)>1
    fprintf('WARNING!!! Some gridpoints may not have converged. Check converge vector!!!!!!')
end

converge





%% create ge portion quantification table 7 %%

table=zeros(2,4);



%export changes
table(1,:)=log(1./out(4,8:11))

%entry changes using ols
table(2,1)=table(1,1)*(k_ols/(k_ols-sig+1))
table(2,3)=table(1,3)*(k_ols/(k_ols-sig+1))

%entry changes using nls model
%u=b/g
u=b/out(4,5)
%entry terms in U
wt_entry_U1=u_entry_wt/(1+u).^(1/(sig-1));
unwt_entry_U1=u_entry_unwt/(1+u).^(1/(sig-1));
%assign entry in logs to table
table(2,2)=log(1/(out(4,2).*unwt_entry_U1).^k)
table(2,4)=log(1/(out(4,2).*wt_entry_U1).^k)



% save aggregate export, entry, and prices changes for risk computation
u=b./out(:,5)
log_expgrow_GE=log(1./out(:,11))
log_price_index=log(out(:,2))
log_exp_entry=log(1./(out(:,2).*wt_entry_U1).^k)
alpha=alpha';
log_dom_entry=log((out(:,2).*((1+out(:,6).*(alpha.*u))./(1+alpha.*u)).^(1/(sig-1))).^k);
china_gval=out(2,5);

save('agg_effect_GE.mat','log_expgrow_GE','log_price_index', 'log_exp_entry','log_dom_entry','china_gval')

% compute range of U1 %
u=b/out(3,5)


 %rearrange columns to match AER output
 
 tab2=zeros(2,2);
 tab2=[table(1,2),table(1,4)]
 
 tab2(2,1)=table(2,2)*(1-k/(sig-1))/k
 tab2(2,2)=-log(ChImpPhat(4))
 
 tab2=round(100*tab2,1)


% create headers labels and data to export
 fnam='table7_GE.out'; % 
 output=dataset({tab2 'Log Change Avg (GE)', 'Log Change Agg (GE)' }, 'obsnames',{'export value','export price'})
 
export(output,'File',fnam,'Delimiter','\t')

%add notes to track this back if needed for later
notes=sprintf('%s\t','Notes: ');
 notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('Sigma=%1.0f, beta_gamma=%1.6f, k=%1.6f, weighted tariff factor=%1.6f, 2005 Import Penetration=%1.3f \r\n', sig,b, k,trat_wt,I_1);
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('alpha=%1.0f, k_ols=%1.6f, beta_unc=%1.6f.  All growth rates expressed in logs. \r\n',alpha(4),k_ols,b_ols);
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('Computed from iterative_transition_dynamics_full.m on date %12s ',date);
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');

 
%% AVEs based on NLS data


%endogenous entry non-linear formulas

%xhat=[Export Change, Variety Change, Price Change,WelfareChange, Dom Sales, Dom Entry, Dom Emp ]
u      = b./out(4,5);
u_h=alpha(4)*u;
%omega_h=out(3,6)
U_h    = ((1+u_h.*out(4,6))./(1+u_h)).^(1./(sig-1));

%Home Sales,Entry, Employment
HomeSales=out(4,2).^k.*U_h^(k-sig+1);
HomeEntry=out(4,2)^k*U_h^k;
HomeEmp=out(4,2)^(k-1)*U_h^(k-sig);
HomePhat=out(4,2)*U_h;

xhat_endog=[out(4,11),(out(4,2).*wt_entry_U1).^k,out(4,2),out(4,2),HomeSales,HomeEntry,HomeEmp,ChImpPhat(4)]; %
trat0=1.05*ones(1,size(xhat_endog,2));
%Use GE agg to calculate tariff AVE
[trat,fval]=fsolve(@(trat) ave_endog(trat,xhat_endog,k,sig,I_1),trat0,options )  % Call solver




trat

logchange_endog=100*log(xhat_endog)
logchange_endog(4)=0.86*logchange_endog(4)

%rearrange to same order as Table 8 in AER paper
logchange_endog=[logchange_endog(1:2),logchange_endog(8),logchange_endog(3:5),logchange_endog(7),logchange_endog(6)]
trat=[trat(1:2),trat(8),trat(3:5),trat(7),trat(6)]



% create headers labels and data to export
 fnam='table8.out'; % 

 output=dataset({[round(100*log(trat'),1),round(logchange_endog',1)] 'Endog_Entry_AVE', 'Endog_Change_LogPts' },...
     'obsnames',{'ExpValue','EntryValue','ChExpPindex','USPindex','USWelfare','US_Sales','US_FirmEntry','US_Emp'})
 
export(output,'File',fnam,'Delimiter','\t')

%add notes to track this back if needed for later
notes=sprintf('%s\t','Notes: ');
 notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('Sigma=%1.0f, beta_gamma=%1.6f, k=%1.6f, weighted tariff factor=%1.6f, 2005 Import Penetration=%1.3f \r\n', sig,qparams(2), k,trat_wt,I_1);
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('alpha=%1.0f for Endogenous Entry.   \r\n',alpha(4));
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('Computed from iterative_transition_dynamics_full.m on date %12s ',date);
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');

 
 
% compute range of U1 %
fprintf('The max of -ln(U1)is: %1.6f\n',-log(u_min*(1+u)^(1-k/(sig-1))))
fprintf('The min of -ln(U1)is: %1.6f\n',-log(u_max*(1+b)^(1-k/(sig-1))))

 
%% Compute Counterfactual Import Penetration Graph %%

%import penetration 2002 to 2012
 [impdata,hdr,RAW]=xlsread('imppen_cf_data.xlsx')

imppen= impdata(14:24,4)

%adjust import pen to account for tariff changes

tauhat_exp_wt=qparams(2);
tauhat_p_wt=qparams(3);
P_mean=(imppen.*tauhat_p_wt+(1-imppen)).^(-1/k)
Rhatmean=tauhat_exp_wt.*P_mean.^k

imppen=imppen.*Rhatmean


%create matrix to save output

impout=zeros(size(imppen,1),13);
impout(:,1)=imppen;

alpha=4;

converge=99*ones(size(imppen,1),1);

%set to tau0 wt relative to 2005;

tau0rat_wt=qparams(12);
D=(I_1*tau0rat_wt+(1-I_1))^(-1/k);

for i=1:11

%% Step 1: solve for steady states using upper bounds


[x,fval] = fsolve(@( x) pindex( x,k,sig,imppen(i),b,U_wt,trat_wt,alpha,tau0rat_wt),x0,options );  % Call solver

% set upper bounds
omega_h= (x(1)).^(1-sig);
g      = (x(2)).^(sig-1);
P2inf=x(2);
P1inf=x(1);

display('Upper bound 1st step of omega and g')
g
omega_h
 
%% Step 2a: compute P1 transition dynamics with given upper bounds (from SS in 1st round, updated thereafter)

g_update=g;
omega_h_update=omega_h;

%set initial guess so loop runs on first iteration
g=2;
omega_h=2;

%loop repeats as long as norm of g terms exceeds tolerance
while (norm(g-g_update,omega_h-omega_h_update)>.000001)
    
    
    
p0=1
P1=zeros(1,size(T,2));
for t=1:size(T,2);
[P1T,fval]=fsolve(@(x) phat1trans( x,k, sig, imppen(i), b, U_wt, trat_wt ,beta_h,alpha,T(t),g_update, omega_h_update,tau0rat_wt),p0,options);

P1(t)=P1T;
end;

%% Step 2b: compute P2 transition dynamics with with given upper bounds (from SS in 1st round, updated thereafter)



P2=zeros(1,size(T,2));
for t=1:size(T,2);
 [P2T,fval]=fsolve(@(x) phat2trans( x,k, sig, imppen(i), b, U_wt, trat_wt ,Uhat_wt, beta_f,alpha,T(t),g_update, omega_h_update),p0,options);
 
  P2(t)=P2T;
end;

%% Step 3: update upper bounds on g and omega_h
pseries1=0;
pseries2=0;
maxT=max(T);
for t=1:size(T,2)
pt2=beta_f^T(t)*P2(t)^(sig-1);
pseries2=pseries2+pt2;

pt1=beta_h^T(t)*P1(t)^(sig-1);
pseries1=pseries1+pt1;

end

display('Starting values of omega and g for this step')

g=g_update
omega_h=omega_h_update



display('Updated values of omega and g for this step')

g_update=(1-beta_f)*(pseries2+beta_f^(maxT+1)*P2T^(sig-1)/(1-beta_f))
omega_h_update=(1-beta_h)*(pseries1+beta_h^(maxT+1)*P1T^(sig-1)/(1-beta_h))


%update the price vector
[Pupdate,fval] = fsolve(@( x) pindex_dyn( x,k,sig,imppen(i),b,U_wt,trat_wt,alpha,g_update,omega_h_update),x0,options );  % Call solver




end;

g=g_update;
omega_h=omega_h_update

[x,fval] = fsolve(@( x) pindex_dyn( x,k,sig,imppen(i),b,U_wt,trat_wt,alpha,g,omega_h),x0,options );  % Call solver



%check convergence: difference between SS prices and transition prices at
%capital T

diffT=[x(1)/D-1/P1T,x(2)-P2T]
diffT2=[x(1)-1/P1T,x(2)-P2T]

%flag if converged, converge==99 implies did not converge
if norm(diffT)<0.0001
    converge(i)=1;
end;




%find the tariff equivalent at each P1_hat level
[trat,fval]=fsolve(@(trat) pindex_ave(trat,x(1),k,sig,imppen(i)),1,options );  % Call solver



impout(i,2)=x(1);
impout(i,3)=x(2);
impout(i,4)=trat;
impout(i,5)=g;
impout(i,6)=omega_h;


%partial Agg OLS
impout(i,10)=1/exp(b_ols*(1-rat_sig_wt));



%compute total GE change in exports from params and mean of term in
%numerator from weighted U term and updated price index

%GE Agg Rhat Model
RhatAggGE=U_wt*(1+b/g)^(1-k/(sig-1))*x(1)^(k)

RhatMeanGE=U_unwt*(1+b/g)^(1-k/(sig-1))*x(1)^(k);

%Use GE agg to calculate tariff AVE
[tratexp,fval]=fsolve(@(trat) export_ave(trat,RhatAggGE,k,sig,imppen(i)),1.1,options );  % Call solver

impout(i,7)=tratexp;

%assign values to matrix

impout(i,11)=RhatAggGE;
%Partial Mean OLS
impout(i,8)=1/exp(b_ols*(1-rat_sig_unwt));

%Agg Mean Model
impout(i,9)=RhatMeanGE;

%Partial Model based
%mean
impout(i,12)=U_unwt*(1+b/g)^(1-k/(sig-1));
%aggregate wgt mean
impout(i,13)=U_wt*(1+b/g)^(1-k/(sig-1))


fprintf('The tariff equivalent for import penetration %1.2f to the change in exports is: %1.6f\n',imppen(i),tratexp)

end;

cf_imp=impdata(14:24,2).*impout(:,11)
cf_imppen=cf_imp./impdata(14:24,3)

FigHandle = figure('Position', [200, 250, 800, 500]);
plot(impdata(2:22),impdata(2:22,4),'b-','linewidth',2)
hold on
plot(impdata(14:22),cf_imppen(1:9), 'r--','linewidth',2)
axis([1989.5 2010.5 0 .07])
v = get(gca);
%China joints WTO last month of 2001, or 2001+5 months
% 2001+(5/6*.5) , 5 months to right our data, which is centered on 2001.
lh = line([2001+.5*5/6, 2001+.5*5/6],[0 0.07])

%Text arrow marking entry to WTO
annotation('textarrow',[(2003.25-1990)/20,(2001.5-1990)/20],[.3,.11],'String','China joins WTO (Dec. 2001)')

set(gca,'XTick',[1990 1995 2000 2005 2010])
set(lh,'Color',[.25 .25 .25],'LineStyle',':','linewidth',1)

legend('Actual (data)', 'Counterfactual Steady State (model,estimates)','Location','West')
legend boxoff
ylabel('Chinese Import Penetration')

hold off
set(gcf,'PaperPositionMode','auto');

print('figure1','-dpdf')


diary off
