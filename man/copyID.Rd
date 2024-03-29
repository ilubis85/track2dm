% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/copyID.R
\name{copyID}
\alias{copyID}
\title{Copy attributes from another spatial points data frame}
\usage{
copyID(points1, points2)
}
\arguments{
\item{points1}{A spatial points data frame, comprising X and Y coordinates, designed to replicate attributes from another spatial points data frame (points2).}

\item{points2}{A spatial points data frame with available attributes to be copied.}
}
\value{
Data in a spatial points data frame (points1) mirroring all attributes copied from another spatial data frame (points2).
}
\description{
A function designed to copy attributes from a nearby spatial points data frame.
}
