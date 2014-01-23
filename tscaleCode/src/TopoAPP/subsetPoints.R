#find points in box

## get obs in grid box10
## shapefile of val points
require(raster)
box<-nbox
#master='/home/joel/src/hobbes/_master/'
#spath='/home/joel/src/hobbes/results_points/b8/'
points_shp=points_shp
cp=dshp
#lc=raster(paste(master,'/topo/lc.tif',sep='')) #given in parfile
#mf=mf


#==================================================
#		OLD METHOD
#==================================================
## shapefile of val points
#dat_cut=points_shp[cp[box,],]
#dat_cut_id=dat_cut$id
#mf=read.table(mfin, sep=',', header=TRUE)
#mf_cut=mf[dat_cut_id,]
#mf_cut$id<-1:length(mf_cut$id) # change id from 1:n
#write.table(mf_cut, paste(spath, '/listpoints.txt', sep=''), sep=',', row.names=F)

##get landcover types
#shp_cut=points_shp[mf_cut$id,]
#lcp=extract(lcin, shp_cut)
#zone=1:length(mf_cut$id)
#modal=lcp
#df=data.frame(zone, modal)
#write.table(df, paste(spath, '/landcoverZones.txt', sep=''), sep=',', row.names=F)

#==================================================
#		NEW METHOD
#==================================================
#requires shapefile
#ID = numeric sequential 1:N
#ID2= numeric specific site ID , not necessarily sequential
## shapefile of val points
dat_cut=points_shp[cp[box,],]
dat_cut$id2<-dat_cut$id # change id from 1:n
dat_cut$id<-1:length(dat_cut$id) # change id from 1:n
write.table(dat_cut, paste(spath, '/listpoints.txt', sep=''), sep=',', row.names=F)

#get landcover types
lcp=extract(lcin, dat_cut)
zone=1:length(dat_cut$id)
modal=lcp
df=data.frame(zone, modal)
write.table(df, paste(spath, '/landcoverZones.txt', sep=''), sep=',', row.names=F)


