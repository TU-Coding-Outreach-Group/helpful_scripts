#!/bin/sh
#PBS -l walltime=24:00:00
#PBS -N ll-fmriprep-newtemplate
#PBS -q normal
#PBS -l nodes=1:ppn=28

cd $PBS_O_WORKDIR

module load singularity

export SINGULARITYENV_TEMPLATEFLOW_HOME=/home/tuh38197/.cache/templateflow
                                 
rm -f archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
touch archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt

for subj in ${subjects}; do
    echo singularity run --cleanenv \
            -B ~/work/learning_lemurs/archive/templateflow:/opt/templateflow \
            ~/work/learning_lemurs/archive/fmriprep-20.2.6.simg \
            ~/work/learning_lemurs ~/work/learning_lemurs/derivatives \
            participant --participant-label ${subj} \
            --output-spaces MNIPediatricAsym:res-2:cohort-2 \
            --fs-license-file ~/work/license.txt \
            --notrack \
            --stop-on-first-crash \
            --nthreads 8 --omp-nthreads 8 \
            --skip_bids_validation >> archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
done
                                                                         
torque-launch -p archive/job_scripts/chk_fmriprep_${PBS_JOBID}.txt archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
