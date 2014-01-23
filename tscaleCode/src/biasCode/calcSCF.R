#requires 3hr data as input starting  1-0ct 00:00
# applys to single years 1-0ct 00:00 - 31-Sept 21:00 
# lotsof hardwired things - BEWARE
#computes MD for all simulated poits
# calculates valid points in box and based on level of missingness
#
#RUN: source('~/src/hobbes/src/TopoAPP/pBiasCorr_script_single.R')


nboxSeq=nboxSeq

for(box in nboxSeq){

max.mis=1000 #levels of missingness in algorithm data not tolerated (single year) - bear in mind 17520 IMIS measurments/year 
misthrsh=0.3
scfseq=scfseq

start=start
end=end
#============================================================================
#		ID's of MODELLED DATA
#============================================================================
require(raster)
#spath='/home/joel/src/hobbes/results_points/b8/'
points_shp=shapefile('/home/joel/data/shapefiles/imisUTM.shp')
cp=shapefile('/home/joel/data/shapefiles/eraDomainUTM32.shp')
mf='/home/joel/data/transformedData/IMIS_meta.txt'

## shapefile of val points
dat_cut=points_shp[cp[box,],]
dat_cut_id=dat_cut$ID
mf=read.table(mf, sep=',', header=TRUE)
mf_cut=mf[dat_cut_id,]
mf_cut$id# change id from 1:n
lobs=length(mf_cut$id)

obsidvec=mf_cut$id
modidvec=1:lobs
scfvec=c()

#=========================== STATION LOOP ================================================
for(st in 1:lobs){
#single pars
sim=modidvec[st]
sim=formatC(sim, width=5,flag='0')
stn=obsidvec[st]
print(st)
meanBiasVec=c()
#=========================== SCFSEQ LOOP ================================================
for (scf in scfseq){
gsimindex=formatC(box, width=5,flag='0')
#scf=1.25
box1=paste(gsimindex, scf,sep='_') #'7_0.2' #identifies parameter experiment dir



#============================================================================
#		MELT DATES OF MODELLED DATA
#============================================================================
source('/home/joel/src/hobbes_utils/biasCode/pBiasCorr.R')
df=read.table(paste(root,'/sim/result/B',box1,'/result/S',sim,'/out/ground.txt',sep=''),sep=',',header=T)
dat=df$X100.000000
#get start point of each year
date=df$Date12.DDMMYYYYhhmm.
day=substr(date,1,2)
month=substr(date,4,5)
year=substr(date,7,10)
hr=substr(date,12,13)
date_format=paste(month,day,hr,sep='/') #mm/dd/hh identifies first and last sub-daily measurment in year (3h step)
yearStart=which(date_format=='10/01/00')
yearEnd=which(date_format=='09/30/21')



#============================ YEAR LOOP ==============================================
yearvec=c()

#year loop
for (i in 1:length(yearEnd)){
date_cut=date[yearStart[i]:yearEnd[i]]
dat_cut1=dat[yearStart[i]:yearEnd[i]]

if(mean(dat_cut1)<1){md=NA}
if(mean(dat_cut1)>=1){md=meltDate(dat=dat_cut1 ,date=date_cut, numeric=T)}
#print(md)
yearvec=c(yearvec,md)
}


meltDateMod=data.frame(yearvec)
#names(meltDateDf)<-validStations




#mdm=rowMeans(meltDateMod)
#meanBiasVec=cbind(meanBiasVec,mdm)
#}
#============================================================================
#		MELT DATES OF IMIS OBSERVATIONS
#============================================================================

require(raster)
#master='/home/joel/src/hobbes/_master/'
#spath='/home/joel/src/hobbes/results_points/b8/'
points_shp=shapefile('/home/joel/data/shapefiles/imisUTM.shp')
cp=shapefile('/home/joel/data/shapefiles/eraDomainUTM32.shp')

mf='/home/joel/data/transformedData/IMIS_meta.txt'

## shapefile of val points
dat_cut=points_shp[cp[box,],]
dat_cut_id=dat_cut$ID
mf=read.table(mf, sep=',', header=TRUE)
mf_cut=mf[dat_cut_id,]

#get and cut data to points in box
require(ncdf)
nc=open.ncdf('/home/joel/data/imis/data/imis_data.nc')
dat_all=get.var.ncdf(nc,var='GST')
dat_all[dat_all>1000]<-NA

#Time crop - need to generalise
##missingness
#miss=c()
#for (i in 1:161){
#n=length(which(is.na(dat_all[i,])==T))/(length(dat_all[i,]))
#miss=c(miss,n)
#}
#missvec=which(miss>misthrsh)

#mf_cut$id[mf_cut$id %in% missvec==T]<-NA
#validStations=na.omit(mf_cut$id)
##dat=dat_all[validStations,]

dat=dat_all

#time
time=get.var.ncdf(nc,var='time')
origin=substr(nc$dim$time$units,15,22)
datesPl<-ISOdatetime(origin,0,0,0,0,0,tz='UTC') + time #dates sequence

dat=dat[,start: end]
datesPl=datesPl[start: end]

#get start point of each year
day=substr(datesPl,9,10)
month=substr(datesPl,6,7)
year=substr(datesPl,1,4)
hr=substr(datesPl,12,13)
min=substr(datesPl,15,16)
date_format=paste(month,day,hr,min,sep='/') #mm/dd/hh identifies first and last sub-daily measurment in year (3h step)
yearStart=which(date_format=='10/01/00/00')
yearEnd=which(date_format=='09/30/23/30')

#format date 'GEOtop'

dates_gt=paste(day,month,year,hr,min,sep='/') 

#stationvec=c()
#for (stn in 1: length(validStations)){

#print(i)
#year loop
yearvec=c()
for (i in 1:length(yearEnd)){
date_cut=dates_gt[yearStart[i]:yearEnd[i]]
dat_cut2=dat[stn,yearStart[i]:yearEnd[i]]
md=meltDate(dat=dat_cut2 ,date=date_cut, numeric=T,max.mis=max.mis)
#print(md)
yearvec=c(yearvec,md)
}
#stationvec=cbind(stationvec, yearvec)
#}

meltDateObs=data.frame(yearvec)



#================================
#Analyse

#used to convert to commom timestep
obsres=0.5
modres=3
obsNam=names(meltDateObs)
modNam=names(meltDateMod)

#obsNam ALWAYS a subset of modNam
#modNamIndex=which(modNam %in% obsNam)

#mi=modNamIndex[i]
mdobs=meltDateObs*obsres
mdmod=meltDateMod*modres
dbdf=(mdmod-mdobs)/24


dayBiasDf=data.frame(dbdf)
#names(dayBiasDf)<-paste('S',validStations,sep='')
#OR

meanBiasVec=cbind(meanBiasVec,dayBiasDf$yearvec)
}

cmb=colMeans(meanBiasVec, na.rm=T)
#plot(scfseq,cmb)

if(is.na(mean(cmb))==T){scf<-NA; scfvec=c(scfvec,scf); next}
scf=approx(cmb,scfseq, xout=0)
scf=scf$y

scfvec=c(scfvec,scf)
}
write.table(scfvec, paste(root,'/scfvec',box,'.txt',sep=''),sep=',')
}
