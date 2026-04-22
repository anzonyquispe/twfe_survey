#!/bin/csh -f

#PBS -V
#PBS -S /bin/tcsh
#PBS -N aco_price_clearing
#PBS -l nodes=1:ppn=1,walltime=05:00:00
# PBS -M NetID@nyu.edu
# PBS -m abe

#  rsync -avuz dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/*.*. /scratch/acw6/aco/matlab/
cd /scratch/acw6/aco/matlab

/share/apps/matlab/2014a/bin/matlab -nodisplay -nojvm -r "asi_simulation10(2005,$PBS_ARRAYID,7)"
# Mothership sync
# ssh preshared keys need to be set up for this one...
rsync -avuz /scratch/acw6/aco/matlab/simulation_asi_inputs_dec2014/*.* dhcp-152-3-10-134.econ.duke.edu:~/Dropbox/India_Power_Shortages/matlab/simulation_asi_inputs_dec2014/
exit 0;
