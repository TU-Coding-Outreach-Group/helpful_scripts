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

rm -f archive/job_scipts/cmd_${PBS_JOBID}.txt
touch archive/job_scipts/cmd_${PBS_JOBID}.txt



export SINGULARITYENV_TEMPLATEFLOW_HOME=~/work/relationship_knowledge/archive/templateflow

singularity run -B ${SINGULARITYENV_TEMPLATEFLOW_HOME:-$HOME/.cache/templateflow}:/home/tuk12127/work/relationship_knowledge/archive/templateflow \
    --cleanenv archive/qsiprep-0.6.6.sif \
    /home/tuk12127/work/relationship_knowledge /home/tuk12127/work/relationship_knowledge/derivatives \
    participant \
	--participant-label ${subj} \
	--output-resolution 2.0 \
	--fs-license-file ~/work/license.txt \
	-w /home/tuk12127/work/relationship_knowledge/derivatives 
