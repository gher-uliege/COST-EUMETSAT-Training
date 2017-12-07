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

# Select Times:
cdo seltime,2017-10-05,2017-10-06,2017-10-07 $ncfile cmems_times_12-14.nc

# Select Dates:
cdo seldate,2017-10-05T00:00:00,2017-10-07T00:00:00 $ncfile cmems_dates.nc
cdo showdate cmems_dates.nc

# Select Months:
cdo selmon,11 $ncfile cmems_month11.nc
cdo showdate cmems_month11.nc

# Select Longitude-Latitude Subset:
cdo sellonlatbox,12.5,13.8,45.4,45.8 $ncfile cmems_ts.nc

# Select Index Box:
cdo selindexbox,3,20,30,45 $ncfile cmems_box.nc

# Select Single Point:
cdo selindexbox,21,21,32,32 $ncfile cmems_point.nc


#================== GRID REMAPINGS / GRIB to NETCDF CONVERSION =========

# ALADIN atmospheric model output grib in Lambert Conformal Conic grid:
# ALZ000_2017120621.grb

# Let's interpolate this GRIB to the LAT-LON grid:
	# Generate ALADIN LAT-LON GRID - you can do it manualy, i will be lazy:
	cdo griddes asmomo_2017120700+0057.grb > as_latlon.grid
	
	# BILINEAR remap from LCC to target.LATLON grid:
	cdo remapbil,as_latlon.grid AL000_2017120706.grb AL000_2017120706_latlon.grb

	# conver GRIB to NETCDF:
	cdo -f nc4 copy AL000_2017120706_latlon.grb AL000_2017120706_latlon.nc

	# Generate CMEMS target grid:
	cdo griddes $ncfile > cmems_latlon.grid

	# BILINEAR:
	# Perform BILINEAR remaping from LCC to target.grid:
	cdo remapbil,cmems_latlon.grid AL000_2017120706_latlon.nc AL000_2017120706_latlon_cmems.nc

#================== BASIC STATISTICS ===================================

# Average over Time
cdo timmean $ncfile cmems_timmean.nc

# Average over Space 
cdo fldmean $ncfile cmems_fldmean.nc

# Max over Time:
cdo timmax $ncfile cmems_timmax.nc

# Min over Time:
cdo timmin $ncfile cmems_timmin.nc

#================== BASIC ARITHMETICS ==================================

# Compute surface windspeed from (u,v).
# GRIB STANDARD: U = var33, V = var34
# SPEED = SQRT(U**2 + V**2)

# extract U:
cdo selname,var33 AL000_2017120706_latlon.nc U.nc

# Square U:
cdo sqr U.nc U2.nc

# extract V:
cdo selname,var34 AL000_2017120706_latlon.nc V.nc

# Square V:
cdo sqr V.nc V2.nc

# Sum of squares:
cdo add U2.nc V2.nc U2+V2.nc

# Windspeed:
cdo sqrt U2+V2.nc windspeed.nc

exit


