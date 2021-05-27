options(rgl.useNULL = FALSE)
library(ggplot2)
library(whitebox)
library(rayshader)
library(rayrender)
library(raster)
library(spatstat)
library(spatstat.utils)
library(suncalc)
library(sp)
library(lubridate)
library(rgdal)
library(png)
library(magick)

camarasa_tif = raster::raster('C:/Users/Gerard/Desktop/GIS/tecsigudl/E1/Rast/mdt1.tif')
camarasa_tif = raster::raster('C:/Users/Gerard/Desktop/GIS/Catalunya/DEM_CAT.tif')
cmrs_mat = raster_to_matrix(camarasa_tif)
cmrs_mat[1:10,1:10]

# Plot 1: traditional elevation map
cmrs_mat %>%
  height_shade() %>%
  plot_map()

# plot 2: sphere shade
cmrs_mat %>%
  sphere_shade() %>%
  plot_map()

#plot 3: sphere shade with water detected. Doesnt work perfectly
cmrs_mat %>%
  sphere_shade() %>%
  add_water(detect_water(cmrs_mat)) %>%
  plot_map()
# plot 4: sphere shade with different texture
cmrs_mat %>%
  sphere_shade(texture = "imhof1") %>%
  plot_map()

cmrs_mat %>%
  lamb_shade(zscale = 2) %>%
  add_shadow(ray_shade(cmrs_mat, zscale = 1, 
                       sunaltitude = 20, lambert = FALSE), 0.3) %>%
  plot_map()

cmrs_mat %>%
  sphere_shade() %>%
  add_water(detect_water(cmrs_mat), color = "lightblue") %>%
  add_shadow(ray_shade(cmrs_mat,zscale = 33, sunaltitude = 5,lambert = FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(cmrs_mat,zscale = 33,sunaltitude = 5), max_darken = 0.5) %>%
  plot_map()

x=5
while (x < 360){
  link = paste(x, "png", sep = ".")
  cmrs_mat %>%
    sphere_shade(texture='desert') %>%
    add_shadow(ray_shade(cmrs_mat, sunaltitude=45, sunangle = 315, zscale=1, labert=T), 0.3) %>%
    add_shadow(ambient_shade(cmrs_mat), max_darken = 0.1)
    #save_png(link)
    plot_map()
  x=x+10
  }

imageswrite <- list.files(path = "./", pattern = "*.png", full.names = T)
images2 = image_read(imageswrite) 
images3 = image_join(images2)
images4 = image_animate(images3, fps=10)
imagesfinal = image_write(images4, "./shadomove2.gif")  

cmrs_mat %>%
  sphere_shade() %>%
  add_water(detect_water(cmrs_mat), color = "lightblue") %>%
  add_shadow(ray_shade(cmrs_mat,zscale = 1, sunaltitude = 45,lambert = FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(cmrs_mat,zscale = 1,sunaltitude = 45), max_darken = 0.5) %>%
  add_shadow(ambient_shade(cmrs_mat), max_darken = 0.1) %>%
  plot_map()

ambientshadows = ambient_shade(cmrs_mat)

cmrs_mat %>%
  sphere_shade() %>%
  add_water(detect_water(cmrs_mat), color = "lightblue") %>%
  add_shadow(ray_shade(cmrs_mat, sunaltitude = 45, zscale = 33, lambert = FALSE), max_darken = 0.5) %>%
  add_shadow(lamb_shade(cmrs_mat, sunaltitude = 45, zscale = 33), max_darken = 0.7) %>%
  add_shadow(ambientshadows, max_darken = 0.1) %>%
  plot_3d(cmrs_mat, zscale = 33,windowsize = c(1000,1000))

rgl::rgl.close() 
