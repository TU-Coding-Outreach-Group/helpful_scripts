# fmriprep Using the Pediatric Template
02/23/2022

__**Authors:**__ Susan Benear and Haroon Popal


## Description
This walkthrough covers how you can preprocess your data using the fmriprep pediatric template, on Owlsnest. This script is set up to run subjects as a batch, but can also be used to run single subjects at a time. It builds on steps that were covered in the [main fmriprep walkthrough](). Please refer to that walkthrough, prior to this one. 

The pediatric template can be used to preprocess and export your data in the MNI pediatric space. Adult brains are very different from kids brains. So depending on your dataset's age range, you might want to consider using a pediatric template. Here's the [list of age ranges](https://github.com/templateflow/tpl-MNIPediatricAsym/blob/bcf77616f547f327ee53c01dadf689ab6518a097/template_description.json#L22-L26) covered in this template.

**Note:** We had a lot of trouble figuring this out. Following the great documentation from fmriprep was still not getting this to work. So we had to do a lot of trial and error. Certain steps in this walkthrough are the result of us guessing and checking. We have no idea why these steps work. Might be a good idea to acquire 9 sheep and sacrifice them prior to running your script. Who knows.....


## Getting the pediatric template data

### Datalad
Datalad can be used to download the desired templates following their [instructions](https://www.templateflow.org/usage/archive/).

### Additional templates
Some additional templates are needed whenever you use any given template. This [script](https://github.com/nipreps/fmriprep/blob/master/scripts/fetch_templates.py) should help you get these additional templates. However, we just used datalad to get them. These additional templates are:
  - MNI152NLin2009cAsym
  - MNI152NLin6Asym
  - OASIS30ANTs
  - fsaverage
  - fsLR


## The code
Here is the whole script, copied from the fmriprep_hpc_pediatric.sh file:

```bash
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
```

### Singularity Templateflow Variable
First, set the SINGULARITYENV_TEMPLATEFLOW_HOME variable to your TU user specific directory like so:
```bash
export SINGULARITYENV_TEMPLATEFLOW_HOME=/home/tuh38197/.cache/templateflow
```

### Binding the templateflow directory
Bind the directory where your templates live in your project directory to the /opt dir where programs live. We don't fully understand this step. Check file sizes in your archive/templateflow directory to make sure they are not 0 bytes.
```bash
-B ~/work/learning_lemurs/archive/templateflow:/opt/templateflow \
```

### Reference the fmriprep singularity image
Make sure this is where your .simg lives and you have the correct version listed. Again, this walkthrough worked for fmriprep version 20.2.6. No promises for other versions.
```bash
~/work/learning_lemurs/archive/fmriprep-20.2.6.simg
```

### Specify the cohort
This code is for cohort 2 of the pediatric atlas (ages 4-8) with resolution at 2mm. You will get structural output in adult MNI space also; it's the default.
```bash
--output-spaces MNIPediatricAsym:res-2:cohort-2 \
```
