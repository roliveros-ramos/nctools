# Test whether dimensions are unlimited

Returns whether each dimension in an open netCDF file is unlimited.

## Usage

``` r
ncdim_isUnlim(nc)
```

## Arguments

- nc:

  An open netCDF connection created with \[ncdf4::nc_open()\].

## Value

A named logical vector indicating whether each dimension is unlimited.

## See also

\[ncdim_size()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc <- ncdf4::nc_open("input.nc")
on.exit(ncdf4::nc_close(nc))

ncdim_isUnlim(nc)
} # }
```
