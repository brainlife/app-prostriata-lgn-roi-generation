#!/bin/bash

#set -x

# parse input configurations
template_left=`jq -r '.template_left' config.json`
template_right=`jq -r '.template_right' config.json`
surf=`jq -r '.freesurfer' config.json`
post_surf=`jq -r '.postfreesurfer' config.json`
#multi-rois
hemisphere="left right"

mkdir -p ./label ./freesurfer

cp -R $surf/ ./freesurfer/

export SUBJECTS_DIR=./freesurfer/

for HEMI in ${hemisphere}
	do
		if [[ ${HEMI} == 'left' ]]; then
			template=$template_left
			hemi_label='L'
			hemi_fsurf_label='lh'
			hemi_wb_label='LEFT'
		else
			template=$template_right
			hemi_label='R'
			hemi_fsurf_label='rh'
			hemi_wb_label='RIGHT'
		fi
		
		if [ ! -f ./template.${HEMI}.label.gii ]; then
			wb_command -cifti-separate ./templates/$template \
				COLUMN \
				-label CORTEX_${hemi_wb_label} \
				./template.${HEMI}.label.gii
		fi

		if [ ! -f ./template.${HEMI}.164k_fs_LR.label.gii ]; then
			wb_command -label-resample template.${HEMI}.label.gii \
				./templates/${hemi_label}.sphere.32k_fs_LR.surf.gii \
				$post_surf/MNINonLinear/*.${hemi_label}.sphere.164k_fs_LR.surf.gii \
				BARYCENTRIC \
				./template.${HEMI}.164k_fs_LR.label.gii
		fi

		if [ ! -f ./${HEMI}.native.label.gii ]; then
			wb_command -label-resample template.${HEMI}.164k_fs_LR.label.gii \
				$post_surf/MNINonLinear/*.${hemi_label}.sphere.164k_fs_LR.surf.gii \
				$post_surf/MNINonLinear/Native/*.${hemi_label}.sphere.MSMAll.native.surf.gii \
				BARYCENTRIC \
				./${HEMI}.native.label.gii
		fi

		if [ ! -f ./label/${hemi_fsurf_label}.${hemi_label}_ProS_ROI.label ]; then
			cp ./templates/${hemi_fsurf_label}.HCP-MMP1.annot \
			./freesurfer/output/label/${hemi_fsurf_label}.HCP-MMP1.annot
			
			mris_convert --annot ./${HEMI}.native.label.gii \
				$post_surf/MNINonLinear/Native/*.${hemi_label}.sphere.MSMAll.native.surf.gii \
				./freesurfer/output/label/${hemi_fsurf_label}.HCP-MMP1.annot

			mri_annotation2label --subject output \
				--hemi ${hemi_fsurf_label} \
				--annotation HCP-MMP1 \
				--outdir ./label/
		fi

		if [ ! -f ./brain.nii.gz ]; then
			mri_convert $surf/mri/brain.mgz ./brain.nii.gz
		fi

		if [ ! -f ./${hemi_label}.ProS.msm.label.nii.gz ]; then
			mri_label2vol --label ./label/${hemi_fsurf_label}.${hemi_label}_ProS_ROI.label \
				--temp brain.nii.gz \
				--identity \
				--subject output \
				--o ${hemi_label}.ProS.msm.label.nii.gz
		fi
	done
