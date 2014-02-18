#========================================================================
#               make batch file
#========================================================================

batchfile=paste(spath,'/batch.txt',sep='')
file.create(batchfile)

sim_entries=paste(spath,'/result/S*',sep='')
write(paste('cd ',exePath,sep=''),file=batchfile,append=T)
write(paste('parallel', exe, ':::', sim_entries, sep=' '),file=batchfile,append=T)

system(paste('chmod 777 ',spath,'/batch.txt',sep=''))

