#========================================================================
#		MAKE GEOTOP INPTS FILE
#========================================================================
#numbers corrospond to ../landcoverZones.txt [lori numbers]
#1=debris [0]
#2=bedrock [1]
#3=vegetation [2]
surface=read.table(paste(spath,'/landcoverZones.txt',sep=''),header=T, sep=',')

# combine to dataframe
ThetaRes = c(ThetaRes1,ThetaRes2,ThetaRes3)
ThetaSat = c(ThetaSat1,ThetaSat2,ThetaSat3)
AlphaVanGenuchten             = c(AlphaVanGenuchten1,AlphaVanGenuchten2,AlphaVanGenuchten3)
NVanGenuchten                 = c(NVanGenuchten1,NVanGenuchten2,NVanGenuchten3)
NormalHydrConductivity        = c(NormalHydrConductivity1,NormalHydrConductivity2,NormalHydrConductivity3)
LateralHydrConductivity       = c(LateralHydrConductivity1,LateralHydrConductivity2,LateralHydrConductivity3)
surfacedf=data.frame(ThetaRes,ThetaSat,AlphaVanGenuchten,NVanGenuchten,NormalHydrConductivity,LateralHydrConductivity)


for(i in 1:npoints){
gsimindex=formatC(i, width=5,flag='0')
expRoot= paste(spath, '/result/S',gsimindex, sep='')

fs=readLines(paste(master,parfilename, sep='')) 

lnLat=gt.par.fline(fs=fs, keyword='Latitude') 
lnLong=gt.par.fline(fs=fs, keyword='Longitude') 
lnMetEle=gt.par.fline(fs=fs, keyword='MeteoStationElevation') 
lnPele=gt.par.fline(fs=fs, keyword='PointElevation') 
#soil
lntr=gt.par.fline(fs=fs, keyword='ThetaRes') 
lnts=gt.par.fline(fs=fs, keyword='ThetaSat') 
lnavg=gt.par.fline(fs=fs, keyword='AlphaVanGenuchten') 
lnnvg=gt.par.fline(fs=fs, keyword='NVanGenuchten')
lnnhc=gt.par.fline(fs=fs, keyword='NormalHydrConductivity')
lnlhc=gt.par.fline(fs=fs, keyword='LateralHydrConductivity')


#getGridMeta feeds in here
fs=gt.par.wline(fs=fs,ln=lnLat,vs=mf$lat[i])
fs=gt.par.wline(fs=fs,ln=lnLong,vs=mf$lon[i])
fs=gt.par.wline(fs=fs,ln=lnMetEle,vs=mf$ele[i])
fs=gt.par.wline(fs=fs,ln=lnPele,vs=mf$ele[i])

#soil
lc=surface$value[i]
fs=gt.par.wline(fs=fs,ln=lntr,vs=surfacedf$ThetaRes[lc])
fs=gt.par.wline(fs=fs,ln=lnts,vs=surfacedf$ThetaSat[lc])
fs=gt.par.wline(fs=fs,ln=lnavg,vs=surfacedf$AlphaVanGenuchten[lc])
fs=gt.par.wline(fs=fs,ln=lnnvg,vs=surfacedf$NVanGenuchten[lc])
fs=gt.par.wline(fs=fs,ln=lnnhc,vs=surfacedf$NormalHydrConductivity[lc])
fs=gt.par.wline(fs=fs,ln=lnlhc,vs=surfacedf$LateralHydrConductivity[lc])

#snow - reduce on debris slopes
#if(lc==1){
#scf=gt.par.fline(fs=fs, keyword='SnowCorrFactor') 
#fs=gt.par.wline(fs=fs,ln=scf,vs=0.4)
#}

#gt.exp.write(eroot_loc=paste(simRoot, 'sim',i, sep=''),eroot_sim,enumber=1, fs=fs)
comchar<-"!" #character to indicate comments
con <- file(expRoot&"/"&parfilename, "w")  # open an output file connection
	cat(comchar,"SCRIPT-GENERATED EXPERIMENT FILE",'\n', file = con,sep="")
	cat(fs, file = con,sep='\n')
	close(con)

}

