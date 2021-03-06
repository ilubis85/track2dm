% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/makeGrids.R
\name{makeGrids}
\alias{makeGrids}
\title{makeGrids}
\usage{
makeGrids(spObject, cellSize, clip = FALSE)
}
\arguments{
\item{spObject}{A spatial object in UTM projection.}

\item{cellSize}{Cell size for each subgrid in meters.}
}
\value{
A spatialpolygonedataframe of grid cells.
}
\description{
A function to create fishnet from a given spatial object/extent.
}
