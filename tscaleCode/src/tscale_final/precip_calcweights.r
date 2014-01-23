#precipitation
require(raster)
require(gtools)

#======================================================================================
#			INFILES
#=======================================================================================
file= mixedsort(list.files('/home/joel/data/CRU/data/months/', pattern='cruEuroPre_cut_interp'))
lsfile=as.list(file)
setwd('/home/joel/data/CRU/data/months/')
stk=brick(lsfile)
subgridP=stk[[1]]
#stk=stack('/home/joel/data/meteoswiss/precipStk.tif')
dem=raster('/home/joel/data/DEM/alps/20121011073246_1677224548.asc') #1km
preFile='/home/joel/data/era/surface/grid74/tp.nc'
eraBoxEle=read.table('/home/joel/data/transformedData/eraBoxEle.txt', header=T, sep=',')

eraShp=rasterToPolygons(ncRst)
ncRst=raster(preFile)
gridBoxRst=init(ncRst, v='cell')
#set up new grid
subgrid=disaggregate(gridBoxRst, fact=5)
subgrid=init(subgrid, fun=runif)
subgridShp=rasterToPolygons(subgrid)

demcrop=trim(crop(dem, ncRst)) 	#crop DEM to aoi
demMatrix=extract(demcrop, subgridShp, fun=mean)	#aggrgate DEM 1km to SUBGRID resolution (subgridShp)
demCoarse=raster(matrix(demMatrix, ncol=ncol(subgridP), nrow=nrow(subgridP), byrow=T)) 	# make raster
extent(demCoarse)<-extent(subgridP) # fix extent
#m=disaggregate(demCoarse, res(demCoarse)[1]/res(demcrop)[1]) # disagg  subgrid resolution DEM to DEM res but no function applied, - CRU ele values at dem resolution (ie repeated within each CRU box to allow computation below.

demCRU<-demCoarse
demERA<-gridBoxRst
values(demERA)<-eraBoxEle$masl

idgrid=disaggregate(gridBoxRst, res(gridBoxRst)[1]/res(demCRU)[1])
demERA_D=disaggregate(demERA, res(demERA)[1]/res(demCRU)[1])
eleDiff=demCRU-demERA_D # ele diff CRU - ERA

#============ SPATIAL VARIABILITY ==================
#make raster stack of lapse rates months 1-12

#================ normalise to mean elev
#normalise to mean elev
pfactor=0.24 #mean value
corfact=1+(pfactor*(eleDiff/1000))/(1-(pfactor*(eleDiff/1000)))
demCruNorm=demCRU*corfact
eleNormCRU=stk_cru_cut_interp*corfact
#writeRaster(eleNormCRU, '/home/joel/data/CRU/data/eleNormCRU.tif', overwrite=T) #dont need write out


#======= Compute distribution weights 
#vectorised up on stack
cruP=eleNormCRU#[[j]]
rstmean=aggregate(cruP, fact=5, fun=mean) 
rstmean2=disaggregate(rstmean,fact=5)
subW=cruP/rstmean2
writeRaster(subW,'/home/joel/data/CRU/data/subWeights.tif', overwrite=T)

#======= ID raster maps coarse to subgrid
writeRaster(idgrid,'/home/joel/data/CRU/data/idgrid.tif', overwrite=T)
