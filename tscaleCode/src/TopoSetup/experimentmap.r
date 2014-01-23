ddem=raster('/home/joel/experiments/alpsSim/_master/ASTERv2_UTM32N.tif')#domain dem
dshp=shapefile('/home/joel/experiments/alpsSim/_master/eraDomainUTM32.shp')#domain shp
tsub=raster('/home/joel/experiments/alpsSim2/box9/landform_100.tif')

#ERA rst
eraFile='/home/joel/data/era/surface/grid74/tair.nc'
x=raster(eraFile)
gridBoxRst=init(x, fun=runif)
eraShp2=rasterToPoints(x)

png('/home/joel/experiments/experimentmap1.png',, height=350)
gseq=gray(seq(0,1,0.001))
plot(ddem, col=gseq, xlab='XUTM32', ylab='YUTM32')
#plot(gridBoxRst, add=T, legend=F,col=matlab.like(28), alpha=0.07)
plot(dshp,border='white', add=T)
dev.off()

png('/home/joel/experiments/experimentmap2.png',height=350)
gseq=gray(seq(0,1,0.001))
plot(ddem, col=gseq, xlab='XUTM32', ylab='YUTM32')
#plot(gridBoxRst, add=T, legend=F,col=matlab.like(28), alpha=0.07)
plot(dshp,border='white', add=T)
plot(tsub, ,col=matlab.like(100),add=T,legend=F)
points(eraShp2, col='white',pch=3,cex=0.5)
dev.off()

