# Write multiple attributes to a netCDF variable or file

Writes several attributes to a variable or to the global file metadata
of an open netCDF file.

## Usage

``` r
ncatt_put_all(
  nc,
  varid,
  attname,
  attval,
  prec = NA,
  verbose = FALSE,
  definemode = FALSE
)
```

## Arguments

- nc:

  An open netCDF connection created with
  [`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

- varid:

  Variable identifier. This can be a character string giving the
  variable name, an object of class `ncvar4`, or an integer id. As a
  special case, `varid = 0` writes global attributes.

- attname:

  Names of the attributes to write. Alternatively, this may be a named
  vector or list of attribute values when `attval` is omitted.

- attval:

  Values of the attributes to write. If omitted, `attname` must be a
  named vector or list whose names are used as attribute names.

- prec:

  Optional precision used when writing the attributes. Passed to
  [`ncdf4::ncatt_put()`](https://rdrr.io/pkg/ncdf4/man/ncatt_put.html).

- verbose:

  Logical. If `TRUE`, print additional information while writing
  attributes.

- definemode:

  Logical. Passed to
  [`ncdf4::ncatt_put()`](https://rdrr.io/pkg/ncdf4/man/ncatt_put.html).
  See that function for details.

## Value

`NULL`, invisibly.

## Details

Attributes can be supplied either as parallel `attname` and `attval`
arguments, or as a single named vector or list. Missing attribute names
are not allowed.

## See also

[`ncatt_get_all()`](ncatt_get_all.md),
[`ncdf4::ncatt_put()`](https://rdrr.io/pkg/ncdf4/man/ncatt_put.html)

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
  ncatt_put_all(nc, 0, attval = list(title = "Edited copy"))
})
```
