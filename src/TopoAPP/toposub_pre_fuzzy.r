######################################################################################################
#	
#			TOPOSUB PREPROCESSOR -fuzzy
#			
######################################################################################################



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
