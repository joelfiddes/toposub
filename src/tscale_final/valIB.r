#evaluate
require(ncdf)

source('/home/joel/src/TopoScale/tscale_final/tscale_src.r')
mf=read.table( '/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt', sep=',' ,header=T)

load('/home/joel/data/ibutton/IB_dirruhorn/Rdata/BH10_iBday.rd')
str(iB.all)
load('/home/joel/data/ibutton/IB_dirruhorn/Rdata/BH10_iBmeasDay.rd')
ib=iB.day.all
plot(ib$date,ib$day.mean,type='l')
ibdate=ib$date
dd=gtout$Date12.DDMMYYYYhhmm.
#=================================================================================================
pdf('/home/joel/experiments/tscaleIB2/out.pdf', height=16, width=16)
par(mfrow=c(4,5))
sites=list.files(path='/home/joel/data/ibutton/IB_dirruhorn/Rdata', pattern='measDay')
obsvec=c()
modvec=c()
bvec=c()
rvec=c()
idvec=c()

Evolution of GST well simulated
Negative GST bias largely occurs in winter
Snow depth development captured 
Melt dates generally simulated correctly
se=c(1:19)
#se=c(2,3,8,16)
for (n in se ){
#for (n in c(12,14,16) ){
i=mf$site[n]
load(paste('/home/joel/data/ibutton/IB_dirruhorn/Rdata/',i,'_iBmeasDay.rd',sep=''))
ib=iB.day.all
date=ib$date

datetime <- strptime(date, format="%Y-%m-%d")
ibdate<-format(as.POSIXct(datetime), format="%d/%m/%Y")

obs=ib$day

gtout=read.table(paste('/home/joel/experiments/tscaleIB2/sim',n,'/out/ground.txt',sep=''), sep=',', header=T)
gtout2=read.table(paste('/home/joel/experiments/tscaleIB2/sim',n,'/out/surface.txt',sep=''), sep=',', header=T)
mod=gtout$X100.000000
mod2=gtout2$Tair.C.
mod3=gtout2$Tsurface.C. 
dd=gtout$Date12.DDMMYYYYhhmm.
dd=substring(dd,1,10)
st=which(dd==ibdate[1])+1
en=which(dd==ibdate[length(ibdate)])+1
r=round(rmse(obs,mod[st:en]),2)
b=bias(mod[st:en],obs)
plot(obs, type='l',main=paste(n,'rmse=',r,sep=' '),lwd=1, ylim=c(-15,15))

lines(mod[st:en], col='red',lwd=1)
#lines(datetime,mod2[st:en], col='green',lwd=1)
#lines(datetime,mod3[st:en], col='green',lwd=1)

obsvec=c(obsvec, obs)
modvec=c(modvec, mod[st:en])
rvec=c(rvec,r)
bvec=c(bvec,b)
id=rep(i, length(obs))
idvec=c(idvec,id)

legend('bottomright', c('OBS', 'MOD'), col=c('black', 'red'),lty=1)
}
#r=round(rmse(obsvec,modvec),2)
#plot(obsvec,modvec,col=rgb(0,0.2,1,0.05),main=paste('rmse=',r,sep=''))
#abline(0,1)
dev.off()


####	PANEL PLOT
require(lattice)
t=ts(obsvec)
lw=ts(modvec)
n=idvec
df=data.frame(val,lw,n)
px1=xyplot(t,data=NULL,xlab='Tair modelled', ylab='Tair measured',layout=c(4,5),screens=1:17,superpose=T

)
px1
















plot(modvec[,1]-obsvec[,1],type='l',col=rgb(0,0.2,1,0.2))
for(i in 2:19){
lines(modvec[,i]-obsvec[,i],col=rgb(0,0.2,1,0.2))
}
#=================================================================================================
require(hydroGOF)
n=14
i=mf$site[n]
load(paste('/home/joel/data/ibutton/IB_dirruhorn/Rdata/',i,'_iBmeasDay.rd',sep=''))
ib=iB.day.all
obs=ib$day
gtout=read.table('/home/joel/experiments/mattertal/sim15/out/ground.txt', sep=',', header=T)
mod2=gtout$X100.000000[]
plot(obs, type='l')
lines(mod, col='red')
pbias(obs,mod)
cor(obs,mod)
rmse(obs,mod+1)


#=================================================================================================

#snow

gtout=read.table('/home/joel/experiments/tscaleIB3/sim14/out/surface.txt', sep=',', header=T)
mod1=gtout$snow_depth.mm.[]
plot(mod1, type='l')

gtout=read.table('/home/joel/experiments/mattertal/sim14/out/surface.txt', sep=',', header=T)
mod2=gtout$snow_depth.mm.[]
lines(mod2, col='red')
