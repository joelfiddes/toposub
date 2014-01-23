#=============================================================================
#		GENERAL
#==============================================================================
1. TopoSCALE precomputes atmospheric and topographic corrections of gridded downwelling (atmosphere) LWIN/SWIN. 
2. Terrain component is computed by GEOtop at model time steps (requires albedo/ surface T).
3. Point elevation = meteo elevation for fluxes dependent on elevation alone.

#=============================================================================
#		NAMING
#==============================================================================
SWin_ts = toposcaled SWin provided in meteo file
SWin_gt = geotop SWin (atm and terrain component):  SWin[W/m2]
SWin_out = geotop computed outgoing: SWup[W/m2]

LWin_ts = toposcaled SWin provided in meteo file
LWin_gt = geotop SWin (atm and terrain component): LWin[W/m2]
SWin_out = geotop computed outgoing: LWup[W/m2]

#=============================================================================
#		WHAT TOPOSCALE DOES
#==============================================================================

SWIN DOWNWELLING
1. input gridded SWin data (incident to horizontal plane)
2. partion to sdir and sdif
3. elevation scaling of sdir based on optical depth
4. Apply cosine correction [dotprod=sunVec %*% as.vector(normalVec)]
5. dotprod[dotprod<0]<-0 #negative indicates selfshading, set sdir to zero
6. sdir_topo=sdir*dotprod
7. sun elev < hor.el <-0 # sun elevations below horizon set sdir to zero
8. sdif_topo= sdif *svf
9. SWin_ts = sdif_topo + sdir_topo

LWIN DOWNWELLING
1. elevation correction
2. svf correction

TAIR
1. elevation correction

RH
1. elevation correction

WS
1. elevation correction
(wind model?)

WD
1. elevation correction
(wind model?)

Precip
1. elevation correction 

#=============================================================================
#		WHAT GEOTOP DOES
#==============================================================================
SWIN
1. Compute SWin_terrain at each timestep
2. SWin_gt = SWin_ts + SWin_terrain

LWIN
1. Compute LWin_terrain at each timestep
2. LWin_gt = LWin_ts + LWin_terrain

TAIR
1. nothing

RH
1. nothing

WS
1. 
(wind model?)

WD
1. 
(wind model?)

Precip
1. nothing


#=============================================================================
#		Testing
#==============================================================================

1. SWin_gt > SWin_ts
2. LWin_gt > LWin_ts
# SWin_out = SWin_gt * albedo  or SWin_ot = SWin_gt_dir * albedo

