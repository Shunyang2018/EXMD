#!/bin/bash
#---------------------------------------------
# QCEIMS SLURM SCRIPT
#---------------------------------------------
#SBATCH --partition=med    # partition to submit to [production, intel]
##SBATCH --job-name=work  # Job name
#SBATCH --nodes=1               # single node, anything more than 1 will not run
#SBATCH --ntasks=8         # equivalent to cpus, stick to around 20 max on gc64, or gc128 nodes
#SBATCH --mem=16G      # memory pool all cores, default is 2GB per cpu
#SBATCH --time=0-48:00:00     # expected time of completion in hours, minutes, seconds, default 1-day
#SBATCH --output=%x_output.txt  # STDOUT
#SBATCH --mail-type=end,fail
#SBATCH --error=%x_error.txt   # STDERR
##SBATCH --mail-user=sywang@ucdavis.edu

#---------------------------------------------
# Example script for running QCEIMS on cluster
#---------------------------------------------
export OMP_NUM_THREADS=8,1
workdir=$1
user=$2
# echo time and date
echo "Job started at " `date`

# show hostname
echo $HOSTNAME
module load orca/3.0.3
# create custom qceims for a specific user // folder name is hardcoded for each user
#mkdir -p /tmp/$user/qms$SLURM_JOB_NAME/

# copy qceims work files to /qms$SLURM_JOB_NAME
# cp: omitting directory /share/fiehnlab/software/qceims/cluster/original-input
#cp -rT /home/shunyang/Software/qceims4.0/ /tmp/$user/qms$SLURM_JOB_NAME

# change the executable mode
# ln -s /tmp/$user/qms$SLURM_JOB_NAME/mndo99_20131011_intel64_composerxe-2013.4.183 /tmp/$user/qms$SLURM_JOB_NAME/mndo99
#chmod +x /tmp/$user/qms$SLURM_JOB_NAME/qceims

# make qceims, getres, plotms and mndo99 available
export PATH=$PATH:/home/shunyang/Software/qceims4.0/

cd /home/shunyang/Software/qceims4.0/
#set environment
source /home/shunyang/Software/qceims4.0/.envrc

# copy inchikey
# cp /share/fiehnlab/users/shunyang/qceims/project/structure/work-inchikey.txt /tmp/$user/work/

# copy mol
# change to workdir on tmp
cd $workdir$SLURM_JOB_NAME
# copy tmol to file "coord"
cp *.tmol coord

# start qceims MD (single core)
qceims
#echo -e $(4) > qceims.in
# run DFT in ORCA (single core)
qceims

# pack the TMPQCEIMS folder and remove it

# move result file back to share

# clean up old qms$SLURM_JOB_NAME dir and work folder

#back to share

# echo that job ended
echo "Job ended at " `date`


