#v.6 
#21/3/2012
#needs 2.5GB memory
#==============================================================================
# locations
#==============================================================================
toposub_crisp<-function(epath,spath,Nclust,fuzzy=1, crisp=1,doInformScale=0,cols=c("X100.000000"),rad=TRUE){
require(raster)
#source('/home/joel/src/code_toposub/toposub_src.r')

#epath='/home/joel/experiments/alpsSim'
#i=1
#spath=paste(epath, '/box', i,sep='') #simulation path
#Nclust=10
#fuzzy=0
#crisp=1
#doInformScale=0
#cols=c("X100.000000")
#rad=TRUE # slope aspect input files radians or degrees?
#set root
#root='/group/geotop/sim/toposub/'
#setwd(root)

#set imulation paths
eroot_loc1 <- epath
esPath <- spath#experiment path #spath


#lsm exe
#gtexPath= paste(root, "/geotop1.224/bin/ls2", sep='')# gt executable path
#gtex ='./geotop1_224' #gt executable 

#input locations
demLoc=paste(esPath,'/ele.tif',sep='')
predRoot=esPath

#set tmp directory for raster package
setOptions(tmpdir=paste(spath, '/tmp', sep=''))


#==============================================================================
# 			TOPOSUB PARAMETERS
#==============================================================================

#key parameters
Nclust =Nclust#<-Nclust [K]
iter.max=20# clusters if prescribed#check 000029 for 100 iter heavy averaging somehow
nRand=100000#sample size
fuzzy.e=1.4 #[M]
nstart1=10 # nstart for sample kmeans [find centers]
nstart2=1 #nstart for entire data kmeans [apply centers]
thresh_per=0.001 # needs experimenting with

# input predictors
predNames<-c('ele', 'slp', 'asp', 'svf') #[PRED]
predFormat='.tif'

#target variables
#cols=c("X100.000000", "SWin.W.m2.", "snow_water_equivalent.mm.", "Tair.C.")# [TV]
cols=cols

#switches
fuzzy=fuzzy #do fuzzy membership
crisp=crisp #do crisp membership
doInformScale=doInformScale
findn=0
samp_reduce=TRUE#rm insig sample, redist members

#experimental parameters [normal behaviour all = FALSE]
randomKmeansInit=FALSE#



#==============================================================================
# other PARAMETERS
#==============================================================================
#========== remove?
##findN
#findn=0
#nMax=200
#thresh=0.05

##plotN
#nrmseError=0.05

##fuzzExp
#feMin=1.2
#feMax=1.8
#step=0.1
#==========remove


#method to concatenate
"&" <- function(...) UseMethod("&") 
"&.default" <- .Primitive("&") 
"&.character" <- function(...) paste(...,sep="") 


#==============================================================================
# TopoSUB preprocessor
#==============================================================================

#set work dir
setwd(eroot_loc1)

##set up folders/ copy files etc
#dir.create(esPath)
dir.create(paste(esPath, '/fuzRst', sep=''))
dir.create(paste(esPath, '/rec', sep=''))
#paste(esPath,'/_master',sep='')->mst
#dir.create(mst)

#copy geotop.inpts to sim dir
#file.copy(paste(eroot_loc1,'/_master/geotop.inpts',sep=''),esPath , overwrite=T)

#copy meteo files to sim dir
#file.copy(paste(eroot_loc1,'/_master/meteo0001.txt',sep=''), mst)
#file.copy(paste(eroot_loc1,'/_master/meteo0002.txt',sep=''), mst)

#make stack of input predictor ==> read in random sample to improve scalability
gridmaps=stack_raster(demLoc=demLoc, predNames=predNames, predRoot=predRoot, predFormat=predFormat)

#check inputs slp/asp in degrees and correct if necessary (careful if applied in flat place!)
if(rad==T){
	gridmaps$asp = radtodeg(gridmaps$asp)
}
if(rad==T){
	gridmaps$slp = radtodeg(gridmaps$slp)
}

#na to numeric (-1) (does this work)
gridmaps@data = natonum(x=gridmaps@data,predNames=predNames ,n=-1)

#decompose aspect
res=aspect_decomp(gridmaps$asp)
res$aspC->gridmaps$aspC
res$aspS->gridmaps$aspS

#define new predNames (aspC, aspS)
allNames<-names(gridmaps@data)

#sample inputs
#need to generalise to accept 'data' argument
samp_dat<-sampleRandomGrid( nRand=nRand, predNames=predNames)

if (findn==1){Nclust=findN(scaleDat=scaleDat, nMax=1000,thresh=0.05)}

#make scaled (see r function 'scale()')data frame of inputs 
scaleDat_samp= simpleScale(data=samp_dat, pnames=predNames)

#random order of kmeans init conditions (variable order) experiment
if(randomKmeansInit==T){
cbind(scaleDat_samp[5],scaleDat_samp[4], scaleDat_samp[3], scaleDat_samp[2], scaleDat_samp[1])->scaleDat_samp
}

#kmeans on sample
clust1=Kmeans(scaleDat=scaleDat_samp,iter.max=iter.max,centers=Nclust, nstart=nstart1)

#scale whole dataset
scaleDat_all= simpleScale(data=gridmaps@data, pnames=predNames)

#kmeans whole dataset
clust2=Kmeans(scaleDat=scaleDat_all,iter.max=iter.max,centers=clust1$centers, nstart=nstart2)

#remove small samples, redist to nearestneighbour attribute space
if(samp_reduce==TRUE){
clust3=sample_redist(pix= length(clust2$cluster),samples=Nclust,thresh_per=thresh_per, clust_obj=clust2)# be careful, samlple size not updated only clust2$cluster changed
}else{clust2->clust3}

#confused by these commented out lines
#gridmaps$clust <- clust3$cluster
#write.asciigrid(gridmaps["landform"], paste(esPath,"/landform_",Nclust,".tif",sep=''),na.value=-9999)

#make map of clusters 
gridmaps$landform <- as.factor(clust3$cluster)
writeRaster(raster(gridmaps["landform"]), paste(esPath,"/landform_",Nclust,".tif",sep=''),NAflag=-9999)



asp=meanAspect(dat=gridmaps@data, agg=gridmaps$landform)

fun=c('mean', 'sd', 'sum')
for (FUN in fun){
	samp=sampleCentroids(dat=gridmaps@data,predNames=predNames, agg=gridmaps$landform, FUN=FUN)
	assign(paste('samp_', FUN, sep=''), samp)
}
samp_mean$asp<-asp
#issue with sd and sum of aspect - try use 'circular'

#write to disk for cmeans(replaced by kmeans 2)
write.table(samp_mean,paste(esPath, '/samp_mean.txt' ,sep=''), sep=',', row.names=FALSE)
write.table(samp_sd,paste(esPath, '/samp_sd.txt' ,sep=''), sep=',', row.names=FALSE)

#make driving topo data file	
lsp <- listpointsMake(samp_mean=samp_mean, samp_sum=samp_sum)
write.table(lsp,paste(esPath, '/listpoints.txt' ,sep=''), sep=',', row.names=FALSE)
#make horizon files
hor(listPath=esPath)

#=================================================================================================================================
##beg inform scale section
#if(doInformScale==1){		

##training sim of LSM
#setwd(gtexPath)
#system(paste(gtex,esPath, sep=' '))

##rm old gt report files and rec dir
#setwd(esPath)
##system('rm _FAILED_*')
#system('rm _SUCCESSFUL_*')
#system('rm -r rec')
#dir.create('rec')
#setwd(eroot_loc1)


##read in output
#file1<-'/soil_tem.txt'
#file2<-'/point.txt'
#param1<-read.table(paste(esPath,file1,sep=''), sep=',', header=T)
#param2<-read.table(paste(esPath,file2,sep=''), sep=',', header=T)

#for (col in cols){
#	
#	if(col=="X100.000000"){file<-'/soil_tem.txt'}else{file<-'/point.txt'}
#	if(col=="X100.000000"){sim_dat<-param1}else{sim_dat<-param2}
#	
#	sim_dat_cut=timeSeriesCut(esPath=esPath,col=col, sim_dat=sim_dat, beg=beg, end=end)
#	
#	timeSeries(esPath=esPath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
#}

#landform<-raster(paste(esPath,"/landform_",Nclust,".asc",sep=''))

##initialise file to write to
#	pvec<-rbind(predNames)
#	x<-cbind("tv",pvec,'r2')
#	write.table(x, paste(esPath,"/coeffs.txt",sep=""), sep=",",col.names=F, row.names=F)
#	write.table(x, paste(esPath,"/decompR.txt",sep=""), sep=",",col.names=F, row.names=F)
#	

#	file1<-'/soil_tem.txt'
#	file2<-'/point.txt'
#	param1<-read.table(paste(esPath,file1, sep=''), sep=',', header=T)
#	param2<-read.table(paste(esPath,file2, sep=''), sep=',', header=T)
#	
#	
#	for(col in cols){
#		if(col=="X100.000000"){param<-param1}else{param<-param2}
#		param_cut=timeSeriesCut(esPath=esPath,col=col, sim_dat=param, beg=beg, end=end) # cut timeseries
#		coeffs=linMod(param=param_cut,col=col, predNames=predNames, mod=mod, scaleIn=scaleIn) #linear model
#		write(coeffs, paste(esPath,"/coeffs.txt",sep=""),ncolumns=7, append=TRUE, sep=",")
#	}
#	
##mean coeffs table
#	weights<-read.table(paste(esPath,"/coeffs.txt",sep=""), sep=",",header=T)
#	coeffs_vec=meanCoeffs(weights=weights, nrth=nrth)
#	y<-rbind(predNames)
#	y <- cbind(y,'r2')
#	write.table(y, paste(esPath,"/coeffs_Mean.txt",sep=""), sep=",",col.names=F, row.names=F)
##write(coeffs_vec[1:(length(predNames)+1)], paste(esPath,"/coeffs_Mean.txt",sep=""),ncolumns=(length(predNames)+1), append=TRUE, sep=",")
#	write(coeffs_vec, paste(esPath,"/coeffs_Mean.txt",sep=""),ncolumns=(length(predNames)+1), append=TRUE, sep=",")
#	weights_mean<-read.table(paste(esPath,"/coeffs_Mean.txt",sep=""), sep=",",header=T)	
#	 
##use original samp_dat
#informScaleDat1=informScale(data=samp_dat, pnames=predNames,weights=weights_mean)
##kmeans on sample
#clust1=Kmeans(scaleDat=informScaleDat1,iter.max=iter.max,centers=Nclust, nstart=nstart1)
##scale whole dataset
#informScaleDat2=informScale(data=gridmaps@data, pnames=predNames,weights=weights_mean)
##kmeans whole dataset
#clust2=Kmeans(scaleDat=informScaleDat2,iter.max=iter.max,centers=clust1$centers, nstart=nstart2)

##remove small samples, redist to nearestneighbour attribute space
#if(samp_reduce==TRUE){
#clust3=sample_redist(pix= length(clust2$cluster),samples=Nclust,thresh_per=thresh_per, clust_obj=clust2)# be careful, samlple size not updated only clust2$cluster changed
#}else{clust2->clust3}

##make map of clusters
#gridmaps$clust <- clust3$cluster
#gridmaps$landform <- as.factor(clust3$cluster)
#write.asciigrid(gridmaps["clust"], paste(esPath,"/landform_",Nclust,".asc",sep=''),na.value=-9999)

##mean aspect
#asp=meanAspect(dat=gridmaps@data, agg=gridmaps$landform)
#	
##get full list predNames again (separate to predictor names)
#allNames<-names(gridmaps@data)
#predNames <- allNames[which(allNames!='clust'&allNames!='landform'&allNames!='asp')]

#	fun=c('mean', 'sd', 'sum')
#	for (FUN in fun){
#		samp=sampleCentroids(dat=gridmaps@data,predNames=predNames, agg=gridmaps$landform, FUN=FUN)
#		assign(paste('samp_', FUN, sep=''), samp)
#	}
#	
##write to disk for cmeans(replaced by kmeans 2)
#	write.table(samp_mean,paste(esPath, '/samp_mean.txt' ,sep=''), sep=',', row.names=FALSE)
#	write.table(samp_sd,paste(esPath, '/samp_sd.txt' ,sep=''), sep=',', row.names=FALSE)

##make driving topo data file	
#lsp <- listpointsMake(samp_mean=samp_mean, samp_sum=samp_sum, asp=asp)
#write.table(lsp,paste(esPath, '/listpoints.txt' ,sep=''), sep=',', row.names=FALSE)
#	
#	
##make horizon files
#hor(listPath=esPath)
#		
#}#end inform scale section
##====================================================================================================================================




#}



















#==================================preprocessor output=========================
#vector sample weights 'lsp$members'
#crisp membership map  'landform.asc'
#fuzzyMember maps 'raster_temp' folder


#==============================================================================
# LSM
#==============================================================================

## LSM
#setwd(gtexPath)
#system(paste(gtex,esPath, sep=' '))
#setwd(eroot_loc1)

##==============================================================================
## TopoSUB postprocessor
##==============================================================================

##read in lsm output
#file1<-'/soil_tem.txt'
#file2<-'/point.txt'
#param1<-read.table(paste(esPath,file1,sep=''), sep=',', header=T)
#param2<-read.table(paste(esPath,file2,sep=''), sep=',', header=T)

##cut timeseries
#for (col in cols){
#	
#	if(col=="X100.000000"){file<-'/soil_tem.txt'}else{file<-'/point.txt'}
#	if(col=="X100.000000"){sim_dat<-param1}else{sim_dat<-param2}
#	sim_dat_cut=timeSeriesCut(esPath=esPath,col=col, sim_dat=sim_dat, beg=beg, end=end)
#	timeSeries(esPath=esPath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
#}

##make crisp maps
#if(crisp==1){
#landform<-raster(paste(esPath,"/landform_",Nclust,".asc",sep=''))

#for (col in cols){
#	crispSpatial(col=col,Nclust=Nclust, esPath=esPath, landform = landform)
#}
#}

##make fuzzy maps
#if(fuzzy==1){

#for (col in cols){
#	spatial(col=col, esPath=esPath, format='asc', Nclust=Nclust)
#	}

###cleanup temp fuzzy member files
#setwd(esPath)
#system('rm -r raster_tmp/')
#}






