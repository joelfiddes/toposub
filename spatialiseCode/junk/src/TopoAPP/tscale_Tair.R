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



#=======================================================================================================
#			READ FILES
#=======================================================================================================

load(paste(outRootmet,'/gPl',sep=''))
load(paste(outRootmet,'/tairPl',sep=''))

#========================================================================
#		COMPUTE SCALED FLUXES - T,Rh,Ws,Wd,LW
#========================================================================

#init dataframes
tPoint=c()

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


		#get grid mean elev
		gridEle<-eraBoxEle[nbox]

	
stations=mf$id

		#get station attributes
		lsp=mf[stations,]
	
			for (i in 1:length(lsp$id)){

			stationEle=lsp$ele[i]
			nameVec=c(nameVec,(lsp$id[i])) #keeps track of order of stations

			#AIR TEMPERATURE
			t_mod<-plevel2point(gdat=gpl,dat=tpl, stationEle=stationEle)
			tPoint=cbind(tPoint, t_mod)
	
			}
write.table(tPoint,paste(spath,  '/tPoint.txt',sep=''), row.names=F, sep=',')
