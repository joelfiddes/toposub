#nbox=10
#LOOP HERE

nboxSeq=nboxSeq

for(box in nboxSeq){
gsimindex=formatC(box, width=5,flag='0')
spath=paste(root,'/sim/result/B',gsimindex,sep='')
#sets computed scf for simulations where possible to compute (according to data missing criteria in calcSCF.R)
scf=read.table(paste(root,'/scfvec',box,'.txt',sep=''), sep=',', header=T)
valPoints=which(is.na(scf)==F)
if(length(valPoints)==0){next}
scfVal=scf[valPoints,]


spathCopy=paste(spath,'scf',sep='_')
exePath='/home/joel/src/geotop/'#remove
exe='./geotop1.225-13'#remove


source('/home/joel/src/hobbes_tscale/src/tscale_final/gt_control.r')#remove

parfilename='geotop.inpts'
npoints=length(list.files(paste(spath,'/result/',sep=''), 'S'))




system(paste('cp -r ',spath,'  ' ,spathCopy, sep=''))

for(n in 1:length(valPoints)){
i=valPoints[n]
v=scfVal[n]
gsimindex=formatC(i, width=5,flag='0')
expRoot= paste(spath, '/result/S',gsimindex, sep='')
fs=readLines(paste(expRoot,parfilename, sep='/')) 
scf=gt.par.fline(fs=fs, keyword='SnowCorrFactor') 
fs=gt.par.wline(fs=fs,ln=scf,vs=v)


comchar<-"!" 
expRoot= paste(spathCopy, '/result/S',gsimindex, sep='')
con <- file(paste(expRoot,parfilename,sep='/'), "w")  
	cat(comchar,"SCRIPT-GENERATED EXPERIMENT FILE",'\n', file = con,sep="")
	cat(fs, file = con,sep='\n')
	close(con)


}

#========================================================================================
#			MAKE BATCH
#======================================================================================
batchfile=paste(spathCopy,'/batch.txt',sep='')
file.create(batchfile)
sim_entries=paste(spathCopy,'/result/S*',sep='')
write(paste('cd ',exePath,sep=''),file=batchfile,append=T)
write(paste('parallel', exe, ':::', sim_entries, sep=' '),file=batchfile,append=T)
system(paste('chmod 777 ',spathCopy,'/batch.txt',sep=''))
#========================================================================================
#				REMOVE UNEEDED SIMS
#======================================================================================
unvalPoints=which(is.na(scf)==T)
gsimindex=formatC(unvalPoints, width=5,flag='0')
rmfile=paste(spathCopy, '/result/S',gsimindex,sep='')
system(paste('rm -r ', rmfile, sep=''))

#========================================================================================
#			SIMULATE
#======================================================================================

setwd(spathCopy)
system('./batch.txt')
}

