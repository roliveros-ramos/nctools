# Get variable compression settings from a netCDF file

Returns the compression setting of one variable, or of all variables, in
an open netCDF file.

## Usage

``` r
ncvar_compression(nc, varid = NA)
```

## Arguments

- nc:

  An open netCDF connection created with \[ncdf4::nc_open()\].

- varid:

  Variable identifier. This can be a character string giving the
  variable name, or an object of class \`ncvar4\`. If \`NA\`,
  compression settings are returned for all variables in the file.

## Value

If \`varid\` is \`NA\`, a named vector or list with the compression
setting of each variable. Otherwise, the compression setting of the
selected variable.

## See also

\[ncvar_change_compression()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc <- ncdf4::nc_open("input.nc")
on.exit(ncdf4::nc_close(nc))

ncvar_compression(nc)
ncvar_compression(nc, varid = "temp")
} # }
```
