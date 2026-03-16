# Compute summary statistics of a netCDF variable

Applies a summary function to a variable in a netCDF file over the
dimensions not listed in \`MARGIN\`, and writes the result to a new
netCDF file.

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
  output, as in \[base::apply()\]. Dimension names may be used.

- na.rm:

  Logical. If \`TRUE\`, missing values are removed before computing the
  statistic.

- trim:

  Numeric scalar giving the fraction of observations to be trimmed from
  each end before computing the mean. Passed to \[base::mean()\]. Used
  only by \`nc_mean()\`.

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

  Logical. If \`TRUE\`, ignore case when matching dimension names
  supplied in \`MARGIN\`.

## Value

Invisibly returns \`output\`.

## Details

\`nc_mean()\` applies \[base::mean()\], \`nc_min()\` applies
\[base::min()\], and \`nc_max()\` applies \[base::max()\].

The output retains the dimensions specified in \`MARGIN\`.

## See also

\[nc_apply()\], \[base::mean()\], \[base::min()\], \[base::max()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc_mean(
  filename = "input.nc",
  varid = "temp",
  MARGIN = c("lon", "lat"),
  na.rm = TRUE,
  output = "temp_mean.nc"
)

nc_min(
  filename = "input.nc",
  varid = "temp",
  MARGIN = c("lon", "lat"),
  na.rm = TRUE,
  output = "temp_min.nc"
)

nc_max(
  filename = "input.nc",
  varid = "temp",
  MARGIN = c("lon", "lat"),
  na.rm = TRUE,
  output = "temp_max.nc"
)
} # }
```
