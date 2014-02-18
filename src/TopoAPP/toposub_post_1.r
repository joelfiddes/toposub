######################################################################################################
#	
#			TOPOSUB POSTPROCESSOR 1
#			
######################################################################################################


outfile=paste(spath,'/meanX_',col,'.txt',sep='')
file.create(outfile)

for ( i in 1:Nclust){
gsimindex=formatC(i, width=5,flag='0')
simpath=paste(spath,'/result/S', gsimindex,sep='')
#esPath=simpath

#read in lsm output
sim_dat=read.table(paste(simpath,file1,sep=''), sep=',', header=T)
#cut timeseries
sim_dat_cut=timeSeriesCut(esPath=simpath,col=col, sim_dat=sim_dat, beg=beg, end=end)	
#mean annual values
timeSeries2(spath=spath,col=col, sim_dat_cut=sim_dat_cut,FUN=mean)
}
