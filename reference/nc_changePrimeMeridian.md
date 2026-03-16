# Change the prime meridian of a variable in a netCDF file

Reorders the longitude dimension of a variable so that longitudes follow
either the \`\[-180, 180\]\` convention or the \`\[0, 360\]\`
convention, and writes the result to a netCDF file.

## Usage

``` r
nc_changePrimeMeridian(
  filename,
  output,
  varid = NA,
  MARGIN = 1,
  primeMeridian = "center",
  verbose = FALSE,
  overwrite = FALSE,
  compression = NA,
  mem.limit = 3072,
  ignore.case = FALSE
)
```

## Arguments

- filename:

  Character string giving the path to the input netCDF file.

- output:

  Optional character string giving the path to the output netCDF file.
  If omitted, \`overwrite = TRUE\` must be used and the input file is
  replaced.

- varid:

  Variable identifier. This can be a character string giving the
  variable name. If omitted and the file contains a single variable,
  that variable is used.

- MARGIN:

  Integer or character string of length one specifying the longitude
  dimension. This can be either the dimension index or its name.

- primeMeridian:

  Character string specifying the target longitude convention. Use
  \`"center"\` for longitudes in the \`\[-180, 180\]\` range and
  \`"left"\` for longitudes in the \`\[0, 360\]\` range.

- verbose:

  Logical. If \`TRUE\`, report progress while processing the variable.

- overwrite:

  Logical. If \`TRUE\`, allow overwriting an existing output file,
  including the input file itself.

- compression:

  Optional numeric compression level for the output variable. Supplying
  this typically requires netCDF4 output.

- mem.limit:

  Numeric. Approximate memory limit, in MiB, used when processing large
  variables. If the variable exceeds this limit, it is reordered
  iteratively in chunks.

- ignore.case:

  Logical. If \`TRUE\`, ignore case when matching \`varid\` or a
  character \`MARGIN\`.

## Value

Invisibly returns \`output\`.

## Details

The function updates the longitude coordinate values of the selected
variable, reorders the data accordingly, and writes the result to a new
netCDF file. If the variable is small enough, the full array is
processed in memory. Otherwise, the variable is processed iteratively in
chunks to reduce memory use.

If the longitude values already follow the requested convention, the
function returns with a warning. When \`output\` differs from
\`filename\`, the input file is copied to \`output\` unchanged.

## See also

\[nc_subset()\], \[nc_apply()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc_changePrimeMeridian(
  filename = "input.nc",
  output = "output.nc",
  varid = "temp",
  MARGIN = "lon",
  primeMeridian = "center"
)

nc_changePrimeMeridian(
  filename = "input.nc",
  output = "output_pacific.nc",
  varid = "temp",
  MARGIN = 1,
  primeMeridian = "left",
  compression = 4
)
} # }
```
