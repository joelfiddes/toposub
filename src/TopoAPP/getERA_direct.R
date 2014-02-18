root='/home/joel/data/era/1996_2012/'
dshp2=shapefile(paste(root,'/sim/_master/shp/eraDomainWGS.shp',sep=''))#domain shp for getting ERA


require(ncdf)
require(raster)


#===============================================================================
#				ERA FETCH PARAMETERS
#=============================================================================
parNameSurf=c()
parCodeSurf=c()

parNamePl=c( 'upl','vpl')
parCodePl=c(131,132)

#mf=read.table( '/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt', sep=',' ,header=T)
dd="19960801/to/20121231"# date range yyyymmdd

grd='0.75/0.75'	# resolution long/lat (0.75/0.75) or grid single integer eg 80
plev= '500/650/775/850/925/1000'	#pressure levels (mb), only written if levtype=pl

epath=paste(root,'sim/',sep='') #created manually
source(paste('~/src/hobbes/src/ERA_tools/getERA_src.r',sep=''))
source(paste('~/src/hobbes//src/TopoAPP/expSetup1.r', sep=''))
source(paste('~/src/hobbes//src/TopoAPP/getERAscript.r',sep='')) 
