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
## get ERA_I for whole domain
	if(fetchERA==T){
	source(paste(root,'/src/TopoAPP/getERAscript.r',sep='')) #test later
	}


## preprocess ERA_I fieldes
print('*** PRE-PROCESSING CLIMATE DATA ***')
source(paste(root,'/src/TopoAPP/toposcale_pre.r',sep=''))

## loop through grid boxs
for(nbox in nboxSeq){

	simindex=formatC(nbox, width=5,flag='0')

	## crisp toposub
	print(paste('*** SET UP BOX ', nbox,' SIMULATION DIRECTORIES ***',sep=''))
	source(paste(root,'/src/TopoAPP/expSetupLoop.r',sep=''))
	print(paste('*** TOPOSUB BOX ', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/toposub_pre_CRISP.r',sep=''))

print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))

#TOPOSCALE PARALLEL
if(parTscale==TRUE){
	setwd(root)
	print(paste('*** TOPOSCALE 1 BOX', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/makebatch_toposcale.R',sep=''))
	setwd(spath)
	system('./batch_tscale.txt')
	setwd(root)
	print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))
	source(paste(root,'/src/TopoAPP/toposcale_writeMet_parallel.R',sep=''))
}

## TOPOSCALE LINEAR
if(parTscale==FALSE){
	print(paste('*** TOPOSCALE 1 BOX', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/toposcale.r',sep=''))
	print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))
	source(paste(root,'/src/TopoAPP/toposcale_writeMet.r',sep=''))
}
	## simulation setup
	print(paste('*** SET UP BOX ', nbox,' SIMULATION 1 ***',sep=''))
	source(paste(root,'/src/TopoAPP/expSetup2.r',sep=''))

	## make simulation .inpts file

	source(paste(root,'/src/TopoAPP/makeInpts.r',sep=''))

	## make batchfile
	source(paste(root,'/src/TopoAPP/makebatch.r',sep=''))

print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))

	## sim 1
	print(paste('*** LSM RUN 1 ON BOX ', nbox,' ***',sep=''))
	setwd(spath)
	system('./batch.txt')

#SUCCESS FILE
outfile=paste(spath,'/RUN_1_SUCCESS.txt',sep='')
file.create(outfile)

print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))

##======= INFORMED SAMPLING -OPTIONAL ===========================================
	if(inform==T){
	print(paste('*** TOPOSUB INFORMED SAMPLING BOX', nbox,' ***',sep=''))
	## post process
	source(paste(root,'/src/TopoAPP/toposub_post_1.r',sep=''))
	source(paste(root,'/src/TopoAPP/toposub_pre_inform.r',sep='')) #-optional

print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))

#TOPOSCALE PARALLEL
if(parTscale==TRUE){
setwd(root)
	print(paste('*** TOPOSCALE 2 BOX', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/makebatch_toposcale.R',sep=''))
	setwd(spath)
	system('./batch_tscale.txt')
setwd(root)
	print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))
	source(paste(root,'/src/TopoAPP/toposcale_writeMet_parallel.R',sep=''))
}

## TOPOSCALE LINEAR
if(parTscale==FALSE){
	print(paste('*** TOPOSCALE 2 BOX ', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/toposcale.r',sep=''))
	print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))
	source(paste(root,'/src/TopoAPP/toposcale_writeMet.r',sep=''))
}

	## simulation setup
	print(paste('*** SET UP BOX ', nbox,' SIMULATION 2',' ***',sep=''))
	source(paste(root,'/src/TopoAPP/expSetup2.r',sep=''))
	## make simulation .inpts file
	
	source(paste(root,'/src/TopoAPP/makeInpts.r',sep=''))

print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))

	## sim 2
	print(paste('*** LSM RUN 2 ON BOX ', nbox,' ***',sep=''))
	setwd(spath)
	system('./batch.txt')
	
	}
#SUCCESS FILE
outfile=paste(spath,'/RUN_2_SUCCESS.txt',sep='')
file.create(outfile)

print(paste('MEMORY USE TOTAL OBJECTS (Mb)= ',round(sum(object.sizes()/1048576),2),sep=''))
#=======================================================================


	if(VALIDATE==T){
	## fuzzy membership -OPTIONAL
	print(paste('*** TOPOSUB FUZZY VALIDATE POINTS BOX ', nbox ,' ***',sep=''))

	##read in val points
	#valPoints <- read.table(paste(root, '/src/valPoints.txt' ,sep=''), sep=',',header=T)
	##read in sample centroid data
	samp_mean <- read.table(paste(spath, '/samp_mean.txt' ,sep=''), sep=',',header=T)
	samp_sd <- read.table(paste(spath, '/samp_sd.txt' ,sep=''), sep=',', header=T)

	fuzMemMat=valPoints(esPath=spath,predNames=predNames,cells,data=valPoints, samp_mean=samp_mean, samp_sd=samp_sd, 		Nclust=Nclust,fuzzy.e=fuzzy.e)
	}


	if(fuzzy==T){
	## fuzzy membership -OPTIONAL
	print(paste('*** TOPOSUB FUZZY MEMBERSHIP BOX ', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/toposub_pre_fuzzy.r',sep='')) #-optional
	}

	## post process
	print(paste('*** TOPOSUB POST-PROCESS BOX ', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/toposub_post_2.r',sep=''))
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
