#' @title Transform the detection matrix into an sf object.
#'
#' @description A function to transform the detection matrix into an sf object.
#'
#' @param detectMatrix A matrix containing species detection/non-detection, generated from 'speciesDM'.
#' @param spProject Spatial object with its projection to be duplicated.
#' @return An sf data frame containing species detection/non-detection.
#'
#' @export
#' @importFrom  magrittr %>%
#'
# Create a function to convert detection matrix to spatial points data
dm2spatial <- function(detectMatrix, spProject){

  # Separate and transform detection
  new_deTect <- detectMatrix %>%
    dplyr::select(dplyr::starts_with("R")) %>%
    # Transform column to row
    tidyr::pivot_longer(cols = dplyr::starts_with("R")) %>%
    # Rearrange
    dplyr::mutate("Rep" = 1:nrow(.)) %>% dplyr::transmute(Rep, "Detection"=value)

  # Separate, transform, and separate X and Y Coordinates
  new_XYcor <- detectMatrix %>%
    dplyr::select(dplyr::starts_with("XY")) %>%
    # Transform column to row
    tidyr::pivot_longer(cols = dplyr::starts_with("XY")) %>%
    # Separate between X and Y
    tidyr::separate(data = ., col = value, into = c("X", "Y"), sep = "_") %>%
    # Select and reformat
    dplyr::select(-name) %>% dplyr::mutate_if(is.character, as.numeric)

  # Combine both detection and coordinate & Remove NA
  new_detMax <- stats::na.omit(cbind(new_deTect, new_XYcor))

  # Convert to spatial data using sf
  new_detMax_sp <- sf::st_as_sf(x = new_detMax, coords = c('X','Y'),
                                crs = terra::crs(spProject))
  # Return output
  return(new_detMax_sp)
}
