#!/bin/bash

# input configs
anat=`jq -r '.anat' config.json`
post_freesurfer=`jq -r '.postfreesurfer' config.json`
warp="$post_freesurfer/MNINonLinear/xfms/standard2acpc_dc.nii.gz"
template="${FSLDIR}/data/atlases/Juelich/Juelich-prob-1mm.nii.gz"
hemisphere="lh rh"

mkdir -p rois

for HEMI in ${hemisphere}
do
	if [[ ${HEMI} == 'lh' ]]; then
		vol=103
	else
		vol=104
	fi
	
	# threshold LGN roi
	if [ ! -f LGN_${HEMI}.nii.gz ]; then	
		fslselectvols -i ${template} -o LGN_${HEMI}.nii.gz --vols=${vol}
	fi
	
	# threshold roi
	if [ ! -f LGN_${HEMI}_30.nii.gz ]; then	
		fslmaths LGN_${HEMI}.nii.gz -thr 30 LGN_${HEMI}_30.nii.gz
	fi
	
	# warp roi
	if [ ! -f LGN_${HEMI}_30_warp.nii.gz ]; then
		applywarp -v -i LGN_${HEMI}_30.nii.gz -r ${anat} -w ${warp} -o LGN_${HEMI}_30_warp.nii.gz
	fi

	# binarize
	if [ ! -f ./rois/LGN_${HEMI}_30.nii.gz ]; then
		fslmaths LGN_${HEMI}_30_warp.nii.gz -bin ./rois/LGN_${HEMI}_30.nii.gz
	fi
done

