#=======================================================================================================
#			SIMULATION BOX (S)
#=======================================================================================================
#sequence of coarse grids to compute (can be sequence if run locally or single value automaticlly written by GC3pie in cloud mode)
nboxSeq=1

#=======================================================================================================
#			SWITCHES
#=======================================================================================================
#MAIN SIMULATION MODES
inform=TRUE	# perform informed scaling routine
crisp=FALSE	
fuzzy=FALSE
VALIDATE=FALSE	# compute fuzzy membership and result of set of validation files (requires ~/src/valPoints.txt - copied with src before simulation starts)
parTscale=TRUE #parallel tscale
#switches
fetchERA=FALSE	# retreive ERA forcing from ECMWF servers?
fuzReduce=FALSE	# reduce number of fuzzy members to top n most significant
swTopo=FALSE
#=======================================================================================================
#			MOST COMMON SETTINGS
#=======================================================================================================
#TSUB
Nclust=10
#TSUB resolution
file1<-'/out/ground.txt' 
#path of geotop output file relative to sim directory
col="X100.000000" 
#"snow_depth.mm." /"Tair.C." /tv to inform cluster and postprocess results (meanX..)
beg <- "01/10/2010 00:00:00"
 #start cut of data timeseries dd/mm/yyyy h:m:s (GEOtop format)
end <- "01/11/2010 00:00:00" 
#end cut data timeseries

#TSCALE
startDate='2010-09-30 00:00:00' #start cut of driving climate (ERA format)	#yyyy-mmd-d h:m:s
endDate='2011-11-02 00:00:00'#end cut of driving climate 
#set as buffer to TSUB dates to allow margin at 00 /2100 etc

#=======================================================================================================
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
source(paste(root,'/src/tscale_final/solar_geometry.R',sep=''))

source(paste(root,'/src/tscale_final/solarPartition.R',sep=''))
source(paste(root,'/src/tscale_final/sdirEleScale.R',sep=''))
source(paste(root,'/src/tscale_final/sdifSvf.R',sep=''))

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
tz=1 				#timezone, negative = west (used in package:insol)
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
dshp=shapefile(paste(root,'sim/_master/shp/ERADomainUTM43.shp',sep=''))#domain shp - same system as grids
dshp2=shapefile(paste(root,'sim/_master/shp/ERADomainWGS.shp',sep=''))#domain shp for getting ERA (must be WGS)

#method to apply climatology to get subgrid distribution of P
climatolP=FALSE # default = FALSE
if(climtolP==TRUE){
#precip grids
subWeights=paste(topoRoot,'/subWeights.tif',sep='')
idgrid=paste(topoRoot,'/idgrid.tif',sep='')
}
#===============================================================================
#				ERA FETCH PARAMETERS
#=============================================================================
#only relevant if fetchERA=TRUE
parNameSurf=c( 'dt', 'strd', 'ssrd', 'p', 't', 'toa')
parCodeSurf=c(168,175,169,228,167,212)

parNamePl=c('gpot','tpl','rhpl','upl','vpl')
parCodePl=c(129,130,157,131,132)

#mf=read.table( '/home/joel/data/ibutton/IB_dirruhorn/mf_IB.txt', sep=',' ,header=T)
dd="19790101/to/20121231"# date range yyyymmdd

grd='0.75/0.75'	# resolution long/lat (0.75/0.75) or grid single integer eg 80
plev= '500/650/775/850/925/1000'	#pressure levels (mb), only written if levtype=pl

#===============================================================================
#				DEFINE SURFACE
#=============================================================================
#numbers corrospond to ../landcoverZones.txt [lori numbers]
#1=debris [0]
#2=bedrock [1]
#3=vegetation [2]

# 1. FIXED STUFF=soil_GRAVEL --> surfacetype debris
ThetaRes1=0.055
ThetaSat1=0.374
AlphaVanGenuchten1=0.1
NVanGenuchten1=2
NormalHydrConductivity1=1
LateralHydrConductivity1=1

# 2. FIXED STUFF=soil_ROCK --> surface type bedrock
ThetaRes2=0
ThetaSat2=0.05
AlphaVanGenuchten2=0.001
NVanGenuchten2=1.2
NormalHydrConductivity2=1e-06
LateralHydrConductivity2=1e-06

# 3. FIXED STUFF=soil_SANDYSILT (mean SILT + SAND) --> surface type vegetation
ThetaRes3 = 0.056
ThetaSat3 = 0.4305
AlphaVanGenuchten3             = 0.002
NVanGenuchten3                 = 2.4
NormalHydrConductivity3        = 0.04375
LateralHydrConductivity3       = 0.04375



