%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% India Power Shortage Model
%
% April 24 2013
% Updated December 10 2014
% Cobb-Douglas Version
%
% SIMULATION From ASI
% Allan Collard-Wexler
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Base Parameters
% Price of Grid Power
%p_e_g=4.5;
% Price of Self-Generated Power
%p_e_s=7;
 
 


function asi_simulation11_ces(shortagefile,p_e_g,p_e_s,sigma)

sigma=sigma/10;

thedirectory=['cd simulation_asi_inputs_dec2014'];
% Version that uses cobb-douglas

infilename=['ASIpanelfields_forsimulation_' int2str(shortagefile) '_edit.csv'];

outfilename=['ASI_Prediction' int2str(shortagefile) '_' int2str(p_e_s)  '_' num2str(sigma) '.csv'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Load ASI Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Most Recent Directory...
eval(thedirectory)
[DATA,delimiterOut,headerlinesOut] = importdata(infilename)
cd ..

DATA.textdata


DATA.colheaders

DAT=DATA.data;
% Purge Missing Data
for j=1:16
notmissings=find(1-isnan(DAT(:,j)));
DAT=DAT(notmissings,:);
end

% For Testing...
% DAT=DAT(1:1000,:);

N_obs=length(DAT)

% Make into variables
cell2vars(DATA.colheaders,DAT);

theyear=DAT(:,1);

% Relabelling
anyyearEprod=anyyeareprod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Prediction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

K=exp(k);
OMEGA=exp(omega);
who

for i=1:N_obs 

% v) Prediction
[Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output_CD_CES(alpha_m(i),alpha_l(i),alpha_k(i),alpha_e(i),sigma,OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g,p_e_s,delta_psp(i),1-anyyearEprod(i));    

yshortage(i)=Y_shortage;
ynoshortage(i)=Y_no_shortage;
mshortage(i)=M_shortage;
mnoshortage(i)=M_no_shortage;
lshortage(i)=L_shortage;
lnoshortage(i)=L_no_shortage;
eselfshortage(i)=E_self_shortage;
eselfnoshortage(i)=E_self_no_shortage;
egridshortage(i)=E_grid_shortage;
egridnoshortage(i)=E_grid_no_shortage;



profit_no_shortage=Y_no_shortage-p_m(i)*M_no_shortage-p_l(i)*L_no_shortage-E_grid_no_shortage;

Profit_No_Shortages(i)=profit_no_shortage;


percent_output_loss(i)=[100*(Y_no_shortage-Y_shortage)/Y_no_shortage];

[i percent_output_loss(i)]

messed_up_compute(i)=[exitflag];

% vi) Value of having a generator
no_generator=1;
[Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output_CD_CES(alpha_m(i),alpha_l(i),alpha_k(i),alpha_e(i),sigma,OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g,p_e_s,delta_psp(i),no_generator); 

profit_no_generator=Y_shortage-p_m(i)*M_shortage-p_l(i)*L_shortage-E_grid_shortage;
y_no_generator(i)=Y_shortage;
e_grid_no_generator(i)=E_grid_shortage;
tfp_shortage=log(Y_shortage)-alpha_l(i)*log(L_shortage)-alpha_m(i)*log(M_shortage)-alpha_k(i)*log(K(i));
tfp_no_shortage=log(Y_no_shortage)-alpha_l(i)*log(L_no_shortage)-alpha_m(i)*log(M_no_shortage)-alpha_k(i)*log(K(i));

diff_tfp_no_generator(i)=tfp_no_shortage-tfp_shortage;

no_generator=0;
[Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output_CD_CES(alpha_m(i),alpha_l(i),alpha_k(i),alpha_e(i),sigma,OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g,p_e_s,delta_psp(i),no_generator); 

 
profit_generator=Y_shortage-p_m(i)*M_shortage-p_l(i)*L_shortage-E_grid_shortage-E_self_shortage;

y_generator(i)=Y_shortage;
e_grid_generator(i)=E_grid_shortage;

tfp_shortage=log(Y_shortage)-alpha_l(i)*log(L_shortage)-alpha_m(i)*log(M_shortage)-alpha_k(i)*log(K(i));
tfp_no_shortage=log(Y_no_shortage)-alpha_l(i)*log(L_no_shortage)-alpha_m(i)*log(M_no_shortage)-alpha_k(i)*log(K(i));

diff_tfp_generator(i)=tfp_no_shortage-tfp_shortage;

Profit_Diff(i)=profit_generator-profit_no_generator;

% v) Elasticity of Output with Respect 
% to price of electricity.

% Output if price of power is 1% higher
[Y_shortage_prime, Y_no_shortage_prime,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output_CD_CES(alpha_m(i),alpha_l(i),alpha_k(i),alpha_e(i),sigma,OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g*1.01,p_e_s*1.01,delta_psp(i),1-anyyearEprod(i)); 

yshortageprime(i)=Y_shortage_prime;
ynoshortageprime(i)=Y_no_shortage_prime;

profitgenerator(i)=profit_generator;
profitnogenerator(i)=profit_no_generator;


end


% fix up bogus observations
A=find(isinf(yshortage));

size(A)

yshortage(A)=zeros(length(A));
ynoshortage(A)=zeros(length(A));
mshortage(A)=zeros(length(A));
mnoshortage(A)=zeros(length(A));
lshortage(A)=zeros(length(A));
lnoshortage(A)=zeros(length(A));
eselfshortage(A)=zeros(length(A));
eselfnoshortage(A)=zeros(length(A));
egridshortage(A)=zeros(length(A));
egridnoshortage(A)=zeros(length(A));

y_no_generator(A)=zeros(length(A));
y_generator(A)=zeros(length(A));

e_grid_no_generator(A)=zeros(length(A));
e_grid_generator(A)=zeros(length(A));
diff_tfp_no_generator(A)=zeros(length(A));
diff_tfp_generator(A)=zeros(length(A));

B=find(isnan(percent_output_loss));

size(B)

yshortage(B)=zeros(length(B));
ynoshortage(B)=zeros(length(B));
mshortage(B)=zeros(length(B));
mnoshortage(B)=zeros(length(B));
lshortage(B)=zeros(length(B));
lnoshortage(B)=zeros(length(B));
eselfshortage(B)=zeros(length(B));
eselfnoshortage(B)=zeros(length(B));
egridshortage(B)=zeros(length(B));
egridnoshortage(B)=zeros(length(B));

y_no_generator(B)=zeros(length(B));
y_generator(B)=zeros(length(B));

e_grid_no_generator(B)=zeros(length(B));
e_grid_generator(B)=zeros(length(B));
diff_tfp_no_generator(B)=zeros(length(B));
diff_tfp_generator(B)=zeros(length(B));


C=isreal(percent_output_loss);

size(C)

yshortage(C)=zeros(length(C));
ynoshortage(C)=zeros(length(C));
mshortage(C)=zeros(length(C));
mnoshortage(C)=zeros(length(C));
lshortage(C)=zeros(length(C));
lnoshortage(C)=zeros(length(C));
eselfshortage(C)=zeros(length(C));
eselfnoshortage(C)=zeros(length(C));
egridshortage(C)=zeros(length(C));
egridnoshortage(C)=zeros(length(C));

e_grid_no_generator(C)=zeros(length(C));
e_grid_generator(C)=zeros(length(C));
diff_tfp_no_generator(C)=zeros(length(C));
diff_tfp_generator(C)=zeros(length(C));


y_no_generator(C)=zeros(length(C));
y_generator(C)=zeros(length(C));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Output Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prediction_headers={   'year'  ,  'delta_PSP'  ,  'delta_PDPM'  , 'mult' ,   'K'   , 'alpha_m' ,   'alpha_l'  ,  'alpha_K'  , 'alpha_e', 'OMEGA',  ...
    'zero_generation_flag', 'p'  ,  'p_m'  ,  'p_l', 'Y_shortage', 'Y_no_shortage', 'M_shortage',  'M_no_shortage', 'L_shortage', ...
 'L_no_shortage', 'E_self_shortage', 'E_self_no_shortage', 'E_grid_shortage' ,'E_grid_no_shortage', 'Pct Shortage', 'Messed Up Compute?',...
 'Y_shortage_prime','Y_no_shortage_prime','profit_generator','profit_no_generator','profit_no_shortages','snic_hc','exog_gen_industry','panelgroup','scheme_dummy','grsale_defl','totpersons','qeleccons','fcapclose','matls_defl','y_no_generator','y_generator','e_grid_no_generator','e_grid_generator','diff_tfp_no_generator','diff_tfp_generator'};

% Giant Matrix with all the variables
OUTPRED=[theyear delta_psp delta_pdpm mult K alpha_m alpha_l alpha_k alpha_e OMEGA anyyearEprod p p_m p_l yshortage' ynoshortage' mshortage' mnoshortage' lshortage' lnoshortage' eselfshortage' eselfnoshortage' egridshortage' egridnoshortage' percent_output_loss' messed_up_compute' yshortageprime' ynoshortageprime' profitgenerator' profitnogenerator' Profit_No_Shortages' snic_hc exog_gen_industry panelgroup scheme_dummy grsale_defl totpersons qeleccons fcapclose_defl matls_defl y_no_generator' y_generator' e_grid_no_generator' e_grid_generator' diff_tfp_no_generator' diff_tfp_generator'];
 
 
whos
size(prediction_headers)
size(OUTPRED) 
% Add Header Row
eval(thedirectory)

csvwrite_with_headers(outfilename,OUTPRED,prediction_headers)

cd ..
	
end
