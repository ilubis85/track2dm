% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/copyID.R
\name{copyID}
\alias{copyID}
\title{copyID}
\usage{
copyID(points1, points2)
}
\arguments{
\item{points1}{Spatial points dataframe consist of X and Y that copys attribute from points2.}

\item{points2}{Spatial points dataframe where the attributes available to be copied.}
}
\value{
Similar data with points1 with additional Id copied from nearby points2.
}
\description{
A function to copy IDs from other nearby SpatialPointsDataframe.
}
