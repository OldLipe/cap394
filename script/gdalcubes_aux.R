library(gdalcubes)
library(tidyverse)


#' create_database
#'
#' @author Felipe Carvalho
#'
#' @param database_name
#'
#' @param gdal_dataset
#'
#' @param json_path
#'
#' @note Please include full path on @param json_path
create_database <- function(database_name, gdal_dataset, json_path){

  gdalcubes::create_image_collection(gdal_dataset,
                                     json_path,
                                     database_name)

}

#' create_gdal_dataset
#'
#'
#'@note This function is specific for .hdf extension
#'
create_gdal_dataset <- function(img_path, bands){

  file_subdatasets <- expand.grid(file=list.files(file.path(img_path),
                                                  pattern=".hdf$",
                                                  full.names = TRUE),
                                                  subdataset=bands)

  gdal_dataset <-  paste("HDF4_EOS:EOS_GRID:\"",
                         file_subdatasets$file,
                         "\":Grid:",
                         file_subdatasets$subdataset,
                         sep="")



  return(gdal_dataset)
}

# Fast and bad way to get all bands from L30 product
get_l30_bands <- function(){
  bands <- c("band01",
             "band02",
             "band03",
             "band04",
             "band05",
             "band06",
             "band07",
             "band09",
             "band10",
             "band11",
             "QA")
  return(bands)

}

# Fast and bad way to get all bands from S30 product
get_s30_bands <- function(){
  bands <- c("B01",
             "B02",
             "B03",
             "B04",
             "B05",
             "B06",
             "B07",
             "B08",
             "B8A",
             "B09",
             "B10",
             "B11",
             "B12",
             "QA")
  return(bands)
}

################################################################################

######## Creating gdal_dataset

# Its needed when working with .hdf extensions
#img_path <- "/home/felipe/Mestrado/HLS_Felipe_23LLF/HLS_S30"
# bands <- get_s30_bands()
# gdal_dataset <- create_gdal_dataset(img_path = img_path,
#                                     bands = bands)


# Creating database
# create_database(database_name = "/home/felipe/Mestrado/HLS_Felipe_23LLF/",
#                 gdal_dataset = gdal_dataset,
#                 json_path = "/home/felipe/R/ets/R/img_col_l30.json")





################################################################################

############ settings

gdalcubes::gdalcubes_options(threads = 8,
                             ncdf_compression_level = 0,
                             debug = FALSE,
                             cache = TRUE,
                             ncdf_write_bounds = TRUE)


img_col <- gdalcubes::image_collection("/home/felipe/Mestrado/HLS_Felipe_23LLF/db_s30_hj.db")
################################################################################

# Montando o cube view
img_cube_view <- gdalcubes::cube_view(extent=img_col,
                                          srs="+proj=utm +zone=23 +ellps=WGS84 +units=m +no_defs",
                                          nx = 3660,
                                          ny = 3660,
                                          dt="P1M",
                                          aggregation = "median")

img_cube_view.trat <- gdalcubes::cube_view(view=img_cube_view,
                                           extent=list(t0="2017-08",
                                                       t1="2018-04"))


hls_cube <- gdalcubes::raster_cube(img_col,
                                   img_cube_view.trat)

################################################################################

# Calc NDVI

ndvi_band_s30 <- hls_cube %>% gdalcubes::select_bands(c("B8A", "B04")) %>%
	gdalcubes::apply_pixel("(B8A-B04)/(B8A+B04)", names="NDVI")


system.time({gdalcubes::write_tif(ndvi_band_s30, dir="/home/felipe/Mestrado/HLS_Felipe_23LLF/Gdalcubes_trab_geo/tif_s30_nir_red_median_one_and_half_year")})
# sem chunk 7271.932 sec
# chunk(32, 512, 512) - Tempo:3114 sec
# chunk(64, 1014, 1014) - Tempo:2090 sec

################################################################################


#gdalcubes::raster_cube(img_col, img_cube_view.trat) %>%
#  select_bands(c("B02","B03","B04")) %>%
#  animate(rgb=3:1, zlim=c(100,1000))



