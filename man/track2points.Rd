% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/track2points.R
\name{track2points}
\alias{track2points}
\title{Generate ordered points using the 'line2points' and 'copyID' functions, utilizing two common columns gathered from waypoints and transect lines.}
\usage{
track2points(
  trackSp,
  track_id_1,
  track_id_2,
  minDist,
  waypointSp,
  point_id_1,
  point_id_2
)
}
\arguments{
\item{trackSp}{A spatial data frame containing digitized track lines.}

\item{track_id_1}{The first common column in the track lines data frame, such as 'Patrol_ID'.}

\item{track_id_2}{The second common column in the track lines data frame, such as 'Patrol_Date'.}

\item{minDist}{The minimum distance between points, measured in meters.}

\item{waypointSp}{A spatial points data frame recorded during the survey along the trackSp.}

\item{point_id_1}{The first common column in spatial points data frame, such as 'Patrol_ID'.}

\item{point_id_2}{The second common column in spatial points data frame. such as 'Waypoint_Date'.}
}
\value{
An ordered spatial points data frame derived from 'trackSp' and 'waypointSp'.
}
\description{
A function to generate ordered points using the 'line2points' and 'copyID' functions, utilizing two common columns gathered from waypoints and transect lines.
}
