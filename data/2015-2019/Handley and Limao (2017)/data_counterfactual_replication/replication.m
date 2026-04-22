%this is a matlab batch file to run all of the quantification programs
%together in place


clear all
cd C:\replication

%   there are weighted data means passed to these matlab
%   programs from the STATA program
%   "replicate_NLS_quant_values_for_simulation.do"
%   that program must be run prior to running any m-files


%endogenous model over alpha = 0,2,4, 6 and import penetration CF
run replicate_iterative_transition_dynamics_full

% counterfactuals for 9 graphs of Figure 6

%plots over gamma and transition prices
run replicate_simulation_noWTO_newCF_final.m

%plots and quant over tau1
run replicate_simulate_over_risk_noWTO_final.m

%plots and quant over tau2, holding tau1 fixed at 2000 level
%note, must run simulate_over_risk_noWTO_final.m first to pass x- y-axis
% limits to graphs over tau2 with same depvars
run replicate_simulate_over_risk_noWTO_fulltau2_final.m

%run simulation over alpha to compute risk shares and robustness
%table A10
run replicate_simulate_over_alpha_robust.m

%clean up aux files

delete tau1graph_axis.mat
delete agg_effect_GE.mat

close all