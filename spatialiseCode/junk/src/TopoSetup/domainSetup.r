t1=Sys.time()
#======================================================================================
#				EXPERIMENT DIRECTORY
#======================================================================================
epath='/home/joel/experiments/alpsSim2/' #created manually
master=paste(epath,'_master/',sep='')#created manually
datRoot=paste(master,'/eraDat/',sep='')#needed only when getERA=T
dir.create(datRoot)
getERA=F
#======================================================================================
#				SOURCE
#======================================================================================
source('/home/joel/src/code_toposub/toposub_src.r')
source('/home/joel/src/TopoSetup/toposub_crisp.r')
source('/home/joel/src/TopoSetup/toposub_fuzzy.r')

source('/home/joel/src/TopoScale/tscale_final/tscale_src.r')
source('/home/joel/src/TopoScale/tscale_final/surfFluxSrc.r')
source('/home/joel/src/TopoScale/tscale_final/solar_functions.r')
source('/home/joel/src/TopoScale/tscale_final/solar.r')
source('/home/joel/src/TopoScale/tscale_final/gt_control.r')
source('/home/joel/src/ERA_tools/getERA_src.r')
#=======================================================================================================
#			PACKAGES
#=======================================================================================================
require(ncdf)
require(raster)
require(rgdal)
require(insol)
require(IDPmisc)
require(colorRamps)


######################################################################################################
#				SETUP 
#				SETUP 
#				SETUP 
#				SETUP 
#				SETUP 
######################################################################################################

#=======================================================================================================
#			PARAMETERS TO SET -TSCALE
#=======================================================================================================
startDate='2008-12-03 00:00:00'
endDate='2010-01-04 00:00:00'
pfactor=0.25 #liston parameter
#=======================================================================================================
#			PARAMETERS TO SET -T
#=======================================================================================================
file1<-'/out/ground.txt'
file2<-'/out/surface.txt'
beg <- "01/01/2009 00:00:00" #start cut of data timeseries
end <- "01/01/2010 00:00:00" #end cut data timeseries
cols="X100.000000"
Nclust=100
rad=TRUE

#=======================================================================================================
#			DIRECTORIES/PATHS TO SET
#=======================================================================================================
exePath='/home/joel/src/geotop/'
exe='./geotop1.225-13'
#location of master geotopinpts
#metaFile='/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt' #points meta file c(id,ele,slp, asp, sky, lat,lon)
#eraBoxEle=read.table('/home/joel/data/transformedData/eraBoxEle.txt', header=T, sep=',') #preprocessed grid ele (slow)
#optional function

#=======================================================================================================
#			DIRECTORIES RELATIVE
#=======================================================================================================
tmp=paste(epath,'tmp/',sep='')
outRootPl=paste(tmp,'pressurelevel/',sep='')
outRootSurf=paste(tmp,'surface/',sep='')
outRootmet=paste(tmp,'all/',sep='')
dir.create(tmp,recursive=T)
dir.create(outRootPl)
dir.create(outRootSurf)
dir.create(outRootmet)

#=======================================================================================================
#			INFILES
#=======================================================================================================
#PRESSURE LEVEL FIELDS (AND DEWT)
infileG=paste(datRoot, 'gpot.nc',sep='')
infileT=paste(datRoot, 'tpl.nc',sep='')
infileRh=paste(datRoot, 'rhpl.nc',sep='')
infileU=paste(datRoot, 'upl.nc',sep='')
infileV=paste(datRoot, 'vpl.nc',sep='')
infileD=paste(datRoot, 'dt.nc',sep='')

#SURFACE FIELDS
lwFile=paste(datRoot, 'strd.nc',sep='')
swFile=paste(datRoot, 'ssrd.nc',sep='')
pFile=paste(datRoot, 'p.nc',sep='')
tFile=paste(datRoot, 't.nc',sep='')
toaFile=paste(datRoot, 'toa.nc',sep='')

#other
step=3 #time step of accumulated fields

#======================================================================================
#				INFILES
#======================================================================================
ddem=raster('/home/joel/experiments/alpsSim/_master/ASTERv2_UTM32N.tif')#domain dem
dasp=raster('/home/joel/experiments/alpsSim/_master/asp')
dslp=raster('/home/joel/experiments/alpsSim/_master/slp')
dsky=raster('/home/joel/experiments/alpsSim/_master/sky')
dshp=shapefile('/home/joel/experiments/alpsSim/_master/eraDomainUTM32.shp')#domain shp
dshp2=shapefile('/home/joel/experiments/alpsSim/_master/eraDomainWGS.shp')#domain shp
#======================================================================================
#				NUMBER SIMULATION BOXES
#======================================================================================
nbox=length(dshp)
#nbox=1
#======================================================================================
#				SET UP SIMULATION DIRECTORIES
#======================================================================================
for( i in 1:nbox){
spath=paste(epath, '/box', i,sep='') #simulation path
dir.create(spath)
opath=paste(epath, '/box', i,'/out',sep='') #simulation output path
dir.create(opath)
dir.create(paste(spath, '/tmp', sep='')) #tmp folder
}

#======================================================================================
#				SEGMENT TOPOGRAPHY BY BOX
#======================================================================================

for( i in 1:nbox){
spath=paste(epath, '/box', i,sep='') #simulation path
demC=crop(ddem, dshp[i,])
daspC=crop(dasp, dshp[i,])
dslpC=crop(dslp, dshp[i,])
dskyC=crop(dsky, dshp[i,])
writeRaster(demC, paste(spath,'/ele.tif',sep=''), NAflag=-9999, overwrite=T) #(tif is smallest format half of size sdat etc)
writeRaster(daspC, paste(spath,'/asp.tif',sep=''), NAflag=-9999,overwrite=T)
writeRaster(dslpC, paste(spath,'/slp.tif',sep=''), NAflag=-9999,overwrite=T)
writeRaster(dskyC, paste(spath,'/svf.tif',sep=''), NAflag=-9999,overwrite=T)
}

######################################################################################################
#				TOPOSUB	
#				TOPOSUB		
#				TOPOSUB		
#				TOPOSUB	
######################################################################################################
#======================================================================================
#				TOPOSUB CRISP
#======================================================================================

for( i in 1:nbox){
spath=paste(epath, '/box', i,sep='') #simulation path



#set imulation paths
eroot_loc1 <- epath
esPath <- spath#experiment path #spath

#set up folders
dir.create(paste(esPath, '/fuzRst', sep=''))
dir.create(paste(esPath, '/rec', sep=''))

#input locations
demLoc=paste(spath,'/ele.tif',sep='')
predRoot=esPath

#set tmp directory for raster package
setOptions(tmpdir=paste(spath, '/tmp', sep=''))


#==============================================================================
# 			TOPOSUB PARAMETERS
#==============================================================================

#key parameters
Nclust =Nclust#<-Nclust [K]
iter.max=20# clusters if prescribed#check 000029 for 100 iter heavy averaging somehow
nRand=100000#sample size
fuzzy.e=1.4 #[M]
nstart1=10 # nstart for sample kmeans [find centers]
nstart2=1 #nstart for entire data kmeans [apply centers]
thresh_per=0.001 # needs experimenting with

# input predictors
predNames<-c('ele', 'slp', 'asp', 'svf') #[PRED]
predFormat='.tif'

#switches
findn=0
samp_reduce=TRUE#rm insig sample, redist members

#experimental parameters [normal behaviour all = FALSE]
randomKmeansInit=FALSE#

#method to concatenate
"&" <- function(...) UseMethod("&") 
"&.default" <- .Primitive("&") 
"&.character" <- function(...) paste(...,sep="") 



#==============================================================================
# TopoSUB preprocessor
#==============================================================================

#make stack of input predictor ==> read in random sample to improve scalability
gridmaps=stack_raster(demLoc=demLoc, predNames=predNames, predRoot=predRoot, predFormat=predFormat)

#check inputs slp/asp in degrees and correct if necessary (careful if applied in flat place!)
if(rad==T){
	gridmaps$asp = radtodeg(gridmaps$asp)
}
if(rad==T){
	gridmaps$slp = radtodeg(gridmaps$slp)
}

#na to numeric (-1) (does this work)
gridmaps@data = natonum(x=gridmaps@data,predNames=predNames ,n=-1)

#decompose aspect
res=aspect_decomp(gridmaps$asp)
res$aspC->gridmaps$aspC
res$aspS->gridmaps$aspS

#define new predNames (aspC, aspS)
allNames<-names(gridmaps@data)

#sample inputs
#need to generalise to accept 'data' argument
samp_dat<-sampleRandomGrid( nRand=nRand, predNames=predNames)

if (findn==1){Nclust=findN(scaleDat=scaleDat, nMax=1000,thresh=0.05)}

#make scaled (see r function 'scale()')data frame of inputs 
scaleDat_samp= simpleScale(data=samp_dat, pnames=predNames)

#random order of kmeans init conditions (variable order) experiment
if(randomKmeansInit==T){
cbind(scaleDat_samp[5],scaleDat_samp[4], scaleDat_samp[3], scaleDat_samp[2], scaleDat_samp[1])->scaleDat_samp
}

#kmeans on sample
clust1=Kmeans(scaleDat=scaleDat_samp,iter.max=iter.max,centers=Nclust, nstart=nstart1)

#scale whole dataset
scaleDat_all= simpleScale(data=gridmaps@data, pnames=predNames)

#kmeans whole dataset
clust2=Kmeans(scaleDat=scaleDat_all,iter.max=iter.max,centers=clust1$centers, nstart=nstart2)

#remove small samples, redist to nearestneighbour attribute space
if(samp_reduce==TRUE){
clust3=sample_redist(pix= length(clust2$cluster),samples=Nclust,thresh_per=thresh_per, clust_obj=clust2)# be careful, samlple size not updated only clust2$cluster changed
}else{clust2->clust3}

#confused by these commented out lines
#gridmaps$clust <- clust3$cluster
#write.asciigrid(gridmaps["landform"], paste(esPath,"/landform_",Nclust,".tif",sep=''),na.value=-9999)

#make map of clusters 
gridmaps$landform <- as.factor(clust3$cluster)
writeRaster(raster(gridmaps["landform"]), paste(esPath,"/landform_",Nclust,".tif",sep=''),NAflag=-9999,overwrite=T)

asp=meanAspect(dat=gridmaps@data, agg=gridmaps$landform)

fun=c('mean', 'sd', 'sum')
for (FUN in fun){
	samp=sampleCentroids(dat=gridmaps@data,predNames=predNames, agg=gridmaps$landform, FUN=FUN)
	assign(paste('samp_', FUN, sep=''), samp)
}
samp_mean$asp<-asp
#issue with sd and sum of aspect - try use 'circular'

#write to disk for cmeans(replaced by kmeans 2)
write.table(samp_mean,paste(esPath, '/samp_mean.txt' ,sep=''), sep=',', row.names=FALSE)
write.table(samp_sd,paste(esPath, '/samp_sd.txt' ,sep=''), sep=',', row.names=FALSE)

#make driving topo data file	
lsp <- listpointsMake(samp_mean=samp_mean, samp_sum=samp_sum)
write.table(lsp,paste(esPath, '/listpoints.txt' ,sep=''), sep=',', row.names=FALSE)
#make horizon files
hor(listPath=esPath)
}


#======================================================================================
#				TOPOSUB INFORMED -option
#======================================================================================

#======================================================================================
#				TOPOSUB FUZZY 	-option
#======================================================================================
#toposub_fuzzym(Nclust,esPath)

#======================================================================================
#				GET TOP N FUZZY MEMBERS 	-option
#=====================================================================================
#TopNmembers( esPath=esPath, Nclust=Nclust,i)


######################################################################################################
#				GET ERA
#				GET ERA
#				GET ERA
#				GET ERA
######################################################################################################
#get ERA-I data script

#NEW SERVER: http://apps.ecmwf.int/datasets/data/interim_full_daily/
#NEW SERVER SCRIPT: https://software.ecmwf.int/wiki/display/WEBAPI/Accessing+ECMWF+data+servers+in+batch?
#DETAILS for server access: /home/joel/src/ERA_tools/eraBatchAccess.r
#REQUIRES: CDO (grb->nc conversion) https://code.zmaw.de/projects/cdo

# fetches ERA interim data based on parameters set. 
# Converts grib files to netcdf
# workd = folder to both write 'download_script.py to and also download data to
# more info on parameters and other options and ECWMF retrieval system 'MARS' http://www.ecmwf.int/publications/manuals/mars/guide/

if(getERA==T){

#===============================================================================
#				SETUP
#=============================================================================
parNameSurf=c( 'dt', 'strd', 'ssrd', 'p', 't', 'toa')
parCodeSurf=c(168,175,169,228,167,212)

parNamePl=c('gpot','tpl','rhpl', 'upl','vpl')
parCodePl=c(129,130,157,131,132)


workd=datRoot
#mf=read.table( '/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt', sep=',' ,header=T)
dd="20081201/to/20100106"# date range yyyymmdd

#===============================================================================
#				GET BBOX FROM MF
#===============================================================================
#tol=0.1
#n=max(mf$lat+tol)
#s=min(mf$lat-tol)
#e=max(mf$lon+tol)
#w=min(mf$lon-tol)

#===============================================================================
#				GET BBOX FROM SHP
#===============================================================================
tol=0.7 #must be greater than 0.5*box resolution to get correct extent
xtent=extent(dshp2)
n=xtent@ymax-tol
s=xtent@ymin+tol
e=xtent@xmax-tol
w=xtent@xmin+tol

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

#===============================================================================
#				CLEAN UP GRIB FILES
#===============================================================================
grb=list.files(workd, pattern='.grb')

for(i in 1:length(grb)){
system(paste('rm ',workd,'/',grb[i],sep=''))
}

}
######################################################################################################
#				TOPOSCALE	
#				TOPOSCALE	
#				TOPOSCALE	
#				TOPOSCALE
######################################################################################################
#======================================================================================
#				TOPOSCALE
#=====================================================================================






########################################################################################################
#													
#				PREPROCESS PRESSURE LEVELS 
#									
########################################################################################################
#interpolate to 3h timestep
#includes dewT (surface field) which comes at 6h

#=======================================================================================================
#			INTERPOLATE 6H FIELDS TO 3H
#=======================================================================================================

#INTERPOLATE TIME
nc=open.ncdf(infileT)
time = get.var.ncdf( nc,'time')
time2=interp6to3(time) #accepts vector
z <- time2*60*60 #make seconds
origin=substr(nc$dim$time$units,13,22)
datesPl<-ISOdatetime(origin,0,0,0,0,0,tz='UTC') + z #dates sequence
save(datesPl, file=paste(outRootPl, '/dates', sep=''))
#write.table(dates,paste(outRootPl, '/dates', sep=''), sep=',', row.names=F, col.names=F)

#INTERPOLATE GRAVITY
nc=open.ncdf(infileG)
var=nc$var$var$name
dat = get.var.ncdf( nc,var)
datInterp=apply(X=dat, MARGIN=c(1,2,3), FUN=interp6to3)
save(datInterp, file=paste(outRootPl, '/gPl', sep=''))

#INTERPOLATE TAIR
nc=open.ncdf(infileT)
var=nc$var$var$name
dat = get.var.ncdf( nc,var)
datInterp=apply(X=dat, MARGIN=c(1,2,3), FUN=interp6to3)
save(datInterp, file=paste(outRootPl, '/tairPl', sep=''))

#INTERPOLATE RHUM
nc=open.ncdf(infileRh)
var=nc$var$var$name
dat = get.var.ncdf( nc,var)
datInterp=apply(X=dat, MARGIN=c(1,2,3), FUN=interp6to3)
save(datInterp, file=paste(outRootPl, '/rhumPl', sep=''))

#INTERPOLATE U
nc=open.ncdf(infileU)
var=nc$var$var$name
dat = get.var.ncdf( nc,var)
datInterp=apply(X=dat, MARGIN=c(1,2,3), FUN=interp6to3)
save(datInterp, file=paste(outRootPl, '/uPl', sep=''))

#INTERPOLATE V
nc=open.ncdf(infileV)
var=nc$var$var$name
dat = get.var.ncdf( nc,var)
datInterp=apply(X=dat, MARGIN=c(1,2,3), FUN=interp6to3)
save(datInterp, file=paste(outRootPl, '/vPl', sep=''))

#INTERPOLATE d2m
nc=open.ncdf(infileD)
var=nc$var$var$name
dat = get.var.ncdf( nc,var)
datInterp=apply(X=dat, MARGIN=c(1,2), FUN=interp6to3)
save(datInterp, file=paste(outRootPl, '/dewT', sep=''))

########################################################################################################
#													
#				PREPROCESS SURFACE FIELDS
#									
########################################################################################################

#convert accumulated values to timestep averages
#precip units changed
#3d to 2d matrix

#=======================================================================================================
#			COORDMAP
#=======================================================================================================
file=lwFile
coordMap=getCoordMap(file)
step=step

#=======================================================================================================
#			CONVERT ACCUMULATED VALUES TO TIMESTEP AVERAGES AND SHIFT
#=======================================================================================================

#=======================================================================================================
#			SURFACE FIELDS TIME VECTOR
#=======================================================================================================

nc=open.ncdf(lwFile)
time = get.var.ncdf( nc,'time')
#origin =unlist(strsplit(nc$dim$time$units,'hours since '))[2]
origin=substr(nc$dim$time$units,13,22)

z <- time*60*60 #make seconds
dates<-ISOdatetime(origin,0,0,0,0,0,tz='UTC') + z #dates sequence
datesSurf=dates[1:length(dates)-1] #remove last time value to account for acummulated to average value conversion

#=======================================================================================================
#			LWIN
#=======================================================================================================
nc=open.ncdf(lwFile)
var=nc$var$var$name
indat = get.var.ncdf( nc, var)

#could vectorise but quick anyway 
lwgridAv=c()
	for(i in coordMap$cells){
	x=coordMap$xlab[i]
	y=coordMap$ylab[i]
	lgav=accumToInstERA_simple(inDat=indat[x,y,], step=step)
	lwgridAv=cbind(lwgridAv,lgav)
	}
#interpolate to original timestep
lwgridAdj=c()
	for(i in coordMap$cells){
	lAdj=adjAccum(lwgridAv[,i])
	lwgridAdj=cbind(lwgridAdj,lAdj)
	}

#=======================================================================================================
#			SWIN
#=======================================================================================================
nc=open.ncdf(swFile)
var=nc$var$var$name
indat = get.var.ncdf( nc, var)

#could vectorise but quick anyway 
swgridAv=c()
	for(i in coordMap$cells){
	x=coordMap$xlab[i]
	y=coordMap$ylab[i]
	sgav=accumToInstERA_simple(inDat=indat[x,y,], step=step)
	swgridAv=cbind(swgridAv,sgav)
	}

#interpolate to original timestep
swgridAdj=c()
	for(i in coordMap$cells){
	sAdj=adjAccum(swgridAv[,i])
	swgridAdj=cbind(swgridAdj,sAdj)
	}

#=======================================================================================================
#			TOA
#=======================================================================================================
nc=open.ncdf(toaFile)
var=nc$var$var$name
indat = get.var.ncdf( nc, var)

#could vectorise but quick anyway 
toagridAv=c()
	for(i in coordMap$cells){
	x=coordMap$xlab[i]
	y=coordMap$ylab[i]
	togav=accumToInstERA_simple(inDat=indat[x,y,], step=step)
	toagridAv=cbind(toagridAv,togav)
	}

#interpolate to original timestep
toagridAdj=c()
	for(i in coordMap$cells){
	toAdj=adjAccum(toagridAv[,i])
	toagridAdj=cbind(toagridAdj,toAdj)
	}


#=======================================================================================================
#			PRECIP
#=======================================================================================================
nc=open.ncdf(pFile)
var=nc$var$var$name
indat = get.var.ncdf( nc, var)

#could vectorise but quick anyway 
pgridAv=c()
	for(i in coordMap$cells){
	x=coordMap$xlab[i]
	y=coordMap$ylab[i]
	pgav=accumToInstERA_simple(inDat=indat[x,y,], step=step)
	pgridAv=cbind(pgridAv,pgav)
	}
#interpolate to original timestep
pgridAdj=c()
	for(i in coordMap$cells){
	pAdj=adjAccum(pgridAv[,i])
	pgridAdj=cbind(pgridAdj,pAdj)
	}

#convert m/s -> mm/hr
pgridAdjHr=pgridAdj*1000*60*60


#=======================================================================================================
#			WRITE FILES
#=======================================================================================================
save(datesSurf, file=paste(outRootSurf, '/dates', sep=''))
save(lwgridAdj, file=paste(outRootSurf, '/lwgrid', sep=''))
save(swgridAdj, file=paste(outRootSurf, '/swgrid', sep=''))
save(pgridAdjHr, file=paste(outRootSurf, '/pgrid', sep=''))
save(toagridAdj, file=paste(outRootSurf, '/toagrid', sep=''))

########################################################################################################
#													
#				CUT FIELDS TO COMMON PERIOD
#									
########################################################################################################

#read dates
load(file=paste(outRootPl, '/dates', sep=''))
#datesPl=dPl$V1 #"1996-01-01 UTC" -- "2009-12-31 18:00:00 UTC"
load(file=paste(outRootSurf, '/dates', sep=''))
#datesSurf=dSurf$V1 #1996-01-01 03:00:00 --2011-12-31 21:00:00

#cut dates - output files should be identical
n1p=which(as.character(datesPl)==startDate)
n2p=which(as.character(datesPl)==endDate)
datesPl_cut=as.character(datesPl[n1p:n2p])
save(datesPl_cut, file=paste(outRootmet, '/datesPl', sep=''))

n1s=which(as.character(datesSurf)==startDate)
n2s=which(as.character(datesSurf)==endDate)
datesSurf_cut=as.character(datesSurf[n1s:n2s])
save(datesSurf_cut, file=paste(outRootmet, '/datesSurf', sep=''))


#PRESSURE LEVEL FIELDS
load(paste(outRootPl, '/gPl', sep=''))
gPl_cut=datInterp[n1p:n2p,,,]
save(gPl_cut, file=paste(outRootmet, '/gPl', sep=''))

load(paste(outRootPl, '/tairPl', sep=''))
tairPl_cut=datInterp[n1p:n2p,,,]
save(tairPl_cut, file=paste(outRootmet, '/tairPl', sep=''))

load(paste(outRootPl, '/rhumPl', sep=''))
rhumPl_cut=datInterp[n1p:n2p,,,]
save(rhumPl_cut, file=paste(outRootmet, '/rhumPl', sep=''))

load(paste(outRootPl, '/uPl', sep=''))
uPl_cut=datInterp[n1p:n2p,,,]
save(uPl_cut, file=paste(outRootmet, '/uPl', sep=''))

load(paste(outRootPl, '/vPl', sep=''))
vPl_cut=datInterp[n1p:n2p,,,]
save(vPl_cut, file=paste(outRootmet, '/vPl', sep=''))

load(paste(outRootPl, '/dewT', sep=''))
dewT_cut=datInterp[n1p:n2p,,]
save(dewT_cut, file=paste(outRootmet, '/dewTSurf', sep=''))


#SURFACE FIELDS
load( paste(outRootSurf, '/lwgrid', sep=''))
lwSurf_cut=lwgridAdj[n1s:n2s,]
load( paste(outRootSurf, '/swgrid', sep=''))
swSurf_cut=swgridAdj[n1s:n2s,]
load(paste(outRootSurf, '/pgrid', sep=''))
pSurf_cut=pgridAdjHr[n1s:n2s,]
load(paste(outRootSurf, '/toagrid', sep=''))
toaSurf_cut=toagridAdj[n1s:n2s,]

save(lwSurf_cut, file=paste(outRootmet, '/lwSurf', sep=''))
save(swSurf_cut, file=paste(outRootmet, '/swSurf', sep=''))
save(pSurf_cut, file=paste(outRootmet, '/pSurf', sep=''))
save(toaSurf_cut, file=paste(outRootmet, '/toaSurf', sep=''))
########################################################################################################
#
#			COMPUTE SURFACE RELATIVE HUMIDITY (for LWin computation)
#
########################################################################################################
#read data
load(file=paste(outRootmet, '/dewTSurf', sep=''))
td=dewT_cut
nc=open.ncdf(tFile)
var=nc$var$var$name
t = get.var.ncdf( nc, var)

#convert to 2d matrix
tgrid=c()
tdgrid=c()
	for(i in coordMap$cells){
	x=coordMap$xlab[i]
	y=coordMap$ylab[i]
	tg=t[x,y,]#nb order of dimensions differs
	tdg=td[,x,y] #nb order of dimensions differs
	tgrid=cbind(tgrid,tg)
	tdgrid=cbind(tdgrid,tdg)
	}

#cut tair data
tSurf_cut=tgrid[n1s:n2s,]

#compute Rh at surface
rhSurf_cut=relHumCalc(tair=tSurf_cut,tdew=tdgrid)
rhSurf_cut[rhSurf_cut>100]<-100 #constrain to 100% Rh
save(rhSurf_cut, file=paste(outRootmet, '/rhSurf', sep=''))
save(tSurf_cut, file=paste(outRootmet, '/tSurf', sep=''))


########################################################################################################
#
#			CLEAN UP
#
########################################################################################################
#system('rm -r /home/joel/data/tscale/tmp/pressurelevel/')
#system('rm -r /home/joel/data/tscale/tmp/surface')

########################################################################################################
#
#			TOPOSCALE
#
########################################################################################################

#===========================================================================
#				POINTS
#===========================================================================
#Get points meta data - loop through box directories
for( i in 1:nbox){ #start nbox loop


spath=paste(epath, '/box', i,sep='') #simulation path
#make shapefile of points
#mf=read.table(metaFile, sep=',', header =T)
mf=read.table(paste(spath,'/listpoints.txt',sep=''),header=T,sep=',')

#for actual point only
#validStations=seq(1:max(mf$id))
#id=mf$id[mf$id %in% validStations]
#lon=mf$lon[mf$id %in% validStations]
#lat=mf$lat[mf$id %in% validStations]
#ele=mf$ele[mf$id %in% validStations]
#valShp=makePointShapeGeneric(lon=lon, lat=lat, data=ele)
npoints=length(mf$id)

#for actual point only
#get point gridbox ID 
#x=raster(infileT)
#gridBoxRst=init(x, v='cell')
#eraCells=cellStats(gridBoxRst,max)
#boxID=extract( gridBoxRst,valShp)
#mf$boxID<-boxID

#for actual point only
#find ele diff station/gidbox
#eraBoxEle=getEraEle(dem='/home/joel/data/DEM/alps/20121011073246_1677224548.asc', eraFile=tFile) # $masl
#gridEle<-eraBoxEle[mf$boxID]
#mf$gridEle<-gridEle
#eleDiff=mf$ele-mf$gridEle
#mf$eleDiff<-eleDiff

#find ele diff station/gidbox
eraBoxEle<-getEraEle(dem='/home/joel/data/DEM/alps/20121011073246_1677224548.asc', eraFile=tFile) # $masl
gridEle<-rep(eraBoxEle[nbox],length(mf$id))
mf$gridEle<-gridEle
eleDiff=mf$ele-mf$gridEle
mf$eleDiff<-eleDiff



#=======================================================================================================
#			READ FILES
#=======================================================================================================

load(paste(outRootmet,'/gPl',sep=''))
load(paste(outRootmet,'/tairPl',sep=''))
load(paste(outRootmet,'/rhumPl',sep=''))
load(paste(outRootmet,'/uPl',sep=''))
load(paste(outRootmet,'/vPl',sep=''))
#var name =*Pl_cut (e.g. gPl_cut)
load(paste(outRootmet,'/lwSurf',sep=''))
load(paste(outRootmet,'/swSurf',sep=''))
load(paste(outRootmet,'/tSurf',sep=''))
load(paste(outRootmet,'/rhSurf',sep=''))
load(paste(outRootmet,'/pSurf',sep=''))
load(paste(outRootmet,'/toaSurf',sep=''))
load(paste(outRootmet,'/datesSurf',sep=''))
#var name =*Surf_cut (e.g. tSurf_cut)
#========================================================================
#		COMPUTE SCALED FLUXES - T,Rh,Ws,Wd,LW
#========================================================================

#init dataframes
tPoint=c()
rPoint=c()
uPoint=c()
vPoint=c()
lwPoint=c()
nameVec=c()

#for actual point only
#nboxSeq=c(1:eraCells)
	#for (nbox in nboxSeq){

		#get grid coordinates
		x<-coordMap$xlab[nbox] # long cell
		y<-coordMap$ylab[nbox]# lat cell

#get long lat centre point of nbox (for solar calcs)
lat=get.var.ncdf(nc, 'lat')
lon=get.var.ncdf(nc, 'lon')
latn=lat[y]
lonn=lon[x]
mf$lat=rep(latn,length(mf$id))
mf$lon=rep(lonn,length(mf$id))

		#extract PL data by nbox coordinates dims[data,xcoord,ycoord, pressurelevel]
		gpl=gPl_cut[,x,y,]
		tpl=tairPl_cut[,x,y,]
		rpl=rhumPl_cut[,x,y,]
		upl=uPl_cut[,x,y,]
		vpl=vPl_cut[,x,y,]

		#extract surface data by nbox  dims[data,nbox]
		lwSurf=lwSurf_cut[,nbox]
		tSurf=tSurf_cut[,nbox]
		rhSurf=rhSurf_cut[,nbox]
		toaSurf=toaSurf_cut[,nbox]
		swSurf=swSurf_cut[,nbox]
		

		#get grid mean elev
		gridEle<-eraBoxEle[nbox]

		#for actual point only
		#get valid stations in nbox
#		singleGridboxPoints_vec=mf$id[mf$boxID==nbox]
#		if (length(na.omit(singleGridboxPoints_vec))==0){next}
#		stations<-na.omit(singleGridboxPoints_vec)
stations=mf$id

		#get station attributes
		lsp=mf[stations,]
	
			for (i in 1:length(lsp$id)){

			stationEle=lsp$ele[i]
			nameVec=c(nameVec,(lsp$id[i])) #keeps track of order of stations

			#AIR TEMPERATURE
			t_mod<-plevel2point(gdat=gpl,dat=tpl, stationEle=stationEle)
			tPoint=cbind(tPoint, t_mod)
			#RELATIVE HUMIDITY
			r_mod<-plevel2point(gdat=gpl,dat=rpl, stationEle=stationEle)
			rPoint=cbind(rPoint, r_mod)
			#WIND U
			wu<-plevel2point(gdat=gpl,dat=upl, stationEle=stationEle)
			uPoint=cbind(uPoint, wu)
			#WIND V
			wv<-plevel2point(gdat=gpl,dat=vpl, stationEle=stationEle)
			vPoint=cbind(vPoint, wv)
			#LWIN			
			lw_mod<-lwinTscale( tpl=t_mod,rhpl=r_mod,rhGrid=rhSurf,tGrid=tSurf, lwGrid=lwSurf, x1=0.484, x2=8)
			lwPoint=cbind(lwPoint, lw_mod)

			}
		#for actual point only}

#========================================================================
#		CONVERT U/V TO WS/WD
#========================================================================
u=uPoint
v=vPoint
wdPoint=windDir(u,v)
wsPoint=windSpd(u,v)

#========================================================================
#		correct order of grid boxes from flux computation
#========================================================================
#nboxOrd=mf$boxID[nameVec]#for actual point only

#========================================================================
#		COMPUTE SW (no loop needed)
#========================================================================


sw=swSurf_cut[,nbox]
swm=matrix(rep(sw,npoints),ncol=npoints) #make matrix with ncol =points, repeats of each nbox vector
toa=toaSurf_cut[,nbox]
toam=matrix(rep(toa,npoints),ncol=npoints)


dd=as.POSIXct(datesSurf_cut)

sol=solarCompute(swin=swm,toa=toam, dates=dd,mf=mf)

#========================================================================
#		COMPUTE P
#========================================================================
pSurf=pSurf_cut[,nbox] #in order of mf file
pSurfm=matrix(rep(pSurf,npoints),ncol=npoints)

#weights function here
#need to convert monthly correction factor to 3hr one
#weights_stk=stack('/home/joel/data/CRU/data/subWeights.tif')
#cf=extract(weights_stk, valShp)
#z=t(cbind(cf,cf,cf,cf,cf,cf,cf,cf,cf,cf,cf,cf,cf))#repeat for x (13) years of dataframe

#============================================================================================
#			Apply Liston lapse
#=============================================================================================
ed=mf$eleDiff
lapseCor=(1+(pfactor*(ed/1000))/(1-(pfactor*(ed/1000))))
pSurf_lapse=pSurfm*lapseCor


#========================================================================
#		MAKE SIM DIRS
#========================================================================
for ( i in 1:npoints){
dir.create(paste(spath,'/sim', mf$id[i],sep=''))
dir.create(paste(spath,'/sim', mf$id[i],'/out',sep=''))
}
#========================================================================
#		MAKE MET FILES PER POINT
#========================================================================
#stationOrder=mf$id[nameVec]

#for(i in 1:length(stationOrder)){
for(i in 1:npoints){

Tair=round((tPoint[,i]-273.15),2) #K to deg
RH=round(rPoint[,i],2)
Wd=round(wdPoint[,i],2)
Ws=round(wsPoint[,i],2)
SW=round(sol[,i],2)
LW=round(lwPoint[,i],2)
Prec=round(pSurf_lapse[,i],2)
Date<-datesSurf_cut
Date<-format(as.POSIXct(Date), format="%d/%m/%Y %H:%M") #GEOtop format date
meteo=cbind(Date,Tair,RH,Wd,Ws,SW,LW,Prec)

if(length(which(is.na(meteo)==TRUE))>0){print(paste('WARNING:', length(which(is.na(meteo)==TRUE)), 'NANs found in meteofile',nameVec[i],sep=' '))}
if(length(which(is.na(meteo)==TRUE))==0){print(paste( length(which(is.na(meteo)==TRUE)), 'NANs found in meteofile',nameVec[i],sep=' '))}

write.table(meteo, paste(spath, '/sim',nameVec[i],'/meteo0001.txt', sep=''), sep=',', row.names=F)
}



#EXTRACT DATA TO POINTS (sw and toa)
#returns 2d matrix with rows=stations in order of boxID (mf)
#boxID=mf$boxID
#swPoint=sw3hr[,boxID]
#toaPoint=toa3hr[,boxID]

#========================================================================
#		MAKE LISTPOINTS
#========================================================================

for(i in 1:npoints){
n=nameVec[i]
listp=data.frame(mf$id[n], mf$ele[n], mf$asp[n], mf$slp[n], mf$svf[n])
listp=round(listp,2)
names(listp)<-c('id', 'ele', 'asp', 'slp', 'svf')
write.table(listp, paste(spath, '/sim',nameVec[i], '/listpoints.txt', sep=''), sep=',',row.names=F)
}

#========================================================================
#		MAKE HORIZON
#========================================================================

for(i in 1:npoints){
hor(listPath=paste(spath, '/sim',nameVec[i], sep=''))
}


#========================================================================
#		MAKE INPTS
#========================================================================

for(i in 1:npoints){
expRoot= paste(spath, '/sim',i, sep='')
parfilename='geotop.inpts'
fs=readLines(paste(master,parfilename, sep='')) 

lnLat=gt.par.fline(fs=fs, keyword='Latitude') 
lnLong=gt.par.fline(fs=fs, keyword='Longitude') 
lnMetEle=gt.par.fline(fs=fs, keyword='MeteoStationElevation') 
lnPele=gt.par.fline(fs=fs, keyword='PointElevation') 

#getGridMeta feeds in here
fs=gt.par.wline(fs=fs,ln=lnLat,vs=mf$lat[i])
fs=gt.par.wline(fs=fs,ln=lnLong,vs=mf$lon[i])
fs=gt.par.wline(fs=fs,ln=lnMetEle,vs=mf$ele[i])
fs=gt.par.wline(fs=fs,ln=lnPele,vs=mf$ele[i])

#gt.exp.write(eroot_loc=paste(simRoot, 'sim',i, sep=''),eroot_sim,enumber=1, fs=fs)
comchar<-"!" #character to indicate comments
con <- file(expRoot&"/"&parfilename, "w")  # open an output file connection
	cat(comchar,"SCRIPT-GENERATED EXPERIMENT FILE",'\n', file = con,sep="")
	cat(fs, file = con,sep='\n')
	close(con)

}



#========================================================================
#		RECORD SRC AND SCRIPTS
#========================================================================
#write logs of script and src
#file.copy(paste(root,'src/toposub_script.r', sep=''), paste(esPath,'/toposub_script_copy.r',sep=''),overwrite=T)
#file.copy(paste(root,'/src/',src, sep=''),  paste(esPath,'/',src,'_copy.r',sep=''),overwrite=T)

#========================================================================
#		make batch file
#========================================================================

batchfile=paste(spath,'/batch.txt',sep='')
file.create(batchfile)

sims=list.files(path=spath, pattern='sim',full.names=T)
write(paste('cd ',exePath,sep=''),file=batchfile,append=T)
for(i in 1:npoints){
write(paste(exe, sims[i], sep=' '),file=batchfile,append=T)
}

 system(paste('chmod 777 ',spath,'/batch.txt',sep=''))

}#end nbox loop

#========================================================================
#		MAKE MEGA BATCH
#========================================================================
system('cd /home/joel/experiments/alpsSim/_master/')
system('./megabatch.txt')
#========================================================================
#		RUN GEOTOP
#========================================================================
t2=Sys.time()-t1

##==============================================================================
## TopoSUB postprocessor
##==============================================================================


for( i in 1:nbox){
spath=paste(epath, '/box', i,sep='') #simulation path
#outfile=paste(spath,'/meanX_X100.000000.txt',sep='')
#file.create(outfile)

#for ( i in 1:Nclust){
#simpath=paste(spath,'/sim', i,sep='')
#esPath=simpath

##read in lsm output
#param1<-read.table(paste(esPath,file1,sep=''), sep=',', header=T)
#param2<-read.table(paste(esPath,file2,sep=''), sep=',', header=T)

##cut timeseries
#for (col in cols){
#	
#	#if(col=="X100.000000"){file<-file1}else{file<-file2}
#	if(col=="X100.000000"){sim_dat<-param1}else{sim_dat<-param2}
#	sim_dat_cut=timeSeriesCut(esPath=esPath,col=col, sim_dat=sim_dat, beg=beg, end=end)
#	#timeSeries(esPath=esPath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
#	timeSeries2(spath=spath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
#}
#}

#stupid method to get nbrs
#need buffer to avoid replication of nbrs at edge/corners
if(i==1){nbrs=c(2,2,7,7)}
if(i==2){nbrs=c(3,3,8,6)}
if(i==3){nbrs=c(4,4,9,2)}
if(i==4){nbrs=c(5,5,10,3)}
if(i==5){nbrs=c(6,6,11,4)}
if(i==6){nbrs=c(12,12,5,5)}
if(i==7){nbrs=c(6,6,8,13)}
if(i==8){nbrs=c(2,9,14,7)}
if(i==9){nbrs=c(3,10,15,8)}
if(i==10){nbrs=c(4,11,16,9)}
if(i==11){nbrs=c(5,12,17,10)}
if(i==12){nbrs=c(6,6,18,11)}
if(i==13){nbrs=c(7,7,14,14)}
if(i==14){nbrs=c(8,15,15,13)}
if(i==15){nbrs=c(9,16,16,14)}
if(i==16){nbrs=c(10,17,17,15)}
if(i==17){nbrs=c(11,18,18,16)}
if(i==18){nbrs=c(12,12,17,17)}

resvec=c()
for(n in 1:Nclust){
	res=spatialWeight(mbox=i, samp=n, nbrs=nbrs, predNames=predNames, wm=0.7, wn=0.4)
	resvec=c(resvec,res)
	}
dir.create(paste(spath,'/crispRst/',sep=''))
land<-raster(paste(spath,"/landform_",Nclust,".tif",sep=''))
meanX <- resvec
l=length(meanX)
s=seq(1,l,1)
meanXdf=data.frame(s,meanX)
rst=subs(land, meanXdf,by=1, which=2)
writeRaster(rst, paste(spath, '/crispRst/',col,'_',l,'_2.tif', sep=''),overwrite=T)
}
t3=Sys.time()-t1

for( i in 1:nbox){
spath=paste(epath, '/box', i,sep='') #simulation path
##make crisp maps
landform<-raster(paste(spath,"/landform_",Nclust,".tif",sep=''))
crispSpatial2(col,Nclust,spath, landform)
}
##==============================================================================
## MERGE RASTERS
##==============================================================================
rs=list.files(epath, pattern='X100.000000_10_2.tif', recursive=T)
rst=paste(epath,rs,sep='')
rmerge=merge(raster(rst[1]),raster(rst[2]),raster(rst[3]),raster(rst[4]),raster(rst[5]),raster(rst[6]),raster(rst[7]),raster(rst[8])
,raster(rst[9]),raster(rst[10]),raster(rst[11]),raster(rst[12]),raster(rst[13]),raster(rst[14]),raster(rst[15]),raster(rst[16]),raster(rst[17]),raster(rst[18]))

plot(rmerge)
writeRaster(rmerge, paste(epath,'rmerge3.tif',sep=''), NAflag=-9999)
t4=Sys.time()-t1

