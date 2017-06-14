library(raster)
rast_path<-list.files('/home/woo457/Dropbox/python_code/Interpolated_netcdfs/interpolated_rasters/',pattern = '.tif',full.names = TRUE)
rasts <- rast_path[-2]
st <- stack(rasts)


