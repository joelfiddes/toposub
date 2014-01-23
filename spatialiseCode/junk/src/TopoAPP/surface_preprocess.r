#define .inpts surface/subsurface
require(raster)
spath='/home/joel/experiments/alpsSim3/box3/'
lc=raster('/home/joel/data/landcover/alps/surface_types1.tif')
zones=raster(paste(spath,'landform_10.tif',sep=''))

lc[lc<800]<-1
lc[lc>=800 & lc<1100]<-2
lc[lc>=1100]<-3

zone.stats=zonal(lc,zones, modal,na.rm=T)
write.table(zone.stats, paste(spath,'landcoverZones.txt',sep=''),sep=',', row.names=F)

dem=raster('/home/joel/data/DEM/alps/aster_proj/dem_alpen1.tif')
dem2000=raster('/home/joel/data/DEM/alps/aster_proj/dhm_ue2000m1.tif')
dem[dem>2000]
#demfootprint=aggregate(dem , fact=100)
#writeRaster(dsub2, '/home/joel/data/DEM/alps/aster_proj/slp_d_u2000.tif')

lakes=raster('/home/joel/data/landcover/CH/lakeMaskWGS.tif')
glacier=raster('/home/joel/data/landcover/alps/alps2003_def_mask21.tif')
glacier[glacier==0]<-2
slp=raster('/home/joel/group/geotop/sim/cryosub/surface/slope_d1.tif')
asp=raster('/home/joel/group/geotop/sim/cryosub/surface/aspect_dem1.tif')
mask=lakes+glaciers

lakesC=trim(crop(lakes, dshp2))
writeRaster(demC, '/home/joel/data/DEM/alps/aster_proj/demCut.tif')
#ddem=raster('/home/joel/experiments/alpsSim/_master/ASTERv2_UTM32N.tif')
#slp=terrain(ddem, opt='slope',unit='degrees')
#smin=35
#smax=55
#mr=(slp-smin)/(smax-smin)


projection(lakes)<-'+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=600000 +y_0=200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs '
projectRaster(from=lakes, res=0.0002777778, crs='+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
