#!/usr/bin/env bash
#---------------------------------------------
# QCEIMS Array SCRIPT
#---------------------------------------------
#SBATCH --partition=intel   # partition to submit to [production, intel]
### SBATCH --nodelist=             # calling a specific gaggle node on [intel]
#SBATCH --exclude=gaggle-[0,1]
#SBATCH --job-name=om2-v12         # Job name
#SBATCH --nodes=1              # single node, anything more than 1 will not run
#SBATCH --ntasks=1                 # equivalent to cpus, stick to around 20 max on gc64, or gc128 nodes
#SBATCH --mem=5G                   # memory pool all cores, default is 2GB per cpu
#SBATCH --time=7-960:00:00          # expected time of completion in hours, minutes, seconds, default 1-day
#SBATCH --output=Array.%A_%a.out  # STDOUT
#SBATCH --error=Array.%A_%a.error   # STDERR
##SBATCH --mail-user=sywang@ucdavis.edu
unlog
aklog
export OMP_NUM_THREADS=8,1
workdir=$1
user=$2
if [ -z $user ]
then
user=swang
echo "user" $user
fi
#module load orca/4.0.0.2
if [ -z $workdir ]
then
workdir="${pwd}"
echo "default workdir" $workdir
fi
cd $workdir$SLURM_JOB_NAME/TMPQCEIMS/TMP.${SLURM_ARRAY_TASK_ID}
# echo time and date
echo "Job started at " `date`
echo ''
module load mndo99/2017

# echo which node we are
echo  $HOSTNAME
echo ''

# echo the CPU
lscpu
echo ''

# echo the  job id
echo 'jobid: '${SLURM_JOB_ID}
echo ''


# check if qceims is already installed on the node, if not install it
if [ ! -f /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/qceims ]; then

	# create custom qceims for a specific user // folder name is hardcoded for each user
	mkdir -p /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/

	# copy qceims work files to /qms
	cp /share/fiehnlab/users/shunyang/xstate_project/qceims/molcas/qceims_mndo /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/qceims


	# change the executable mode
	chmod +x /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/qceims

fi

cd /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/
#set environment
ls -la
# make qceims, getres, plotms and mndo99 available
export PATH=$PATH:/tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}
export MOLCAS_MEM=32000

# copy data from share to single node
cd $workdir$SLURM_JOB_NAME/TMPQCEIMS/TMP.${SLURM_ARRAY_TASK_ID}
export Project=TMP.${SLURM_ARRAY_TASK_ID}
export WorkDir=/tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/
cp $workdir$SLURM_JOB_NAME/mndo.opt $workdir$SLURM_JOB_NAME/TMPQCEIMS/TMP.${SLURM_ARRAY_TASK_ID}
cp $workdir$SLURM_JOB_NAME/qceims.in $workdir$SLURM_JOB_NAME/TMPQCEIMS/TMP.${SLURM_ARRAY_TASK_ID}

# cd into same dir
dft=false
if $dft ;then
echo orca > qceims.in
echo mo-orca >> qceims.in
echo pbe0 >> qceims.in
echo SV\(P\) >> qceims.in
echo ip-orca >> qceims.in
fi

# run qceims production "> qceims.out 2>&1"
qceims -p -qcp /software/mndo99/2017/lssc0-linux/ > qceims.out 2>&1

# wait
wait
rm RUNNING
touch FINISHED
# collect output back to share

# remove the single directory
rm -rf /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/
# tell its finished
# touch FINISHED
# echo that job ended
echo "Job ended at " `date`
