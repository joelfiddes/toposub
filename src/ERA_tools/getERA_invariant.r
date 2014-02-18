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
#etc
#download of 14years step=3hr 1 surface variable = 50mins


#set parameters
workd='/home/joel/data/era/surface'

date=	"'date'	:  '19890101',"
time=	"'time'    : '12'," #00/12 gives 3hr data for sfc retrieval ; 00/06/12/18 gives 6hr data for pl retrieval (3hr not possible)
grid=	"'grid'    : '0.75/0.75'," # resolution long/lat or grid single integer eg 80
step=	"'step'    : '0'," #3/6/9/12 gives 3hr data for sfc ; 0 gives 6hr data for pl retrieval (3hr not possible)
levtype="'levtype' : 'sfc'," # sfc=surface or pl=pressure level
type=	"'type'    : 'an'," #an=analysis or fc=forecast, depends on parameter - check on ERA gui.
param=	"'param'   : '129.128'," # parameter code - check on ERA gui.
area=	"'area'    : '48/6/46.5/9.5'," # region of interest N/W/S/E
target=	"'target'  : 'geop.grb'" # target, only grid allowed
pl=	"'levelist': '500/650/775/850/925/1000'"#pressure levels (mb)	
			#only written if levtype=pl
if(levtype=="'levtype' : 'pl'," ){pl=pl}else{pl=NULL}

#write python script
filename = file(paste(workd, "/download_script.py", sep=""), open="wt")

write("#!/usr/bin/python", filename)
write("from ecmwf import ECMWFDataServer", filename, append=TRUE)
write("server = ECMWFDataServer(", filename, append=TRUE)
write("'http://data-portal.ecmwf.int/data/d/dataserver/',", filename, append=TRUE)
write("'e048b71d037cc44d0772b0bc97a366ff',", filename, append=TRUE)
write("'joelfiddes@gmail.com'", filename, append=TRUE)
write("  )", filename, append=TRUE)
write("server.retrieve({", filename, append=TRUE)

write("'dataset' : 'interim_invariant',", filename, append=TRUE)

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
#setwd(folder)
files=list.files(folder, '.grb')
name=unlist(strsplit(files, '.grb'))


for (i in name){
system(paste('cdo -f nc copy ', paste(i,'.grb',sep=''),' ', paste(i,'.nc', sep=''),sep=''))

}
