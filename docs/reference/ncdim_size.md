# Get dimension lengths from a netCDF file

Returns the lengths of all dimensions in an open netCDF file.

## Usage

``` r
ncdim_size(nc)
```

## Arguments

- nc:

  An open netCDF connection created with \[ncdf4::nc_open()\].

## Value

A named list giving the length of each dimension.

## See also

\[ncvar_dim()\], \[ncdim_isUnlim()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc <- ncdf4::nc_open("input.nc")
on.exit(ncdf4::nc_close(nc))

ncdim_size(nc)
} # }
```
