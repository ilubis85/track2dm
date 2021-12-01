#' @title joinPoint
#'
#' @description A function to combine and rearrange waypoints and trackpoints.
#'
#' @param waypointDF A dataframe of waypoints.
#' @param trackDF A dataframe of trackpoints.
#' @param Xcol A quoted name of column that consists X coordinates.
#' @param Ycol A quoted name of column that consists Y coordinates.
#' @param IDcol A quoted name of column that consists the Ids.
#'
#' @return A dataframe of waypoints and tracks and reordered by "Id".
#'
#'
#'
#' @export
# Combine both waypoint and trackpoint using a function
joinPoint <- function(waypointDF, trackDF, IDcol, Xcol, Ycol){

  # Join the table
  jointable <- dplyr::full_join(waypointDF, trackDF, by = c(IDcol, Xcol, Ycol)) %>%
    # Arrange by Id
    dplyr::arrange(.[,IDcol])

  # Create a vector to check if the Id from consecutive rows is similar, if so, put "yes"
  jointable[,"duplicate"] <- dplyr::if_else(jointable["Id"] == dplyr::lag(jointable["Id"]), "Yes", "No")

  # Then remove the track that has similar Id with waypoint
  jointable <- subset(jointable, duplicate != "Yes")

  # Remove "duplicate" columns
  jointable <- within(jointable, rm(duplicate))

  return(jointable)
}
