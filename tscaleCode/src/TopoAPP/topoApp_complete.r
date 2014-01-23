#TOPOAPP - gridboxes (as opposed to points/mf)
t1=Sys.time()
#=======================================================================================================
#			SET EXPERIMENT ROOT
#=======================================================================================================
root=
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

	##make listpoints and surface
	source(paste(root,'/src/TopoAPP/subsetPoints.R',sep=''))

	## toposcale
	print(paste('*** TOPOSCALE 1 BOX', nbox,' ***',sep=''))
	source(paste(root,'/src/TopoAPP/toposcale.r',sep=''))
	source(paste(root,'/src/TopoAPP/toposcale_writeMet.r',sep=''))

	## simulation setup
	print(paste('*** SET UP BOX ', nbox,' SIMULATION 1 ***',sep=''))
	source(paste(root,'/src/TopoAPP/expSetup2.r',sep=''))

	## make simulation .inpts file

	source(paste(root,'/src/TopoAPP/makeInpts.r',sep=''))

	## make batchfile
	source(paste(root,'/src/TopoAPP/makebatch.r',sep=''))

if(SIMULATE==TRUE){
	# sim 1
	print(paste('*** LSM RUN 1 ON BOX ', nbox,' ***',sep=''))
	setwd(spath)
	system('./batch.txt')
}
}
t2=t1-Sys.time()
print(paste('*** BOX ', nbox,' COMPLETE: ',t2,' ***',sep=''))

#source('/home/joel/src/hobbes_utils/biasCode/scfPeturb.R') #generate peturbed scf simulate all
#source('/home/joel/src/hobbes_utils/biasCode/calcSCF.R') # calc true scf
#nboxSeq=c(4:14)
#source('/home/joel/src/hobbes_utils/biasCode/setSCF.R') #re-sim with true scf


write.table(NULL,paste(spath, '/_RUN_COMPLETE',sep=''))
