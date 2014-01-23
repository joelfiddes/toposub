#=======================================================================================================
#			SIMULATION BOX (S)
#=======================================================================================================
#sequence of coarse grids to compute (can be sequence if run locally or single value automaticlly written by GC3pie in cloud mode)

#=======================================================================================================
#			SWITCHES
#=======================================================================================================
#MAIN SIMULATION MODES
crisp=FALSE	
fuzzy=TRUE
VALIDATE=FALSE	# compute fuzzy membership and result of set of validation files (requires ~/src/valPoints.txt - copied with src before simulation starts)

#switches
fuzReduce=FALSE	# reduce number of fuzzy members to top n most significant
#=======================================================================================================
#			MOST COMMON SETTINGS
#=======================================================================================================
#TSUB
Nclust=200 #TSUB resolution
col="X100.000000" #"snow_depth.mm." /"Tair.C." /tv to inform cluster and postprocess results (meanX..)
#====================================================================================================
#			PACKAGES
#=======================================================================================================
require(ncdf)
require(raster)
require(rgdal)
require(insol)
require(IDPmisc)
require(colorRamps)
require(Hmisc)
require(gdata)
require(gtools)
require(gmodels)

#======================================================================================
#	`			SOURCE
#======================================================================================
source(paste(root,'/src/ERA_tools/getERA_src.r',sep=''))
source(paste(root,'/src/code_toposub/toposub_src.r',sep=''))
source(paste(root,'/src/TopoSetup/toposub_crisp.r',sep=''))
source(paste(root,'/src/TopoSetup/toposub_fuzzy.r',sep=''))
source(paste(root,'/src/tscale_final/gt_control.r',sep=''))

source(paste(root,'/src/tscale_final/tscale_src.r',sep=''))
source(paste(root,'/src/tscale_final/surfFluxSrc.r',sep=''))
source(paste(root,'/src/tscale_final/solar_functions.r',sep=''))
source(paste(root,'/src/tscale_final/solar.r',sep=''))

nboxSeq=
#=======================================================================================================
#			DIRECTORIES/PATHS TO SET
#=======================================================================================================
epath=paste(root,'sim/',sep='') #created manually
srcRoot=paste(root,'src/TopoAPP/',sep='')
topoRoot=paste(root,'sim/_master/topo/',sep='')
exePath=paste(root,'src/',sep='')
exe='./geotop1.225-13'
parfilename='geotop.inpts'
#location of master geotopinpts
#metaFile='/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt' #points meta file c(id,ele,slp, asp, sky, lat,lon)
#eraBoxEle=read.table('/home/joel/data/transformedData/eraBoxEle.txt', header=T, sep=',') #preprocessed grid ele (slow)
#optional function

#==============================================================================
# 			TOPOSUB PARAMETERS -GENERALLY FIXED
#==============================================================================
rad=TRUE #SLP/ASP IN RADIANS
nFuzMem=10 #number of members to retain
iter.max=20	# maximum number of iterations of clustering algorithm
nRand=100000	# sample size
fuzzy.e=1.4 	# fuzzy exponent
nstart1=10 	# nstart for sample kmeans [find centers]
nstart2=1 	# nstart for entire data kmeans [apply centers]
thresh_per=0.001 # needs experimenting with

# input predictors
predNames<-c('ele', 'slp', 'asp', 'svf') #[PRED], 'svf'
predFormat='.tif'

#switches
findn=0
samp_reduce=FALSE#rm insig sample, redist members (needs fixing)

#experimental parameters [normal behaviour all = FALSE]
randomKmeansInit=FALSE

#=======================================================================================================
#			PARAMETERS TO SET: TSCALE
#=======================================================================================================
pfactor=0.25 				#liston precipitation parameter
#other
step=3 					#time step of accumulated fields

#======================================================================================
#				INFILES
#======================================================================================
#grids (all in UTM, can be other system but all the same)
ddem=raster(paste(topoRoot,'/ele.tif',sep=''))
dasp=raster(paste(topoRoot,'/asp.tif',sep=''))
dslp=raster(paste(topoRoot,'/slp.tif',sep=''))
dsky=raster(paste(topoRoot,'/svf.tif',sep=''))
lc=raster(paste(topoRoot,'/lc.tif',sep=''))
mask=raster(paste(topoRoot,'/mask.tif',sep=''))
eraBoxEleDem=paste(topoRoot,'/20121011073246_1677224548.asc',sep='')
#shp
dshp=shapefile(paste(root,'sim/_master/shp/eraDomainUTM32.shp',sep=''))#domain shp - same system as grids
dshp2=shapefile(paste(root,'sim/_master/shp/eraDomainWGS.shp',sep=''))#domain shp for getting ERA (must be WGS)

#precip grids
subWeights=paste(topoRoot,'/subWeights.tif',sep='')
idgrid=paste(topoRoot,'/idgrid.tif',sep='')

