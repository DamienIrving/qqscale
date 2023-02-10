# Workflow for producing climate projection data using the CSIRO quantile delta change method

.PHONY: help

include ${CONFIG}

#PYTHON=/g/data/wp00/users/dbi599/miniconda3/envs/cih/bin/python
PYTHON=/g/data/xv83/dbi599/miniconda3/envs/qqscale/bin/python
PAPERMILL=/g/data/xv83/dbi599/miniconda3/envs/qqscale/bin/papermill
CODE_DIR=/g/data/wp00/shared_code/qqscale

## adjustment-factors: Calculate the QQ-scale adjustment factors
adjustment-factors : ${AF_PATH}
${AF_PATH} :
	mkdir -p ${OUTPUT_REF_DIR}
	${PYTHON} ${CODE_DIR}/calc_adjustment.py ${HIST_VAR} ${REF_VAR} $@ --hist_files ${HIST_DATA} --ref_files ${REF_DATA} --hist_time_bounds ${HIST_START}-01-01 ${HIST_END}-12-31 --ref_time_bounds ${REF_START}-01-01 ${REF_END}-12-31 --mapping ${MAPPING} --scaling ${SCALING} --input_hist_units ${HIST_UNITS} --input_ref_units ${REF_UNITS} --output_units ${OUTPUT_UNITS} --grouping ${GROUPING} --verbose

## quantiles : Calculate quantiles for the target data
quantiles : ${TARGET_Q_PATH}
${TARGET_Q_PATH} :
	mkdir -p ${OUTPUT_OBS_DIR}
	${PYTHON} ${CODE_DIR}/calc_quantiles.py ${TARGET_DATA} ${TARGET_VAR} 100 $@ --input_units ${TARGET_UNITS} --output_units ${OUTPUT_UNITS} --time_bounds ${TARGET_START}-01-01 ${TARGET_END}-12-31

## qqscale-projections: Calculate QQ-scaled climate projection data
qqscale-projections : ${QQ_PATH}
${QQ_PATH} : ${AF_PATH} ${TARGET_Q_PATH}
	${PYTHON} ${CODE_DIR}/apply_adjustment.py ${TARGET_DATA} ${TARGET_VAR} $< ${OUTPUT_GRID} $@ --time_bounds ${TARGET_START}-01-01 ${TARGET_END}-12-31 --mapping ${MAPPING} --scaling ${SCALING} --input_units ${TARGET_UNITS} --output_units ${OUTPUT_UNITS} --ref_time ${SSR} --verbose --reference_quantile_file $(word 2,$^) --reference_quantile_var ${TARGET_VAR}
	module load nco
	${PYTHON} /g/data/wp00/shared_code/attribute-editing/define_attributes.py $@ qqscale-cmip6 /g/data/wp00/shared_code/attribute-editing/global_attributes.yml --custom_global_attrs title="QQ Scaled Climate Variables, daily ${REF_VAR}" --del_var_attrs analysis_time analysis_version_number cell_methods frequency length_scale_for_analysis source history bias_adjustment --del_coord_attrs bounds --keep_attrs history xclim_version > metadata_fix.sh
	bash metadata_fix.sh
	rm metadata_fix.sh

## match-mean : Modify QQ-scaled data so mean change matches GCM
match-mean : ${QQ_MEAN_MATCH_PATH}
${QQ_MEAN_MATCH_PATH} : ${QQ_PATH}
	${PYTHON} ${CODE_DIR}/match_mean_change.py $< ${TARGET_VAR} $@ --output_units ${OUTPUT_UNITS} --hist_files ${HIST_DATA} --hist_var ${HIST_VAR} --input_hist_units ${HIST_UNITS} --ref_files ${REF_DATA} --ref_var ${REF_VAR} --input_ref_units ${REF_UNITS} --target_files ${TARGET_DATA} --input_target_units ${TARGET_UNITS} --hist_time_bounds ${HIST_START}-01-01 ${HIST_END}-12-31 --ref_time_bounds ${REF_START}-01-01 ${REF_END}-12-31 --target_time_bounds ${TARGET_START}-01-01 ${TARGET_END}-12-31 --scaling ${SCALING} --verbose

## validation : Create validation plots for QQ-scaled climate projection data
validation : ${VALIDATION_NOTEBOOK}
${VALIDATION_NOTEBOOK} : ${TEMPLATE_NOTEBOOK} ${AF_PATH} ${QQ_PATH} ${TARGET_Q_PATH}
	${PAPERMILL} -p adjustment_file $(word 2,$^) -p qq_file $(word 3,$^) -r hist_files "${HIST_DATA}" -r ref_files "${REF_DATA}" -r target_files "${TARGET_DATA}" -r target_q_file $(word 4,$^) -r hist_time_bounds "${HIST_START}-01-01 ${HIST_END}-12-31" -r ref_time_bounds "${REF_START}-01-01 ${REF_END}-12-31" -r target_time_bounds "${TARGET_START}-01-01 ${TARGET_END}-12-31" -p example_lat ${EXAMPLE_LAT} -p example_lon ${EXAMPLE_LON} -p example_month ${EXAMPLE_MONTH} -p hist_units ${HIST_UNITS} -p ref_units ${REF_UNITS} -p target_units ${TARGET_UNITS} -p output_units ${OUTPUT_UNITS} -p hist_var ${HIST_VAR} -p ref_var ${REF_VAR} -p target_var ${TARGET_VAR} $< $@

## help : show this message
help :
	@echo 'make [target] [-Bn] CONFIG=config_file.mk'
	@echo ''
	@echo 'valid targets:'
	@grep -h -E '^##' ${MAKEFILE_LIST} | sed -e 's/## //g' | column -t -s ':'

