# Get variable compression settings from a netCDF file

Returns the compression setting of one variable, or of all variables, in
an open netCDF file.

## Usage

``` r
ncvar_compression(nc, varid = NA)
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

- varid:

  Variable identifier. This can be a character string giving the
  variable name, or an object of class `ncvar4`. If `NA`, compression
  settings are returned for all variables in the file.

## Value

If `varid` is `NA`, a named vector or list with the compression setting
of each variable. Otherwise, the compression setting of the selected
variable.

## See also

[`ncvar_change_compression()`](ncvar_change_compression.md)

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
  ncvar_compression(nc)
})
#> temperature 
#>          NA 
```
