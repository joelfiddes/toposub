#ERA EXTENT TOOLS (longlat)

#maek grid extent raster (varname = any varname in ncdf, not important, just uses spatial reference. )
#values of boxes either those of varname (seqVAl=F) or seq 1...n boxes (seqVal=T) 
era2rst<-function(file, varname, seqVal=F){
require(raster)
extent<-raster(file, varname=varname)
boxes<-ncell(extent)
if(seqVal==T){values(extent)<-seq(1,boxes,1)}
return(extent)
}

#maek grid extent shape
era2shp=function(file, varname,seqVal=F){
rst=era2rst(file=file, varname=varname, seqVal=seqVal)
shp=rasterToPolygons(rst)
return(shp)
}

#write shp

shapefile(object=shp,filename= '~/SRMExp/gridERA.shp', overwrite=T)


#maek grid extent  kml
era2kml=function(file, varname, outfile, seqVal=F){
rst=era2rst(file=file, varname=varname, seqVal=seqVal)
KML(x=rst, filename=outfile)
}

#get gridele
dem='/home/joel/data/bamiyan2012/gdem2_bamiyan.asc
raster(dem)
########### script ###########################

#extract timeseries based on input shape file
file='~/SRMExp/tairERA.nc'

varname='t2m'
rst=era2rst(file=file, varname=varname, seqVal=T)
bas=raster('/home/joel/data/bamiyan2012/dem/ahangDEM.asc')
KML(bas, '/home/joel/SRMExp/basin.kmz')

x=intersect(rst, bas)
boxID=getValues(x)

row_vec=c()
col_vec=c()
for(i in boxID){
ydim=dim(rst)[1]
xdim=dim(rst)[2]

row=ceiling(i/xdim)
col=floor(xdim*((i/xdim)-floor(i/xdim)))
row_vec=c(row_vec, row)
col_vec=c(col_vec, col)
}

require(ncdf)
nc<-open.ncdf(file)
var = get.var.ncdf( nc, varname) 
dat=var[col_vec, row_vec,]#check rder
plot(dat, type='l') #why repeated? forecast correect check era Q&A

#conversions


#aggregate (mean, min, max)


#get grid elevation


#timeseries
timeVar = get.var.ncdf( nc, "time")
z <- timeVar*60*60 #make seconds
time<-ISOdatetime(1900,1,1,0,0,0) + z   
t = get.var.ncdf( nc, "t2m")
#temp K -> degC
t<-t-273.15

#t[col,row,data] - era ncdf indexing

#calc timeseries for each relevant grid box
df=c()
for (i in 1:length(row_vec)){
#assign(paste('ts',i,sep=''),t[col_vec[i], row_vec[i],])
ts=t[col_vec[i], row_vec[i],]
df=cbind(df, ts)
}
dfMean= rowMeans(df) # mean boxes timeseries

# times as days (for aggregation
day=as.POSIXct(strptime(format(time,format="%Y/%m/%d %H"),format="%Y/%m/%d"),tz="UTC")

#compute daily mean, min, max tair
t_day_mean<-aggregate(dfMean,by=list(day),FUN=mean,na.rm=TRUE)
t_day_max<-aggregate(dfMean,by=list(day),FUN=max,na.rm=TRUE)
t_day_min<-aggregate(dfMean,by=list(day),FUN=min,na.rm=TRUE)

#dataframe construct and output
tdf=data.frame(t_day_mean$Group.1,t_day_mean$x, t_day_min$x, t_day_max$x)
names(tdf)<-c('time','mean', 'min', 'max')
write.table(tdf, '~/SRMExp/tair.txt', sep=',', row.names=F)

#make one big dataset out of multiple downloads (result of download restriction. Requires folder and variable name.
#uses 'ncrcat' function of NCO program http://nco.sourceforge.net/#RTFM  http://nco.sourceforge.net/nco.html#Averaging-vs_002e-Concatenating
#cd to folder
# run 'ncrcat file1 file2 ... outputfile.ncdf'
#or  'ncrcat * outputfile.ncdf'
ncMerge=function(folder='/home/joel/data/era/pressureLevels/vwind'){
setwd(folder)
system('ncrcat * outfile.nc')
}

#check data good
library(ncdf)
nc=open.ncdf('/home/joel/data/era/surface/6hr/outfile.nc')
timeVar = get.var.ncdf( nc, "time")
z <- timeVar*60*60 #make seconds
time<-ISOdatetime(1900,1,1,0,0,0) + z   
t = get.var.ncdf( nc, "t2m")
#temp K -> degC
tair<-t-273.15
plot(time, tair[1,1,6,], type='l')
