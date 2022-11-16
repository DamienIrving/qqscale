MODEL_VAR=pr
OBS_VAR=precip
OBS_UNITS="mm d-1"
MODEL_UNITS="kg m-2 s-1"
OUTPUT_UNITS="mm d-1"

ADAPT_THRESHOLD=0.5mm
ADAPT_OPT=--adapt_freq "0.5 mm d-1"

METHOD=multiplicative
MODEL=ACCESS-ESM1-5
OBS_DATASET=AGCD
EXPERIMENT=ssp370
RUN=r1i1p1f1
OBS_BASE_START=1990
OBS_BASE_END=2019
MODEL_BASE_START=1995
MODEL_BASE_END=2014
FUTURE_START=2035
FUTURE_END=2064


HIST_FILES := /g/data/fs38/publications/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/day/pr/gn/latest/pr_day_ACCESS-ESM1-5_historical_r1i1p1f1_gn_19500101-19991231.nc /g/data/fs38/publications/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/day/pr/gn/latest/pr_day_ACCESS-ESM1-5_historical_r1i1p1f1_gn_20000101-20141231.nc

FUTURE_FILES := /g/data/fs38/publications/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp370/r1i1p1f1/day/pr/gn/latest/pr_day_ACCESS-ESM1-5_ssp370_r1i1p1f1_gn_20150101-20641231.nc /g/data/fs38/publications/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp370/r1i1p1f1/day/pr/gn/latest/pr_day_ACCESS-ESM1-5_ssp370_r1i1p1f1_gn_20650101-21001231.nc

OBS_FILES := /g/data/xv83/agcd-csiro/precip/daily/precip-total_AGCD-CSIRO_r005_19000101-20220405_daily_space-chunked.zarr

AF_FILE=${MODEL_VAR}-qqscale-factors-${METHOD}_day_${MODEL}_${EXPERIMENT}_${RUN}_${MODEL_BASE_START}0101-${MODEL_BASE_END}1231_${FUTURE_START}0101-${FUTURE_END}1231_freq-adapt-${ADAPT_THRESHOLD}.nc
QQ_BASE=${MODEL_VAR}-qqscaled-${METHOD}_day_${OBS_DATASET}-${MODEL}_${EXPERIMENT}_${RUN}_${FUTURE_START}0101-${FUTURE_END}1231_freq-adapt


