# Extract a variable to a new netCDF file

Creates a new netCDF file containing a single variable copied from an
existing file.

## Usage

``` r
nc_extract(filename, varid, output)
```

## Arguments

- filename:

  Character string giving the path to the input netCDF file.

- varid:

  Character string giving the name of the variable to extract. If
  missing and the file contains a single variable, that variable is
  used.

- output:

  Character string giving the path to the output netCDF file to create.

## Value

Invisibly returns `output`.

## See also

[`write_ncdf()`](write_ncdf.md), [`nc_subset()`](nc_subset.md),
[`nc_apply()`](nc_apply.md)

## Examples

``` r
local({
  input = system.file("extdata",
    "temperature_2001_01.nc",
    package = "nctools",
    mustWork = TRUE)
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  nc_extract(input, "temperature", output)
})
```
