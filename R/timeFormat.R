#' @title timeFormat
#'
#' @description A function to reformat date and time.
#'
#' @param myString Information about date and time from tracklogs.
#' @param addTime A number of time to be added which happens when the timezone is not defined yet (e.g. Jakarta is UTC+7, so need to add 7 if the current time zone is UTC/GMT). Default is "00
#'
#' @return a new string with DateTime format (as.Date or as.POSIXct).
#'
#'
#'
#' @export
timeFormat <- function(myString, addTime = "00"){
  # Remove anything other than number from the string
  justNo <- gsub("[^0-9]", "", myString)

  # Then split based on position (year-month-date-hour-min-sec)
  year <- stringr::str_sub(justNo, start = 1, end = 4)
  month <- stringr::str_sub(justNo, start = 5, end = 6)
  date <- stringr::str_sub(justNo, start = 7, end = 8)
  hour <- stringr::str_sub(justNo, start = 9, end = 10)
  min <- stringr::str_sub(justNo, start = 11, end = 12)
  sec <- stringr::str_sub(justNo, start = 13, end = 14)

  # Combine as Date and Time as POSIXct
  Date <- paste(year, month, date, sep = "-")
  Time <- paste(hour, min, sec, sep = ":")
  datetime <- paste(Date, Time, sep = " ")
  DateTime <- as.POSIXct(datetime, tz="Asia/Jakarta")

  # Add time difference (e.g. Jakarta is UTC+7)
  timeAdd <- paste(addTime, "00", "00", sep = ":")
  DateTime <- DateTime + lubridate::hms(timeAdd)

  return(DateTime)
}
