#PROCESS IMIS

#Purpose - input IMIS data ncdf, 
#in=imis ncdf
#out=dataframe of all stations aggregated etc

source('/home/joel/src/TopoScale/tools_src.r')

file='/home/joel/data/era/pressureLevels/tair/outfile.nc'
var='t'
threshold= 50000 # cleaning threshold, max value allowed

#aggregates time variable to daily values
t=timeDaily(fileName=file, origin=1900, step='seconds', timeVar='time')

#get data
nc<-open.ncdf(file)
dat = get.var.ncdf( nc, var)

#aggregates data to daily timeseries
z=dataDailyApply(X=dat, MARGIN=c(1,2,3), ts=t)
c=z[1,1,1] # get dims
dat=as.data.frame(z)
dates=dat[1]
dates=dates$Group.1
n=names(dat) # names of dataframe
data=dat[grep('x', n)] # subset dataframe by index of names containing 'x' ie data.

data[data>threshold]<-NA #assign 'NA' to non-value (with some tolerance)
names(data)<-seq(1:length(data)) #rename
#plot station n
#n=length(data)
#plot(dates,data[,n])

#write variable data to disk
write.table(data, paste('~/data/transformedData/MET_', var,'.txt', sep=''), row.names=F)

