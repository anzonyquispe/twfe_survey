%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% India Power Shortage Model
%
% August 4 2015
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
 
 


function asi_simulation_elasticity(p_e_g,p_e_s)

% Version that uses median lambda in an industry

thedirectory=['cd simulation_asi_inputs_dec2014'];
infilename=['ASIpanelfields_less1pct.csv']
outfilename=['ASI_Prediction_elast.csv'] 

% Step Size
epsilon=0.001;


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


for i=1:N_obs 


% Hacklet
% if alpha_l+alpha_m+alpha_e>0.999 things get weird.
sum_alpha=alpha_l(i)+alpha_m(i)+alpha_e(i);
if sum_alpha>0.985 
   alpha_l(i)=alpha_l(i)/(sum_alpha+0.05);
   alpha_m(i)=alpha_m(i)/(sum_alpha+0.05);
   alpha_k(i)=alpha_k(i)/(sum_alpha+0.05);
end


% v) Prediction
[Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output2(alpha_e(i),alpha_m(i),alpha_l(i),alpha_k(i),OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g,p_e_s,delta_psp(i),1-anyyearEprod(i));

yshortage(i)=Y_shortage;
mshortage(i)=M_shortage;
lshortage(i)=L_shortage;
eselfshortage(i)=E_self_shortage;
egridshortage(i)=E_grid_shortage;

percent_output_loss(i)=[100*(Y_no_shortage-Y_shortage)/Y_no_shortage];
messed_up_compute(i)=[exitflag];

profits_shortage=Y_shortage-p_m(i)*M_shortage-p_l(i)*L_shortage-E_grid_shortage;
Profit_shortage(i)=profits_shortage;


% Repeat for a slightly higher value.
[Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output2(alpha_e(i),alpha_m(i),alpha_l(i),alpha_k(i),OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g,p_e_s,delta_psp(i)+epsilon,1-anyyearEprod(i));

yshortage_prime(i)=Y_shortage;
mshortage_prime(i)=M_shortage;
lshortage_prime(i)=L_shortage;
eselfshortage_prime(i)=E_self_shortage;
egridshortage_prime(i)=E_grid_shortage;


profits_shortage_prime=Y_shortage-p_m(i)*M_shortage-p_l(i)*L_shortage-E_grid_shortage;
Profit_shortage_prime(i)=profits_shortage_prime;

% vi) Value of having a generator
no_generator=1;
[Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output2(alpha_e(i),alpha_m(i),alpha_l(i),alpha_k(i),OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g,p_e_s,delta_psp(i),no_generator);

profit_no_generator=Y_shortage-p_m(i)*M_shortage-p_l(i)*L_shortage-E_grid_shortage;
y_no_generator(i)=Y_shortage;
e_grid_no_generator(i)=E_grid_shortage;
tfp_shortage=log(Y_shortage)-alpha_l(i)*log(L_shortage)-alpha_m(i)*log(M_shortage)-alpha_k(i)*log(K(i));
tfp_no_shortage=log(Y_no_shortage)-alpha_l(i)*log(L_no_shortage)-alpha_m(i)*log(M_no_shortage)-alpha_k(i)*log(K(i));

diff_tfp_no_generator(i)=tfp_no_shortage-tfp_shortage;

no_generator=0;
[Y_shortage, Y_no_shortage,M_shortage, M_no_shortage,L_shortage, L_no_shortage,E_self_shortage,E_self_no_shortage,E_grid_shortage,E_grid_no_shortage,exitflag]=...
    optimal_output2(alpha_e(i),alpha_m(i),alpha_l(i),alpha_k(i),OMEGA(i),K(i),p(i),p_m(i),p_l(i),p_e_g,p_e_s,delta_psp(i),no_generator);

 
profit_generator=Y_shortage-p_m(i)*M_shortage-p_l(i)*L_shortage-E_grid_shortage-E_self_shortage;

y_generator(i)=Y_shortage;
e_grid_generator(i)=E_grid_shortage;

tfp_shortage=log(Y_shortage)-alpha_l(i)*log(L_shortage)-alpha_m(i)*log(M_shortage)-alpha_k(i)*log(K(i))-alpha_e(i)*log(E_grid_shortage+E_self_shortage);
tfp_no_shortage=log(Y_no_shortage)-alpha_l(i)*log(L_no_shortage)-alpha_m(i)*log(M_no_shortage)-alpha_k(i)*log(K(i))-alpha_e(i)*log(E_grid_no_shortage+E_self_no_shortage);

diff_tfp_generator(i)=tfp_no_shortage-tfp_shortage;

Profit_Diff(i)=profit_generator-profit_no_generator;


profitgenerator(i)=profit_generator;
profitnogenerator(i)=profit_no_generator;


end


% fix up bogus observations
A=find(isinf(yshortage));

size(A)

yshortage(A)=zeros(length(A));
yshortage_prime(A)=zeros(length(A));
mshortage(A)=zeros(length(A));
mshortage_prime(A)=zeros(length(A));
lshortage(A)=zeros(length(A));
lshortage_prime(A)=zeros(length(A));
eselfshortage(A)=zeros(length(A));
eshortage_prime(A)=zeros(length(A));
egridshortage(A)=zeros(length(A));
eshortage_prime(A)=zeros(length(A));

y_no_generator(A)=zeros(length(A));
y_generator(A)=zeros(length(A));

e_grid_no_generator(A)=zeros(length(A));
e_grid_generator(A)=zeros(length(A));
diff_tfp_no_generator(A)=zeros(length(A));
diff_tfp_generator(A)=zeros(length(A));

Profit_shortage_prime(A)=zeros(length(A));
Profit_shortage(A)=zeros(length(A));

B=find(isnan(percent_output_loss));

size(B)

yshortage(B)=zeros(length(B));
yshortage_prime(B)=zeros(length(B));
mshortage(B)=zeros(length(B));
mshortage_prime(B)=zeros(length(B));
lshortage(B)=zeros(length(B));
lshortage_prime(B)=zeros(length(B));
eselfshortage(B)=zeros(length(B));
eshortage_prime(B)=zeros(length(B));
egridshortage(B)=zeros(length(B));
eshortage_prime(B)=zeros(length(B));

y_no_generator(B)=zeros(length(B));
y_generator(B)=zeros(length(B));

e_grid_no_generator(B)=zeros(length(B));
e_grid_generator(B)=zeros(length(B));
diff_tfp_no_generator(B)=zeros(length(B));
diff_tfp_generator(B)=zeros(length(B));

Profit_shortage_prime(B)=zeros(length(B));
Profit_shortage(B)=zeros(length(B));

C=isreal(percent_output_loss);

size(C)

yshortage(C)=zeros(length(C));
yshortage_prime(C)=zeros(length(C));
mshortage(C)=zeros(length(C));
mshortage_prime(C)=zeros(length(C));
lshortage(C)=zeros(length(C));
lshortage_prime(C)=zeros(length(C));
eselfshortage(C)=zeros(length(C));
eshortage_prime(C)=zeros(length(C));
egridshortage(C)=zeros(length(C));
eshortage_prime(C)=zeros(length(C));

y_no_generator(C)=zeros(length(C));
y_generator(C)=zeros(length(C));

e_grid_no_generator(C)=zeros(length(C));
e_grid_generator(C)=zeros(length(C));
diff_tfp_no_generator(C)=zeros(length(C));
diff_tfp_generator(C)=zeros(length(C));

Profit_shortage_prime(C)=zeros(length(C));
Profit_shortage(C)=zeros(length(C));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Output Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prediction_headers={   'year'  ,  'delta_PSP'  ,  'delta_PDPM'  , 'mult' ,   'K'   , 'alpha_m' ,   'alpha_l'  ,  'alpha_K', 'alpha_e'  , 'OMEGA',  ...
   'zero_generation_flag', 'p'  ,  'p_m'  ,  'p_l', 'Y_shortage', 'Y_shortage_prime', 'M_shortage',  'M_shortage_prime', 'L_shortage', ...
 'L_shortage_prime', 'E_self_shortage', 'E_self_shortage_prime', 'E_grid_shortage' ,'E_grid_shortage_prime', 'Pct Shortage', 'Messed Up Compute?',...
'profit_generator','profit_no_generator','profit_shortage','profit_shortage_prime','snic_hc','exog_gen_industry','panelgroup','scheme_dummy','grsale_defl','totpersons','qeleccons','fcapclose','matls_defl','y_no_generator','y_generator','e_grid_no_generator','e_grid_generator','diff_tfp_no_generator','diff_tfp_generator'};

% Giant Matrix with all the variables
OUTPRED=[theyear delta_psp delta_pdpm mult K alpha_m alpha_l alpha_k alpha_e OMEGA anyyearEprod p p_m p_l yshortage' yshortage_prime' mshortage' mshortage_prime' lshortage' lshortage_prime' eselfshortage' eselfshortage_prime' egridshortage' egridshortage_prime' percent_output_loss' messed_up_compute' profitgenerator' profitnogenerator' Profit_shortage' Profit_shortage_prime' snic_hc exog_gen_industry panelgroup scheme_dummy grsale_defl totpersons qeleccons fcapclose_defl matls_defl y_no_generator' y_generator' e_grid_no_generator' e_grid_generator' diff_tfp_no_generator' diff_tfp_generator'];

whos
size(prediction_headers)
size(OUTPRED) 
% Add Header Row
eval(thedirectory)

csvwrite_with_headers(outfilename,OUTPRED,prediction_headers)

cd ..
	
end
