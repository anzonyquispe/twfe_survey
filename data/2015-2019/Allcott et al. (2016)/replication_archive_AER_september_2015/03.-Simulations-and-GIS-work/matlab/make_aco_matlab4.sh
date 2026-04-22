# Make Simulation for ACO Paper
# Full MakeFile
# Allan Collard-Wexler
# First Version: December 16 2013
# Current Version: November 4 2014
# Using the NYU HPC General Cluster
# Switch to Cobb-Douglas Production function. 

# Other work

# ----------------------------------------------------------------
# Production Function Coefficients Table
cd ~/Dropbox/India_Power_Shortages/AER_R1/
stata-se -b do	production_function_coefficients.do
cd ~/Dropbox/India_Power_Shortages/matlab



# ----------------------------------------------------------------
# Inputs: simulation_asi_inputs_october2014 from ASI Stata Work
# Directory
# 1. Bring in Data:
# ac418@dhcp-152-3-10-134.econ.duke.edu
rsync -avuz ac418@dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/simulation_asi_inputs_dec2014/*.*  /scratch/acw6/aco/matlab/simulation_asi_inputs_dec2014/
# Codebase too?
rsync -avuz ac418@dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/*.*  /scratch/acw6/aco/matlab/


	cd /scratch/acw6/aco/matlab/

# Prep Data
module load stata
stata-se do sim_prep_code1.do


# ----------------------------------------------------------------
# Matlab
# Submit Code to cluster
qsub -t 1992-2010 aco_sim_10.sh

# Market Clearing Prices
qsub -t 4-16 aco_sim_price_clearing2.sh

# Shortages
qsub -t 0,3,5,7,10,14,15,20 aco_sim_10_shortages.sh
qsub aco_sim_10_halve_shortages.sh

# Elasticity Computation
qsub -t 1,2 aco_sim_10_one_percent_decrease.sh

# CES Computation
qsub -t 1,5,8,9,10,11,12,15 aco_sim_ces_10.sh

# When done: analyze these files
while [ $n_jobs -le 0 ]; do

    n_jobs=$(qstat -t -a  -u acw6 | grep " s48 " | wc -l)
	sleep 1m
	# Waiting for these files to be done

done


# ----------------------------------------------------------------
# Elasticity Computation
matlab -r 'asi_simulation_elasticity(4.5,7)'

# ----------------------------------------------------------------
# Estimation of Costs of Self-Generation
stata-se -b do gen_returns_to_scale1.do

stata-se -b do estimate_cost_generators2.do



# ----------------------------------------------------------------
# Evaluation of Output (Table 14)
module load stata
stata-se -b do analysis_simulation11.do 


# Curtailment
stata-mp -b do voluntary_power_cut2.do 


# Ship back to the mothership:
rsync -avuz /scratch/acw6/aco/matlab/simulation_asi_inputs_dec2014/*.*  ac418@dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/simulation_asi_inputs_dec2014/

rsync -avuz /scratch/acw6/aco/matlab/*.* ac418@dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/

# Email me about it
echo "Dude, the matlab stuff in the India Power Shortages Project is done" | mailx -s "Computation India Power Shortagaes" collardwexler@gmail.com
# ----------------------------------------------------------------


end