######################################################################################################
#	
#			EXPERIMENT SETUP 2
#			
######################################################################################################

#========================================================================
#		MAKE LISTPOINTS for sim dir
#========================================================================

for(i in 1:npoints){
gsimindex=formatC(nameVec[i], width=5,flag='0')
n=nameVec[i]
listp=data.frame(mf$id[n], mf$ele[n], mf$asp[n], mf$slp[n], mf$svf[n])
listp=round(listp,2)
names(listp)<-c('id', 'ele', 'asp', 'slp', 'svf')
write.table(listp, paste(spath, '/result/S',gsimindex, '/listpoints.txt', sep=''), sep=',',row.names=F)
}

#========================================================================
#		MAKE HORIZON for sim dir
#========================================================================

for(i in 1:npoints){
gsimindex=formatC(nameVec[i], width=5,flag='0')
hor(listPath=paste(spath, '/result/S',gsimindex, sep=''))
}





#========================================================================
#		RECORD SRC AND SCRIPTS
#========================================================================
#write logs of script and src
#file.copy(paste(root,'src/toposub_script.r', sep=''), paste(esPath,'/toposub_script_copy.r',sep=''),overwrite=T)
#file.copy(paste(root,'/src/',src, sep=''),  paste(esPath,'/',src,'_copy.r',sep=''),overwrite=T)



#========================================================================
#		MAKE MEGA BATCH
#========================================================================
#system('cd /home/joel/experiments/alpsSim/_master/')
#system('./megabatch.txt')
#========================================================================
#		RUN GEOTOP
#========================================================================



