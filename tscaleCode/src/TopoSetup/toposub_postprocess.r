epath='/home/joel/experiments/alpsSim2/' #created manually
file1<-'/out/ground.txt'
file2<-'/out/surface.txt'
beg <- "01/01/2009 00:00:00" #start cut of data timeseries
end <- "01/01/2010 00:00:00" #end cut data timeseries
cols="snow_water_equivalent.mm."
Nclust=100

#=============================================================================
#				SOURCE
#======================================================================================
source('/home/joel/src/code_toposub/toposub_src.r')
source('/home/joel/src/TopoSetup/toposub_crisp.r')
source('/home/joel/src/TopoSetup/toposub_fuzzy.r')

#======================================================
#			PACKAGES
#=======================================================================================================
require(ncdf)
require(raster)
require(rgdal)
require(insol)
require(IDPmisc)
require(colorRamps)


##==============================================================================
## TopoSUB postprocessor
##==============================================================================

Nclust=100

for( i in 1:18){
spath=paste(epath, '/box', i,sep='') #simulation path
outfile=paste(spath,'/meanX_',cols,'.txt',sep='')
file.create(outfile)

for ( i in 1:Nclust){
simpath=paste(spath,'/sim', i,sep='')
esPath=simpath

#read in lsm output
param1<-read.table(paste(esPath,file1,sep=''), sep=',', header=T)
param2<-read.table(paste(esPath,file2,sep=''), sep=',', header=T)

#cut timeseries
for (col in cols){
	

	if(col=="X500.000000"){sim_dat<-param1}else{sim_dat<-param2}
	sim_dat_cut=timeSeriesCut(esPath=esPath,col=col, sim_dat=sim_dat, beg=beg, end=end)
	#timeSeries(esPath=esPath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
	timeSeries2(spath=spath,col=col, sim_dat_cut=sim_dat_cut,FUN=max)
}
}

#make crisp maps
landform<-raster(paste(spath,"/landform_",Nclust,".tif",sep=''))
crispSpatial2(col,Nclust,spath, landform)
}

##==============================================================================
## MERGE RASTERS
##==============================================================================
rs=list.files(epath, pattern=paste(cols,'_',Nclust,'.tif',sep=''), recursive=T)
rst=paste(epath,rs,sep='')

rmerge=round(merge(raster(rst[1]),raster(rst[2]),raster(rst[3]),raster(rst[4]),raster(rst[5]),raster(rst[6]),raster(rst[7]),raster(rst[8]),raster(rst[9]),raster(rst[10]),raster(rst[11]),raster(rst[12]),raster(rst[13]),raster(rst[14]),raster(rst[15]),raster(rst[16]),raster(rst[17]),raster(rst[18])),1)


writeRaster(rmerge, paste(epath,'rmerge_500.tif',sep=''), NAflag=-9999,overwrite=T,options="COMPRESS=LZW")

##==============================================================================
## TopoSUB inform sample
##==============================================================================


for( i in 1:nbox){
spath=paste(epath, '/box', i,sep='') #simulation path
listpoints=read.table(paste('/home/joel/experiments/alpsSim2/box',i,'/listpoints.txt',sep=''), sep=',',header=T)
outfile=paste(spath,'/meanX_X100.000000.txt',sep='')
file.create(outfile)

for ( i in 1:Nclust){
simpath=paste(spath,'/sim', i,sep='')
esPath=simpath

#read in lsm output
param1<-read.table(paste(esPath,file1,sep=''), sep=',', header=T)
param2<-read.table(paste(esPath,file2,sep=''), sep=',', header=T)

#cut timeseries
for (col in cols){
	
	#if(col=="X100.000000"){file<-file1}else{file<-file2}
	if(col=="X100.000000"){sim_dat<-param1}else{sim_dat<-param2}
	sim_dat_cut=timeSeriesCut(esPath=esPath,col=col, sim_dat=sim_dat, beg=beg, end=end)
	#timeSeries(esPath=esPath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
	timeSeries2(spath=spath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
}
}



##make crisp maps
landform<-raster(paste(spath,"/landform_",Nclust,".tif",sep=''))

#}


#===============================================================================


#initialise file to write to
	pvec<-rbind(predNames)
	x<-cbind("tv",pvec,'r2')
	write.table(x, paste(spath,"/coeffs.txt",sep=""), sep=",",col.names=F, row.names=F)
	write.table(x, paste(spath,"/decompR.txt",sep=""), sep=",",col.names=F, row.names=F)
	

	
	
	for(col in cols){
		#if(col=="X100.000000"){param<-param1}else{param<-param2}
		meanX=read.table( paste(spath, '/meanX_', col,'.txt', sep=''), sep=',')
		#param_cut=timeSeriesCut(esPath=esPath,col=col, sim_dat=param, beg=beg, end=end) # cut timeseries
		coeffs=linMod2(meanX=meanX,listpoints=listpoints, predNames=predNames,col=col) #linear model
		write(coeffs, paste(esPath,"/coeffs.txt",sep=""),ncolumns=7, append=TRUE, sep=",")
	}
	
#mean coeffs table
	weights<-read.table(paste(esPath,"/coeffs.txt",sep=""), sep=",",header=T)
	coeffs_vec=meanCoeffs(weights=weights, nrth=nrth)
	y<-rbind(predNames)
	y <- cbind(y,'r2')
	write.table(y, paste(esPath,"/coeffs_Mean.txt",sep=""), sep=",",col.names=F, row.names=F)
#write(coeffs_vec[1:(length(predNames)+1)], paste(esPath,"/coeffs_Mean.txt",sep=""),ncolumns=(length(predNames)+1), append=TRUE, sep=",")
	write(coeffs_vec, paste(esPath,"/coeffs_Mean.txt",sep=""),ncolumns=(length(predNames)+1), append=TRUE, sep=",")
	weights_mean<-read.table(paste(esPath,"/coeffs_Mean.txt",sep=""), sep=",",header=T)	
	 
#use original samp_dat
informScaleDat1=informScale(data=samp_dat, pnames=predNames,weights=weights_mean)
#kmeans on sample
clust1=Kmeans(scaleDat=informScaleDat1,iter.max=iter.max,centers=Nclust, nstart=nstart1)
#scale whole dataset
informScaleDat2=informScale(data=gridmaps@data, pnames=predNames,weights=weights_mean)
#kmeans whole dataset
clust2=Kmeans(scaleDat=informScaleDat2,iter.max=iter.max,centers=clust1$centers, nstart=nstart2)

#remove small samples, redist to nearestneighbour attribute space
if(samp_reduce==TRUE){
clust3=sample_redist(pix= length(clust2$cluster),samples=Nclust,thresh_per=thresh_per, clust_obj=clust2)# be careful, samlple size not updated only clust2$cluster changed
}else{clust2->clust3}

#make map of clusters
gridmaps$clust <- clust3$cluster
gridmaps$landform <- as.factor(clust3$cluster)
write.asciigrid(gridmaps["clust"], paste(esPath,"/landform_",Nclust,".asc",sep=''),na.value=-9999)

#mean aspect
asp=meanAspect(dat=gridmaps@data, agg=gridmaps$landform)
	
#get full list predNames again (separate to predictor names)
allNames<-names(gridmaps@data)
predNames <- allNames[which(allNames!='clust'&allNames!='landform'&allNames!='asp')]

	fun=c('mean', 'sd', 'sum')
	for (FUN in fun){
		samp=sampleCentroids(dat=gridmaps@data,predNames=predNames, agg=gridmaps$landform, FUN=FUN)
		assign(paste('samp_', FUN, sep=''), samp)
	}
	
#write to disk for cmeans(replaced by kmeans 2)
	write.table(samp_mean,paste(esPath, '/samp_mean.txt' ,sep=''), sep=',', row.names=FALSE)
	write.table(samp_sd,paste(esPath, '/samp_sd.txt' ,sep=''), sep=',', row.names=FALSE)

#make driving topo data file	
lsp <- listpointsMake(samp_mean=samp_mean, samp_sum=samp_sum, asp=asp)
write.table(lsp,paste(esPath, '/listpoints.txt' ,sep=''), sep=',', row.names=FALSE)
	
	
#make horizon files
hor(listPath=esPath)
		
}#end inform scale section


