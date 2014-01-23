#evaluate
require(ncdf)
source('/home/joel/src/TopoScale/tscale_final/tscale_src.r')
valT=read.table('/home/joel/data/transformedData/MET_AirT.txt',sep=',')
valG=read.table('/home/joel/data/transformedData/MET_Prec.txt',sep=',')


infile='/home/joel/data/meteoswiss/meteoch.nc'
nc=open.ncdf(infile)
z = get.var.ncdf( nc, 'time')
time<-ISOdatetime(origin,1,1,0,0,0) + z  
dayTS=as.POSIXct(strptime(format(time,format="%Y/%m/%d %H"),format="%Y/%m/%d"),tz="UTC")# tz correct?
c=as.factor(dayTS)
dates=levels(c)
d=as.Date(dates)
d1=which(d=='1996-10-02')
d2=which(d=='2008-10-01')
dates=d[d1:d2]

#val data
Hse = get.var.ncdf( nc, 'HSm')
Hse[Hse>10000]<-NA
rs=rowSums(Hse,na.rm=T)
ind=which(rs>0)


pdf('outMet.pdf', height=12, width=16)
par(mfrow=c(4,4))
for(i in ind){
exp=i
valS=aggregate(Hse[exp,], by=list(dayTS), FUN=mean, na.rm=T)
obs=valS$x[d1:d2]*10
gtout=read.table(paste('/home/joel/data/tscaleMet/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
mod=gtout$snow_depth.mm.
if(sum(obs,na.rm=T)==0){next}
plot(obs,type='l', main=paste(i, round(cor(mod,obs,use='complete.obs'),2), round(rmse(obs,mod),0),sep=' / '))
lines( mod, col='red')
legend('topright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
}
dev.off()


#==========================================================================
#		EXPERIMENT MEANS
#==========================================================================

##get complete sims
#s=substr(sims,28,length(sims))
#sdone=as.numeric(s[1:161])
##plot(rowMeans( valG[2:4384,sdone],na.rm=T),typ='l')
#sdone=c(7,11, 12, 18, 34)
##get snoH
#df1=c()
#for(exp in sdone){
#gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
#gt=gtout$snow_depth.mm.
#df1=cbind(df1,gt)
#}

##get gst
#df2=c()
#for(exp in sdone){
#gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/ground.txt',sep=''), sep=',', header=T)
#gt=gtout$X100.000000
#df2=cbind(df2,gt)
#}

##get air
#df3=c()
#for(exp in sdone){
#gtout=read.table(paste('/home/joel/data/tscale/sim',exp,'/out/surface.txt',sep=''), sep=',', header=T)
#gt=gtout$Tair.C.  
#df3=cbind(df3,gt)
#}

#date=gtout$Date12.DDMMYYYYhhmm.
#dates=dayDates()
#date=dates[276:4658]

#pdf('out.pdf', height=8, width=8)
#	xlim=c(date[800],date[4383])
#	par(mfrow=c(3,1))
#	plot(date,rowMeans( valT[2:4384,sdone],na.rm=T),typ='l', xlim=xlim,ylab='AirT (degC)')
#	lines(date,rowMeans( df3,na.rm=T),col='red',xlim=xlim)
#	legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
#	plot(date,rowMeans( valS[2:4384,sdone],na.rm=T)*10,typ='l', xlim=xlim,ylab='Snow Height (mm)')
#	lines(date,rowMeans( df1,na.rm=T),col='red',xlim=xlim)
#	legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
#	plot(date,rowMeans( valG[2:4384,sdone],na.rm=T),typ='l',xlim=xlim, ylab='GST (degC)')
#	lines(date,rowMeans( df2[2:4384,],na.rm=T),xlim=xlim,col='red')
#	legend('bottomright', c('OBS', 'MOD') , col=c('black', 'red') , lty=1)
#dev.off()


##==========================================================================
##		find valid stations
##==========================================================================
#s=c()
#for(i in 1:161){
#x=length(na.omit(valG[2:4384,i]))
#s=c(s,x)
#}
#i=s/4384
#which(i>0.90)

