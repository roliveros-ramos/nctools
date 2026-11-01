# Get all attributes from variables or dimensions

Returns all attributes associated with variables or dimensions in an
open netCDF file.

## Usage

``` r
ncatt_get_all(nc, type = c("var", "dim"))
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

- type:

  Character string indicating whether to return attributes for variables
  (`"var"`) or dimensions (`"dim"`).

## Value

A named list of attribute lists.

## See also

[`ncatt_put_all()`](ncatt_put_all.md),
[`ncdf4::ncatt_get()`](https://rdrr.io/pkg/ncdf4/man/ncatt_get.html)

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
  ncatt_get_all(nc)
})
#> $temperature
#> $temperature$units
#> [1] "degree_C"
#> 
#> $temperature$`_FillValue`
#> [1] -9999
#> 
#> $temperature$long_name
#> [1] "Synthetic daily temperature"
#> 
#> 
```
