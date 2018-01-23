#!/bin/bash

#=======================================================================
#========== CDO TUTORIAL ===============================================
#===========COST EUMETSAT TRAINING, HAMBURG FEB 2018====================
#===========Matjaz Licer (NIB), matjaz.licer@nib.si=====================
#=======================================================================

ncfile=sv03-med-ingv-tem-an-fc-d_1512631329207.nc

#================== NCDUMP =============================================
ncdump -h $ncfile
ncdump -v depth $ncfile

#================== CDO ================================================
#================== BASIC INFO =========================================

# Getting basic information about / from the NetCDF file
# [still, nothing beats "ncdump -h fname_0" for this]:
cdo sinfo $ncfile

# Getting the dates / timestamps from the NetCDF file:
cdo showdate $ncfile
cdo showtimestamp $ncfile

# Getting the grid description from NetCDF file:
cdo griddes $ncfile

#================== FILE OPERATIONS ====================================

# Split NetCDF to separate NetCDFs by vertical level:
cdo splitlevel $ncfile cmems_thetao_level_

# Split NetCDF to separate NetCDFs by day:
cdo splitday $ncfile cmems_thetao_day_

# Split NetCDF to separate NetCDFs by month:
cdo splitmon $ncfile cmems_thetao_month_

#================== FILE SELECTIONS ====================================

# Select NetCDF level by depth: 
	# First, list available depth:
	ncdump -v depth $ncfile
	# Second, select specific depth:
	cdo sellevel,5.464963 $ncfile cmems_level_5.464963.nc

# Select NetCDF level by level index: 
	cdo sellevidx,7 $ncfile cmems_levelidx_7.nc

# Select Timestep:
cdo seltimestep,12,13,14 $ncfile cmems_timesteps_12-14.nc

# Select Dates:
cdo seldate,2017-10-05T00:00:00,2017-10-07T00:00:00 $ncfile cmems_dates.nc
cdo showdate cmems_dates.nc

# Select Months:
cdo selmon,11 $ncfile cmems_month11.nc
cdo showdate cmems_month11.nc

# Select Season (JFMAMJJASOND):
cdo select,season=OND $ncfile mfs_2017_OND.nc
cdo showdate mfs_2017_OND.nc

# Select Longitude-Latitude Subset:
cdo sellonlatbox,12.5,13.8,45.4,45.8 $ncfile cmems_ts.nc

# Select Index Box:
cdo selindexbox,3,20,30,45 $ncfile cmems_box.nc

# Select Single Point:
cdo selindexbox,21,21,32,32 $ncfile cmems_point.nc

#================== GRID REMAPINGS ===================================

# Generate grid file from the original NetCDF:
cdo griddes sv03-med-ingv-tem-an-fc-d_1512631329207.nc > cmems_t_original_grid.txt

# Copy cmems_t_original_grid.txt to cmems_t_inset_grid.txt and modify it as you like
# for example:
#
# gridID 1
#
# gridtype  = lonlat
# gridsize  = 19600
# xsize     = 140
# ysize     = 140
# xname     = lon
# xlongname = "longitude"
# xunits    = "degrees_east"
# yname     = lat
# ylongname = "latitude"
# yunits    = "degrees_north"
# xfirst    = 12
# xinc      = 0.02
# yfirst    = 44
# yinc      = 0.02

# Nearest Neighbour remap:
cdo remapnn,cmems_t_inset_grid.txt sv03-med-ingv-tem-an-fc-d_1512631329207.nc sv03-med-ingv-temp_inset.nc

# Bilinear remap:
cdo remapbil,cmems_t_inset_grid.txt sv03-med-ingv-tem-an-fc-d_1512631329207.nc sv03-med-ingv-temp_inset.nc


#================== GRIB TO NETCDF CONVERSION ===================================

# Very often, Met Office data comes in GRIB format. Like this one:
# asmomo_2017120700+0057.grb

# You might need to convert this to NetCDF, and CDO gives you this possibility:
cdo -f nc copy asmomo_2017120700+0057.grb asmomo_2017120700+0057.nc


#================== BASIC STATISTICS ===================================

# Average over Time
cdo timmean $ncfile cmems_timmean.nc

# Average over Space 
cdo fldmean $ncfile cmems_fldmean.nc

# Max over Time:
cdo timmax $ncfile cmems_timmax.nc

# Min over Time:
cdo timmin $ncfile cmems_timmin.nc

# Linear Regression for a specific Season:
cdo trend mfs_2017_OND.nc k0_mfs_2017_OND.nc k1_mfs_2017_OND.nc

#================== BASIC ARITHMETICS ==================================

# Compute surface windspeed from (u,v).
# GRIB STANDARD: U = var33, V = var34
# SPEED = SQRT(U**2 + V**2)

# extract U:
cdo selname,var33 asmomo_2017120700+0057.nc U.nc

# Square U:
cdo sqr U.nc U2.nc

# extract V:
cdo selname,var34 asmomo_2017120700+0057.nc V.nc

# Square V:
cdo sqr V.nc V2.nc

# Sum of squares:
cdo add U2.nc V2.nc U2+V2.nc

# Windspeed:
cdo sqrt U2+V2.nc windspeed.nc


#================== COMBINING OPERATORS ==============================

# Extract December Data from a Single Point and compute Linear Trend at its Location:
# Intermediate output files are not created, only streamed:

# Without chaining the operators:
# cdo selindexbox,21,21,32,32 $ncfile tmp1.nc
# cdo selmon,12 tmp1.nc tmp2.nc
# cdo trend tmp2.nc tmp_k0.nc tmp_k1.nc
# rm tmp1.nc tmp2.nc

# WITH chaining of operators:
cdo trend -selmon,12 -selindexbox,21,21,32,32 $ncfile point_k0.nc point_k1.nc
#   3rd op  2nd op         1st operation      input        final outputs