% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/df2sp.R
\name{df2sp}
\alias{df2sp}
\title{df2sp}
\usage{
df2sp(dataFrame, Xcol, Ycol, UTMZone)
}
\arguments{
\item{dataFrame}{A data-frame contains to be converted to spatial object data-frame.}

\item{Xcol}{A quoted name of column that consists X coordinates.}

\item{Ycol}{A quoted name of column that consists Y coordinates.}

\item{UTMZone}{A UTM projection of the target.}
}
\value{
Spatial object data-frame.
}
\description{
A function to convert data-frame to spatial object data-frame.
}
