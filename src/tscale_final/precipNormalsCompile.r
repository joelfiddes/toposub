#compile monthly normals precipitation
require(raster)

filez <- list.files("/home/joel/data/meteoswiss/gridded_datasets/precipitation/origdata/netcdf/RhiresM_ch02.lonlat_61_10/") 
allstack <- stack(filez) 
years=length(filez)

stk=stack()
for (i in 1:12){
monthvec=seq(i,years*12,12)
newstack=stack(allstack[[monthvec]])
mp=stackApply(x=newstack, fun=mean, indices=rep(1,years))	
stk=stack(stk, mp)
}

par(mfrow=c(3,4))
for(i in 1:12){
plot(stk[[i]],main=i)

}
writeRaster(stk, '/home/joel/data/meteoswiss/precipStk.tif',overwrite=T)
