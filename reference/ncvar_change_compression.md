# Change variable compression settings in a netCDF object

Modifies the compression setting of one or more variables in an open
netCDF object.

## Usage

``` r
ncvar_change_compression(nc, varid = NA, compression)
```

## Arguments

- nc:

  An open netCDF connection created with \[ncdf4::nc_open()\].

- varid:

  Variable identifier. This can be a character string giving the
  variable name, or an object of class \`ncvar4\`. If \`NA\`, the
  compression setting is changed for all variables in the file.

- compression:

  Numeric compression level to assign.

## Value

The modified netCDF object.

## See also

\[ncvar_compression()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc <- ncdf4::nc_open("input.nc")
on.exit(ncdf4::nc_close(nc))

nc <- ncvar_change_compression(nc, varid = "temp", compression = 4)
} # }
```
