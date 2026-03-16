# Write data to a netCDF file

\`write_ncdf()\` is an S3 generic for writing R objects to a netCDF
file. Methods are provided for writing a single array-like object
(\`write_ncdf.default()\`) and a list of arrays (\`write_ncdf.list()\`).

## Usage

``` r
write_ncdf(x, filename, ...)

# Default S3 method
write_ncdf(
  x,
  filename,
  varid,
  dim,
  longname,
  units,
  prec = "float",
  missval = NA,
  compression = 9,
  chunksizes = NA,
  verbose = FALSE,
  dim.names,
  dim.units,
  dim.longname,
  unlim = FALSE,
  global = list(),
  force_v4 = FALSE,
  ...
)

# S3 method for class 'list'
write_ncdf(
  x,
  filename,
  varid,
  dim,
  longname,
  units,
  prec = "float",
  missval = NA,
  compression = 9,
  chunksizes = NA,
  verbose = FALSE,
  dim.names,
  dim.units,
  dim.longname,
  unlim = FALSE,
  global = list(),
  force_v4 = FALSE,
  ...
)
```

## Arguments

- x:

  Object to write. Supported methods currently accept either a single
  array-like object or a list of array-like objects.

- filename:

  Character string giving the path to the netCDF file to create.

- ...:

  Additional arguments passed to methods.

- varid:

  Character string giving the name of the variable to create in the
  output file.

- dim:

  A named or unnamed list defining the coordinates of each dimension.
  Each element contains the coordinate values for one dimension. If
  omitted, dimensions are generated as \`seq_len()\` for each dimension
  of \`x\`.

- longname:

  Character string giving the long name of the output variable. Defaults
  to \`""\`.

- units:

  Character string giving the units of the output variable. Defaults to
  \`""\`.

- prec:

  Character string giving the storage precision passed to
  \[ncdf4::ncvar_def()\], for example \`"short"\`, \`"integer"\`,
  \`"float"\` or \`"double"\`.

- missval:

  Missing value used in the netCDF variable definition.

- compression:

  Numeric compression level passed to \[ncdf4::ncvar_def()\].
  Compression usually requires netCDF4 output.

- chunksizes:

  Optional chunk sizes for compressed variables.

- verbose:

  Logical. Should \`ncdf4\` report progress while creating and filling
  the file?

- dim.names:

  Character vector with names for the dimensions when \`dim\` is
  unnamed. Ignored when \`dim\` already has names.

- dim.units:

  Character vector giving the units of the dimensions. If omitted, empty
  strings are used.

- dim.longname:

  Character vector giving the long names of the dimensions. If omitted,
  empty strings are used.

- unlim:

  Character string naming the unlimited dimension. Use \`FALSE\` for no
  unlimited dimension.

- global:

  Named list of global attributes to add to the output file. A
  \`history\` attribute documenting the function call is added
  automatically.

- force_v4:

  Logical. Should the output file be forced to netCDF4 format?

## Value

Invisibly returns \`filename\`.

## Details

\`write_ncdf.default()\` writes a single object \`x\` as one variable in
a new netCDF file. The dimensions of the variable are defined by
\`dim\`.

If \`dim\` is unnamed, dimension names are taken from \`dim.names\`, or
generated automatically as \`"dim1"\`, \`"dim2"\`, and so on. Dimension
units and long names can be supplied through \`dim.units\` and
\`dim.longname\`.

\`write_ncdf.list()\` writes each element of \`x\` as a separate
variable in the same netCDF file.

If \`varid\` is omitted, variable names are taken from \`names(x)\`.
Arguments such as \`longname\`, \`units\`, and \`prec\` can be supplied
either as length-one values, to be recycled to all variables, or as one
value per variable.

The object \`dim\` defines the full set of dimensions available in the
file. Individual variables may use all or a subset of those dimensions,
provided their sizes are consistent with the declared dimension lengths.

## Examples

``` r
if (FALSE) { # \dontrun{
## Single variable
x <- array(rnorm(20 * 10), dim = c(20, 10))

write_ncdf(
  x,
  filename = "example_single.nc",
  varid = "temp",
  dim = list(lon = seq_len(20), lat = seq_len(10)),
  longname = "Temperature",
  units = "degree_C"
)

## Multiple variables
x1 <- array(rnorm(20 * 10), dim = c(20, 10))
x2 <- array(rnorm(20 * 10), dim = c(20, 10))

write_ncdf(
  list(temp = x1, salt = x2),
  filename = "example_multi.nc",
  varid = c("temp", "salt"),
  dim = list(lon = seq_len(20), lat = seq_len(10)),
  longname = c("Temperature", "Salinity"),
  units = c("degree_C", "psu")
)
} # }
```
