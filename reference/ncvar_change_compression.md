# Change variable compression settings in a netCDF object

Modifies the compression setting of one or more variables in an open
netCDF object.

## Usage

``` r
ncvar_change_compression(nc, varid = NA, compression)
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

- varid:

  Variable identifier. This can be a character string giving the
  variable name, or an object of class `ncvar4`. If `NA`, the
  compression setting is changed for all variables in the file.

- compression:

  Numeric compression level to assign.

## Value

The modified netCDF object.

## See also

[`ncvar_compression()`](ncvar_compression.md)

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
  nc = ncvar_change_compression(nc, compression = 4)
  ncvar_compression(nc)
  # This changes the in-memory definition, not the stored data.
})
#> temperature 
#>           4 
```
