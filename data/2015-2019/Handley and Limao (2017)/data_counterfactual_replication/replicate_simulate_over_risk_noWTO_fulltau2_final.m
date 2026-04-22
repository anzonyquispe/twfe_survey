%%

clear all


diary off
delete replicate_simulate_over_risk_noWTO_fulltau2_final.log
diary replicate_simulate_over_risk_noWTO_fulltau2_final.log

%% Bring in params from estimation and setup options for solver

%import and define params from estimation

qparams=dlmread('quant_params_new.txt','\t',1,1)

%this is a grid over changes in y but it requires we recompute the u params
%for each value of ratio, given a change tau1, so grid is over u
rgrid=dlmread('quant_riskgrid.txt','\t',1,1)
rgrid=rgrid(1:13,1:24);

%Note last 3 grid points are over alpha= 2, 4, 6
% we only want alpha=4 in this exercise from column 23

rgrid=[rgrid(:,1:21),rgrid(:,23)];

%get mean tariff terms

targrid=dlmread('tariffs_simplemeans.txt','\t',1,1)

% pareto shape param
k=qparams(16)

% EOS
sig=3;

% Import penetration
% using man_imp_exp_usitc.xlsx
I_init=0.257;%2005 import pen

%tariff means values from OLS sample 

tau0=targrid(1,1);%MFN tariff in 2005
tau1=targrid(2,1); %MFN tariff in 2000
tau2=targrid(3,1); %Col2 tariff in 2000 divided by 2

% estimated portion of u term
b=qparams(26)

%use estimated g values for China to compute  little u
%get the little g value computed in previous output for this counter
%factual exercise
load('agg_effect_GE.mat')

%little g value for this exercise
china_gval
u=b/china_gval

u=b/china_gval



% set death rate
beta_f=.85;
beta_h=.9;


% set scale for alpha
%alpha=[1];
lam2=0.5;
alpha=((1-lam2)/lam2)*(beta_h/beta_f)*(1-beta_f)/(1-beta_h)
%alpha=4;
umax=beta_f*beta_h/(beta_h*(1-beta_f)+alpha*beta_f*(1-beta_h))
ugrid(1,1:25)=linspace(0,umax,25);

%factor to convert estimated little u into gamma

gam_adj=(1/lam2)*((1-beta_f)/beta_f)

x0 = [1.01 1.01  ]           % Make a starting guess at the solution

% set options for numerical optimization
options=optimset('Display','off','MaxFunEvals',1000, 'MaxIter',1000,'TolX',1e-8,'TolFun',1e-8 );   % Option to display output

%set time periods for iteration
T=[0:250];

%set grid over little u term
gridsize=25;

%create matrix to save output

out=zeros(gridsize,11);

%out(:,1)=rgrid(1,:)';
%u=zeros(gridsize,1);
y=rgrid(1,:);
P2inf=[];
P1inf=[];
converge=99*ones(gridsize,1)
% 
% tau0hat=rgrid(6,:)';
% taumean=rgrid(8,:)';

lam2=linspace(0,1,25);

tau2grid=lam2*tau2+(1-lam2).*tau1;



for i=1:gridsize
    
%% Step 0: recompute import penetration if tariffs at mean

%taumean=lam2*tau2+(1-lam2)*tau1


%tauhat_exp_wt=rgrid(2,i);
tauhat_exp_wt=(tau1/tau0)^(-k*sig/(sig-1));
%tauhat_p_wt=rgrid(3,i);
tauhat_p_wt=(tau1/tau0)^(1-k*sig/(sig-1));


P_mean=(I_init*tauhat_p_wt+(1-I_init))^(-1/k);
Rhatmean=tauhat_exp_wt*P_mean^k;

I_1=I_init*Rhatmean;
out(i,11)=I_1;

%% Step 1: solve for steady states using upper bounds

%hold alpha fixed over the grid for tau1


%compute u and y terms*
tau0hat=tau0/tau1;
ratgrid=tau1/tau2grid(i);


%uncertainty term to power for entry computation*
U_wt_entry=(1+b*ratgrid^sig)^(1/(sig-1))
%U_wt_entry=rgrid(11,i);


%tariff increase raised power*
% weight power mean values of uncertainty measure and tariff ratio

trat_wt=(1/ratgrid)^(1-k*sig/(sig-1))


tau0rat_wt=tau0hat^(1-k*sig/(sig-1));


[x,fval] = fsolve(@( x) pindex_wto( x,k,sig,I_1,u,ratgrid,trat_wt,alpha,tau0rat_wt),x0,options );  % Call solver

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
U_wt=(1+u*g_update*ratgrid.^sig).^((k-sig+1)./(sig-1))
%interaction term of tariff and unc terms for transition pindex*
Uhat_wt=(1/ratgrid)^(1-sig)*U_wt
%set initial guess so loop runs on first iteration
g=2;
omega_h=2;

%loop repeats as long as norm of g terms exceeds tolerance
while (norm(g-g_update,omega_h-omega_h_update)>.000001)
    


p0=1;
P1=zeros(1,size(T,2));
for t=1:size(T,2);
   
[P1T,fval]=fsolve(@(x) phat1trans( x,k, sig, I_1, u*g, U_wt, trat_wt ,beta_h,alpha,T(t),g_update, omega_h_update,tau0rat_wt),p0,options);

P1(t)=P1T;
end;


%% Step 2b: compute P2 transition dynamics with with given upper bounds (from SS in 1st round, updated thereafter)

P2=zeros(1,size(T,2));
for t=1:size(T,2);
   
 [P2T,fval]=fsolve(@(x) phat2trans( x,k, sig, I_1,u*g, U_wt, trat_wt ,Uhat_wt, beta_f,alpha,T(t),g_update, omega_h_update),p0,options);
 
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


U_wt=(1+u*g_update*ratgrid.^sig).^((k-sig+1)./(sig-1))
%interaction term of tariff and unc terms for transition pindex*
Uhat_wt=(1/ratgrid)^(1-sig)*U_wt

%update prices with new g
[Pupdate,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,u*g_update ,U_wt,trat_wt,alpha,g_update,omega_h_update),x0,options );  %


end;

g=g_update;
omega_h=omega_h_update

%solve for prices with last updated value
[x,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,u*g,U_wt,trat_wt,alpha,g,omega_h),x0,options );  % Call solver


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
%u(i)=b/g;
out(i,2)=u;

%compute total GE change in exports from params and mean of term in
%numerator from weighted U term and updated price index

Rhat=U_wt*(1+u)^(1-k/(sig-1))*x(1)^(k)


out(i,8)=Rhat;

%save mean tariff
out(i,9)=tau2grid(i);
%save change in price to mean
out(i,10)=P_mean;




end;

%% check convergence, generate warning
if mean(converge)>1
    fprintf('WARNING!!! Some gridpoints may not have converged. Check converge vector!!!!!!')
end

converge



%% GRAPHS to show the tau0hat intuition and risk decomposition in one set of charts

%load axis data from graphs vs tau1 to have same for graph vs tau2

load('tau1graph_axis')


%domestic entry
home_entry=(out(:,3).*((1+out(:,6).*(alpha.*u))./(1+alpha.*u)).^(1/(sig-1))).^k;

%home_entry_bnd=home_entry(22);
%home_entry=home_entry(1:21);

%domestic sales
home_sales=out(:,3).^k.*((1+out(:,6).*(alpha.*u))./(1+alpha.*u)).^((k-sig+1)/(sig-1));

%home_sales_bnd=home_sales(22);
%home_sales=home_sales(1:21);

%taumean_bnd=taumean(22);
%taumean=taumean(1:21);

figure, plot(tau2grid,home_entry,'r-', tau2grid,home_sales,'b--','linewidth',1)

%title('Domestic Entry and Sales vs. $\tau_2$','Interpreter','latex')
axis tight
xlabel('Threat Tariff ($\tau_2$)','Interpreter','latex')
v = get(gca);
V=axis
%V(4)=1.08;
axis([V(1) V(2) Vdom(3) Vdom(4)]);
lh = line([v.XLim],[  1 1])
set(lh,'Color',[.25 .25 .25],'LineStyle',':')
leg=legend('Domestic Entry Change','Domestic Sales Change')
set(leg,'Interpreter','latex')
set(leg,'Position',[.65,.35,.1,.1],'Box','off')
%axis([1 max(taumean) .98 1.02])
set(gcf,'PaperPositionMode','auto');
save2pdf('figure6_r3c2',gcf,300)


%foreign entry

wt_entry_U1=(1+b.*(tau1./tau2grid).^sig).^(1/(sig-1))./(1+u').^(1/(sig-1));

ch_entry=(out(:,3).*wt_entry_U1').^k;

%foreign sales
ch_sales=out(:,8);

u_h=alpha*u;
%entry terms in U

U_h    = ((1+u_h.*out(:,6))./(1+u_h)).^(1./(sig-1));

%Home Goods Price Change
HomePhat=(out(:,3).*U_h).^(1-k/(sig-1));

%Chinese Import Price Change
ChImpPhat=(out(:,3).*wt_entry_U1').^(1-k/(sig-1))


figure, plot(tau2grid,ch_entry,'r-',tau2grid,ch_sales,'b--','linewidth',1)
hold on

axis tight
V=axis

axis(V);
v = get(gca);



h=legend('Export Entry', 'Export Sales ')
set(h,'Position',[.65,.65,.1,.1],'Box','off')
set(h,'Interpreter','latex')

xlabel('Threat Tariff ($\tau_2$)','Interpreter','latex')

V=axis

axis([V(1) V(2) Vexp(3) Vexp(4)]);
v = get(gca);

lh = line([v.XLim],[  1 1])
set(lh,'Color',[.25 .25 .25],'LineStyle',':')

hold off
set(gcf,'PaperPositionMode','auto');
save2pdf('figure6_r2c2',gcf,300)




%%%%  NOW PLOT AUTARKY AND UNCERTAINTY PRICE EFFECTS VS TAU1
figure
plot(tau2grid,(1-out(1:25,11)).^(-1/k),'-k',tau2grid,out(1:25,3),'--k','linewidth',1)
ax=gca;
leg=legend('Autarky Price Change $\hat{P}_A(\tau_1)$','Uncertainty Price Change $\hat{P}_1(\tau_1)$')
set(leg,'Interpreter','latex', 'location','east')
legend BOXOFF
%title('Change in Price from Uncertainty and Autarky vs. Initial $\tau_1$','Interpreter','latex')
xlabel('Threat Tariff ($\tau_2$)','Interpreter','latex')
%ylabel('Price Change Relative to $P_1^D(\tau_1)$','Interpreter','latex')
axis tight
V=axis
V(4)=1.08;
axis(V);
ylim=ax.YLim
ax.YLim=[1 ylim(2)]


set(gcf,'PaperPositionMode','auto');
save2pdf('figure6_r1c2',gcf,300);
 
 



 %% end of file
 diary off