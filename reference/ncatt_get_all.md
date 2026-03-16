# Get all attributes from variables or dimensions

Returns all attributes associated with variables or dimensions in an
open netCDF file.

## Usage

``` r
ncatt_get_all(nc, type = c("var", "dim"))
```

## Arguments

- nc:

  An open netCDF connection created with \[ncdf4::nc_open()\].

- type:

  Character string indicating whether to return attributes for variables
  (\`"var"\`) or dimensions (\`"dim"\`).

## Value

A named list of attribute lists.

## See also

\[ncatt_put_all()\], \[ncdf4::ncatt_get()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc <- ncdf4::nc_open("input.nc")
on.exit(ncdf4::nc_close(nc))

ncatt_get_all(nc, type = "var")
ncatt_get_all(nc, type = "dim")
} # }
```
