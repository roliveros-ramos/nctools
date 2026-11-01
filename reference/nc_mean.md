# Compute summary statistics of a netCDF variable

Applies a summary function to a variable in a netCDF file over the
dimensions not listed in `MARGIN`, and writes the result to a new netCDF
file.

## Usage

``` r
nc_mean(
  filename,
  varid,
  MARGIN = c(1, 2),
  na.rm = TRUE,
  trim = 0,
  output = NULL,
  drop = TRUE,
  compression = NA,
  verbose = FALSE,
  force_v4 = TRUE,
  ignore.case = FALSE
)

nc_min(
  filename,
  varid,
  MARGIN = c(1, 2),
  na.rm = TRUE,
  output = NULL,
  drop = TRUE,
  compression = NA,
  verbose = FALSE,
  force_v4 = TRUE,
  ignore.case = FALSE
)

nc_max(
  filename,
  varid,
  MARGIN = c(1, 2),
  na.rm = TRUE,
  output = NULL,
  drop = TRUE,
  compression = NA,
  verbose = FALSE,
  force_v4 = TRUE,
  ignore.case = FALSE
)
```

## Arguments

- filename:

  Character string giving the path to the input netCDF file.

- varid:

  Character string giving the name of the variable to process. If
  missing and the file contains a single variable, that variable is
  used.

- MARGIN:

  Integer or character vector specifying the dimensions to retain in the
  output, as in [`base::apply()`](https://rdrr.io/r/base/apply.html).
  Dimension names may be used.

- na.rm:

  Logical. If `TRUE`, missing values are removed before computing the
  statistic.

- trim:

  Numeric scalar giving the fraction of observations to be trimmed from
  each end before computing the mean. Passed to
  [`base::mean()`](https://rdrr.io/r/base/mean.html). Used only by
  `nc_mean()`.

- output:

  Character string giving the path to the output netCDF file to create.

- drop:

  Logical. Currently not implemented.

- compression:

  Optional numeric compression level for the output variable.

- verbose:

  Logical. Currently unused.

- force_v4:

  Logical. Currently unused internally.

- ignore.case:

  Logical. If `TRUE`, ignore case when matching dimension names supplied
  in `MARGIN`.

## Value

Invisibly returns `output`.

## Details

`nc_mean()` applies [`base::mean()`](https://rdrr.io/r/base/mean.html),
`nc_min()` applies
[`base::min()`](https://rdrr.io/r/base/Extremes.html), and `nc_max()`
applies [`base::max()`](https://rdrr.io/r/base/Extremes.html).

The output retains the dimensions specified in `MARGIN`.

## See also

[`nc_apply()`](nc_apply.md),
[`base::mean()`](https://rdrr.io/r/base/mean.html),
[`base::min()`](https://rdrr.io/r/base/Extremes.html),
[`base::max()`](https://rdrr.io/r/base/Extremes.html)

## Examples

``` r
local({
  input = system.file("extdata",
    "temperature_2001_01.nc",
    package = "nctools",
    mustWork = TRUE)
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  nc_mean(input, "temperature", MARGIN = c("lon", "lat"), output = output)
})
```
