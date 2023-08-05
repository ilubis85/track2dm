\name{occu_survey}
\alias{occu_survey}
\docType{data}
\title{
Data from occupancy survey
}
\description{
Dummy data from occupancy survey
}
\usage{data("occu_survey")}
\format{
  A data frame with 236 observations on the following 18 variables.
  \describe{
    \item{\code{No}}{a numeric vector}
    \item{\code{Grid_ID}}{a character vector}
    \item{\code{Leader}}{a character vector}
    \item{\code{DateTime}}{a POSIXct}
    \item{\code{Wp_Id}}{a numeric vector}
    \item{\code{Km}}{a numeric vector}
    \item{\code{Meter}}{a numeric vector}
    \item{\code{Species}}{a character vector}
    \item{\code{X}}{a numeric vector}
    \item{\code{Y}}{a numeric vector}
    \item{\code{Types}}{a character vector}
    \item{\code{Canopy}}{a numeric vector}
    \item{\code{Age}}{a character vector}
    \item{\code{Certnty}}{a character vector}
    \item{\code{Habitat}}{a character vector}
    \item{\code{Anml_tr}}{a character vector}
    \item{\code{Substrt}}{a character vector}
    \item{\code{Rain}}{a character vector}
  }
}
\details{
The data is used for an example to create detection matrix
}
\source{
Wildlife Conservation Society - Indonesian Program
}
\references{
Lubis et al., 2023
}
\examples{
str(occu_survey)
## maybe str(occu_survey) ; plot(occu_survey) ...
}
\keyword{datasets}
