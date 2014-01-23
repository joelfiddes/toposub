#surface
getSampleSurface=function(spath,nclust){
require(raster)
lc=raster(paste(spath,'/surface.tif',sep=''))
zones=raster(paste(spath,'/landform_',nclust,'.tif',sep=''))
zoneStats=zonal(lc,zones, modal,na.rm=T)
return(zoneStats)
}

write.table(zone.stats, paste(spath,'landcoverZones.txt',sep=''),sep=',', row.names=F)

