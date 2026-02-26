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

#### Example 1: Single Series

Download Real GDP (GDPC1) from FRED, filter to 1970 onward and plot.

``` r
gdp <- fredr(series_id = "GDPC1")
gdp <- gdp[gdp$date >= as.Date("1970-01-01"), ]

p <- ggplot(gdp, aes(x = date, y = value)) +
  geom_line(color = "blue") +
  scale_x_date(expand = c(0, 0)) +
  xlab("") + ylab("Billions of Chained 2017 Dollars") +
  ggtitle("Real GDP") +
  theme_bw()
p
```

![](ActGraphs_files/figure-gfm/single-series-1.png)<!-- -->

Now pass the plot to `recplot()` to add recession bands:

``` r
recplot(p)
```

![](ActGraphs_files/figure-gfm/single-series-rec-1.png)<!-- -->

#### Example 2: Two Series

Download Real GDP (GDPC1) and Real Gross Private Domestic Investment
(GPDIC1), combine them into a single data frame and plot.

``` r
library(reshape2)

gdp <- fredr(series_id = "GDPC1")
inv <- fredr(series_id = "GPDIC1")

gdp <- gdp[gdp$date >= as.Date("1970-01-01"), c("date", "value")]
inv <- inv[inv$date >= as.Date("1970-01-01"), c("date", "value")]

combined <- merge(gdp, inv, by = "date", suffixes = c("_gdp", "_inv"))
colnames(combined) <- c("date", "Real GDP", "Real Investment")
melted <- melt(combined, id = "date")

p2 <- ggplot(melted, aes(x = date, y = value, colour = variable)) +
  geom_line() +
  scale_x_date(expand = c(0, 0)) +
  xlab("") + ylab("Billions of Chained 2017 Dollars") +
  ggtitle("Real GDP and Real Investment") +
  theme_bw()
p2
```

![](ActGraphs_files/figure-gfm/two-series-1.png)<!-- -->

Add recession shading with `recplot()`:

``` r
recplot(p2)
```

![](ActGraphs_files/figure-gfm/two-series-rec-1.png)<!-- -->
