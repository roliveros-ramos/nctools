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

  An open netCDF connection created with \[ncdf4::nc_open()\].

- varid:

  Variable identifier. This can be a character string giving the
  variable name, an object of class \`ncvar4\`, or an integer id. As a
  special case, \`varid = 0\` writes global attributes.

- attname:

  Names of the attributes to write. Alternatively, this may be a named
  vector or list of attribute values when \`attval\` is omitted.

- attval:

  Values of the attributes to write. If omitted, \`attname\` must be a
  named vector or list whose names are used as attribute names.

- prec:

  Optional precision used when writing the attributes. Passed to
  \[ncdf4::ncatt_put()\].

- verbose:

  Logical. If \`TRUE\`, print additional information while writing
  attributes.

- definemode:

  Logical. Passed to \[ncdf4::ncatt_put()\]. See that function for
  details.

## Value

\`NULL\`, invisibly.

## Details

Attributes can be supplied either as parallel \`attname\` and \`attval\`
arguments, or as a single named vector or list. Missing attribute names
are not allowed.

## See also

\[ncatt_get_all()\], \[ncdf4::ncatt_put()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc <- ncdf4::nc_open("input.nc", write = TRUE)
on.exit(ncdf4::nc_close(nc))

ncatt_put_all(
  nc,
  varid = "temp",
  attname = c("long_name", "units"),
  attval = list("Temperature", "degree_C")
)

ncatt_put_all(
  nc,
  varid = 0,
  attval = list(title = "Example file", source = "nctools")
)
} # }
```
