#gst experiment script 4/7/13

#==================================================================================
#			WRITE PARFILE
#=================================================================================

#write parfile.r to each of remote instances 
#writes variables: Nclust, Nseq

source('~/src/hobbes/src/tscale_final/gt_control.r')

#sequence of grid boxes corrospoding to n instances


#nseq=c(4,5,6,7,12,13)#8:11
nseq=c(8,9,10,11,14,4)
#ip addresses of instances (last 2 digits only required here)
ipaddress=c(46,65,66,73,75,74)

#toposub clusters
Nclust=200

#master par file
parfilename='~/src/hobbes/src/TopoAPP/parfile.r'
setupfile='~/src/hobbes/src/TopoAPP/topoApp_complete.r'
for(i in 1:length(nseq)){
fs=readLines(parfilename) 
n=gt.par.fline(fs=fs, keyword='nboxSeq') 
nclust=gt.par.fline(fs=fs, keyword='Nclust') 
fs=gt.par.wline(fs=fs,ln=n,vs=nseq[i])
fs=gt.par.wline(fs=fs,ln=nclust,vs=Nclust)
con <- file(parfilename, "w")  # open an output file connection
cat(fs, file = con,sep='\n')
close(con)
#transfer files using scp and ssh key (this line NOT generic)

##COPY inpts
system(paste('scp -i /home/joel/.ssh/joel.pem ', '/home/joel/src/hobbes/_master/geotop.inpts', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/_master/',sep=''))
#COPY SRC
system(paste('scp -r -i /home/joel/.ssh/joel.pem /home/joel/src/hobbes/src/ gc3-user@130.60.24.',ipaddress[i],':~/',sep=''))

}


#for(i in 1:length(nseq)){
#system(paste('scp -r -i /home/joel/.ssh/joel.pem ', '/home/joel/data/era/1979_2012/sim/_master/eraDat', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/_master/',sep=''))
#}

#==================================================================================
#			TRANSFER RESULTS
#=================================================================================

#write parfile.r to each of remote instances 
#writes variables: Nclust, Nseq

source('~/src/hobbes/src/tscale_final/gt_control.r')
nresults='_gst15'
#nseq=c(4,5,6,7,12,13)#8:11
nseq=c(8,9,10,11,14,4)
#ip addresses of instances (last 2 digits only required here)
ipaddress=c(46,65,66,73,75,74)


for(i in 1:length(nseq)){

system(paste('scp -i /home/joel/.ssh/joel.pem ', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/box',nseq[i],'/meanX_X100.000000.txt /home/joel/src/hobbes/results',nresults,'/b',nseq[i],'/',sep=''))

system(paste('scp -i /home/joel/.ssh/joel.pem ', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/box',nseq[i],'/samp_sd.txt /home/joel/src/hobbes/results',nresults,'/b',nseq[i],'/',sep=''))

system(paste('scp -i /home/joel/.ssh/joel.pem ', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/box',nseq[i],'/samp_mean.txt /home/joel/src/hobbes/results',nresults,'/b',nseq[i],'/',sep=''))

system(paste('scp -r -i /home/joel/.ssh/joel.pem ', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/box',nseq[i],'/sim* /home/joel/src/hobbes/results',nresults,'/b',nseq[i],'/',sep=''))
#system(paste('scp -i /home/joel/.ssh/joel.pem ', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/box',nseq[i],'/fuzRst/fuzRst2_X100.000000.tif /home/joel/src/hobbes/results',nresults,'/b',nseq[i],'/',sep=''))

#system(paste('scp -i /home/joel/.ssh/joel.pem ', ' gc3-user@130.60.24.',ipaddress[i],':~/sim/box',nseq[i],'/out/fuz_X100.000000.tif /home/joel/src/hobbes/results',nresults,'/b',nseq[i],'/',sep=''))

}
#transfer fuz olfd

