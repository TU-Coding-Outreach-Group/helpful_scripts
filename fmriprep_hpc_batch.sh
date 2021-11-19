#!/bin/sh
#PBS -l walltime=24:00:00
#PBS -N Relation-fmriprep
#PBS -q normal
#PBS -l nodes=1:ppn=28
#PBS -m bae
#PBS -M tuk12127@temple.edu


# This script tries to run subjects optimally on the Owlsnest HPC
# It uses torque launch to run multiple subjects at the same time on a single node.
# You can run this script using qsub. But if you want to optimally use the computing resources
# (this will make the HPC people happy), you should run subjects in batches of six.
# Use the following command to run this script for batches of 6 subjects at a time 
# (i.e. this will create multiple jobs with 6 subjects per job).

# Define subject list
# subjects_list=(301 651 653 693 695 697 699 700 701 706 715 716 719 720 721 722 723 724 726 727 730 738 739 740 743 745 747 749 751 753 754 759 761 762 763 764 765 766 767)

# Run in batches of 6 subjects
#for ((i=0; i < ${#subjects_list[@]}; i+=6)); do
#	part=( "${subjects_list[@]:i:6}" )
#	qsub code/fmriprep_hpc_batch.sh -v subjects="${part[*]}"
#done




# Import relevant modules
module load singularity

cd $PBS_O_WORKDIR

# Set up for fmriprep
# This directory needs to be mapped since nodes do not have internet connection on Owlsnest
export SINGULARITYENV_TEMPLATEFLOW_HOME=/home/fmriprep/.cache/templateflow


# Set up fmriprep torque-launch
# Save command files in a subdirectory within your BIDS directory
rm -f archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
touch archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt

for subj in ${subjects}; do
    echo singularity run --cleanenv \
            # If running a more recent version of fmriprep, you might have to change the 
            # container directory to /opt/templateflow
            -B ~/work/relationship_knowledge/archive/templateflow:/home/fmriprep/.cache/templateflow \
            ~/fmriprep-20.1.1.simg \
            /home/tuk12127/work/relationship_knowledge /home/tuk12127/work/relationship_knowledge/derivatives \
            participant \
            --participant-label ${subj} \
            --output-spaces MNI152NLin2009cAsym T1w \
            --fs-license-file ~/work/license.txt \
            --notrack \
            --omp-nthreads 8 \
            --skip_bids_validation >> archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt
done

# Run fmriprep
torque-launch -p archive/job_scripts/chk_fmriprep_${PBS_JOBID}.txt archive/job_scripts/cmd_fmriprep_${PBS_JOBID}.txt


# Set up for mriqc
#export SINGULARITYENV_TEMPLATEFLOW_HOME=~/work/relationship_knowledge/archive/templateflow

# Set up mriqc torque-launch
#rm -f archive/job_scripts/cmd_mriqc_${PBS_JOBID}.txt
#touch archive/job_scripts/cmd_mriqc_${PBS_JOBID}.txt

#for subj in ${subjects}; do
#    echo singularity run --cleanenv \
#        -B ${SINGULARITYENV_TEMPLATEFLOW_HOME:-$HOME/.cache/templateflow}:/home/tuk12127/work/relationship_knowledge/archive/templateflow \
#        archive/mriqc_latest.sif \
#        /home/tuk12127/work/relationship_knowledge \
#        /home/tuk12127/work/relationship_knowledge/derivatives/mriqc participant \
#        --participant_label ${subj} \
#        --nprocs=4 \
#        --no-sub \
#        --verbose-reports >> archive/job_scripts/cmd_mriqc_${PBS_JOBID}.txt
#done

# Run mriqc
#torque-launch -p archive/job_scripts/chk_mriqc_${PBS_JOBID}.txt archive/job_scripts/cmd_mriqc_${PBS_JOBID}.txt


