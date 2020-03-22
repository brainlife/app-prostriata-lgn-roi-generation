#!/bin/bash

# input configs
anat=`jq -r '.anat' config.json`
hemisphere="L R"

mkdir -p rois

for HEMI in ${hemisphere}
do
	if [[ ${HEMI} == 'L' ]]; then
		hemi_label='lh'
	else
		hemi_label='rh'
	fi

	fslmaths ${HEMI}.ProS_vol_1.25.nii.gz -thr 0.3 -bin ./rois/${hemi_label}.Pros_vol_1.25_clean.nii.gz
done

# generate LGN
. ./generate-lgn.sh
