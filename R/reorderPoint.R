#' @title reorderPoint
#'
#' @description A function to reorder point based on group information and distance among the points
#'
#' @param pointsDF A dataframe of points to be reordered, it should contain grouping Ids.
#' @param startPoint A specific row from pointsDF where the point starts.
#' @param groupID The Id that represents the group information.
#'
#' @return Similar data with wayPoints with additional Id copied from nearby track points.
#'
#'
#'
#' @export
# Create a function that copy the ID from nearby track points to a waypoint
# Both data are spatial points dataframe in UTM projection
reorderPoint <- function(pointsDF, startPoint, groupID){

  ########################## PART 1 ####################################
  # Create a vector of group from the smallest of WP_ID to the largest
  Vec_ID <- pointsDF[, groupID] %>% sort() %>% unique()

  # Add a new variable of Dist, then split dataframe based on Vec_ID
  group_ID_split <- pointsDF %>% dplyr::mutate(Dist = as.numeric(NA))
  group_ID_split <- split(pointsDF, pointsDF[, groupID])

  # Then rearrange the points for each group based on distance
  # Rearrange the first group
  for (i in 1:nrow(group_ID_split[[1]])) {
    # Calculate distance from start point to all point
    group_ID_split[[1]][i, "Dist"] <- raster::pointDistance(startPoint[,c("X", "Y")],
                                                            group_ID_split[[1]][i,c("X", "Y")],
                                                            lonlat = FALSE)
    # Rearrange by distance
    group_ID_split[[1]] <- group_ID_split[[1]] %>% dplyr::arrange(Dist)
  }

  ########################### PART 2 #########################################
  # Then for the subsequent group, do the same but using a start point from -
  # the last point of the previous group
  # Start from group 2
  for (j in 2:length(group_ID_split)) {

    # Specify the start point for each group
    startPoint2 <- utils::tail(group_ID_split[[j-1]], 1)

    # Then calculate distance between start point from the previous group, to the points of the next group
    for (k in 1:nrow(group_ID_split[[j]])) {

      # Calculate distance from start point to all point
      group_ID_split[[j]][k, "Dist"] <- raster::pointDistance(startPoint2[,c("X", "Y")],
                                                              group_ID_split[[j]][k, c("X", "Y")],
                                                              lonlat = FALSE)

      # Rearrange by distance
      group_ID_split[[j]] <- group_ID_split[[j]] %>% dplyr::arrange(Dist)
    }
    group_ID_split
  }
  # Combine all group
  group_ID_split_join <- do.call(rbind, group_ID_split)

  # Return value
  return(group_ID_split_join)
}
