#ERA preprocess 2 - acummulated values to period average
#converts SW/LW and precipitation to 3h averges of w/m2 and mm/hr respectively
#converts 3d vec to 2d vec
#=======================================================================================================
#			PACKAGES
#=======================================================================================================
require(ncdf)

#=======================================================================================================
#			SRC
#=======================================================================================================
source('~/src/TopoScale/tools_src.r')


#=======================================================================================================
#			DIRECTORIES
#=======================================================================================================
outRoot='/home/joel/data/tscale_final/EraMet/acumm2av'
#=======================================================================================================
#			INFILES
#=======================================================================================================
lwFile='/home/joel/data/era/surface/grid74/strd.nc'
swFile='/home/joel/data/era/surface/grid74/ssrd.nc'
pFile='/home/joel/data/era/surface/grid74/tp.nc'

#=======================================================================================================
#			SETUP
#=======================================================================================================
file=lwFile
coordMap=getCoordMap(file)
step=3

#=======================================================================================================
#			LWIN
#=======================================================================================================
file=lwFile
nc=open.ncdf(file)
indat = get.var.ncdf( nc, "var175")

#could vectorise but quick anyway 
lwgridAv=c()
for(i in coordMap$cells){
x=coordMap$xlab[i]
y=coordMap$ylab[i]
lgav=accumToInstERA_simple(inDat=indat[x,y,], step=step)
lwgridAv=cbind(lwgridAv,lgav)
}
#interpolate to original timestep
lwgridAdj=c()
for(i in coordMap$cells){
lAdj=adjAccum(lwgridAv[,1])
lwgridAdj=cbind(lwgridAdj,lAdj)
}

#=======================================================================================================
#			SWIN
#=======================================================================================================
file=swFile
nc=open.ncdf(file)
indat = get.var.ncdf( nc, "var169")

#could vectorise but quick anyway 
swgridAv=c()
for(i in coordMap$cells){
x=coordMap$xlab[i]
y=coordMap$ylab[i]
sgav=accumToInstERA_simple(inDat=indat[x,y,], step=step)
swgridAv=cbind(swgridAv,sgav)
}

#interpolate to original timestep
swgridAdj=c()
for(i in coordMap$cells){
sAdj=adjAccum(swgridAv[,1])
swgridAdj=cbind(swgridAdj,sAdj)
}

#=======================================================================================================
#			PRECIP
#=======================================================================================================
file=pFile
nc=open.ncdf(file)
indat = get.var.ncdf( nc, "var228")

#could vectorise but quick anyway 
pgridAv=c()
for(i in coordMap$cells){
x=coordMap$xlab[i]
y=coordMap$ylab[i]
pgav=accumToInstERA_simple(inDat=indat[x,y,], step=step)
pgridAv=cbind(pgridAv,pgav)
}
#interpolate to original timestep
pgridAdj=c()
for(i in coordMap$cells){
pAdj=adjAccum(pgridAv[,1])
pgridAdj=cbind(pgridAdj,pAdj)
}


#convert m/s -> mm/hr
pgridAdjHr=pgridAdj*1000*60*60


#=======================================================================================================
#			WRITE FILES
#=======================================================================================================

write.table(lwgridAdj, paste(outRoot, '/lwgrid.txt', sep=''), sep=',', row.names=F)
write.table(swgridAdj, paste(outRoot, '/swgrid.txt', sep=''), sep=',', row.names=F)
write.table(pgridAdjHr, paste(outRoot, '/pgrid.txt', sep=''), sep=',', row.names=F)


#=======================================================================================================
#			time
#=======================================================================================================
var="time"
nc=open.ncdf(lwFile)
time = get.var.ncdf( nc,var)
origin='1996-01-01'
z <- time*60*60 #make seconds
dates<-ISOdatetime(origin,0,0,0,0,0,tz='UTC') + z #dates sequence

dd=dates[1:length(dates)-1]

write.table(dd, paste(outRoot, '/dates.txt', sep=''), sep=',', row.names=F, col.names=F)
