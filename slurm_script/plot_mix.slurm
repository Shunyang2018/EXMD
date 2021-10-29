#!/bin/bash
#---------------------------------------------
# QCEIMS SLURM SCRIPT
#---------------------------------------------
#SBATCH --partition=med    # partition to submit to [production, intel]
#SBATCH --ntasks=1         # equivalent to cpus, stick to around 20 max on gc64, or gc128 nodes
#SBATCH --mem=2G      # memory pool all cores, default is 2GB per cpu
#SBATCH --time=0-0:30:00     # expected time of completion in hours, minutes, seconds, default 1-day
#SBATCH --output=plot%x_output.txt  # STDOUT
#SBATCH --error=plot%x_error.txt   # STDERR
#SBATCH --mail-type=END,FAIL
##SBATCH --mail-user=sywang@ucdavis.edu
workdir=$1
user=$2
# echo time and date
echo "Job started at " `date`
echo ''

# echo which node we are
echo  $HOSTNAME
echo ''

# echo the  job id
echo 'jobid: '${SLURM_JOB_ID}
echo ''

#pqceims results
DIR=TMPQCEIMS
cd $workdir$SLURM_JOB_NAME/
if [ ! -d "$DIR" ]; then
    echo "run qceims first!"
    exit
fi

# plotms - ground state
/home/shunyang/Software/mndo_2017/plotms_accurate
sed -i "s/TITLE=/TITLE=${SLURM_JOB_NAME}"/ result.jdx
mv result.jdx $SLURM_JOB_NAME.jdx
cp $SLURM_JOB_NAME.jdx ../$SLURM_JOB_NAME.jdx
#acc
sed -i "s/TITLE=/TITLE=${SLURM_JOB_NAME}"/ accuratemass.jdx
mv accuratemass.jdx acc$SLURM_JOB_NAME.jdx
cp acc$SLURM_JOB_NAME.jdx ../acc$SLURM_JOB_NAME.jdx
# ex
mv tmpqceims.res groundqceims.res
mv extmpqceims.res tmpqceims.res
/home/shunyang/Software/mndo_2017/plotms_accurate
sed -i "s/TITLE=/TITLE=ex${SLURM_JOB_NAME}"/ result.jdx
mv result.jdx ex$SLURM_JOB_NAME.jdx
cp ex$SLURM_JOB_NAME.jdx ../ex$SLURM_JOB_NAME.jdx
#acc-ex
sed -i "s/TITLE=/TITLE=ex${SLURM_JOB_NAME}"/ accuratemass.jdx
mv accuratemass.jdx accex$SLURM_JOB_NAME.jdx
cp accex$SLURM_JOB_NAME.jdx ../accex$SLURM_JOB_NAME.jdx

# clean
mv tmpqceims.res extmpqceims.res
mv groundqceims.res tmpqceims.res
mkdir arrayout
mv *-*.out arrayout
rm -rf /tmp/$user/qms$SLURM_JOB_NAME/
echo "Job ended at " `date`
