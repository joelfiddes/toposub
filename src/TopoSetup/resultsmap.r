require(raster)
require(rgdal)
require(colorRamps)

#raster in
r=raster('/home/joel/experiments/alpsSim2/rmerge3.tif')

#shp in
metaFile='/home/joel/data/transformedData/IMIS_meta.txt'
mf=read.table(metaFile, sep=',', header =T)

#ll shp
shpi=makePointShapeGeneric(lon=mf$lon, lat=mf$lat, data=mf$id)
#project--> UTM
p=project(xy=cbind(mf$lon, mf$lat), proj='+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs ')
#UTM shp
shpi=makePointShapeGeneric(lon=p[,1], lat=p[,2], data=mf$id,proj='+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs')

#plot
pdf('~/out.pdf',8,6)
plot(r, col=matlab.like(100))
plot(shpi,add=T)
dev.off()

