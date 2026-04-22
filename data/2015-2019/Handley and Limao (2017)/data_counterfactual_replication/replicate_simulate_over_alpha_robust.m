%%

clear all
%iterative equilibrium solution for steady state and transition dynamics


diary off
delete simulate_over_risk_alpharobust.log
diary simulate_over_risk_alpharobust.log

%% Bring in params from estimation and setup options for solver

%import and define params from estimation

qparams=dlmread('C:\Users\handleyk\Dropbox\ChinaMFN\estimation\aer_rr\quant_params_new.txt','\t',1,1)

%this is a grid over changes in y but it requires we recompute the u params
%for each value of ratio, given a change tau1, so grid is over u
rgrid=dlmread('C:\Users\handleyk\Dropbox\ChinaMFN\estimation\aer_rr\quant_riskgrid.txt','\t',1,1)
rgrid=rgrid(1:13,1:24);

%Note last 4 grid points are over alpha=0, 2, 4, 6

rgrid=[rgrid(:,21:24)];

% pareto shape param
k=qparams(16)

% EOS
sig=3;

% Import penetration 2005
I_init=0.045;

% estimated portion of u term
b=qparams(26)

%alpha grid
agrid=[0 2 4 6];

% set death rate
beta_f=.85;
beta_h=.9;

x0 = [1.01 1.01  ]           % Make a starting guess at the solution

% set options for numerical optimization
options=optimset('Display','off','MaxFunEvals',1000, 'MaxIter',1000,'TolX',1e-8,'TolFun',1e-8 );   % Option to display output

%set time periods for iteration
T=[0:250];

%set grid over little u term
gridsize=size(rgrid,2);

%create matrix to save output

out=zeros(gridsize,11);

out(:,1)=rgrid(1,:)';
u=zeros(gridsize,1);
y=rgrid(1,:);
P2inf=[];
P1inf=[];
converge=99*ones(gridsize,1)

tau0hat=rgrid(6,:)';
taumean=rgrid(8,:)';

for i=1:4
    
%% Step 0: recompute import penetration if tariffs at mean

alpha=agrid(i);
tauhat_exp_wt=rgrid(2,i);
tauhat_p_wt=rgrid(3,i);
P_mean=(I_init*tauhat_p_wt+(1-I_init))^(-1/k)
Rhatmean=tauhat_exp_wt*P_mean^k

I_1=I_init*Rhatmean
out(i,11)=I_1
%% Step 1: solve for steady states using upper bounds

%hold alpha fixed over the grid for tau1


%compute u and y terms*
ratgrid=rgrid(6,i);

%U_wt=(1+b*ratgrid^sig)^((k-sig+1)/(sig-1));
U_wt=rgrid(9,i);

%interaction term of tariff and unc terms for transition pindex*

Uhat_wt=rgrid(10,i);

%uncertainty term to power for entry computation*

U_wt_entry=rgrid(11,i);


%tariff increase raised power*
% weight power mean values of uncertainty measure and tariff ratio


trat_wt=rgrid(13,i);

tau0rat_wt=rgrid(12,i);

[x,fval] = fsolve(@( x) pindex( x,k,sig,I_1,b,U_wt,trat_wt,alpha,tau0rat_wt),x0,options );  % Call solver

% set upper bounds
D=(I_1*tau0rat_wt+(1-I_1))^(-1/k);

omega_h= (x(1)).^(1-sig);
g      = (x(2)).^(sig-1);
P2inf=x(2);
P1inf=x(1);

display('Upper bound 1st step of omega and g')
g
omega_h
 
%% Step 2a: compute P1 transition dynamics with given upper bounds (from SS in 1st round, updated thereafter)

%update starting value to upper bounds
g_update=g;
omega_h_update=omega_h;

%set initial guess so loop runs on first iteration
g=2;
omega_h=2;


%loop repeats as long as norm of g terms exceeds tolerance
while (norm(g-g_update,omega_h-omega_h_update)>.000001)
    

p0=1;
P1=zeros(1,size(T,2));
for t=1:size(T,2);
   
[P1T,fval]=fsolve(@(x) phat1trans( x,k, sig, I_1, b, U_wt, trat_wt ,beta_h,alpha,T(t),g_update, omega_h_update,tau0rat_wt),p0,options);

P1(t)=P1T;
end;


%% Step 2b: compute P2 transition dynamics with with given upper bounds (from SS in 1st round, updated thereafter)




P2=zeros(1,size(T,2));
for t=1:size(T,2);
   
 [P2T,fval]=fsolve(@(x) phat2trans( x,k, sig, I_1,b, U_wt, trat_wt ,Uhat_wt, beta_f,alpha,T(t),g_update, omega_h_update),p0,options);
 
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


%update prices with new g
[Pupdate,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,b ,U_wt,trat_wt,alpha,g_update,omega_h_update),x0,options );  %


end;

g=g_update;
omega_h=omega_h_update

%solve for prices with last updated value
[x,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,b,U_wt,trat_wt,alpha,g,omega_h),x0,options );  % Call solver


%check convergence: difference between SS prices and transition prices at
%capital T

diffT=[x(1)/D-1/P1T,x(2)-P2T]

%flag if converged, converge==99 implies did not converge
if norm(diffT)<0.0001
    converge(i)=1;
end;



out(i,3)=x(1);
out(i,4)=x(2);

out(i,5)=g;
out(i,6)=omega_h;
u(i)=b/g;
out(i,2)=u(i);

%compute total GE change in exports from params and mean of term in
%numerator from weighted U term and updated price index

Rhat=U_wt*(1+u(i))^(1-k/(sig-1))*x(1)^(k)


out(i,8)=Rhat;

%save mean tariff
out(i,9)=rgrid(8,i);
%save change in price to mean
out(i,10)=P_mean;


end;

%% check convergence, generate warning
if mean(converge)>1
    fprintf('WARNING!!! Some gridpoints may not have converged. Check converge vector!!!!!!')
end

converge


%% output all of this to file 


% load GE effect to compute share due to risk

load('agg_effect_GE.mat','log_expgrow_GE','log_price_index')
%use vector but delete 2nd element
log_expgrow_GE(2)=[]
log_price_index(2)=[]
share_risk=log(1./out(:,8))./log_expgrow_GE
share_p_risk=log(out(:,3))./log_price_index


% create headers labels and data to export

  fnam='tableA10.out'; % 
  hdr={'alpha','Implied lambda_2','Log Export Growth','Risk Share (log growth)'};
  m=[agrid',round(out(:,1),2),round(100*log_expgrow_GE,1),round(share_risk,2)];
 
  
% out to tab delim text
     labels=sprintf('%s\t',hdr{:});
     labels(end)='';
     
  
% fprintf(fileID,'Computed from simulate_over_u.m on date %12s \r\n',date);
     
     dlmwrite(fnam,labels,'');
     
     
     dlmwrite(fnam,m,'-append','delimiter','\t','precision',6);
 notes=sprintf('%s\t','Notes: ');
 notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('Sigma=%1.0f, beta_gamma=%1.6f, k=%1.6f, 2005 Import Penetration=%1.3f \r\n', sig,qparams(2), k,I_init);
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
 notes=sprintf('Risk Share is log(1/Rhat(GE) at mean) divided by Log total agg GE growth');
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
notes=sprintf('Computed from replicate_simulate_over_alpha_robust.m on date %12s ',date);
notes(end)='';
 dlmwrite(fnam,notes,'-append','delimiter','');
 
 
 
 
 %% end of file
 
diary off