#Era preoprocess 1 - convert 3d matrix to 2d matrix for simplicity of computations
conv3dto2d<-function(infile, varname){
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
outRoot='/home/joel/data/tscale_final/EraMet/conv3dto2d'

#=======================================================================================================
#			INFILES
#=======================================================================================================
infile='/home/joel/data/era/surface/grid74/strd.nc'

#=======================================================================================================
#			GET COORDMAP
#=======================================================================================================
coordMap=getCoordMap(infile)

#=======================================================================================================
#			3d matrix to 2d conversion
#=======================================================================================================
nc=open.ncdf(infile)
indat = get.var.ncdf( nc, varname)#"var175"

#could vectorise but quick anyway 
infile2dvec=c()
for(i in coordMap$cells){
x=coordMap$xlab[i]
y=coordMap$ylab[i]
infile2d=indat[x,y,]
infile2dvec=cbind(infile2dvec,infile2d)
}

return(infile2dvec)
}
