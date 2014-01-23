########################################################################################################
#
#			TOPOSCALE SW
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
#				POINTS
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
sol=solarCompute(swin=swm,toa=toam, dates=dd,mf=mf)

write.table(sol,paste(spath,  '/sol.txt',sep=''), row.names=F, sep=',')
