
library(fredr)
library(ggplot2)

fredr_set_key(Sys.getenv("FRED_API_KEY"))

get_recession_dates <- function() {
  usrec <- fredr(series_id = "USREC")
  usrec <- usrec[order(usrec$date), ]
  rec <- usrec$value
  dates <- usrec$date

  # Detect transitions: 0->1 is a peak, 1->0 is a trough
  starts <- which(diff(rec) == 1) + 1
  ends   <- which(diff(rec) == -1) + 1

  # Handle series starting inside a recession
  if (rec[1] == 1) {
    starts <- c(1, starts)
  }

  # Handle series ending inside a recession (ongoing recession)
  if (rec[length(rec)] == 1) {
    ends <- c(ends, length(rec))
  }

  data.frame(Peak = dates[starts], Trough = dates[ends])
}

recplot <- function(p) {
  recessions.df <- get_recession_dates()

  # Extract the x-axis range from the existing plot to filter recessions
  build <- ggplot_build(p)
  x_range <- range(build$layout$panel_params[[1]]$x.range)
  x_min <- as.Date(x_range[1], origin = "1970-01-01")
  x_max <- as.Date(x_range[2], origin = "1970-01-01")

  recessions.df <- recessions.df[recessions.df$Trough >= x_min & recessions.df$Peak <= x_max, ]

  # Clip recession bars to the original data range
  recessions.df$Peak   <- pmax(recessions.df$Peak, x_min)
  recessions.df$Trough <- pmin(recessions.df$Trough, x_max)

  p + geom_rect(data = recessions.df,
                aes(xmin = Peak, xmax = Trough, ymin = -Inf, ymax = +Inf),
                fill = "gray", alpha = 0.3, inherit.aes = FALSE) +
    coord_cartesian(xlim = c(x_min, x_max))
}
