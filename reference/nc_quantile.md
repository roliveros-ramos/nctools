# Compute sample quantiles of a netCDF variable

Applies [`stats::quantile()`](https://rdrr.io/r/stats/quantile.html) to
a variable in a netCDF file over the dimensions not listed in `MARGIN`,
and writes the result to a new netCDF file.

## Usage

``` r
nc_quantile(
  filename,
  varid,
  MARGIN = c(1, 2),
  na.rm = TRUE,
  probs = c(0, 0.5, 1),
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
  quantiles.

- probs:

  Numeric vector of probabilities in `[0, 1]` passed to
  [`stats::quantile()`](https://rdrr.io/r/stats/quantile.html).

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

The output retains the dimensions specified in `MARGIN`. An additional
dimension is appended to store the quantiles defined by `probs`.

## See also

[`nc_apply()`](nc_apply.md),
[`stats::quantile()`](https://rdrr.io/r/stats/quantile.html)

## Examples

``` r
local({
  input = system.file("extdata",
    "temperature_2001_01.nc",
    package = "nctools",
    mustWork = TRUE)
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  nc_quantile(input, "temperature", MARGIN = c("lon", "lat"), output = output)
})
```
