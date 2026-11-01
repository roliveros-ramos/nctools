# Get variable dimensions from a netCDF file

Returns the dimensions associated with one variable, or with all
variables in an open netCDF file.

## Usage

``` r
ncvar_dim(nc, varid = NULL, value = FALSE)
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

- varid:

  Variable identifier. This can be a character string giving the
  variable name, or an object of class `ncvar4`. If `NULL`, dimensions
  are returned for all variables in the file.

- value:

  Logical. If `TRUE`, return the coordinate values of each dimension
  instead of only the dimension names.

## Value

If `varid` is `NULL`, a named list with one element per variable. If
`varid` is supplied, the dimensions of the selected variable only. When
`value = FALSE`, dimensions are returned as character vectors of
dimension names. When `value = TRUE`, dimensions are returned as named
lists of coordinate values.

## See also

[`ncvar_size()`](ncvar_size.md), [`ncdim_size()`](ncdim_size.md),
[`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html)

## Examples

``` r
local({
  input = system.file("extdata",
    "temperature_2001_01.nc",
    package = "nctools",
    mustWork = TRUE)
  copy = tempfile(fileext = ".nc")
  file.copy(input, copy)
  nc = ncdf4::nc_open(copy, write = TRUE)
  on.exit({ ncdf4::nc_close(nc); unlink(copy) }, add = TRUE)
  ncvar_dim(nc)
})
#> $temperature
#> [1] "lon"  "lat"  "time"
#> 
```
