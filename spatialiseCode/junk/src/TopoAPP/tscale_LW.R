########################################################################################################
#
#			TOPOSCALE
#
########################################################################################################
#===========================================================================
#				SETUP
#===========================================================================
wd<-getwd()
root=paste(wd,'/',sep='')
parfile=paste(root,'/src/TopoAPP/parfile.r', sep='')
source(parfile) #give nbox and epath packages and functions
nbox<-nboxSeq
simindex=formatC(nbox, width=5,flag='0')
spath=paste(epath,'/result/B',simindex,sep='') #simulation path

setup=paste(root,'/src/TopoAPP/expSetup1.r', sep='')
source(setup) #give tFile outRootmet

t_mod=read.table(paste(spath,  '/tPoint.txt',sep=''), header=T, sep=',')
r_mod=read.table(paste(spath,  '/rPoint.txt',sep=''), header=T, sep=',')

file=lwFile
coordMap=getCoordMap(file)
nc=open.ncdf(infileT)
#===========================================================================
#				POINTS
#===========================================================================
#Get points meta data - loop through box directories

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
#eraBoxEle=getEraEle(dem=eraBoxEleDem, eraFile=tFile) # $masl
#gridEle<-eraBoxEle[mf$boxID]
#mf$gridEle<-gridEle
#eleDiff=mf$ele-mf$gridEle
#mf$eleDiff<-eleDiff

#find ele diff station/gidbox
eraBoxEle<-getEraEle(dem=eraBoxEleDem, eraFile=tFile) # $masl
gridEle<-rep(eraBoxEle[nbox],length(mf$id))
mf$gridEle<-gridEle
eleDiff=mf$ele-mf$gridEle
mf$eleDiff<-eleDiff



#=======================================================================================================
#			READ FILES
#=======================================================================================================


load(paste(outRootmet,'/lwSurf',sep=''))
load(paste(outRootmet,'/tSurf',sep=''))
load(paste(outRootmet,'/rhSurf',sep=''))
#var name =*Surf_cut (e.g. tSurf_cut)
#========================================================================
#		COMPUTE SCALED FLUXES - T,Rh,Ws,Wd,LW
#========================================================================

#init dataframes
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

	
		#extract surface data by nbox  dims[data,nbox]
		lwSurf=lwSurf_cut[,nbox]
		tSurf=tSurf_cut[,nbox]
		rhSurf=rhSurf_cut[,nbox]
	

lwPoint<-lwinTscale( tpl=t_mod,rhpl=r_mod,rhGrid=rhSurf,tGrid=tSurf, lwGrid=lwSurf, x1=0.484, x2=8)
		
write.table(lwPoint,paste(spath,  '/lwPoint.txt',sep=''), row.names=F, sep=',')

		


