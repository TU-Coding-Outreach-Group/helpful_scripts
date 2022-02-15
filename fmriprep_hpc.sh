#!/bin/sh
#PBS -l walltime=24:00:00
#PBS -N Relation-fmriprep
#PBS -q normal
#PBS -l nodes=1:ppn=8
#PBS -m bae
#PBS -M tuk12127@temple.edu


# Import relevant modules
module load singularity

cd $PBS_O_WORKDIR



export SINGULARITYENV_TEMPLATEFLOW_HOME=/home/fmriprep/.cache/templateflow

singularity run -B ~/work/relationship_knowledge/archive/templateflow:/home/fmriprep/.cache/templateflow \
        --cleanenv archive/fmriprep-20.1.1.simg  \
        /home/tuk12127/work/relationship_knowledge /home/tuk12127/work/relationship_knowledge/derivatives \
        participant \
        --participant-label ${subj} \
        --fs-license-file ~/work/license.txt \
        --notrack \
        --skip_bids_validation


