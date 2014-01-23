setwd(root)
source(paste(root,'/src/TopoAPP/makebatch_toposcale.R',sep=''))
setwd(spath)
system('./batch_tscale.txt')
setwd(root)
source(paste(root,'/src/TopoAPP/toposcale_writeMet_parallel.R',sep=''))

