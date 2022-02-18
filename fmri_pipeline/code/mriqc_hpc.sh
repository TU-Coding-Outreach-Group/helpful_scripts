#!/bin/sh
#PBS -l walltime=24:00:00
#PBS -N Relation-mriqc
#PBS -q normal
#PBS -l nodes=1:ppn=28
#PBS -m bae
#PBS -M tuk12127@temple.edu


# Import relevant modules
module load singularity

cd $PBS_O_WORKDIR


# This directory needs to be mapped since nodes do not have internet connection on Owlsnest
export SINGULARITYENV_TEMPLATEFLOW_HOME=~/work/relationship_knowledge/archive/templateflow

# Run mriqc
#singularity run -B ${SINGULARITYENV_TEMPLATEFLOW_HOME:-$HOME/.cache/templateflow}:/home/tuk12127/work/relationship_knowledge/archive/templateflow \
#    --cleanenv ~/mriqc_latest.sif \
#	~/work/relationship_knowledge \
#	~/work/relationship_knowledge/derivatives/mriqc participant \
#	--participant_label ${subjects} \
#	--nprocs=28 \
#	--verbose-reports


# Set up mriqc torque-launch
rm -f ~/scratch/job_scripts/cmd_mriqc_${PBS_JOBID}.txt
touch ~/scratch/job_scripts/cmd_mriqc_${PBS_JOBID}.txt

for subj in ${subjects}; do
    echo singularity run --cleanenv \
        -B ${SINGULARITYENV_TEMPLATEFLOW_HOME:-$HOME/.cache/templateflow}:/home/tuk12127/work/relationship_knowledge/archive/templateflow \
        ~/mriqc-0.15.1.simg \
        /home/tuk12127/work/relationship_knowledge \
        /home/tuk12127/work/relationship_knowledge/derivatives/mriqc participant \
        --participant_label ${subj} \
        --nprocs=10 \
        --no-sub \
        --verbose-reports >> ~/scratch/job_scripts/cmd_mriqc_${PBS_JOBID}.txt
done

# Run mriqc
torque-launch -p ~/scratch/job_scripts/chk_mriqc_${PBS_JOBID}.txt ~/scratch/job_scripts/cmd_mriqc_${PBS_JOBID}.txt

