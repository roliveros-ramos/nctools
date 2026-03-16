# Subset a variable in a netCDF file

Extracts a subset of a variable from a netCDF file using coordinate
bounds supplied for one or more dimensions, and writes the result to a
new file.

## Usage

``` r
nc_subset(
  filename,
  varid,
  output,
  newvarid,
  compression,
  force_v4 = FALSE,
  ...,
  ignore.case = FALSE,
  drop = FALSE
)
```

## Arguments

- filename:

  Character string giving the path to the input netCDF file.

- varid:

  Character string giving the name of the variable to subset. If missing
  and the file contains a single variable, that variable is used.

- output:

  Character string giving the path to the output netCDF file to create.

- newvarid:

  Optional character string giving the name of the variable in the
  output file. By default, the original variable name is used.

- compression:

  Optional numeric compression level for the output variable. Supplying
  this typically requires netCDF4 output.

- force_v4:

  Logical. If \`TRUE\`, force creation of a netCDF4 output file.

- ...:

  Named bounds for dimensions to subset. Each argument name must match a
  dimension name. Values should be numeric vectors of length two giving
  lower and upper bounds. A length-one value is treated as an exact
  coordinate and expanded internally to \`c(x, x)\`.

- ignore.case:

  Logical. If \`TRUE\`, ignore case when matching dimension names
  supplied in \`...\`.

- drop:

  Logical. If \`TRUE\`, drop dimensions of length one in the output.

## Value

Invisibly returns \`output\`, or \`NULL\` invisibly if none of the
supplied dimension names match the variable dimensions.

## Details

Only dimensions named in \`...\` are subset; all others are kept in
full. The output file contains the subsetted variable, with updated
dimension values. Global attributes from the source file are copied to
the output file, and the global \`history\` attribute is updated with
the function call.

## See also

\[nc_extract()\], \[write_ncdf()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc_subset(
  filename = "input.nc",
  varid = "temp",
  output = "subset.nc",
  lon = c(-80, -70),
  lat = c(-20, -10),
  depth = c(0, 100)
)
} # }
```
