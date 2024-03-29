#' Manual calculation of land cover changes
#'
#' The \code{manualrotate} function analyzes land cover changes based on two raster files from the CropScape. The analysis is done in three steps.
#'  At step 1, the two raster files are converted to data tables. At step 2, the two data tables are merged together based on their coordinates.
#'  The coordinates without macthes are discarded during the merging process.
#'  At step 3, the merged data are aggregated by counting the number of pixels for each land cover change group.
#'
#'
#' @param datat1 A raster file.
#' @param datat2 A raster file.
#'
#' @return
#' The function returns a data frame.
#'
#' @export
#'
#'
manualrotate <- function(datat1, datat2){
  if(class(datat1) != c('RasterLayer')) stop('datat1 must be a raster file.')
  if(class(datat2) != c('RasterLayer')) stop('datat2 must be a raster file.')

  res1 <- raster::res(datat1)
  res2 <- raster::res(datat2)

  if(res1[1] > res2[1]){datat2 <- raster::resample(datat2, datat1, method = "ngb")}
  if(res1[1] < res2[1]){datat1 <- raster::resample(datat1, datat2, method = "ngb")}

  stopifnot(raster::res(datat1)[1] == raster::res(datat2)[1])
  conversionfactor <- ifelse(raster::res(datat1) == 56, 0.774922, 0.222394)

  datat1 <- raster::rasterToPoints(datat1)
  datat2 <- raster::rasterToPoints(datat2)

  datat1 <- data.table::as.data.table(datat1)
  datat2 <- data.table::as.data.table(datat2)

  pixelcounts <- merge(datat1, datat2, by = c('x', 'y')) %>%
    as.data.frame() %>%
    'colnames<-'(c('x', 'y', 'value.x', 'value.y')) %>%
    dplyr::filter(value.x > 0, value.y > 0) %>%
    dplyr::group_by(value.x, value.y) %>%
    dplyr::summarise(Count = dplyr::n()) %>%
    dplyr::left_join(., linkdata, by = c('value.x' = 'MasterCat')) %>%
    dplyr::left_join(., linkdata, by = c('value.y' = 'MasterCat')) %>%
    dplyr::ungroup() %>%
    dplyr::select(-value.x, -value.y) %>%
    dplyr::rename(From = Crop.x, To = Crop.y) %>%
    dplyr::mutate(Acreage = Count*conversionfactor[1])

  return(pixelcounts)
}

