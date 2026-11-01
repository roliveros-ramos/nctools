# Apply a function over margins of a netCDF variable

Reads a variable from a netCDF file, applies a function over one or more
of its dimensions using
[`base::apply()`](https://rdrr.io/r/base/apply.html), and writes the
result to a new netCDF file.

## Usage

``` r
nc_apply(
  filename,
  varid,
  MARGIN,
  FUN,
  ...,
  output = NULL,
  drop = FALSE,
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

  Character string giving the path to the input netCDF file.

- varid:

  Character string giving the name of the variable to process. If
  missing and the file contains a single variable, that variable is
  used.

- MARGIN:

  Integer or character vector specifying the dimensions to retain in the
  output, as in [`base::apply()`](https://rdrr.io/r/base/apply.html).
  Dimension names may be used.

- FUN:

  Function to apply.

- ...:

  Additional arguments passed to `FUN`.

- output:

  Character string giving the path to the output netCDF file to create.

- drop:

  Logical. Currently not implemented.

- newdim:

  Optional numeric values for the dimension created when `FUN` returns a
  vector of length greater than one.

- name:

  Optional character string giving the name of the output variable. By
  default, the original variable name is used.

- longname:

  Optional character string giving the long name of the output variable.
  By default, a name based on `FUN` and the original variable long name
  is generated.

- units:

  Optional character string giving the units of the output variable. By
  default, the units of the input variable are used.

- compression:

  Optional numeric compression level for the output variable.

- verbose:

  Logical. Currently unused.

- force_v4:

  Logical. Currently unused internally.

- ignore.case:

  Logical. If `TRUE`, ignore case when matching dimension names supplied
  in `MARGIN`.

## Value

Invisibly returns `output`.

## Details

The selected variable is read into memory and processed with
[`base::apply()`](https://rdrr.io/r/base/apply.html). The output retains
the dimensions specified in `MARGIN`. If `FUN` returns a vector of
length greater than one, an additional dimension is appended to the
result; its coordinate values are taken from `newdim` when provided, or
generated automatically otherwise.

## See also

[`nc_subset()`](nc_subset.md), [`write_ncdf()`](write_ncdf.md),
[`base::apply()`](https://rdrr.io/r/base/apply.html)

## Examples

``` r
local({
  input = system.file("extdata",
    "temperature_2001_01.nc",
    package = "nctools",
    mustWork = TRUE)
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  nc_apply(input, "temperature", MARGIN = "time", FUN = mean, na.rm = TRUE, output = output)
})
```
