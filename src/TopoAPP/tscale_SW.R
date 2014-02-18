########################################################################################################
#
#			TOPOSCALE SWin
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

file=lwFile
coordMap=getCoordMap(file)
nc=open.ncdf(infileT)
#===========================================================================
#				COMPUTE POINTS META DATA - eleDiff, gridEle, Lat, Lon
#===========================================================================
mf=read.table(paste(spath,'/listpoints.txt',sep=''),header=T,sep=',')
npoints=length(mf$id)

#find ele diff station/gidbox
eraBoxEle<-getEraEle(dem=eraBoxEleDem, eraFile=tFile) # $masl
gridEle<-rep(eraBoxEle[nbox],length(mf$id))
mf$gridEle<-gridEle
eleDiff=mf$ele-mf$gridEle
mf$eleDiff<-eleDiff

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


#=======================================================================================================
#			READ FILES
#=======================================================================================================
load(paste(outRootmet,'/swSurf',sep=''))
load(paste(outRootmet,'/toaSurf',sep=''))
load(paste(outRootmet,'/datesSurf',sep=''))
#var name =*Surf_cut (e.g. tSurf_cut)


#========================================================================
#		COMPUTE SW (no loop needed)
#========================================================================
sw=swSurf_cut[,nbox]
swm=matrix(rep(sw,npoints),ncol=npoints) #make matrix with ncol =points, repeats of each nbox vector
toa=toaSurf_cut[,nbox]
toam=matrix(rep(toa,npoints),ncol=npoints)
dd=as.POSIXct(datesSurf_cut)

if(swTopo==Topo){
#START
#partition
sdif=solarPartition(swPoint=swm,toaPoint=toam, out='dif')
sdir=solarPartition(swPoint=swm,toaPoint=toam, out='dir')

#elevation scale of SWin_dir (additative)
sdirScale=sdirEleScale(sdirm=sdir,toaPoint=toam,dates=dd, mf=mf)

#topo correction to SWin_dif - reduce according to svf
sdifcor=sdifSvf(sdifm=sdif, mf=mf)

#corrects direct beam component for solar geometry, cast shadows and self shading
sdirTopo=solarGeom(mf=mf,dates=dd, sdirm=sdirScale, tz=tz)

#add both components
sglobal=sdirTopo+sdifcor
#FINISH
write.table(sglobal,paste(spath,  '/sol.txt',sep=''), row.names=F, sep=',')
write.table(sdirTopo,paste(spath,  '/solDir.txt',sep=''), row.names=F, sep=',')
write.table(sdifcor,paste(spath,  '/solDif.txt',sep=''), row.names=F, sep=',')

}

if(swTopo==F){
#old combined function replaced by functions between START and FINISH
sol=solarCompute(swin=swm,toa=toam, dates=dd,mf=mf, tz=tz)
write.table(sol,paste(spath,  '/sol.txt',sep=''), row.names=F, sep=',')
}
