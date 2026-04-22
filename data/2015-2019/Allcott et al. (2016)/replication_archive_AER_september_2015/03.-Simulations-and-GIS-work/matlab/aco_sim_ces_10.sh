#!/bin/csh -f

#PBS -V
#PBS -S /bin/tcsh
#PBS -N aco_simulation_10_CES
#PBS -l nodes=1:ppn=1,walltime=05:00:00
# PBS -M NetID@nyu.edu
# PBS -m abe

#  rsync -avuz dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/simulation_asi_inputs_dec2014/*.* /scratch/acw6/aco/matlab/simulation_asi_inputs_dec2014/
# rsync -avuz dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/*.* /scratch/acw6/aco/matlab/

cd /scratch/acw6/aco/matlab

# Mothership sync
# ssh preshared keys need to be set up for this one...
#rsync -avuz /scratch/acw6/aco/matlab/simulation_asi_inputs_dec2014/*.* dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/simulation_asi_inputs_dec2014/

# CES Simulations
/share/apps/matlab/2014a/bin/matlab -nodisplay -nojvm -r "asi_simulation11_ces(2005,4.5,7,$PBS_ARRAYID)"

# Mothership sync
rsync -avuz /scratch/acw6/aco/matlab/simulation_asi_inputs_dec2014/*.* dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/simulation_asi_inputs_dec2014/

exit 0;
