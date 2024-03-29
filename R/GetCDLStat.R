#' Request summary statistics of the CDL data
#'
#' A function that requests summary statistics of the CDL data for any Area of Interests (AOI) in a given year from the CropScape.
#' This function implements the GetCDLStat services provided by the CropScape \url{https://nassgeodata.gmu.edu/CropScape}.
#'
#' The usage of this function is similar to the \code{GetCDLData} function. Please see the help page of the \code{GetCDLData} function
#' for details. Note that the \code{aoi} cannot be a single point here.
#'
#' @param aoi Area of interest. Can be a 5-digit FIPS code of a county, 2-digit FIPS code of a state, four corner points or an sf object that defines a rectangle (or a box) area,
#' multiple coordinates that defines a polygon, or a URL of an compressed ESRI shapefile.
#' @param year  Year of data. Should be a 4-digit numeric value.
#' @param type Type of the selected AOI. 'f' for state or county, 'b' for box area, 'ps' for polygon, 's' for ESRI shapefile.
#' @param crs Coordinate system. \code{NULL} if use the default coordinate system (i.e., Albers projection); Use '+init=epsg:4326' for longitude/latitude.
#' @param tol_time Number of seconds to wait for a response until giving up. Default is 20 seconds.
#'
#' @return
#' The function returns a data frame that reports summary statistics of the CDL data for an AOI in a given year.

#' @export
#'
#' @examples
#'\donttest{
#' # Example 1. Retrieve data for the Champaign county in Illinois (FIPS = 17109) in 2018.
#' data <- GetCDLStat(aoi = 17019, year = 2018, type = 'f')
#' head(data, n = 5) # Show top 5 rows of retrieved data
#'
#' # Example 2. Retrieve data for a polygon (a triangle) defined by three points in 2018.
#' data <- GetCDLStat(aoi = c(175207,2219600,175207,2235525,213693,2219600), year = 2018, type = 'ps')
#' head(data, n = 5)
#'
#' # Example 3. Retrieve data for a rectangle box defined by three corner points in 2018.
#' data <- GetCDLStat(aoi = c(130783,2203171,153923,2217961), year = '2018', type = 'b')
#' head(data, n = 5)
#'}

GetCDLStat <- function(aoi = NULL, year = NULL, type = NULL, crs = NULL, tol_time = 20){
  targetCRS <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

  if(is.null(aoi)) stop('aoi must be provided. See details. \n')

  if(is.null(year)) stop('year must be provided. See details. \n')

  if(is.null(type)) stop('type must be provided. See details. \n')

  if(type == 'p') stop('Cannot request statistics for a single point. \n')

  if(!type %in% c('f', 'ps', 'b', 's')) stop('Invalid type value. See details. \n')

  if(type == 'f'){
    aoi <- as.character(aoi)
    if ((nchar(aoi) == 1)|(nchar(aoi) == 4)){
      aoi <- paste0('0', aoi)
    }
    data <- tryCatch(GetCDLStatF(fips = aoi, year = year, tol_time = tol_time),
                     error = function(cond){
                       message('NA returned. Data request encounters the following error:')
                       message(cond)
                       return(NA)
                     })
  }

  if(type == 's'){
    if(!is.null(crs)) stop('The coordinate system must be the Albers projection system. \n')
    data <- tryCatch(GetCDLStatS(poly = aoi, year = year, tol_time = tol_time),
                     error = function(cond){
                       message('NA returned. Data request encounters the following error:')
                       message(cond)
                       return(NA)
                     })
  }

  if(type == 'ps'){
    if(length(aoi) < 6) stop('The aoi must be a numerical vector with at least 6 elements. \n')
    if(!is.null(crs)){ aoi <- convert_crs(aoi, crs)}
    data <- tryCatch(GetCDLStatPs(points = aoi, year = year, tol_time = tol_time),
                     error = function(cond){
                       message('NA returned. Data request encounters the following error:')
                       message(cond)
                       return(NA)
                     })
  }

  if(type == 'b'){
    if (!is.numeric(aoi)) {
      if (!(class(aoi)[1] == "sf" | class(aoi)[2] == "sfc")) stop('aoi must be a numerical vector or a sf object. \n')
      if(is.na(sf::st_crs(aoi))) stop('The sf object for aoi does not contain crs. \n')
      aoi_crs <- sf::st_crs(aoi)[[2]]

      if(aoi_crs != targetCRS){aoi <- sf::st_transform(aoi, targetCRS)}
      data <- tryCatch(GetCDLStatB(box = sf::st_bbox(aoi), year = year, tol_time = tol_time),
                       error = function(cond){
                         message('NA returned. Data request encounters the following error:')
                         message(cond)
                         return(NA)
                       })
    }else{
      if(length(aoi) != 4) stop('The aoi must be a numerical vector with 4 elements. \n')
      if(!is.null(crs)){ aoi <- convert_crs(aoi, crs)}
      data <- tryCatch(GetCDLStatB(box = aoi, year = year, tol_time = tol_time),
                       error = function(cond){
                         message('NA returned. Data request encounters the following error:')
                         message(cond)
                         return(NA)
                       })
    }
  }
  return(data)
}

