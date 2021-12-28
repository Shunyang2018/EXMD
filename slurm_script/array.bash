#!/usr/bin/env bash
#author SYWANG
###reference: https://hpc.nih.gov/docs/job_dependencies.html
###reference: https://stackoverflow.com/questions/52248393/having-a-job-depend-on-an-array-job-in-slurm
#v3: can change qceims.in file.
#use this code by 'bash array.bash STUCTURE.tmol'
bin=/home/shunyang/bin
file=${1##*/}
structures=/home/shunyang/project/xstate_recalculate/input/
if [ ! $file ]; then
        echo "Usage: bash array.bash STUCTURE.tmol"
        exit
fi
#this parameter is for qceims.in
#you can leave it empty
in=''
in2=''
#########config part
#put this file and bin folder and your structure *.tmol under workdir
workdir=/home/shunyang/project/xstate_recalculate/
#the name used in /tmp/user/qme
user=swang
#i didn't have a config about these: you can change it in the slurm file
#task       ncpu    mem
#folder     16      120G
#each array 4       32G
#plot        4       8G
#########

echo $file
echo workdir: $workdir
echo user:$user
path=`echo $file|sed 's/.tmol//g'`
mkdir $path
anumber=`grep -v '^\s*$' $1 | wc -l`
#get number of trajectories by default setting, anumber*25
trajnumber=$(($(($anumber-2))*25))
opt=${file%.*}.opt
echo 'array_number'
echo $trajnumber
#collect slurm files and structures
cp ${bin}/folder.slurm $workdir$path/folder.slurm
cp ${bin}/array_mix.slurm $workdir$path/array.slurm
cp ${bin}/plot_mix.slurm $workdir$path/plot.slurm
cp $structures../mndo/$opt $workdir$path/mndo.opt 
cp $structures$file $workdir$path/structure.tmol
#go to the subfolder
cd $path
echo 'workpath'
pwd
#--exclude=all rafter nodes
#ex=rafter-[0,2,3,4,5,6,7,8,9,11,12,13,14,18,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48]
ex=[rafter-14,c6-84]
echo 'sub job1'
jid1=$(sbatch --job-name=$path --parsable folder.slurm $workdir $user $in $in2)
echo $jid1
echo 'sub job2'
jid2=$(sbatch  --dependency=afterok:$jid1 --job-name=$path --array=1-${trajnumber}%5 --parsable array.slurm $workdir $user $in)
#jid2=$(sbatch  --job-name=$path --array=1-${trajnumber}% --parsable array.slurm $workdir $user $in)
echo $jid2
echo 'sub job3'
sbatch --dependency=singleton --job-name=$path plot.slurm $workdir $user

