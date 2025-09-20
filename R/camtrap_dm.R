#' @title camtrap_dm
#'
#' @description A function to extract detection matrices for a species from camtrap survey.
#'
#' @param ctTable A dataframe from camera trap survey.
#' @param gridId A column contain grid ID.
#' @param camId A column contain camera ID.
#' @param dateCol A column contain date information (in POSIXct format).
#' @param Xcol A quoted column name representing X coordinates within the dataFrame.
#' @param Ycol A quoted column name representing Y coordinates within the dataFrame.
#' @param speCol A column containing all the species for which to extract detection matrices.
#' @param speName A selected species name within the "speCol" column to be extracted as detection matrices.
#' @param numOcc Number of days or times used for an occation.
#'
#' @return A data frame containing the detection matrix for selected species from camera trap survey
#'
#'
#' @export
#' @importFrom  magrittr %>%
#'
# Create a package to extract detection matrices
camtrap_dm <- function(ctTable, gridId, camId, speCol, speName, dateCol, Xcol, Ycol, numOcc){

  # Give warning if date is not in the right format
  if (!inherits(ctTable[[dateCol]], "POSIXt")) {
    stop(glue::glue("Column '{dateCol}' must be in datetime format (POSIXct or POSIXlt)."))
  }

  # Rearrange column
  camtrap_df <- ctTable %>%
    dplyr::transmute(grid_id = .data[[gridId]], camera_id = .data[[camId]],
                     species = .data[[speCol]], date = .data[[dateCol]],
                     X = .data[[Xcol]], Y  = .data[[Ycol]])

  # Create detection matrices
  camtrap_occ <- camtrap_df %>%
    # Create a new column for n-day occasion (occasion index)
    dplyr::mutate(days_since_first = as.integer(as.numeric(difftime(date, dplyr::first(date), units = "days"))),
                  occasion = as.integer(days_since_first/numOcc)+1)

  # Create detection matrices for selected species
  species_detected <- camtrap_occ %>%
    dplyr::filter(species == speName) %>%  # Select target species
    dplyr::mutate(detected = 1) %>%               # Assign detection = 1
    dplyr::group_by(camera_id, occasion) %>%                # Group by Site and Week
    dplyr::summarise(detected = max(detected), .groups = "drop") %>%  # Ensure unique value per Site-Week
    tidyr::pivot_wider(names_from = occasion, values_from = detected, values_fill = 0) %>%
    dplyr::arrange(camera_id) %>%
    select(camera_id, order(as.numeric(names(.)[-1])) + 1) %>% # Ensure Week columns are in order
    dplyr::rename_with( .fn = ~ paste0("occ_", seq_along(.x)), .cols = -camera_id)  # rename and apply only to columns other than grid_id

  # Create an array of grid id with XY coordinates
  ct_locs <- camtrap_df %>%
    dplyr::select(camera_id, X, Y) %>%
    distinct(camera_id,.keep_all = TRUE) # Remove duplicates in GRID

  # Combine CT locs with detection matrices
  ct_species_dm <- dplyr::left_join(ct_locs, species_detected, by = "camera_id") %>%
    # Replace NA with 0
    dplyr::mutate_all(~ replace(., is.na(.), 0))

  # Return the result
  return(ct_species_dm)
}
