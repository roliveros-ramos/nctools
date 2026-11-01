# Concatenate records of a variable across netCDF files

Concatenates the records of the same variable from multiple netCDF files
along the unlimited dimension and writes the result to a new file.

## Usage

``` r
nc_rcat(filenames, varid, output)
```

## Arguments

- filenames:

  Character vector with the paths to the input netCDF files.

- varid:

  Character string giving the name of the variable to concatenate. If
  missing, the variable is inferred from the first file when possible.

- output:

  Character string giving the path to the output netCDF file to create.

## Value

Invisibly returns `output`.

## Details

All files must contain the selected variable and must be compatible in
all non-unlimited dimensions. The unlimited dimension is appended in the
order given by `filenames`.

## See also

[`nc_unlim()`](nc_unlim.md), [`write_ncdf()`](write_ncdf.md)

## Examples

``` r
local({
  input = system.file("extdata",
    "temperature_2001_01.nc",
    package = "nctools",
    mustWork = TRUE)
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  files = system.file("extdata",
    sprintf("temperature_2001_%02d.nc",
    1:3),
    package = "nctools",
    mustWork = TRUE)
  first = tempfile(fileext = ".nc")
  on.exit(unlink(first), add = TRUE)
  nc_rcat(files[1:2], "temperature", first)
  nc_rcat(c(first, files[3]), "temperature", output)
})
```
