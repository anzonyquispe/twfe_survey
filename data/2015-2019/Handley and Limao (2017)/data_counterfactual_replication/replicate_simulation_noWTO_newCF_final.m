%%

clear

diary off
delete replicate_simulate_noWTO_newCF.log
diary  replicate_simulate_noWTO_newCF.log

%% Bring in params from estimation and setup options for solver

%import and define params from estimation

qparams=dlmread('quant_params_new.txt','\t',1,1)
%this is a grid over changes in y but it requires we recompute the u params
%for each value of ratio, given a change tau1, so grid is over u
rgrid=dlmread('quant_riskgrid.txt','\t',1,1)


%get weighted tariff terms, using 2005 import expenditure weights

targrid=dlmread('tariffs_simplemeans.txt','\t',1,1)

ugrid=dlmread('quant_ugrid.txt','\t',1,1)
ugrid=ugrid(1:4,1:25);

%tack our estimated beta_gamma onto grid
% U_wt=qparams(9)
% Uhat_wt=qparams(10)
% u_entry_wt=qparams(11)

estu=[qparams(26);qparams(9);qparams(10);qparams(11)]
ugrid=[ugrid, estu]


% pareto shape param
k=qparams(16)

% EOS
sig=3;

% Import penetration
% using man_imp_exp_usitc.xlsx
I_init=0.257;%2005 import pen

%I_init=0.285; %2010 import pen

%set tariffs tau0, tau1, tau2


%tariff values
tau0=targrid(1,1);%MFN tariff in 2005
tau1=targrid(2,1); %MFN tariff in 2000
tau2=targrid(3,1); %Col2 tariff in 2000


% estimated portion of u term
b=qparams(26)

% weight power mean values of uncertainty measure and tariff ratio
%trat_wt=qparams(13)
trat_wt=(tau2/tau0)^(1-k*sig/(sig-1));


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

%make first gridpoint non-zero but almost zero
ugrid(1,1)=0.00001;

%factor to convert estimated little u into gamma
%gam_adj=0.62092 %gamma=0.62092*u for later
gam_adj=(1/lam2)*((1-beta_f)/beta_f)

% Make a starting guess at the solution
x0 = [1.01 1.01  ]        
% set options for numerical optimization
options=optimset('Display','off','MaxFunEvals',1000, 'MaxIter',1000,'TolX',1e-8,'TolFun',1e-8 );   % Option to display output

%set time periods for iteration
T=[0:250];

%set grid over little u term
gridsize=size(ugrid,2);

%set u to be evenly space on line over the grid
%u=linspace(0,1/(1-beta_f),gridsize)

%create matrix to save output 
 
out=zeros(gridsize,10);
out(:,2)=ugrid(1,:)';
u=zeros(gridsize,1);
P2inf=[];
P1inf=[];
HomePhat=zeros(gridsize,1);
ChImpPhat=zeros(gridsize,1);

converge=99*ones(gridsize,1);

%adjust import pen to 2000

%tauhat_exp_wt=qparams(2);
tauhat_exp_wt=(tau1/tau0)^(-k*sig/(sig-1));

%tauhat_p_wt=qparams(3);
tauhat_p_wt=(tau1/tau0)^(1-k*sig/(sig-1));


P_mean=(I_init*tauhat_p_wt+(1-I_init))^(-1/k)

Rhatmean=tauhat_exp_wt*P_mean^k

I_1=I_init*Rhatmean


%set to tau0 wt relative to 2005;

%tau0rat_wt=qparams(12);
tau0rat_wt=(tau0/tau1)^(1-k*sig/(sig-1));

D=(I_1*tau0rat_wt+(1-I_1))^(-1/k);

%set gamma*g to value from estimates
ug=qparams(26);

for i=1:gridsize
%% Step 1: solve for steady states using upper bounds

%U_wt=ugrid(2,i);
U_wt=(1+ugrid(1,i)*(tau1/tau2)^sig)^((k-sig+1)/(sig-1));

%Uhat_wt=ugrid(3,i);
Uhat_wt=(tau2/tau1)^(1-sig)*U_wt;

%U_wt_entry=ugrid(4,i);
U_wt_entry=(1+ugrid(1,i)*(tau1/tau2)^sig)^(1/(sig-1));


[x,fval] = fsolve(@( x) pindex( x,k,sig,I_1,ugrid(1,i),U_wt,trat_wt,alpha,tau0rat_wt),x0,options );  % Call solver

% set upper bounds
D=(I_1*tau0rat_wt+(1-I_1))^(-1/k);

omega_h= (x(1)).^(1-sig);
g      = (x(2)).^(sig-1);


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
   
[P1T,fval]=fsolve(@(x) phat1trans( x,k, sig, I_1, ugrid(1,i), U_wt, trat_wt ,beta_h,alpha,T(t),g_update, omega_h_update,tau0rat_wt),p0,options);

P1(t)=P1T;
end;


%% Step 2b: compute P2 transition dynamics with with given upper bounds (from SS in 1st round, updated thereafter)




P2=zeros(1,size(T,2));
for t=1:size(T,2);
   
 [P2T,fval]=fsolve(@(x) phat2trans( x,k, sig, I_1,ugrid(1,i), U_wt, trat_wt ,Uhat_wt, beta_f,alpha,T(t),g_update, omega_h_update),p0,options);
 
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

display('Starting values of omega and g')

g = g_update
omega_h=omega_h_update


display('Updated values of omega and g')
      
g_update=(1-beta_f)*(pseries2+beta_f^(maxT+1)*P2T^(sig-1)/(1-beta_f))
omega_h_update=(1-beta_h)*(pseries1+beta_h^(maxT+1)*P1T^(sig-1)/(1-beta_h))


%update prices with new g
[Pupdate,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,ugrid(1,i) ,U_wt,trat_wt,alpha,g_update,omega_h_update),x0,options );  %


display('loop over u is')
i

end;


g=g_update;
omega_h=omega_h_update

%solve for prices with last updated value

[x,fval] = fsolve(@( x) pindex_dyn( x,k,sig,I_1,ugrid(1,i),U_wt,trat_wt,alpha,g,omega_h),x0,options );  % Call solver


%check convergence: difference between SS prices and transition prices at
%capital T

diffT=[x(1)/D-1/P1T,x(2)-P2T]

%flag if converged, converge==99 implies did not converge
if norm(diffT)<0.0001
    converge(i)=1;
end;



%find the tariff equivalent at each P1_hat level
[trat,fval]=fsolve(@(trat) pindex_ave(trat,x(1),k,sig,I_1),1,options );  % Call solver



out(i,3)=x(1);
out(i,4)=x(2);
out(i,5)=trat;
out(i,6)=g;
out(i,7)=omega_h;
u(i)=ugrid(1,i)/g;
out(i,8)=U_wt*(1+u(i))^(1-k/(sig-1))
out(i,1)=u(i);

%compute total GE change in exports from params and mean of term in
%numerator from weighted U term and updated price index

Rhat=U_wt*(1+u(i))^(1-k/(sig-1))*x(1)^(k)

[tratexp,fval]=fsolve(@(trat) export_ave(trat,Rhat,k,sig,I_1),1.1,options );  % Call solver

out(i,9)=NaN;
out(i,10)=Rhat;


%Domestic and Foreign Componenent of Price index changes

u_h=alpha*u(i);
%entry terms in U
wt_entry_U1=U_wt_entry/(1+u(i)).^(1/(sig-1));
%unwt_entry_U1=u_entry_unwt/(1+u).^(1/(sig-1));

%omega_h=out(i,6)
U_h    = ((1+u_h.*out(i,6))./(1+u_h)).^(1./(sig-1));

%Home Goods Price Change
HomePhat(i)=(out(i,3)*U_h)^(1-k/(sig-1));

%Chinese Import Price Change
ChImpPhat(i)=(out(i,3).*wt_entry_U1)^(1-k/(sig-1))


end;


%% compute other quantities and make graphs


%check convergence, generate warning
if mean(converge)>1
    fprintf('WARNING!!! Some gridpoints may not have converged. Check converge vector!!!!!!')
end

converge

%compute gamma
gamma=gam_adj*u;


%domestic entry
home_entry=(out(:,3).*((1+out(:,7).*(alpha.*u))./(1+alpha.*u)).^(1/(sig-1))).^k;

%domestic sales
home_sales=out(:,3).^k.*((1+out(:,7).*(alpha.*u))./(1+alpha.*u)).^((k-sig+1)/(sig-1));

figure, plot(gamma(1:25),home_entry(1:25),'r-', gamma(1:25),home_sales(1:25),'b--','linewidth',1)
leg=legend('Domestic Entry Change', 'Domestic Sales Change', 'location','east')
set(leg,'Interpreter','latex')
legend BOXOFF
%title('Domestic Entry and Sales vs. Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')
xlabel('Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')
axis tight

v = get(gca);
ax1=gca;
xlim(ax1,[0 1]);
lh = line([0 0 NaN v.XLim],[v.YLim NaN  1 1])
set(lh,'Color',[.25 .25 .25],'LineStyle',':')
set(gcf,'PaperPositionMode','auto');
save2pdf('figure6_r3c1',gcf,300)

%foreign entry

wt_entry_U1=(1+ugrid(1,:)'.*(tau1/tau2)^sig).^(1/(sig-1))./(1+u).^(1/(sig-1));
ch_entry=(out(:,3).*wt_entry_U1).^k;

%foreign sales

ch_sales=out(:,10);

figure, plot(gamma(1:25),ch_entry(1:25),'r-', gamma(1:25),ch_sales(1:25),'b--','linewidth',1)
leg=legend('Export Entry Change', 'Export Sales Change')
set(leg,'Interpreter','latex')
legend BOXOFF
%title('Export Entry and Sales vs. Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')
axis tight
xlabel('Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')
v = get(gca);
ax1=gca;
xlim(ax1,[0 1]);
lh = line([0 0 NaN v.XLim],[v.YLim NaN  1 1])
set(lh,'Color',[.25 .25 .25],'LineStyle',':')
set(gcf,'PaperPositionMode','auto');
save2pdf('figure6_r2c1',gcf,300);


%price index vs gamma
figure, plot(gamma(1:25),out(1:25,3),'r-','linewidth',1)
leg=legend('Price Index Change $\hat{P}_1$','Interpreter','latex','Location','northeast')
set(leg,'Interpreter','latex')
legend BOXOFF
%title('Price Index vs. Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')
axis tight
V=axis;
V(4)=1.08;
axis(V);
xlabel('Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')


v = get(gca);
ax1=gca;
xlim(ax1,[0 1]);
lh = line([0 0 NaN v.XLim],[v.YLim NaN  1 1])
set(lh,'Color',[.25 .25 .25],'LineStyle',':')
set(gcf,'PaperPositionMode','auto');
save2pdf('figure6_r1c1',gcf,300)



%import and domestic price index vs gamma

figure
h1=line(gamma(1:25),ChImpPhat(1:25),'Color','b')

%line(gamma(26),ChImpPhat(26),'Marker','^','Color','b')

ax1=gca;
ax1.XColor = 'k';
ax1.YColor= 'b';


ax1_pos=ax1.Position;
ax2=axes('Position',ax1_pos,'XAxisLocation','bottom','YAxisLocation','right','Color','none');
ax2.YColor='r';

h2=line(gamma(1:25),HomePhat(1:25),'Color','r','LineStyle','--')
%line(gamma(26),HomePhat(26),'Marker','^','Color','r')

xlim(ax1,[0 1]);
xlim(ax2,[0 1]);

maxval = cellfun(@(x) max(abs(x)), get([h1 h2], 'YData'));
ylim = [2-maxval, maxval];  % Mult by 1.1 to pad out a bit
set(ax1, 'YLim', [(1-(1-ylim(1,1))/2) ylim(1,2)]);
set(ax2, 'YLim', [1-(1-.88)/2 1.12]);

set(ax1, 'YTick',[1 1.05 1.1 1.15 1.20 1.25 1.3]);
set(ax2, 'YTick',[.94 .96 .98 1]);

%title('Import and Domestic Price Index vs. Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')
xlabel('Policy Shock Arrival Rate ($\gamma$)','Interpreter','latex')

hold on
axes(ax1)
[xf,yf]=ds2nfu(ax1,gamma(12), ChImpPhat(12))
ChP=annotation('textbox',[xf+.07 yf+.04 0 0],'EdgeColor','none','Color','blue','String','Foreign Varieties $\hat{P}_{1,x}$ (left axis)','Interpreter','Latex','FitBoxToText','on')

%line(gamma(26)*ones(2,1),ax1.YLim,'LineStyle',':','Color','k')
line([0 1],[1 1],'Linestyle',':','Color','k')
axes(ax2)
[xf,yf]=ds2nfu(ax2,gamma(12), HomePhat(12))
DP=annotation('textbox',[xf+.03 yf+.05 0 0],'EdgeColor','none','Color','red','String','Domestic Varieties $\hat{P}_{1,h}$ (right axis)','Interpreter','Latex','FitBoxToText','on')

%Est=annotation('textbox',[xf+.15 yf+.15 0 0],'EdgeColor','none','Color','black','String','Estimated Values in Data (?)','FitBoxToText','on')
hold off

set(gcf,'PaperPositionMode','auto');
save2pdf('figure5',gcf,300)



%price index transitions from MFN to Col2 and WTO states
%using our estimate values of u


U_wt=ugrid(2,26);
Uhat_wt=ugrid(3,26);

U_wt_entry=ugrid(4,26);
g=out(26,6);
omega_h=out(26,7)
p0=1;
P1=zeros(1,size(T,2));
for t=1:size(T,2);
   
[P1T,fval]=fsolve(@(x) phat1trans( x,k, sig, I_1, ugrid(1,26), U_wt, trat_wt ,beta_h,alpha,T(t),g, omega_h,tau0rat_wt),p0,options);

P1(t)=P1T;
end;


P2=zeros(1,size(T,2));
for t=1:size(T,2);
   
 [P2T,fval]=fsolve(@(x) phat2trans( x,k, sig, I_1,ugrid(1,26), U_wt, trat_wt ,Uhat_wt, beta_f,alpha,T(t),g, omega_h),p0,options);
 
  P2(t)=P2T;
end;




figure, plot(T,P1,'r-',T,P2,'b--','linewidth',1)
leg=legend('Price Index - Transition to State 0 (WTO)','Price Index - Transition to State 2 (Col 2)', 'Location','East')
set(leg,'Interpreter','latex')
set(leg,'Position',[.5 .65 .1 .05])
legend BOXOFF
%title('Price Index Transition Dynamics from State 1 (MFN) - Estimated Parameters','Interpreter','latex')

axis([0 30 .965 1.035])
%axis tight

v = get(gca);
lh = line([0 0 NaN v.XLim],[v.YLim NaN  1 1])
set(lh,'Color',[.25 .25 .25],'LineStyle',':')
set(gcf,'PaperPositionMode','auto');
save2pdf('figureA4',gcf,300)


 %% end of file
 
 diary off    
     