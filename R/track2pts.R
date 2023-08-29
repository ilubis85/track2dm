#' @title Combine track and waypoints based on two common columns
#'
#' @description A function that combine track and waypoints based on two common columns.
#'
#' @param trackSp Digitised tracks in spatial dataframe.
#' @param track_id_1 The first common column in tracks data (e.g., Patrol_ID).
#' @param track_id_2 The second common column in tracks data (e.g., Patrol_Date).
#' @param minDist Minimum distance between points.
#' @param waypointSp Waypoints in spatial dataframe.
#' @param point_id_1 The first common column in waypoints data (e.g., Patrol_ID).
#' @param point_id_2 The second common column in waypoints data (e.g., Waypoint_Date).
#'
#' @return Spatial points dataframe.
#'
#'
#'
#' @export
# Create a function that combine track and waypoints based on two common columns
track2pts <- function(trackSp, track_id_1, track_id_2, minDist, waypointSp, point_id_1, point_id_2){

  # 1 : SPLIT TRACKS
  tracks <- list()

  # List of tracks
  track_list <- trackSp@data[, c(track_id_1, track_id_2)] %>% unique()

  for (i in 1:nrow(track_list)) {
    tracks[[i]]  <- subset(trackSp, trackSp@data[, track_id_1] == track_list[i,1] &
                             trackSp@data[, track_id_2] == track_list[i,2])
  }

  # Merge tracks with similar columns
  print(paste("track_length", length(tracks), sep = " = "))

  # 2 : SELECT WAYPOINT BASED ON SELECTED TRACK
  waypoints <- list()

  for (k in seq_along(tracks)) {

    # Select tracks
    track_k <- tracks[[k]]

    # Extract ID from colums
    id_1 <- track_k@data[, track_id_1]
    id_2 <- track_k@data[, track_id_2]

    # Then select way point based on track category
    waypoints[[k]] <- subset(waypointSp, waypointSp@data[,point_id_1] == id_1 &
                               waypointSp@data[,point_id_2] == id_2)

  }

  # 3 : CREATE DM FOR EACH COMBINATION OF TRACKS AND WP
  # Create progress bar
  pb = progress::progress_bar$new(
    format = "  processing [:bar] :percent in :elapsed",
    total = length(tracks), clear = FALSE, width= 60)

  # Output
  track_pts <- list()

  # Convert each track to multipoints
  for (i in 1:length(tracks)) {

    # Suppress warning
    options(warn=-1)

    # Select individual item
    tracks_i <- tracks[[i]]
    waypoints_i <- waypoints[[i]]

    # Add WP_ID for each waypoints, to be copied on the track
    waypoints_i@data <- waypoints_i@data %>% dplyr::mutate(WP_ID = 1:nrow(waypoints_i@data))

    # Convert tracks to multipoints
    tracks_pts_i <- track2dm::line2points(spLineDF = tracks_i, minDist = minDist)

    # Show plot
    # plot(tracks_i, col="grey")
    # plot(waypoints_i, pch=16, col='black', add=TRUE)
    # plot(tracks_pts_i, pch=1, col='red', add=TRUE)

    # Then copy the ID
    track_pt_wpID <- track2dm::copyID(points1 = tracks_pts_i, points2 = waypoints_i)

    # Copy common columns
    track_pt_wpID@data <- track_pt_wpID@data %>%
      dplyr::mutate_at(dplyr::vars(point_id_1, point_id_2), dplyr::na_if, y="") %>%
      tidyr::fill(point_id_1, point_id_2)

    # Combine result
    track_pts[[i]] <- track_pt_wpID

    # Progress bar
    pb$tick()
    Sys.sleep(1 / length(tracks))
  }

  # 4 : Combine as a result
  result <- do.call(rbind, track_pts)
  return(result)
}
