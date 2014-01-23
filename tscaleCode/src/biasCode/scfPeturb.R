#nbox=10
#LOOP HERE
nboxSeq=nboxSeq
for(nbox in nboxSeq){
gsimindex=formatC(nbox, width=5,flag='0')
spath=paste(root,'/sim/result/B',gsimindex,sep='')#TO CHANGE

print(paste('*** PETURB SNOWCORRFACTOR BOX', '***',sep=''))
exePath='/home/joel/src/geotop/'#remove
exe='./geotop1.225-13'#remove

#perturb snowCorrFactor
# copy nbox for each scf value and change 'snowCorrFactor' to value scf
source('/home/joel/src/hobbes_tscale/src/tscale_final/gt_control.r')#remove

parfilename='geotop.inpts'
npoints=length(list.files(paste(spath,'/result/',sep=''), 'S'))



vecScf=scfseq

#behaviour 1 - i master batch in scf=1 folder
batchfile=paste(spath,'/batch.txt',sep='')
file.create(batchfile)
for (v in vecScf){
spathCopy=paste(spath,'_',v, sep='')
system(paste('cp -r ',spath,'  ' ,spathCopy, sep=''))
#behaviour 2 - each file has batch.txt
#batchfile=paste(spathCopy,'/batch.txt',sep='')
#file.create(batchfile)
for(i in 1:npoints){
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
sim_entries=paste(spathCopy,'/result/S*',sep='')
write(paste('cd ',exePath,sep=''),file=batchfile,append=T)
write(paste('parallel', exe, ':::', sim_entries, sep=' '),file=batchfile,append=T)
}


system(paste('chmod 777 ',spath,'/batch.txt',sep=''))


	print(paste('*** RUN LSM BOX', 'ALL PETURBATIONS***',sep=''))
	setwd(spath)
	system('./batch.txt')

}
