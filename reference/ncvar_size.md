# Get variable sizes from a netCDF file

Returns the dimension sizes of a selected variable in an open netCDF
file.

## Usage

``` r
ncvar_size(nc, varid = NULL)
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

- varid:

  Variable identifier. This can be a character string giving the
  variable name, or an object of class `ncvar4`. If `NULL`, dimensions
  are returned for all variables in the file.

## Value

A numeric vector giving the dimension sizes of the selected variable. If
the file contains a single variable, that variable is used by default.

## Details

If the file contains more than one variable, `varid` must be supplied.

## See also

[`ncvar_dim()`](ncvar_dim.md), [`ncdim_size()`](ncdim_size.md)

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
  ncvar_size(nc)
})
#> [1] 15 20 31
```
