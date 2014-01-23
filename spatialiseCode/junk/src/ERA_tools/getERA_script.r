#get ERA-I data script

#NEW SERVER: http://apps.ecmwf.int/datasets/data/interim_full_daily/
#NEW SERVER SCRIPT: https://software.ecmwf.int/wiki/display/WEBAPI/Accessing+ECMWF+data+servers+in+batch?
#DETAILS for server access: /home/joel/src/ERA_tools/eraBatchAccess.r
#REQUIRES: CDO (grb->nc conversion) https://code.zmaw.de/projects/cdo

# fetches ERA interim data based on parameters set. 
# Converts grib files to netcdf
# workd = folder to both write 'download_script.py to and also download data to
# more info on parameters and other options and ECWMF retrieval system 'MARS' http://www.ecmwf.int/publications/manuals/mars/guide/



#===============================================================================
#				SETUP
#=============================================================================
parNameSurf=c( 'dt', 'strd', 'ssrd', 'p', 't', 'toa')
parCodeSurf=c(168,175,169,228,167,212)

parNamePl=c('gpot','tpl','rhpl', 'upl','vpl')
parCodePl=c(129,130,157,131,132)

source('/home/joel/src/ERA_tools/getERA_src.r')
workd='/home/joel/data/era/mattertal'
mf=read.table( '/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt', sep=',' ,header=T)
dd="20101201/to/20130131"# date range yyyymmdd

#===============================================================================
#				GET BBOX
#===============================================================================
tol=0.1
n=max(mf$lat+tol)
s=min(mf$lat-tol)
e=max(mf$lon+tol)
w=min(mf$lon-tol)

#===============================================================================
#				GLOBAL PARAMETERS
#===============================================================================
grd='0.75/0.75'	# resolution long/lat (0.75/0.75) or grid single integer eg 80
ar= paste(n,w,s,e,sep='/')# region of interest N/W/S/E
plev= '500/650/775/850/925/1000'	#pressure levels (mb), only written if levtype=pl

#===============================================================================
#				 PARAMETERS SURFACE
#===============================================================================
t='00/12'#00/12 gives 3hr data for sfc retrieval ; 00/06/12/18 gives 6hr data for pl retrieval (3hr not possible) ; 00/12 for accumulated
stp='3/6/9/12'#3/6/9/12 gives 3hr data for sfc ; 0 gives 6hr data for pl retrieval (3hr not possible)
lt='sfc'# sfc=surface or pl=pressure level
typ='fc'#an=analysis or fc=forecast, depends on parameter - check on ERA gui.


#===============================================================================
#				GET DATA SURFACE
#===============================================================================
for( i in 1:length(parNameSurf)){
par= parCodeSurf[i]# parameter code - check on ERA gui.
tar=paste(parNameSurf[i],'.grb', sep='')
getERA(dd=dd, t=t, grd=grd, stp=stp, lt=lt,typ=typ,par=par,ar=ar,tar=tar,plev=plev,workd=workd)
}

#===============================================================================
#				 PARAMETERS PRESSURE LEVEL
#===============================================================================
t='00/06/12/18'#00/12 gives 3hr data for sfc retrieval ; 00/06/12/18 gives 6hr data for pl retrieval (3hr not possible) ; 00/12 for accumulated
stp='0'#3/6/9/12 gives 3hr data for sfc ; 0 gives 6hr data for pl retrieval (3hr not possible)
lt='pl'# sfc=surface or pl=pressure level
typ='an'#an=analysis or fc=forecast, depends on parameter - check on ERA gui.

#===============================================================================
#				GET DATA PRESSURE LEVEL
#===============================================================================
for( i in 1:length(parNamePl)){
par= parCodePl[i]# parameter code - check on ERA gui.
tar=paste(parNamePl[i],'.grb', sep='')
getERA(dd=dd, t=t, grd=grd, stp=stp, lt=lt,typ=typ,par=par,ar=ar,tar=tar,plev=plev,workd=workd)
}

