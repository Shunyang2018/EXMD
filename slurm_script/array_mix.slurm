#!/usr/bin/env bash
#---------------------------------------------
# QCEIMS Array SCRIPT
#---------------------------------------------
#SBATCH --partition=med   # partition to submit to [production, intel]
#SBATCH --nodes=1              # single node, anything more than 1 will not run
#SBATCH --ntasks=8                 # equivalent to cpus, stick to around 20 max on gc64, or gc128 nodes
#SBATCH --mem=20G                   # memory pool all cores, default is 2GB per cpu
#SBATCH --time=0-24:00:00          # expected time of completion in hours, minutes, seconds, default 1-day
#SBATCH --output=Array.%A_%a.out  # STDOUT
#SBATCH --error=Array.%A_%a.error   # STDERR
##SBATCH --mail-user=sywang@ucdavis.edu
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
	cp -rT /home/shunyang/Software/qceims4.0/ /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/


	# change the executable mode
	chmod +x /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/qceims

fi

cd /tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/
source /home/shunyang/Software/qceims4.0/.envrc
#set environment
ls -la
# make qceims, getres, plotms and mndo99 available
export PATH=$PATH:/tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}
export MOLCAS_MEM=32000

# ground state calculation
cp -rT $workdir$SLURM_JOB_NAME/TMPQCEIMS/TMP.${SLURM_ARRAY_TASK_ID} $workdir$SLURM_JOB_NAME/TMPQCEIMS/exTMP.${SLURM_ARRAY_TASK_ID}
cd $workdir$SLURM_JOB_NAME/TMPQCEIMS/TMP.${SLURM_ARRAY_TASK_ID}
#export Project=TMP.${SLURM_ARRAY_TASK_ID}
#export WorkDir=/tmp/$user/qms$SLURM_JOB_NAME${SLURM_ARRAY_TASK_ID}/

qceims -prod > qceims.out 2>&1
cat qceims.res >> ../../tmpqceims.res
# excited state calculation

cp $workdir$SLURM_JOB_NAME/mndo.opt $workdir$SLURM_JOB_NAME/TMPQCEIMS/exTMP.${SLURM_ARRAY_TASK_ID}
cp $workdir/qceims.in $workdir$SLURM_JOB_NAME/TMPQCEIMS/exTMP.${SLURM_ARRAY_TASK_ID}
cd $workdir$SLURM_JOB_NAME/TMPQCEIMS/exTMP.${SLURM_ARRAY_TASK_ID}

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
/home/shunyang/Software/mndo_2017/qceims_mndo -p -qcp /home/shunyang/Software/mndo_2017/ > qceims.out 2>&1
cat qceims.res >> ../../extmpqceims.res

echo ${SLURM_ARRAY_TASK_ID} $Project >> ../../validate.txt
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
