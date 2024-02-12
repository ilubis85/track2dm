#' @title Generate ordered points using the 'line2points' and 'copyID' functions, utilizing two common columns gathered from waypoints and transect lines.
#'
#' @description A function to generate ordered points using the 'line2points' and 'copyID' functions, utilizing two common columns gathered from waypoints and transect lines.
#'
#' @param trackSp A spatial data frame containing digitized track lines.
#' @param track_id_1 The first common column in the track lines data frame, such as 'Patrol_ID'.
#' @param track_id_2 The second common column in the track lines data frame, such as 'Patrol_Date'.
#' @param minDist The minimum distance between points, measured in meters.
#' @param waypointSp A spatial points data frame recorded during the survey along the trackSp.
#' @param point_id_1 The first common column in spatial points data frame, such as 'Patrol_ID'.
#' @param point_id_2 The second common column in spatial points data frame. such as 'Waypoint_Date'.
#'
#' @return An ordered spatial points data frame derived from 'trackSp' and 'waypointSp'.
#'
#'
#'
#' @export
# Create a function
track2points <- function(trackSp, track_id_1, track_id_2, minDist, waypointSp, point_id_1, point_id_2){

  # Convert to sf object
  tracksf <- sf::st_as_sf(trackSp)
  waypointsf <- sf::st_as_sf(waypointSp)

  # 1 : SPLIT TRACKS
  tracks_skip <- list() # Remove if track length < minDist
  tracks_keep <- list()

  # List of tracks
  # track_list <- trackSp@data[, c(track_id_1, track_id_2)] %>% unique()
  track_list <- tracksf %>% sf::st_drop_geometry() %>%
    dplyr::select(track_id_1, track_id_2) %>%  # Select
    dplyr::group_by_(track_id_1, track_id_2) %>%  # Select
    dplyr::arrange(track_id_1, track_id_2, .by_group=TRUE) %>% unique()

  # Convert to individual line as "LINESTRING"
  for (i in 1:nrow(track_list)) {
    tracks_i  <- sf::st_cast(tracksf[i,], "LINESTRING", do_split=FALSE) # Do not split object

    # Remove traks that have track length < 2 x minDist
    if (as.numeric(st_length(tracks_i)) < 2*minDist){
      tracks_skip[[i]] <- tracks_i

      # Else, skip
    }else{tracks_keep[[i]] <- tracks_i}
  }

  # Discard NULL
  tracks_skip <- tracks_skip %>% discard(is.null)
  tracks_keep <- tracks_keep %>% discard(is.null)

  # Print message
  print(paste("number of tracks", length(tracks_keep), sep = " is "))
  n_skip <- paste("number of tracks discarded due to track length", paste(2*minDist, "mtrs", sep = " "), sep = " <= ")
  print(paste(n_skip, length(tracks_skip), sep = " is "))

  # 2 : SELECT WAYPOINT BASED ON SELECTED TRACK
  waypoints <- list()
  for (j in seq_along(tracks_keep)) {

    # Suppress warning
    options(warn=-1)

    # Select tracks
    track_j <- tracks_keep[[j]]

    # Extract ID from colums
    id_1 <- track_j[, track_id_1] %>% sf::st_drop_geometry() %>% as.vector()
    id_2 <- track_j[, track_id_2] %>% sf::st_drop_geometry() %>% as.vector()

    # Then select way point based on track category
    waypoints[[j]] <- waypointsf %>%
      dplyr::filter(dplyr::across(dplyr::all_of(point_id_1), ~. == id_1) &
                      dplyr::across(dplyr::all_of(point_id_2), ~. == id_2))

  }
  # 3 : CREATE DM FOR EACH COMBINATION OF TRACKS AND WP
  # Create progress bar
  pb = progress::progress_bar$new(
    format = "  processing [:bar] :percent in :elapsed",
    total = length(tracks_keep), clear = FALSE, width= 60)

  # Output
  track_pts <- list()

  # Convert each track to multipoints
  for (k in 1:length(tracks_keep)) {

    # Suppress warning
    options(warn=-1)

    # Select individual item
    tracks_k <- tracks_keep[[k]]
    waypoints_k <- waypoints[[k]]

    # Add WP_ID for each waypoints, to be copied on the track
    waypoints_k <- waypoints_k %>% dplyr::mutate(WP_ID = 1:nrow(waypoints_k))

    # Convert tracks to multipoints
    tracks_pts_k <- track2dm::line2points(spLineDF = tracks_k, minDist = minDist)

    # Show plot
    plot(st_geometry(tracks_k), lwd=1.4, col="lightblue")
    plot(st_geometry(waypoints_k), pch=16, cex=0.8, col='grey40', add=TRUE)
    plot(st_geometry(tracks_pts_k), pch=8, col='red', add=TRUE)
    text(x = base::mean(waypoints_k$X), y = base::mean(waypoints_k$Y),
         font=1, cex=1.3, paste("track", k, sep = " "))

    # Then copy the ID
    track_pt_wpID <- track2dm::copyID(points1 = tracks_pts_k, points2 = waypoints_k)

    # Fill empty point_id_1 and point_id_2 columns
    # track_pt_wpID <- track_pt_wpID %>%
    #   dplyr::mutate_at(dplyr::vars(point_id_1, point_id_2), dplyr::na_if, y="") %>%
    #   tidyr::fill(point_id_1, point_id_2)

    # Combine result
    track_pts[[k]] <- track_pt_wpID

    # Progress bar
    pb$tick()
    Sys.sleep(1 / length(tracks_keep))
  }
  # 4 : Combine as a result
  result_com <- do.call(rbind, track_pts)

  # Rearrange id
  result <- result_com %>% dplyr::mutate(Id = 1:nrow(result_com))

  return(result)
}
