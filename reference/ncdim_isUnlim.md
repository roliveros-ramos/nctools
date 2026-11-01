# Test whether dimensions are unlimited

Returns whether each dimension in an open netCDF file is unlimited.

## Usage

``` r
ncdim_isUnlim(nc)
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

## Value

A named logical vector indicating whether each dimension is unlimited.

## See also

[`ncdim_size()`](ncdim_size.md)

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
  ncdim_isUnlim(nc)
})
#>   lon   lat  time 
#> FALSE FALSE  TRUE 
```
