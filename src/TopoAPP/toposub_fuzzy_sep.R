root='/home/joel/sim/gst200_8411/GTSC_nS5_Nc200_X100.000000_01101984_01102011/'
epath=paste(root,'sim/',sep='') #created manually
#source(paste(root,'/parfile.r',sep=''))


#=======================================================================================================
#			PACKAGES
#=======================================================================================================
require(ncdf)
require(raster)
require(rgdal)
require(insol)
require(IDPmisc)
require(colorRamps)
require(Hmisc)
require(gdata)
require(gtools)
require(gmodels)

#======================================================================================
#	`			SOURCE external
#======================================================================================

root2='~/sim/src_master/'

source(paste(root2,'/src/ERA_tools/getERA_src.r',sep=''))
source(paste(root2,'/src/code_toposub/toposub_src.r',sep=''))
source(paste(root2,'/src/TopoSetup/toposub_crisp.r',sep=''))
source(paste(root2,'/src/TopoSetup/toposub_fuzzy.r',sep=''))
source(paste(root2,'/src/tscale_final/gt_control.r',sep=''))

source(paste(root2,'/src/tscale_final/tscale_src.r',sep=''))
source(paste(root2,'/src/tscale_final/surfFluxSrc.r',sep=''))
source(paste(root2,'/src/tscale_final/solar_functions.r',sep=''))
source(paste(root2,'/src/tscale_final/solar.r',sep=''))

#======================================================================================
#	`			general setup
#=====================================================================================

demLoc=paste(spath,'/preds/ele.tif',sep='')
predNames<-c('ele', 'slp', 'asp', 'svf') #[PRED], 'svf'
predFormat='.tif'
predRoot=paste(spath,'/preds',sep='')
rad=TRUE #SLP/ASP IN RADIANS
Nclust=200

#======================================================================================
#	`			box loop here
#=====================================================================================
nbox=5
simindex=formatC(nbox, width=5,flag='0')

#======================================================================================
#	`			setrup
#======================================================================================
spath=paste(epath,'/result/B',simindex,sep='') #simulation path

#==================================================================================================================================
#			read in pixel data
#===================================================================================================================================
gridmaps=stack_raster(demLoc=demLoc, predNames=predNames, predRoot=predRoot, predFormat=predFormat)

#check inputs slp/asp in degrees and correct if necessary (careful if applied in flat place!)
if(rad==T){
	gridmaps$asp = radtodeg(gridmaps$asp)
}
if(rad==T){
	gridmaps$slp = radtodeg(gridmaps$slp)
}

#na to numeric (-1) (does this work) REMOVED due to mask
#gridmaps@data = natonum(x=gridmaps@data,predNames=predNames ,n=-1)

#decompose aspect
res=aspect_decomp(gridmaps$asp)
res$aspC->gridmaps$aspC
res$aspS->gridmaps$aspS

#define new predNames (aspC, aspS)
allNames<-names(gridmaps@data)
predNames2 <- allNames[which(allNames!='landform'&allNames!='asp')]


#==================================================================================================================================
#			compute membership
#===================================================================================================================================

#cmeans(x=scaleDat_samp, centers=64, iter.max = 10, verbose = TRUE,dist = "euclidean", method = "cmeans", m = 1.4,    rate.par = NULL, weights = 1, control = list())
res=extentandcells(rstPath=demLoc)
cells <- res$cells
ext <- res$x

#read in sample centroid data
samp_mean <- read.table(paste(spath, '/samp_mean.txt' ,sep=''), sep=',',header=T)
samp_sd <- read.table(paste(spath, '/samp_sd.txt' ,sep=''), sep=',', header=T)
#for (col in cols){


#needs to return smal matrix
mask=raster(paste(spath,'/mask.tif',sep=''))
fuzzyMember(esPath=spath,ext=ext,cells=cells,predNames=predNames2,data=gridmaps@data, samp_mean=samp_mean,samp_sd=samp_sd, Nclust=Nclust)

if(fuzReduce==TRUE){
topMembers(esPath=spath, Nclust=Nclust,nFuzMem)
}

##==================================================================================================================================
##			compute NN samples to samples
##===================================================================================================================================
#Nclust=200
#Nmembers=20
#dat=read.table('/home/joel/sim/gst200_8411/GTSC_nS5_Nc200_X100.000000_01101984_01102011/sim/result/B00005/listpoints.txt', sep=',', header=T)

#dat2=data.frame(dat$ele, dat$slp, dat$svf, dat$aspC, dat$aspS)

#distObj=dist(dat2)
#do=as.matrix(distObj)

#membMat=c()
#for(i in 1:Nclust){	#loop thru samples_rm
#sort_dm<-sort(do[i,], decreasing=F)
#a=sort_dm[2:(Nmembers+1)]
#membVec=as.numeric(names(a)) 
#membMat=cbind(membMat,membVec)
#}


#fuzMemMat=valPoints(esPath=spath,predNames=predNames,cells=npoints,data=dat, samp_mean=samp_mean, samp_sd=samp_sd, Nclust=Nclust,fuzzy.e=1.4)

