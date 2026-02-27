R functions to update my time series plots
================

## Overview

This repository includes a collection of R functions that help automate
maintaining updated versions of graphs of several macroeconomic
variables from public data. Below is a description and examples of the
use of these functions.

## 1. *`recplot()`:*

Requires a FRED API key set as an environment variable in R. The
function takes an existing ggplot2 plot and adds gray NBER recession
shading. Recession dates are downloaded from FRED (series `USREC`), so
they stay up to date automatically. The shading is clipped to match the
x-axis range of the input plot.

**Usage:**

``` r
recplot(p)
```

where `p` is a ggplot object with a date-based x-axis.

#### Example

Download Real GDP (GDPC1) and Real Gross Private Domestic Investment
(GPDIC1), compute year-over-year growth rates as log differences, and
plot.

``` r
library(reshape2)

gdp <- fredr(series_id = "GDPC1")
inv <- fredr(series_id = "GPDIC1")

gdp <- gdp[gdp$date >= as.Date("1970-01-01"), c("date", "value")]
inv <- inv[inv$date >= as.Date("1970-01-01"), c("date", "value")]

# Year-over-year log difference (lag 4 quarters), in percent
gdp$growth <- c(rep(NA, 4), 100 * diff(log(gdp$value), lag = 4))
inv$growth <- c(rep(NA, 4), 100 * diff(log(inv$value), lag = 4))

combined <- merge(gdp[, c("date", "growth")], inv[, c("date", "growth")],
                  by = "date", suffixes = c("_gdp", "_inv"))
colnames(combined) <- c("date", "Real GDP", "Real Investment")
combined <- combined[complete.cases(combined), ]
melted <- melt(combined, id = "date")

p2 <- ggplot(melted, aes(x = date, y = value, colour = variable)) +
  geom_line() +
  scale_colour_manual(values = c("Real GDP" = "darkblue", "Real Investment" = "darkred")) +
  scale_x_date(expand = c(0, 0)) +
  xlab("") + ylab("Percent") +
  ggtitle("Real GDP and Real Investment — Year-over-Year Growth Rates") +
  theme_bw()
```

``` r
recplot(p2)
```

![](ActGraphs_files/figure-gfm/two-series-rec-1.png)<!-- -->

## 2. *`BEAdat()`:*

Downloads a single time series from the Bureau of Economic Analysis
(BEA) API and returns it as a tibble with columns `date`, `series_id`,
and `value`, mirroring the format returned by `fredr()`. The function is
defined in `beafunctions.R`.

**Arguments:**

| Argument | Description |
|----|----|
| `datasetname` | BEA dataset (e.g. `"NIPA"`) |
| `TableName` | Table identifier (e.g. `"T10109"` for Table 1.1.9) |
| `series` | Line number within the table (character, e.g. `"1"`) |
| `freq` | Frequency: `"A"` (annual), `"Q"` (quarterly), `"M"` (monthly) |

**Usage:**

``` r
df <- BEAdat(datasetname, TableName, series, freq)
# Returns a tibble with columns: date, series_id, value
```

#### Example: GDP Implicit Price Deflator — Annual Growth Rate

Download the GDP Implicit Price Deflator from NIPA Table 1.1.9, Line 1,
at quarterly frequency. Compute the year-over-year growth rate as the
log difference (log of current quarter minus log of the same quarter one
year prior), plot with ggplot2, and pass to `recplot()` for recession
shading.

``` r
library(bea.R)
library(zoo)
source("beafunctions.R")

# Download GDP Implicit Price Deflator (Table 1.1.9, Line 1, Quarterly)
deflator <- BEAdat("NIPA", "T10109", "1", "Q")

# Year-over-year log difference (lag 4 quarters), in percent
deflator$growth <- c(rep(NA, 4), 100 * diff(log(deflator$value), lag = 4))
deflator <- deflator[!is.na(deflator$growth), ]

p3 <- ggplot(deflator, aes(x = date, y = growth)) +
  geom_line(color = "darkred", linewidth = 0.8) +
  scale_x_date(expand = c(0, 0)) +
  xlab("") + ylab("Percent") +
  ggtitle("GDP Implicit Price Deflator — Year-over-Year Growth Rate") +
  theme_bw()
p3
```

![](ActGraphs_files/figure-gfm/bea-deflator-1.png)<!-- -->

Now pass the plot to `recplot()` to add recession bands:

``` r
recplot(p3)
```

![](ActGraphs_files/figure-gfm/bea-deflator-rec-1.png)<!-- -->
