toposub_fuzzym=function(Nclust,esPath){
rstPath=paste(esPath,'/ele.tif', sep='')
#calculate fuzzy membership

#cmeans(x=scaleDat_samp, centers=64, iter.max = 10, verbose = TRUE,dist = "euclidean", method = "cmeans", m = 1.4,    rate.par = NULL, weights = 1, control = list())
res=extentandcells(rstPath=rstPath)
cells <- res$cells
ext <- res$x

#read in sample centroid data
samp_mean <- read.table(paste(esPath, '/samp_mean.txt' ,sep=''), sep=',',header=T)
samp_sd <- read.table(paste(esPath, '/samp_sd.txt' ,sep=''), sep=',', header=T)

#compute fuzzy memberships
fuzzyMember(esPath=esPath,ext=ext,cells=cells,data=gridmaps@data, samp_mean=samp_mean,samp_sd=samp_sd, Nclust=Nclust)
}
