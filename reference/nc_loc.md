# Locate the depth where a variable reaches a given value

Finds the position along one dimension of a netCDF variable where the
variable reaches a target value, and writes the result to a new netCDF
file. In the typical use case, this is used to estimate the depth at
which a variable equals \`loc\`, using linear interpolation between
adjacent depth levels when needed.

## Usage

``` r
nc_loc(
  filename,
  varid,
  MARGIN,
  loc,
  output = NULL,
  drop = TRUE,
  newdim = NULL,
  name = NULL,
  longname = NULL,
  units = NULL,
  compression = NA,
  verbose = FALSE,
  force_v4 = TRUE,
  ignore.case = FALSE
)
```

## Arguments

- filename:

  Character string. Path to the input netCDF file.

- varid:

  Character string. Name of the variable to analyse. If missing and the
  file contains only one variable, that variable is used.

- MARGIN:

  Integer or character string of length one. Dimension along which the
  target value is searched. This can be either the dimension index or
  its name (for example \`"depth"\`).

- loc:

  Numeric. Target value to locate in the variable.

- output:

  Character string. Path to the output netCDF file to create.

- drop:

  Logical. Should degenerate dimensions be dropped? Currently not used
  internally.

- newdim:

  Reserved for future use. Currently not used internally.

- name:

  Character string. Name of the output variable. By default, the name of
  the searched dimension is used.

- longname:

  Character string. Long name for the output variable. By default, a
  descriptive name is generated automatically.

- units:

  Character string. Units for the output variable. Currently not used
  internally; by default, the units of the searched dimension are used.

- compression:

  Numeric. Compression level for the output variable. If not \`NA\`,
  compression is applied and netCDF4 output is required.

- verbose:

  Logical. Should extra information be printed? Currently not used
  internally.

- force_v4:

  Logical. Should the output file be forced to netCDF4? Currently not
  used internally.

- ignore.case:

  Logical. Ignore case when matching the dimension name in \`MARGIN\`?

## Value

Invisibly returns the path to the created output file.

## Details

The function searches for the first sign change in \`variable - loc\`
along the selected dimension, then estimates the exact position by
linear interpolation between the two surrounding grid points.

The output file contains a new variable with the searched dimension
removed. For example, if \`MARGIN\` corresponds to depth, the output is
a field giving the estimated depth at which \`varid\` reaches \`loc\`
for each remaining combination of dimensions.

## Examples

``` r
if (FALSE) { # \dontrun{
# Estimate the depth of the 20 degree isotherm
nc_loc(
  filename = "temperature.nc",
  varid = "temp",
  MARGIN = "depth",
  loc = 20,
  output = "depth_20C.nc"
)
} # }
```
