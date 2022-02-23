#!/bin/sh
#PBS -l walltime=24:00:00
#PBS -N ll-fmriprep-newtemplate
#PBS -q normal
#PBS -l nodes=1:ppn=28

cd $PBS_O_WORKDIR

module load singularity

#this should be where your templates live; you should check to confirm it is; ensure file sizes are not 0 bytes
export SINGULARITYENV_TEMPLATEFLOW_HOME=/home/tuh38197/.cache/templateflow
                                 
rm -f archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
touch archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt

for subj in ${subjects}; do
    echo singularity run --cleanenv \
            # binding the directory where your templates live in your project directory to the /opt dir where
            # programs live (don't fully understand this step tbh; check file sizes in your archive/templateflow 
            # dir are again not 0 bytes)
            -B ~/work/learning_lemurs/archive/templateflow:/opt/templateflow \
            # make sure this is where your .simg lives and you have the correct version listed
            ~/work/learning_lemurs/archive/fmriprep-20.2.6.simg \
            ~/work/learning_lemurs ~/work/learning_lemurs/derivatives \
            participant --participant-label ${subj} \
            # this is for cohort 2 of the pediatric atlas (ages 4-8) with resolution at 2mm
            # you will get structural output in adult MNI space also; it's the default
            --output-spaces MNIPediatricAsym:res-2:cohort-2 \
            --fs-license-file ~/work/license.txt \
            --notrack \
            --stop-on-first-crash \
            --nthreads 8 --omp-nthreads 8 \
            --skip_bids_validation >> archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
done
                                                                         
torque-launch -p archive/job_scripts/chk_fmriprep_${PBS_JOBID}.txt archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
