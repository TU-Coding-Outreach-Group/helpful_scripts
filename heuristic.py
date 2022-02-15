import os

def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes
def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where
    allowed template fields - follow python string module:
    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """
    t1w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_run-{item:03d}_T1w')
    func_task = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-relscenarios_run-{item:03d}_bold')
    fmap_bold =  create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_epi')
    dwi = create_key('sub-{subject}/{session}/dwi/sub-{subject}_{session}_run-{item:03d}_dwi')
    fmap_dwi_ap = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_dir-AP_dwi')
    fmap_dwi_pa = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_dir-PA_dwi')

    info = {t1w: [], func_task: [], fmap_bold: [], dwi: [], fmap_dwi_ap: [], fmap_dwi_pa: []}
    
    for idx, s in enumerate(seqinfo):
        if (s.dim1 == 256) and (s.dim2 == 256) and ('t1_mprage' in s.protocol_name):
            info[t1w].append(s.series_id)
        if (s.dim1 == 86) and (s.dim2 == 86) and (s.dim4 == 206) and ('func_task' in s.protocol_name):
            info[func_task].append(s.series_id)
        if (s.dim3 == 60) and (s.dim4 == 1) and ('gre_field_mapping' in s.protocol_name):
            info[fmap_bold] = [s.series_id]
        if (s.dim2 == 120) and (s.dim4 == 145) and ('hydi' in s.protocol_name):
            info[dwi].append(s.series_id)
        elif (s.dim2 == 120) and (s.dim4 == 2) and ('cmrr_fieldmapse' in s.protocol_name):
            if '_ap' in s.protocol_name:
                info[fmap_dwi_ap].append(s.series_id)
            elif '_pa' in s.protocol_name:
                info[fmap_dwi_pa].append(s.series_id)
    return info


