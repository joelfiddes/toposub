######################################################################################################
#	
#			TOPOSUB POSTPROCESSOR 2
#			
######################################################################################################

outfile=paste(spath,'/meanX_',col,'.txt',sep='')
file.create(outfile)

for ( i in 1:Nclust){
gsimindex=formatC(i, width=5,flag='0')
simpath=paste(spath,'/result/S', gsimindex,sep='')


#read in lsm output
sim_dat=read.table(paste(simpath,file1,sep=''), sep=',', header=T)
#cut timeseries
sim_dat_cut=timeSeriesCut(esPath=simpath,col=col, sim_dat=sim_dat, beg=beg, end=end)	
#mean annual values
timeSeries2(spath=spath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
}
#write success file
outfile=paste(spath,'/POSTPROCESS_2_SUCCESS.txt',sep='')
file.create(outfile)
##make crisp maps
landform<-raster(paste(spath,"/landform_",Nclust,predFormat,sep=''))

if(crisp==TRUE){
crispSpatial2(col=col,Nclust=Nclust,esPath=spath, landform=landform)
}
#make fuzzy maps
if(fuzzy==TRUE){
	mask=raster(paste(spath,'/mask',predFormat,sep=''))
	#fuzSpatial(col=col, esPath=spath, format=predFormat, Nclust=Nclust,mask=mask)
fuzSpatial_subsum(col=col, esPath=spath, format=predFormat, Nclust=Nclust, mask=mask)
	}

if(VALIDATE==TRUE){
dat <- read.table(paste(spath,'/meanX_',col,'.txt',sep=''), sep=',',header=F)
dat<-dat$V1
fuzRes=calcFuzPoint(dat=dat,fuzMemMat=fuzMemMat)

write.table(fuzRes,paste(outpath, '/fuzRes.txt', sep=''), sep=',', row.names=FALSE)
}

##==============================================================================
## MERGE RASTERS
##==============================================================================
#rs=list.files(epath, pattern='X100.000000_100.tif', recursive=T)
#rst=paste(epath,rs,sep='')
#rmerge=round(merge(raster(rst[1]),raster(rst[2]),raster(rst[3]),raster(rst[4]),raster(rst[5]),raster(rst[6]),raster(rst[7]),raster(rst[8]),raster(rst[9]),raster(rst[10]),raster(rst[11]),raster(rst[12]),raster(rst[13]),raster(rst[14]),raster(rst[15]),raster(rst[16]),raster(rst[17]),raster(rst[18])),1)


#writeRaster(rmerge, paste(epath,'rmerge3.tif',sep=''), NAflag=-9999,overwrite=T,options="COMPRESS=LZW")
#t4=Sys.time()-t1

#png('/home/joel/Documents/posters_presentations/kolloqium/alps.png',width=1200,height=900)
#plot(rmerge, col=matlab.like(100),maxpixels=3000000)
#dev.off()


