# Get variable sizes from a netCDF file

Returns the dimension sizes of a selected variable in an open netCDF
file.

## Usage

``` r
ncvar_size(nc, varid = NULL)
```

## Arguments

- nc:

  An open netCDF connection created with \[ncdf4::nc_open()\].

- varid:

  Variable identifier. This can be a character string giving the
  variable name, or an object of class \`ncvar4\`. If \`NULL\`,
  dimensions are returned for all variables in the file.

## Value

A numeric vector giving the dimension sizes of the selected variable. If
the file contains a single variable, that variable is used by default.

## Details

If the file contains more than one variable, \`varid\` must be supplied.

## See also

\[ncvar_dim()\], \[ncdim_size()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc <- ncdf4::nc_open("input.nc")
on.exit(ncdf4::nc_close(nc))

ncvar_size(nc, varid = "temp")
} # }
```
