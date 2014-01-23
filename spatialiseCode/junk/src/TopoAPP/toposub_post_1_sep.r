######################################################################################################
#	
#			TOPOSUB POSTPROCESSOR 1
#			
######################################################################################################
file1<-'/out/surface.txt' #path of geotop output file relative to sim directory
beg <- "01/10/1996 00:00:00" #start cut of data timeseries dd/mm/yyyy h:m:s
end <- "01/10/2011 00:00:00" #end cut data timeseries

for(n in c(4,5,7:12)){
n2=formatC(n, width=2,flag='0')
spath=paste("/home/joel/sim/tsub5y_GST/GTSC_nS",n,"_Nc100_X100.000000_01102006_01102011/sim/result/B000",n2,sep='')



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
}
