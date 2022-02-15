#!/bin/sh
#PBS -l walltime=24:00:00
#PBS -N Relation-fmriprep
#PBS -q normal
#PBS -l nodes=1:ppn=8
#PBS -m bae
#PBS -M tuk12127@temple.edu
#PBS


# Import relevant modules
module load singularity

cd $PBS_O_WORKDIR

# This directory needs to be mapped since nodes do not have internet connection on Owlsnest
export SINGULARITYENV_TEMPLATEFLOW_HOME=~/work/relationship_knowledge/archive/templateflow

# Run fmriprep
singularity run -B ${SINGULARITYENV_TEMPLATEFLOW_HOME:-$HOME/.cache/templateflow}:/home/tuk12127/work/relationship_knowledge/archive/templateflow \
        --cleanenv archive/fmriprep.simg \
        /home/tuk12127/work/relationship_knowledge /home/tuk12127/work/relationship_knowledge/derivatives \
        participant \
        --participant-label ${subj} \
        --fs-license-file ~/work/license.txt \
        --notrack

# Run qsiprep
singularity run -B ${SINGULARITYENV_TEMPLATEFLOW_HOME:-$HOME/.cache/templateflow}:/home/tuk12127/work/relationship_knowledge/archive/templateflow \
    --cleanenv archive/qsiprep-0.6.6.sif \
    /home/tuk12127/work/relationship_knowledge /home/tuk12127/work/relationship_knowledge/derivatives \
    participant \
	--participant-label ${subj} \
	--output-resolution 2.0 \
	--fs-license-file ~/work/license.txt \
	-w /home/tuk12127/work/relationship_knowledge/derivatives 
