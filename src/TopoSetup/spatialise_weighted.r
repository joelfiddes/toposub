#crude first go
#aspect not treated properly
#=====================================================================
##box8 - neighbours = 2,7,9,14
##spatialise sample 6 box 8

#samp=6
#mbox=8
#nbrs=c(2,9,14,7) #clockwise from north
#predNames<-c('ele', 'slp', 'asp', 'svf')
#wm=0.7 #weight main sample
#wn=0.3 # weight of weighted 4 neighbour samples in nspace

spatialWeight=function(mbox,samp, nbrs, predNames=c('ele', 'slp', 'asp', 'svf'), wm=0.7,wn=0.4){
m=read.table(paste('/home/joel/experiments/alpsSim/box',mbox,'/listpoints.txt',sep=''),  sep=',', header=T)
n1=read.table(paste('/home/joel/experiments/alpsSim/box',nbrs[1],'/listpoints.txt',sep=''),  sep=',', header=T)
n2=read.table(paste('/home/joel/experiments/alpsSim/box',nbrs[2],'/listpoints.txt',sep=''),  sep=',', header=T)
n3=read.table(paste('/home/joel/experiments/alpsSim/box',nbrs[3],'/listpoints.txt',sep=''),  sep=',', header=T)
n4=read.table(paste('/home/joel/experiments/alpsSim/box',nbrs[4],'/listpoints.txt',sep=''),  sep=',', header=T)


#generate unique ids
m$id2=paste('mm',m$id,sep='')
n1$id2=paste('n1',m$id,sep='')
n2$id2=paste('n2',m$id,sep='')
n3$id2=paste('n3',m$id,sep='')
n4$id2=paste('n4',m$id,sep='')

#make single matrix
mat=rbind(m,n1,n2,n3,n4) 
mat2=mat[predNames]

distMat=as.matrix(dist(mat2))

#as m is first in rbind -> samp(m) id = samp(distmatrix) id
distVecSamp=distMat[,samp]


#rankSize=rank(distVecSamp) # index
sortSize=sort(distVecSamp)
totalDist=sortSize[2]+sortSize[3]+sortSize[4]+sortSize[5] # 4 nearest neighbours in nspace. sortSize[1] is sample itself.
w1=sortSize[2]/totalDist
w2=sortSize[3]/totalDist
w3=sortSize[4]/totalDist
w4=sortSize[5]/totalDist

weightVec=round(as.numeric(rev(c((w1),(w2),(w3),(w4)))),3) #invert so closet has most weight)
idVec=rev(as.numeric(c(names(w1),names(w2),names(w3),names(w4)))) #sample ids
id2Vec=mat$id2[idVec]

results=data.frame(weightVec, idVec, id2Vec)

#get data
box=substring(results$id2Vec,2,2)
sample=as.numeric(substring(results$id2Vec,3,))

boxmap=data.frame(c(8,2,9,14,7),c('m',1,2,3,4))
names(boxmap)<-c('box','pos')

#read in main result
datin=read.table(paste('/home/joel/experiments/alpsSim/box',mbox,'/meanX_X100.000000.txt',sep=''),  sep=',', header=F)
datm=datin[samp,]

datvec=c()
for(i in 1:length(box)){
n=boxmap$box[boxmap$pos==box[i]]
datin=read.table(paste('/home/joel/experiments/alpsSim/box',n,'/meanX_X100.000000.txt',sep=''),  sep=',', header=F)
dat=datin[sample[i],]
datvec=c(datvec,dat)
}

neigh=sum(datvec*weightVec)

res=(datm*wm)+(neigh*wn)

return(res)
}

