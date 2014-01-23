#prepare files for post-process saptialisation
session='gst200_8411'
epath=paste('/home/joel/sim/',session,'_spatial/sim/',sep='')
nbox=c(3:15)

col='X100.000000'
dates='01101984_01102011'
Nclust=200

for(box in nbox){
simindex=formatC(box, width=5,flag='0')
boxf=formatC(box, width=2,flag='0')
print(box)
spath=paste('/home/joel/sim/',session,'/GTSC_nS',box,'_Nc',Nclust,'_',col,'_',dates,'/sim/result/B000',boxf,sep='')

#copy files
file.copy(paste(spath, '/meanX_X100.000000.txt', sep=''), paste(epath, '/meanX_X100.000000_',simindex,'.txt' ,sep=''))
file.copy(paste(spath, '/samp_sd.txt', sep=''), paste(epath, '/samp_sd_',simindex,'.txt' ,sep=''))
file.copy(paste(spath, '/samp_mean.txt', sep=''), paste(epath, '/samp_mean_',simindex,'.txt' ,sep=''))
file.copy(paste(spath, '/mask.tif', sep=''), paste(epath,'/mask_',simindex,'.tif',sep=''))
file.copy(paste(spath, '/landform_',Nclust,'.tif', sep=''), paste(spath,"/landform_",Nclust,'_',simindex,'.tif',sep=''))
}
