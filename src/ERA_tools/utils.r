#orOGRAPHY
library(raster)
library(ncdf)
file='/home/joel/src/ERA_tools/oro.nc'
nc<-open.ncdf(file)
z= get.var.ncdf( nc, "z")

 r=raster(z)
r=t(r)
 plot(r)

#precip (convective versus large scale)
library(raster)
library(ncdf)
file='/home/joel/Downloads/output (4).nc'
nc<-open.ncdf(file)

origin="1900-01-01 00:00:00"
time = get.var.ncdf( nc, "time")#get times hr since "1900-01-01 00:00:00"
### suppose we have a time in seconds since 1960-01-01 00:00:00 GMT
### (the origin used by SAS)
q <- time*60*60 #make seconds
## ways to convert this
date<-as.POSIXct(q, origin=origin)                # local
day=as.POSIXct(strptime(format(date,format="%Y/%m/%d %H"),format="%Y/%m/%d"),tz="UTC")# for aggegation
#month=as.POSIXct(strptime(format(day,format="%Y/%m/%d"),format="%Y/%m"),tz="UTC")# for aggegation

lsp= get.var.ncdf( nc, "lsp")
cp= get.var.ncdf( nc, "cp")

ybox=1
xbox=1
lsp=lsp[xbox,ybox,]
cp=cp[xbox,ybox,]

lspDay=aggregate(lsp, by=list(day), FUN=mean)
cpDay=aggregate(cp, by=list(day), FUN=mean)

cpn=as.numeric(cp)
lspn=as.numeric(lsp)
cp10=aggregate.ts(cpn, nfrequency=0.025/3, FUN=mean)
lsp10=aggregate.ts(lspn, nfrequency=0.025/3, FUN=mean)

plot(lspDay$Group.1,lspDay$x, type='l')
lines(cpDay$Group.1,cpDay$x, col='red')

#alpine dem 
library(colorRamps)
library(RColorBrewer)



alps=raster('/home/joel/data/DEM/alps/20121011073246_1677224548.asc')
era=raster('/home/joel/data/DEM/alps/alps075deg')

g <­- brewer.pal(100, "Greys")

plot(alps, col=g ,legend=F)
plot(era, alpha=0.3, add=T, col=matlab.like(100))

plot(alps, colRamp=BW)
