% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/joinPoint.R
\name{joinPoint}
\alias{joinPoint}
\title{joinPoint}
\usage{
joinPoint(waypointDF, trackDF, IDcol, Xcol, Ycol)
}
\arguments{
\item{waypointDF}{A dataframe of waypoints.}

\item{trackDF}{A dataframe of trackpoints.}

\item{IDcol}{A quoted name of column that consists the Ids.}

\item{Xcol}{A quoted name of column that consists X coordinates.}

\item{Ycol}{A quoted name of column that consists Y coordinates.}
}
\value{
A dataframe of waypoints and tracks and reordered by "Id".
}
\description{
A function to combine and rearrange waypoints and trackpoints.
}
