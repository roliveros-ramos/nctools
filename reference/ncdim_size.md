# Get dimension lengths from a netCDF file

Returns the lengths of all dimensions in an open netCDF file.

## Usage

``` r
ncdim_size(nc)
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

## Value

A named list giving the length of each dimension.

## See also

[`ncvar_dim()`](ncvar_dim.md), [`ncdim_isUnlim()`](ncdim_isUnlim.md)

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
  ncdim_size(nc)
})
#> $lon
#> [1] 15
#> 
#> $lat
#> [1] 20
#> 
#> $time
#> [1] 31
#> 
```
