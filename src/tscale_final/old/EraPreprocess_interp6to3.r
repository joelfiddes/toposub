#ERA Preprocess 3 - interpolate all 6h data to 3h
#pressure level data and dewpoint surface (dont know why this is at 6h)
#T,Rh, U,V, d2m

#=======================================================================================================
#			PACKAGES
#=======================================================================================================
require(ncdf)

#=======================================================================================================
#			SRC
#=======================================================================================================
source('~/src/TopoScale/tools_src.r')

#=======================================================================================================
#			DIRECTORIES
#=======================================================================================================
outRoot='/home/joel/data/tscale_final/EraMet/interp6to3'

#=======================================================================================================
#			INFILES
#=======================================================================================================
infile='/home/joel/data/era/pressureLevels/tair/outfile.nc'
var="t"
nc=open.ncdf(infile)
dat = get.var.ncdf( nc,var)

var="time"
nc=open.ncdf(infile)
time = get.var.ncdf( nc,var)
#=======================================================================================================
#			INTERPOLATE 6H TIME VECTOR TO 3H TIME VECTOR
#=======================================================================================================
#interpolates data at 6h 00UTC, 06UTC,12UTC, 18UTC -> 3h 00UTC, 03UTC, 06UTC, 09UTC, 12UTC, 15UTC, 18UTC, 21UTC
#WARNING: final 21UTC missing in some cases if 6h data  eg 01011996 00UTC -> 31122008 18UTC (should download +1 day in future to allow final 21UTC interpolation point)

#INTERPOLATE TIME
time2=interp6to3(time) #accepts vector
origin='1900-01-01'
z <- time2*60*60 #make seconds
dates<-ISOdatetime(origin,0,0,0,0,0,tz='UTC') + z #dates sequence

#=======================================================================================================
#			INTERPOLATE 6H DATA TO 3H DATA
#=======================================================================================================
#GENERAL
#dat= multidim variable timeseries to be aggregated
#MARGIN = dimensions to remain constant (ie FUNCTION NOT APPLIED)
#FUN= FUNCTION TO APPLY OVER 

##EXAMPPLE
#str(dat)
##num [1:7, 1:4, 1:6, 1:20456] 
##APPLY TO DIM 4

#FUNCTION
z=apply(X=dat, MARGIN=c(1,2,3), FUN=interp6to3)

