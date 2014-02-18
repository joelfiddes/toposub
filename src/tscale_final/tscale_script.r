#tscale_script
#interpoilate pl fields
t1=Sys.time()
#=======================================================================================================
#			PARAMETERS TO SET
#=======================================================================================================
#use period #1996-01-01 03:00:00UTC -- "2008-12-31 UTC"
#startDate='1996-01-01 03:00:00'
#endDate='2008-12-31 00:00:00'
startDate='2010-12-02 00:00:00'
endDate='2013-12-30 00:00:00'
pfactor=0.25 #liston parameter

#originPl='1900-01-01' # automated now
#originSurf='1996-01-01' #automated now


#=======================================================================================================
#			DIRECTORIES/PATHS TO SET
#=======================================================================================================
simRoot='/home/joel/data/tscaleIB/'
datRoot='/home/joel/data/era/mattertal/'
ginptsPath= '/home/joel/data/tscale/_master/geotop.inpts'#location of master geotopinpts
metaFile='/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt' #points meta file c(id,ele,slp, asp, sky, lat,lon)
#eraBoxEle=read.table('/home/joel/data/transformedData/eraBoxEle.txt', header=T, sep=',') #preprocessed grid ele (slow)
#optional function
eraBoxEle$masl=getEraEle(dem='/home/joel/data/DEM/alps/20121011073246_1677224548.asc', eraFile=tFile) # $masl
exeRoot='/home/joel/src/geotop/'
exe='./geotop1.225-13'
#=======================================================================================================
#				MAIN CODE
# 				 | | |  
#				 v v v
#				 v v v
# 				 v v v 
#=======================================================================================================

#=======================================================================================================
#			PACKAGES
#=======================================================================================================
require(ncdf)
require(raster)
require(insol)
#=======================================================================================================
#			SRC
#=======================================================================================================
source('/home/joel/src/TopoScale/tscale_final/tscale_src.r')
source('~/experiments/surfFlux/src/surfFluxSrc.r')
source('~/src/TopoScale/tscale/solar_functions.r')
source('/home/joel/src/TopoScale/tscale_final/solar.r')
source('/home/joel/src/code_toposub/toposub_src.r')
source('/home/joel/experiments/bigsim/src/gt_control.r')


#=======================================================================================================
#			DIRECTORIES RELATIVE
#=======================================================================================================
dir.create(simRoot,recursive=T)
root=paste(simRoot,'tmp/',sep='')
dir.create(root,recursive=T)
outRootPl=paste(root,'pressurelevel',sep='')
dir.create(outRootPl)
outRootSurf=paste(root,'surface',sep='')
dir.create(outRootSurf)
outRootmet=paste(root,'all',sep='')
dir.create(outRootmet)
master=paste(simRoot,'_master/',sep='')
dir.create(master)
file.copy(ginptsPath, master)

#=======================================================================================================
#			INFILES
#=======================================================================================================


#PRESSURE LEVEL FIELDS (AND DEWT)
infileG=paste(datRoot, 'gpot.nc',sep='')
varG='var129'
infileT=paste(datRoot, 'tpl.nc',sep='')
varT="var130"
varTimePl="time"
infileRh=paste(datRoot, 'rhpl.nc',sep='')
varRh="var157"
infileU=paste(datRoot, 'upl.nc',sep='')
varU="var131"
infileV=paste(datRoot, 'vpl.nc',sep='')
varV="var132"
infileD=paste(datRoot, 'dt.nc',sep='')
varD="var168"

#SURFACE FIELDS
lwFile=paste(datRoot, 'strd.nc',sep='')
varLw="var175"
varTimeSurf="time"
swFile=paste(datRoot, 'ssrd.nc',sep='')
varSw="var169"
pFile=paste(datRoot, 'p.nc',sep='')
varP="var228"
tFile=paste(datRoot, 't.nc',sep='')
varTsurf="var167"
toaFile=paste(datRoot, 'toa.nc',sep='')
varToa='var212'

#other

step=3 #time step of accumulated fields


#OLD SYSTEM

##PRESSURE LEVEL FIELDS (AND DEWT)
#infileG='/home/joel/data/era/pressureLevels/geopotential/outfile.nc'
#varG='z'
#infileT='/home/joel/data/era/pressureLevels/tair/outfile.nc'
#varT="t"
#varTimePl="time"
#infileRh='/home/joel/data/era/pressureLevels/rhum/outfile.nc'
#varRh="r"
#infileU='/home/joel/data/era/pressureLevels/uwind/outfile.nc'
#varU="u"
#infileV='/home/joel/data/era/pressureLevels/vwind/outfile.nc'
#varV="v"
#infileD='/home/joel/data/era/surface/dewT.nc'
#varD="d2m"

##SURFACE FIELDS
#lwFile='/home/joel/data/era/surface/grid74/strd.nc'
#varLw="var175"
#varTimeSurf="time"
#swFile='/home/joel/data/era/surface/grid74/ssrd.nc'
#varSw="var169"
#pFile='/home/joel/data/era/surface/grid74/tp.nc'
#varP="var228"
#tFile='/home/joel/data/era/surface/grid74/tair.nc'
#varTsurf="var167"
#toaFile='/home/joel/data/era/surface/toa.nc'
#varToa='var212'



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
time = get.var.ncdf( nc,varTimePl)
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
#Get points meta data

#make shapefile of points
mf=read.table(metaFile, sep=',', header =T)
validStations=seq(1:max(mf$id))
id=mf$id[mf$id %in% validStations]
lon=mf$lon[mf$id %in% validStations]
lat=mf$lat[mf$id %in% validStations]
ele=mf$ele[mf$id %in% validStations]
valShp=makePointShapeGeneric(lon=lon, lat=lat, data=ele)
npoints=length(mf$id)

#get point gridbox ID 
x=raster(infileT)
gridBoxRst=init(x, v='cell')
eraCells=cellStats(gridBoxRst,max)
boxID=extract( gridBoxRst,valShp)
mf$boxID<-boxID

#find ele diff station/gidbox
gridEle<-eraBoxEle$masl[mf$boxID]
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

nboxSeq=c(1:eraCells)
	for (nbox in nboxSeq){

		#get grid coordinates
		x<-coordMap$xlab[nbox] # long cell
		y<-coordMap$ylab[nbox]# lat cell

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
		gridEle<-eraBoxEle$masl[nbox]

		#get valid stations in nbox
		singleGridboxPoints_vec=mf$id[mf$boxID==nbox]
		if (length(na.omit(singleGridboxPoints_vec))==0){next}
		stations<-na.omit(singleGridboxPoints_vec)

		#get station attributes
		lsp=mf[stations,]
		#ID=seq(1,length(ls$id),1)
		#lsp<-cbind(ID, ls)
		#names(lsp)[2]<-'stn'

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
	}

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
nboxOrd=mf$boxID[nameVec]

#========================================================================
#		COMPUTE SW (no loop needed)
#========================================================================

sw=swSurf_cut[,nboxOrd]
toa=toaSurf_cut[,nboxOrd]
dd=as.POSIXct(datesSurf_cut)

sol=solarCompute(swin=sw,toa=toa, dates=dd,mf=mf)

#========================================================================
#		COMPUTE P
#========================================================================
pSurf=pSurf_cut[,nboxOrd] #in order of mf file


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
pSurf_lapse=(pSurf)*lapseCor


#========================================================================
#		MAKE SIM DIRS
#========================================================================
for ( i in 1:npoints){
dir.create(paste(simRoot,'sim', mf$id[i],sep=''))
dir.create(paste(simRoot,'sim', mf$id[i],'/out',sep=''))
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

write.table(meteo, paste(simRoot, 'sim',nameVec[i],'/meteo0001.txt', sep=''), sep=',', row.names=F)
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
listp=data.frame(mf$id[n], mf$ele[n], mf$asp[n], mf$slp[n], mf$sky[n])
listp=round(listp,2)
names(listp)<-c('ID', 'ele', 'asp', 'slp', 'svf')
write.table(listp, paste(simRoot, 'sim',nameVec[i], '/listpoints.txt', sep=''), sep=',',row.names=F)
}

#========================================================================
#		MAKE HORIZON
#========================================================================

for(i in 1:npoints){
hor(listPath=paste(simRoot, 'sim',nameVec[i], sep=''))
}


#========================================================================
#		MAKE INPTS
#========================================================================

for(i in 1:npoints){
expRoot= paste(simRoot, 'sim',i, sep='')
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

batchfile=paste(master,'/batch.txt',sep='')
file.create(batchfile)

sims=list.files(path=simRoot, pattern='sim',full.names=T)
write('cd /home/joel/src/geotop/',file=batchfile,append=T)
for(i in 1:npoints){
write(paste(exe, sims[i], sep=' '),file=batchfile,append=T)
}


t2=Sys.time() -t1
print(t2)
