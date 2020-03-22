#!/bin/bash

# input configs
anat=`jq -r '.anat' config.json`
hemisphere="L R"

for HEMI in ${hemisphere}
do
	3dAllineate -input ${HEMI}.ProS.msm.label.nii.gz \
		-newgrid 1.25 \
		-prefix "${HEMI}.ProS_vol_1.25.nii.gz" \
		-final wsinc5 \
		-master $anat \
		-1Dparam_apply '1D: 12@0'\'
done

