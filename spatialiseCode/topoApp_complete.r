#TOPOAPP - gridboxes (as opposed to points/mf)
t1=Sys.time()
#=======================================================================================================
#			SET EXPERIMENT ROOT
#=======================================================================================================
root=

#======================================================================================
#				MEMORY PROFILE FUNCTION
#======================================================================================
object.sizes <- function()
{
	return(rev(sort(sapply(ls(envir=.GlobalEnv), function (object.name)
										object.size(get(object.name))))))
}
#======================================================================================
#				CODE
#======================================================================================
## parameter file
source(paste(root,'/src/TopoAPP/parfile.r',sep=''))
## experiment setup
source(paste(root,'/src/TopoAPP/expSetup1.r',sep=''))




## loop through grid boxs
for(nbox in nboxSeq){

	simindex=formatC(nbox, width=5,flag='0')

	## crisp toposub
	print(paste('*** SET UP BOX ', nbox,' SIMULATION DIRECTORIES ***',sep=''))
	source(paste(root,'/src/TopoAPP/expSetupLoop.r',sep=''))
	print(paste('*** READ IN TOPO DATA ', nbox,' ***',sep=''))

#==========================REQUIRED LINES FROM TOPOSUB_CRISP================================================

#======================================================================================
#				SEGMENT TOPOGRAPHY BY BOX
#======================================================================================
demC=crop(ddem, dshp[nbox,])
daspC=crop(dasp, dshp[nbox,])
dslpC=crop(dslp, dshp[nbox,])
dskyC=crop(dsky, dshp[nbox,])
maskC=crop(mask, dshp[nbox,])
lcC=crop(lc, dshp[nbox,])
writeRaster(demC, paste(spath,'/preds/ele.tif',sep=''), NAflag=-9999, overwrite=T) #(tif is smallest format half of size sdat etc)
writeRaster(daspC, paste(spath,'/preds/asp.tif',sep=''), NAflag=-9999,overwrite=T)
writeRaster(dslpC, paste(spath,'/preds/slp.tif',sep=''), NAflag=-9999,overwrite=T)
writeRaster(dskyC, paste(spath,'/preds/svf.tif',sep=''), NAflag=-9999,overwrite=T)
writeRaster(maskC, paste(spath,'/mask.tif',sep=''), NAflag=-9999,overwrite=T)
writeRaster(lcC, paste(spath,'/surface.tif',sep=''), NAflag=-9999,overwrite=T)


#======================================================================================
#				Apply mask (glacier)
#======================================================================================
mask=raster(paste(spath,'/mask.tif',sep=''))
predfiles=list.files(path=predRoot, pattern=predFormat,full.names=T)

for(pf in predfiles){
rst=raster(pf)
rst[is.na(rst)]<- -1 # when flat aspects are coded NA
rst.mask=rst*mask

writeRaster(rst.mask, pf, NAflag=-9999, overwrite=T) 
}

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


#===============================================================================================	
#READ IN REQUIRED FILES (box suffix)

samp_mean <- read.table(paste(epath, '/_master/samp_mean_',simindex,'.txt' ,sep=''), sep=',',header=T)
samp_sd <- read.table(paste(epath, '/_master/samp_sd_',simindex,'.txt' ,sep=''), sep=',', header=T)
mask=raster(paste(epath,'/_master/mask_',simindex,'.tif',sep=''))
landform<-raster(paste(epath,"/_master/landform_",Nclust,'_',simindex,predFormat,sep=''))

#=======================================================================
#dat <- read.table(paste(epath,'/_master/meanX_',col,'_',simindex,'.txt',sep=''), sep=',',header=F)
file.copy(paste(epath,'/_master/meanX_',col,'_',simindex,'.txt',sep=''),paste(spath,'/meanX_',col,'.txt',sep=''))


#=======================================================================================
#			compute fuzzy membership		
#======================================================================================

	print(paste('*** COMPUTE MEMBERSHIP ', nbox,' ***',sep=''))

if(fuzzy==TRUE){
res=extentandcells(rstPath=demLoc)
cells <- res$cells
ext <- res$x
fuzzyMember(esPath=spath,ext=ext,cells=cells,predNames=predNames2,data=gridmaps@data, samp_mean=samp_mean,samp_sd=samp_sd, Nclust=Nclust)
}

if(fuzReduce==TRUE){
topMembers(esPath=spath, Nclust=Nclust,nFuzMem)
}

print(paste('*** SPATIALISE ', nbox,' ***',sep=''))
#source(paste(root,'/src/TopoAPP/toposub_post_2_spatial.r',sep=''))
if(crisp==TRUE){
crispSpatial2(col=col,Nclust=Nclust,esPath=spath, landform=landform)
}
#make fuzzy maps
if(fuzzy==TRUE){
	mask=raster(paste(spath,'/mask',predFormat,sep=''))
	#fuzSpatial(col=col, esPath=spath, format=predFormat, Nclust=Nclust,mask=mask)
fuzSpatial_subsum(col=col, esPath=spath, format=predFormat, Nclust=Nclust, mask=mask)
	}


}

t2=Sys.time()-t1
print(paste('*** BOX ', nbox,' COMPLETE: ',t2,' ***',sep=''))

# write completion flag conditional on fuzzy option (main mode) being selected
#if(fuzzy==T){
#fexist=list.files(outpath, pattern = 'fuz')
#if(length(fexist)==1){write.table(NULL,paste(spath, '/_RUN_COMPLETE',sep=''))}
#if(length(fexist)==0){write.table(NULL,paste(spath, '/_RUN_FAILED',sep=''))}
#}

write.table(NULL,paste(spath, '/_RUN_COMPLETE',sep=''))
