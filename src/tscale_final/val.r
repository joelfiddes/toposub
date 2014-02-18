#evaluate
require(ncdf)
valT=read.table('/home/joel/data/transformedData/IMIS_AirT.txt',sep=',')
valG=read.table('/home/joel/data/transformedData/IMIS_GST.txt',sep=',')
valS=read.table('/home/joel/data/transformedData/IMIS_HSno.txt',sep=',')
source('/home/joel/src/TopoScale/tscale_final/tscale_src.r')
infile='/home/joel/data/imis/data/imis_data.nc'

nc=open.ncdf(infile)
time = get.var.ncdf( nc,'time')
#time2=interp6to3(time) #accepts vector
z <- time#make seconds
dates<-ISOdatetime('1970-1-1',0,0,0,0,0,tz='UTC') + time #dates sequence



#107 good
#c(101,102, 104,105,107,108,109,110,112)
exp=109
par(mfrow=c(2,1))

plotseq=rep(1:161,rep(20,161))
for (i in plotseq){

#pdf('out.pdf', height=8, width=8)
par(mfrow=c(2,1))
#exp=107
i=18
exp=i
 xlim=c(0,4500)


#par(mfrow=c(4,5))
#for(i in (7,11,12,18,34){
#exp=i
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
plot(gtout$snow_depth.mm.,type='l', col='red', xlim=xlim, main=i)
lines( valS[2:4384,exp]*10)
legend('topright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
#}
#par(mfrow=c(5,5))
#for(i in 1:25){
exp=i
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/ground.txt',sep=''), sep=',', header=T)
plot(gtout$X100.000000 ,type='l', col='red',xlim=xlim,main=i)
lines( valG[2:4384,exp])
legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
#}
#dev.off()
#}
exp=1
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/ground.txt',sep=''), sep=',', header=T)
smoothScatter(gtout$X100.000000 ,valG[1:4384,exp],main=i, xlim=c(-10,20), ylim=c(-10,20))

#==========================================================================
#	ASSEMBLE GT DATAFRAME
#==========================================================================
png('~/paper3/results/scatterIMIS.png')

valG=read.table('/home/joel/data/transformedData/IMIS_GST.txt',sep=',')
valS=read.table('/home/joel/data/transformedData/IMIS_HSno.txt',sep=',')

par(mfrow=c(1,2))
gdat=c()
for (exp in 1:161){
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/ground.txt',sep=''), sep=',', header=T)
gdat=cbind(gdat,gtout$X100.000000)
}
vdat=c()
for (exp in 1:161){
mat=as.vector(valG[2:4385,exp])
vdat=cbind(vdat,mat)
}
require(hydroGOF)
rms=rmse(as.vector(vdat),as.vector(gdat))
r=cor(as.vector(vdat),as.vector(gdat),use='complete.obs')
plot(vdat,gdat,col=rgb(0,0,1,0.1),main = paste('RMSE=',round(rms,2),'R=',round(r,2),'N=',length(gdat),sep=' '),xlim=c(-20,30), ylim=c(-20,30))
abline(0,1)
#==========================================================================
#	ASSEMBLE snow DATAFRAME
#==========================================================================
gdat=c()
for (exp in 1:161){
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
gdat=cbind(gdat,gtout$snow_depth.mm.)
}
vdat=c()
for (exp in 1:161){
mat=as.vector(valS[2:4384,exp])
vdat=cbind(vdat,mat)
}
require(hydroGOF)
rms=rmse(as.vector(vdat),as.vector(gdat))
r=cor(as.vector(vdat),as.vector(gdat),use='complete.obs')
plot(vdat*10,gdat,col=rgb(0,0,1,0.05),main = paste('RMSE=',round(rms,2),'R=',round(r,2),'N=',length(gdat),sep=' '),xlim=c(0,7000), ylim=c(0,7000))
abline(0,1)

dev.off()









#==========================================================================
#		EXPERIMENT MEANS
#==========================================================================

#get complete sims
s=substr(sims,28,length(sims))
sdone=as.numeric(s[1:161])
#plot(rowMeans( valG[2:4384,sdone],na.rm=T),typ='l')
sdone=c(7,11, 12, 18, 34)
#get snoH
df1=c()
for(exp in sdone){
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
gt=gtout$snow_depth.mm.
df1=cbind(df1,gt)
}

#get gst
df2=c()
for(exp in sdone){
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/ground.txt',sep=''), sep=',', header=T)
gt=gtout$X100.000000
df2=cbind(df2,gt)
}

#get air
df3=c()
for(exp in sdone){
gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
gt=gtout$Tair.C.  
df3=cbind(df3,gt)
}

date=gtout$Date12.DDMMYYYYhhmm.
dates=dayDates()
date=dates[276:4658]

pdf('outIMIS.pdf', height=4, width=8)
	xlim=c(date[800],date[4383])
	par(mfrow=c(3,1))
	plot(date,rowMeans( valT[2:4384,sdone],na.rm=T),typ='l', xlim=xlim,ylab='AirT (degC)')
	lines(date,rowMeans( df3,na.rm=T),col='red',xlim=xlim)
	legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
	plot(date,rowMeans( valS[2:4384,sdone],na.rm=T)*10,typ='l', xlim=xlim,ylab='Snow Height (mm)')
	lines(date,rowMeans( df1,na.rm=T),col='red',xlim=xlim)
	legend('topright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
	plot(date,rowMeans( valG[2:4384,sdone],na.rm=T),typ='l',xlim=xlim, ylab='GST (degC)')
	lines(date,rowMeans( df2[2:4384,],na.rm=T),xlim=xlim,col='red')
	legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1,bg='white')
dev.off()


#==========================================================================
#		find valid stations
#==========================================================================
s=c()
for(i in 1:161){
x=length(na.omit(valG[2:4384,i]))
s=c(s,x)
}
i=s/4384
which(i>0.90)




#==========================================================================
#	ASSEMBLE snow DATAFRAME mattertal
#==========================================================================
pdf('~/snow1_cf1.4.pf', height=8, width=10)
par(mfrow=c(2,1))

plotseq=rep(158)
for (i in plotseq){

exp=i
xlim=c(0,4500)

gtout1=read.table(paste('/home/joel/experiments/mattertal/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
plot(valS[2:4384,exp]*10,type='l', xlim=xlim, main='Snow Depth')
lines(gtout1$snow_depth.mm., col='red') 
lines(gtout1$Psnow_over_canopy.mm.*10, col='green') 
lines(gtout1$snow_water_equivalent.mm., col='blue') 

legend('topright', c('OBS', 'MOD','snow in','swe') , col=c('black', 'red','green','blue') , lty=1)
abline(v=seq(1,4384,30),col='grey', lty=2)

abline(v=seq(1,4384,90),col='grey', lty=1)


exp=i
gtout=read.table(paste('/home/joel/experiments/mattertal/sim',exp,'/out/ground.txt',sep=''), sep=',', header=T)
plot( valG[2:4384,exp],type='l', ,xlim=xlim,main='GST')
lines(gtout$X100.000000,col='red' )
#lines(gtout1$Tair.C.,col='green' ) 

legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
abline(v=seq(1,4384,30),col='grey', lty=2)
abline(v=seq(1,4384,90),col='grey', lty=1)


#plot( valT[2:4384,exp],type='l', ,xlim=xlim,main='AirT')
#lines(gtout1$Tair.C.,col='red' ) 
#legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
#abline(v=seq(1,4000,30),col='grey', lty=2)
#abline(v=seq(1,4000,90),col='blue', lty=2)


}
dev.off()
#mean annual plots
exp=158
val=valG[1:4384,exp]
gtout=read.table(paste('/home/joel/experiments/mattertal/sim',exp,'/out/ground.txt',sep=''), sep=',', header=T)
dd=gtout$Date12.DDMMYYYYhhmm.
dd1=substring(dd,1,2)
dd2=substring(dd,4,5)
dd=paste(dd2,dd1,sep='/')
gsta=aggregate(gtout$X100.000000, by=list(dd), FUN=mean)
gstv=aggregate(val, by=list(dd), FUN=mean,na.rm=T)
plot(gstv$x, type='l')
lines(gsta$x, col='red')


#mean annual plots
exp=158
val=valS[2:4384,exp]
gtout=read.table(paste('/home/joel/experiments/mattertal/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
dd=gtout$Date12.DDMMYYYYhhmm.
dd1=substring(dd,1,2)
dd2=substring(dd,4,5)
dd=paste(dd2,dd1,sep='/')
gsta=aggregate(gtout$snow_depth.mm., by=list(dd), FUN=mean)
gstv=aggregate(val, by=list(dd), FUN=mean,na.rm=T)
plot(gstv$x*10, type='l')
lines(gsta$x, col='red')
