
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nctools

<!-- badges: start -->

[![R-CMD-check](https://github.com/roliveros-ramos/nctools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/roliveros-ramos/nctools/actions/workflows/R-CMD-check.yaml)
[![lifecycle](https://img.shields.io/badge/Lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html)
![GitHub R package
version](https://img.shields.io/github/r-package/v/roliveros-ramos/nctools?label=GitHub)
[![GitHub
issues](https://img.shields.io/github/issues/roliveros-ramos/nctools)](https://github.com/roliveros-ramos/nctools/issues)
<!-- badges: end -->

### Tools for Writing and Manipulating netCDF Files

At its core, **nctools** is designed to make it easy to write array data
from R to netCDF files, then inspect and manipulate those files with
lightweight helper functions.

This R package, **nctools**, provides helper functions for creating,
editing, subsetting, concatenating, and transforming netCDF files from
within R. Its main entry point is **`write_ncdf()`**, which offers a
quick and convenient way to write array data generated in R to netCDF
files with minimal boilerplate.

Built around **ncdf4**, the package also includes utilities for
inspecting variables and dimensions, reading and writing attributes,
renaming variables and dimensions, subsetting variables by dimension
values, concatenating records along unlimited dimensions, changing
longitude conventions, and applying summary functions over selected
margins.

The package is especially useful in modelling and environmental
workflows where arrays are first generated or processed in R and then
need to be exported to netCDF format for storage, exchange, or
downstream analysis. See <https://roliveros-ramos.github.io/nctools/>
for documentation and examples.

### Installation

``` r
# Once available on CRAN:
install.packages("nctools")

# Development version from GitHub:
# install.packages("remotes")
remotes::install_github("roliveros-ramos/nctools")
```

**Note:** because **nctools** depends on **ncdf4**, installation may
require a working system netCDF library.

### Usage

A typical workflow in **nctools** starts with array data already
available in R. The function **`write_ncdf()`** provides a simple
interface to turn those arrays into netCDF files by defining the
variable name, dimensions, and metadata directly in R.

Load the package:

``` r
library(nctools)
```

#### Quick start: write an array to a netCDF file

The main entry point of the package is **`write_ncdf()`**, which makes
it easy to export array data created in R to a netCDF file.

``` r
x <- array(rnorm(24), dim = c(4, 3, 2))

write_ncdf(
  x,
  filename = "example.nc",
  varid = "temp",
  dim = list(
    lon = seq(-72, -69, length.out = 4),
    lat = seq(-20, -18, length.out = 3),
    depth = c(0, 10)
  ),
  longname = "Temperature",
  units = "degree_C"
)
```

This creates a netCDF file directly from an R array, with named
dimensions and basic metadata, in a single step.

Once a netCDF file has been created, **nctools** provides a set of
utilities for common follow-up tasks.

Subset a variable using dimension bounds:

``` r
nc_subset(
  filename = "example.nc",
  varid = "temp",
  output = "subset.nc",
  lon = c(-71, -69),
  depth = 10
)
```

Compute a summary statistic over selected margins:

``` r
nc_mean(
  filename = "example.nc",
  varid = "temp",
  MARGIN = c("lon", "lat"),
  output = "temp_mean.nc"
)
```

Change the longitude convention of a variable:

``` r
nc_changePrimeMeridian(
  filename = "example.nc",
  output = "example_180.nc",
  varid = "temp",
  MARGIN = "lon",
  primeMeridian = "center"
)
```

Useful entry points to explore the package include:

``` r
?write_ncdf
?nc_subset
?nc_apply
?nc_changePrimeMeridian
```

### Contributions

If you find a bug, have questions about the documentation, or want to
suggest an enhancement, please [open an
issue](https://github.com/roliveros-ramos/nctools/issues).

Contributions are welcome as pull requests.
