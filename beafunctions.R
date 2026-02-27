BEAdat <- function(datasetname, TableName, series, freq) {

  APIkey <- Sys.getenv("BEA_API_KEY")

  paramlist <- list('UserID' = APIkey,
                    'Method' = 'GetData',
                    'datasetname' = datasetname,
                    'Frequency' = freq,
                    'YEAR' = 'X',
                    'TableName' = TableName)

  BL <- bea2List(beaGet(paramlist, asTable = FALSE))
  BL <- BL[(BL[3] == series), c(4, 5, 9)]
  varname <- BL[1, 1]
  BL <- BL[, c(2, 3)]

  # Parse time periods into Date objects
  if (freq == 'A') {
    dates <- as.Date(paste0(BL[, 1], "-01-01"))
  } else if (freq == 'Q') {
    dates <- as.Date(as.yearqtr(
      paste0(substr(BL[, 1], 1, 4), " Q", substr(BL[, 1], 6, 6))
    ))
  } else {
    dates <- as.Date(as.yearmon(
      paste0(substr(BL[, 1], 1, 4), "-", substr(BL[, 1], 6, 7))
    ))
  }

  tibble::tibble(
    date      = dates,
    series_id = varname,
    value     = as.numeric(BL[, 2])
  )
}
