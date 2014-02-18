######################################################################################################
#	
#			TOPOSUB PREPROCESSOR INFORMED SAMPLING
#			
######################################################################################################

#read listpoint
listpoints=read.table(paste(spath,'/listpoints.txt',sep=''), sep=',',header=T)

#make stack of input predictor ==> read in random sample to improve scalability
#gridmaps=stack_raster(demLoc=demLoc, predNames=predNames, predRoot=predRoot, predFormat=predFormat)

##make stack of input predictor ==> read in random sample to improve scalability
#gridmaps=stack_raster(demLoc=demLoc, predNames=predNames, predRoot=spath, predFormat=predFormat)

##check inputs slp/asp in degrees and correct if necessary (careful if applied in flat place!)
#if(rad==T){
#	gridmaps$asp = radtodeg(gridmaps$asp)
#}
#if(rad==T){
#	gridmaps$slp = radtodeg(gridmaps$slp)
#}

##na to numeric (-1) (does this work)
#gridmaps@data = natonum(x=gridmaps@data,predNames=predNames ,n=-1)

##decompose aspect
#res=aspect_decomp(gridmaps$asp)
#res$aspC->gridmaps$aspC
#res$aspS->gridmaps$aspS

##define new predNames (aspC, aspS)
#allNames<-names(gridmaps@data)
#predNames2 <- allNames[which(allNames!='landform'&allNames!='asp')]


#initialise file to write to
pvec<-rbind(predNames2)
x<-cbind("tv",pvec,'r2')
write.table(x, paste(spath,"/coeffs.txt",sep=""), sep=",",col.names=F, row.names=F)
write.table(x, paste(spath,"/decompR.txt",sep=""), sep=",",col.names=F, row.names=F)

meanX=read.table( paste(spath, '/meanX_', col,'.txt', sep=''), sep=',')
coeffs=linMod2(meanX=meanX,listpoints=listpoints, predNames=predNames2,col=col) #linear model
write(coeffs, paste(spath,"/coeffs.txt",sep=""),ncolumns=7, append=TRUE, sep=",")

weightsMean<-read.table(paste(spath,"/coeffs.txt",sep=""), sep=",",header=T)

#==========mean coeffs table for multiple preds ================================
#coeffs_vec=meanCoeffs(weights=weights, nrth=nrth) #rmove nrth
##y<-rbind(predNames)
#y <- cbind(y,'r2')
#write.table(y, paste(esPath,"/coeffs_Mean.txt",sep=""), sep=",",col.names=F, row.names=F)
#write(coeffs_vec, paste(esPath,"/coeffs_Mean.txt",sep=""),ncolumns=(length(predNames)+1), append=TRUE, sep=",")
#weightsMean<-read.table(paste(esPath,"/coeffs_Mean.txt",sep=""), sep=",",header=T)	
	
#samp_dat<-sampleRandomGrid( nRand=nRand, predNames=predNames2)
#use original samp_dat
informScaleDat1=informScale(data=samp_dat, pnames=predNames2,weights=weightsMean)

#remove NA's from dataset (not tolerated by kmeans)
informScaleDat_samp=na.omit(informScaleDat1)

#kmeans on sample
clust1=Kmeans(scaleDat=informScaleDat_samp,iter.max=iter.max,centers=Nclust, nstart=nstart1)
#scale whole dataset
informScaleDat2=informScale(data=gridmaps@data, pnames=predNames2,weights=weightsMean)

#remove NA's from dataset (not tolerated by kmeans)
informScaleDat_all=na.omit(informScaleDat2)
#kmeans whole dataset
clust2=Kmeans(scaleDat=informScaleDat_all,iter.max=iter.max,centers=clust1$centers, nstart=nstart2)

#**CLEANUP**
rm(informScaleDat_all)
rm(clust1)

#remove small samples, redist to nearestneighbour attribute space
if(samp_reduce==TRUE){
clust3=sample_redist(pix= length(clust2$cluster),samples=Nclust,thresh_per=thresh_per, clust_obj=clust2)# be careful, samlple size not updated only clust2$cluster changed
}else{clust2->clust3}
#**CLEANUP**
rm(clust2)
#confused by these commented out lines
#gridmaps$clust <- clust3$cluster
#write.asciigrid(gridmaps["landform"], paste(esPath,"/landform_",Nclust,".tif",sep=''),na.value=-9999)

#make map of clusters 

# new method to deal with NA values 
#vector of non NA index
n2=which(is.na(informScaleDat2$ele)==FALSE)
#make NA vector
vec=rep(NA, dim(informScaleDat2)[1])
#replace values
vec[n2]<-as.factor(clust3$cluster)

#**CLEANUP**
rm(informScaleDat2)

gridmaps$landform <- vec
writeRaster(raster(gridmaps["landform"]), paste(spath,"/landform_",Nclust,".tif",sep=''),NAflag=-9999,overwrite=T)

fun=c('mean', 'sd', 'sum')
for (FUN in fun){
	samp=sampleCentroids(dat=gridmaps@data,predNames=predNames2, agg=gridmaps$landform, FUN=FUN)
	assign(paste('samp_', FUN, sep=''), samp)
}

#replace asp with correct mmean asp
asp=meanAspect(dat=gridmaps@data, agg=gridmaps$landform)
samp_mean$asp<-asp
#issue with sd and sum of aspect - try use 'circular'

#write to disk for cmeans(replaced by kmeans 2)
write.table(samp_mean,paste(spath, '/samp_mean.txt' ,sep=''), sep=',', row.names=FALSE)
write.table(samp_sd,paste(spath, '/samp_sd.txt' ,sep=''), sep=',', row.names=FALSE)

#make driving topo data file	
lsp <- listpointsMake(samp_mean=samp_mean, samp_sum=samp_sum)
write.table(lsp,paste(spath, '/listpoints.txt' ,sep=''), sep=',', row.names=FALSE)
	
	
#make horizon files
hor(listPath=spath)

#get modal surface type of each sample 1=debris, 2=steep bedrock, 3=vegetation
zoneStats=getSampleSurface(spath=spath,Nclust=Nclust, predFormat=predFormat)
write.table(zoneStats, paste(spath,'/landcoverZones.txt',sep=''),sep=',', row.names=F)		

#**CLEANUP**
rm(clust3)
rm(gridmaps)

#write success file
outfile=paste(spath,'/TOPOSUB_PRE_INFORM_SUCCESS.txt',sep='')
file.create(outfile)
