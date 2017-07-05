# install.packages('rgdal')
library(raster)
rast_path<-list.files('/home/woo457/Dropbox/python_code/Interpolated_netcdfs/interpolated_rasters/',pattern = '.tif',full.names = TRUE)
rasts <- rast_path[-c(2,4,10,11,13)]
st <- stack(rasts)
st <- shift(st,y=180)
plot(st)

mask_rast <- raster('/home/woo457/Dropbox/python_code/Interpolated_netcdfs/interpolated_rasters/t_mask_25.tiff')
mask_rast <- flip(mask_rast,direction = "y")
mask_rast <- shift(mask_rast,y=180)
mask_rast <- calc(mask_rast,function(x){x[x>50]<-NA;return(x)})

st_mask <- mask(st,mask_rast)
## I need to incorporate the ocean std data.
## let's do the seafloor first. A little easier and doesn't require Terry's layers.
## First let's estimate slope and aspect of gebco layer.
# install.packages('ncdf4')
depth <- raster('/home/woo457/Dropbox/python_code/Interpolated_netcdfs/interpolated_rasters/gebco_depth_25.tiff')
depth <- shift(depth,y=180)
depth_mask <- mask(depth,mask_rast)

## example
# elevation <- getData('alt', country='CHE')
slope_aspect <- terrain(depth_mask, opt=c('slope', 'aspect'), unit='degrees')
# hillshade <- hillShade(slope_aspect[[1]],slope_aspect[[2]])
plot(slope_aspect)
plot(st_mask)

st <- stack(st_mask,depth_mask,slope_aspect[[1]])
x_mask <- sum(st)
st_all_mask <- mask(st,x_mask)

kmeans_data <- rasterToPoints(st_all_mask)
kmeans_data[,-1:-2] <- scale(kmeans_data[,-1:-2])

n_kmeans_seafloor <- lapply(2:20,function(x)kmeans(kmeans_data[,-1:-2],x))
test_k_means_seafloor$cluster


r <- st_all_mask[[1]]
ll <- replicate( 19 , r )
big.stack <- stack(ll)

for (i in 1:19)big.stack[[i]][!is.na(big.stack[[i]])] <- n_kmeans_seafloor[[i]]$cluster
plot(big.stack,col=rainbow(19))
names(big.stack) <- paste0('benthic_kmeans_cluster_',2:20,'_centers')

