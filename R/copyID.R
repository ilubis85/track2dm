#' @title Copy attributes from another spatial points data frame
#'
#' @description A function designed to copy attributes from a nearby spatial points data frame.
#'
#' @param points1 A spatial points data frame, comprising X and Y coordinates, designed to replicate attributes from another spatial points data frame (points2).
#' @param points2 A spatial points data frame with available attributes to be copied.
#'
#' @return Data in a spatial points data frame (points1) mirroring all attributes copied from another spatial data frame (points2).
#'
#'
#'
#' @export
# Create a function that copy the attributes from nearby track points to a waypoint
copyID <- function(points1, points2){

  # Convert to sf object
  points1_sf <- sf::st_as_sf(points1)
  points2_sf <- sf::st_as_sf(points2)

  # For each point, create a buffer with length is about a half of between 2 points from "points1"
  # Then check if there are any other points from "points2" within the buffer area
  # If there are more than one points of points2, get the nearest one
  # If no points around, keep the points1 data
  # create an output on a list
  newpoints <- list()

  # Use iteration for each point
  for (i in 1:nrow(points1_sf)) {
    # Select the i data
    subset_i <- points1_sf[i,]

    # Calculate the length between two points of points1
    pointdist <- terra::distance(sf::st_coordinates(points1_sf[1,]),  lonlat = FALSE,
                                 sf::st_coordinates(points1_sf[2,]))

    # Create a buffer using width from pointdist
    point_buff <- sf::st_buffer(x = subset_i, dist = base::floor(pointdist))

    # plot for check
    # plot(st_geometry(point_buff), border = 'red')
    # plot(st_geometry(subset_i), pch=18, col="blue", cex=1.4, add=TRUE)
    # plot(st_geometry(points2_sf), pch=17, col='black', cex=1.5, add=TRUE)

    # Intersect between buffer with data from points2
    if (sum(sf::st_intersects(point_buff, points2_sf, sparse = F)) >= 1){
      points2_in <- sf::st_intersection(points2_sf, point_buff)

      # Compile the result
      point_in <- data.frame("Id" = NA,
                             "X" = sf::st_coordinates(points2_in)[,'X'],
                             "Y" = sf::st_coordinates(points2_in)[,'Y'],
                             "WP_ID" = dplyr::select(sf::st_drop_geometry(points2_in),'WP_ID'))

      # If there is only one point within the buffer area, return the point_in
      if (nrow(points2_in) == 1){ point_in <- point_in

      } # If there are multiple points within the buffer area,
      else{
        # Calculate distance from each point to previous point (i-1)
        for (j in 1:nrow(point_in)) {
          # For the first row, calculate distance from point1_i
          if (i == 1){
            point_in[j, 'dist_to_prev_point'] <- terra::distance(x = sf::st_coordinates(points1_sf[i,]),
                                                                 y = as.matrix(point_in[j, c("X", "Y")]),
                                                                 pairwise=TRUE, lonlat = FALSE)
          } else {
            # For rows > 1
            point_in[j, 'dist_to_prev_point'] <- terra::distance(x =  sf::st_coordinates(points1_sf[i-1,]),
                                                                 y = as.matrix(point_in[j, c("X", "Y")]),
                                                                 pairwise=TRUE, lonlat = FALSE)
          }
        }
        # Then arrange points by distance from a point (i) to previous waypoint (i-1)
        # For the first row, arrange distance from points1 i
        if (i == 1){
          point_in <- point_in %>% dplyr::arrange(dplyr::desc(dist_to_prev_point)) %>%
            # Then remove dist_to_prev_point
            dplyr::select(1:4)
        } else {
          # For rows > 1 calculate distance from points1 i-1
          point_in <- point_in %>% dplyr::arrange(dist_to_prev_point) %>%
            # Then remove dist_to_prev_point
            dplyr::select(1:4)
        }
      }
    }
    # If no points2 within the buffer area, return points1
    else {
      point_in <- data.frame("Id" =subset_i$Id,
                             "X" = sf::st_coordinates(subset_i)[1],
                             "Y" = sf::st_coordinates(subset_i)[2], "WP_ID" = NA)
    }
    # Return result
    newpoints[[i]] <- point_in
  }
  # Combine the result
  newpoints_re <- do.call(rbind, newpoints)

  # COnvert to dataframe
  points2_df <- data.frame(sf::st_drop_geometry(points2_sf), sf::st_coordinates(points2_sf))

  # Combine newpoints_re with ponts2 data
  newResult <- dplyr::left_join(newpoints_re, points2_df, by = c("X", "Y", "WP_ID")) %>%
    unique() %>% # Remove duplicate values
    dplyr::mutate(Id = 1:nrow(.)) # Re-numbered ID

  # Return as a spatialPointsDataframe
  result_sp <- sf::st_as_sf(x = newResult, coords = c("X","Y"), crs = terra::crs(points2_sf))

  # Return the result
  return(result_sp)
}

