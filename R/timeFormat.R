#' @title timeFormat
#'
#' @description A function to reformat date and time.
#'
#' @param myString Information about date and time from tracklogs.
#'
#' @return a new string with DateTime format (as.Date or as.POSIXct).
#'
#'
#'# Reformat the datetime
#' swts::trackTime(TrackSP = df, TimeZone = "UTC")
#'
#' @export
timeFormat <- function(myString){
  # Remove anything other than number from the string
  justNo <- gsub("[^0-9]", "", myString)

  # Then split based on position (year-month-date-hour-min-sec)
  year <- str_sub(justNo, start = 1, end = 4)
  month <- str_sub(justNo, start = 5, end = 6)
  date <- str_sub(justNo, start = 7, end = 8)
  hour <- str_sub(justNo, start = 9, end = 10)
  min <- str_sub(justNo, start = 11, end = 12)
  sec <- str_sub(justNo, start = 13, end = 14)

  # Combine as Date and Time as POSIXct
  Date <- paste(year, month, date, sep = "-")
  Time <- paste(hour, min, sec, sep = ":")
  datetime <- paste(Date, Time, sep = " ")
  DateTime <- as.POSIXct(datetime, tz="Asia/Jakarta")

  return(DateTime)
}
