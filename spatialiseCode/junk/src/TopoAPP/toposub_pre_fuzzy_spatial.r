######################################################################################################
#	
#			TOPOSUB PREPROCESSOR -fuzzy
#			
######################################################################################################



res=extentandcells(rstPath=demLoc)
cells <- res$cells
ext <- res$x
fuzzyMember(esPath=spath,ext=ext,cells=cells,predNames=predNames2,data=gridmaps@data, samp_mean=samp_mean,samp_sd=samp_sd, Nclust=Nclust)

if(fuzReduce==TRUE){
topMembers(esPath=spath, Nclust=Nclust,nFuzMem)
}
