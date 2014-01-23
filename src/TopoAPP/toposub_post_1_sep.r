######################################################################################################
#	
#			TOPOSUB POSTPROCESSOR 1
#			
######################################################################################################
source('/home/joel/sim/src_master/src/code_toposub/toposub_src.r')
file1<-'/out/ground.txt' #path of geotop output file relative to sim directory
beg <- "01/10/1996 00:00:00" #start cut of data timeseries dd/mm/yyyy h:m:s
end <- "01/10/2011 00:00:00" #end cut data timeseries
col='X100.000000'
Nclust=200

for(n in c(9)){
n2=formatC(n, width=2,flag='0')

spath=paste("/home/joel/group/geotop/sim/cryosub/topoApp/gst200/GTSC_nS",n,"_Nc100_X100.000000_01101996_01102011/sim/result/B000",n2,sep='')
spath='/home/joel/group/geotop/sim/cryosub/topoApp/gst200/GTSC_nS9_Nc200_X100.000000_01101996_01102011/sim/result/B00009'


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
