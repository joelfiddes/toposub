#NEW SERVER SCRIPT: https://software.ecmwf.int/wiki/display/WEBAPI/Accessing+ECMWF+data+servers+in+batch?
#DETAILS: /home/joel/src/ERA_tools/eraBatchAccess.r

#fetches ERA interim data based on parameters set. Converts grib to netcdf
# workd = folder to both write 'download_script.py to and also download data to
# more info on parameters and other options and ECWMF retrieval system 'MARS' http://www.ecmwf.int/publications/manuals/mars/guide/

#vwind sfc fc 166.128
#uwind sfc fc 165.128
#2m dewpoint sfc fc 168.128
#2m air temp sfc fc 167.128
#ssrd sfc fc 169.128
#strd sfc fc 175.128
#totprecipi sfc fc 228.128
#convective precip sfc fc 143.128
#large scale precip sfc fc 142.128
#specific cloud liquid water 246.128
#TOA rad in 212.128
#surf pressure 134.128
#sealevel pressure 151.128
#vertical integral mass of atmosphere = 53.162
#total colum water fc 136.128
#total column ozone fc 206.128
#total column water vapour fc 137.128
#Surface net solar radiation, clear sky fc 210.128
#albedo an 174.128
#cloud press levels 248.128
#longwave surface net clear  211.128
#etc


#getERA<-function(levtype,param,target){

#===================================================================================================
#			NORMAL USE EDIT: time, step,levtype, type, param,target
#===================================================================================================

#set parameters
#workd='/home/joel/data/era/pressureLevels'
workd='/home/joel/data/era/surface'

date=	"'date'    : '19960101/to/20081231'," # date range yyyymmdd
#date=	"'date'    : '19960101/to/19960131'," # date range yyyymmdd TEST
time=	"'time'    : '00/12'," #00/12 gives 3hr data for sfc retrieval ; 00/06/12/18 gives 6hr data for pl retrieval (3hr not possible) ; 00/12 for accumulated
grid=	"'grid'    : '0.75/0.75'," # resolution long/lat or grid single integer eg 80
step=	"'step'    : '3/6/9/12'," #3/6/9/12 gives 3hr data for sfc ; 0 gives 6hr data for pl retrieval (3hr not possible)
levtype="'levtype' : 'sfc'," # sfc=surface or pl=pressure level
type=	"'type'    : 'fc'," #an=analysis or fc=forecast, depends on parameter - check on ERA gui.
param=	"'param'   : '211'," # parameter code - check on ERA gui.
area=	"'area'    : '48/6/46/10'," # region of interest N/W/S/E
#area=	"'area'    : '48.1/6/48 /6.1'," #TEST
target=	"'target'  : 'lwnetcs1BOX.grb'" # target, only grib allowed
pl=	"'levelist': '500/650/775/850/925/1000',"#pressure levels (mb)	
			#only written if levtype=pl
if(levtype=="'levtype' : 'pl'," ){pl=pl}else{pl=NULL}

#write python script
filename = file(paste(workd, "/download_script.py", sep=""), open="wt")

write("#!/usr/bin/python", filename)
write("from ecmwfapi import ECMWFDataServer", filename, append=TRUE)
write("server = ECMWFDataServer()", filename, append=TRUE)

write("server.retrieve({", filename, append=TRUE)

write("'dataset' : 'interim',", filename, append=TRUE)

write(date, filename, append=TRUE)
write("'stream'	 : 'oper',", filename, append=TRUE)
write(time, filename, append=TRUE)
write(grid, filename, append=TRUE)
write(step, filename, append=TRUE)
write(levtype, filename, append=TRUE)
write(type, filename, append=TRUE)
write("'class'   : 'ei',", filename, append=TRUE)
write(param, filename, append=TRUE)
write(area, filename, append=TRUE)
write(pl, filename, append=TRUE)
write(target, filename, append=TRUE)
write("    })", filename, append=TRUE)
  close(filename)
setwd(workd)

#run script, download data
system('./download_script.py')


#convert grib ->netcdf
# uses climate data operators (cdo) https://code.zmaw.de/projects/cdo

folder=workd
setwd(folder)
files=list.files(folder, '.grb')
name=unlist(strsplit(files, '.grb'))


for (i in name){
system(paste('cdo -f nc copy ', paste(i,'.grb',sep=''),' ', paste(i,'.nc', sep=''),sep=''))
}

