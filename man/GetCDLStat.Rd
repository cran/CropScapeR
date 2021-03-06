% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GetCDLStat.R
\name{GetCDLStat}
\alias{GetCDLStat}
\title{Request summary statistics of the CDL data}
\usage{
GetCDLStat(aoi = NULL, year = NULL, type = NULL, crs = NULL, tol_time = 20)
}
\arguments{
\item{aoi}{Area of interest. Can be a 5-digit FIPS code of a county, 2-digit FIPS code of a state, four corner points or an sf object that defines a rectangle (or a box) area,
multiple coordinates that defines a polygon, or a URL of an compressed ESRI shapefile.}

\item{year}{Year of data. Should be a 4-digit numeric value.}

\item{type}{Type of the selected AOI. 'f' for state or county, 'b' for box area, 'ps' for polygon, 's' for ESRI shapefile.}

\item{crs}{Coordinate system. \code{NULL} if use the default coordinate system (i.e., Albers projection); Use '+init=epsg:4326' for longitude/latitude.}

\item{tol_time}{Number of seconds to wait for a response until giving up. Default is 20 seconds.}
}
\value{
The function returns a data frame that reports summary statistics of the CDL data for an AOI in a given year.
}
\description{
A function that requests summary statistics of the CDL data for any Area of Interests (AOI) in a given year from the CropScape.
This function implements the GetCDLStat services provided by the CropScape \url{https://nassgeodata.gmu.edu/CropScape}.
}
\details{
The usage of this function is similar to the \code{GetCDLData} function. Please see the help page of the \code{GetCDLData} function
for details. Note that the \code{aoi} cannot be a single point here.
}
\examples{
\donttest{
# Example 1. Retrieve data for the Champaign county in Illinois (FIPS = 17109) in 2018.
data <- GetCDLStat(aoi = 17019, year = 2018, type = 'f')
head(data, n = 5) # Show top 5 rows of retrieved data

# Example 2. Retrieve data for a polygon (a triangle) defined by three points in 2018.
data <- GetCDLStat(aoi = c(175207,2219600,175207,2235525,213693,2219600), year = 2018, type = 'ps')
head(data, n = 5)

# Example 3. Retrieve data for a rectangle box defined by three corner points in 2018.
data <- GetCDLStat(aoi = c(130783,2203171,153923,2217961), year = '2018', type = 'b')
head(data, n = 5)
}
}
