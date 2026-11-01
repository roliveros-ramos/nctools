# Set a dimension as unlimited

Recreates a netCDF file with the selected dimension marked as unlimited.

## Usage

``` r
nc_unlim(filename, unlim, output = NULL)
```

## Arguments

- filename:

  Character string giving the path to the input netCDF file.

- unlim:

  Character string giving the name of the dimension to set as unlimited.

- output:

  Optional character string giving the path to the output file. If
  `NULL`, the input file is replaced.

## Value

Invisibly returns the list of variable definitions used to create the
new file.

## Details

The function rebuilds the file definition with the requested dimension
marked as unlimited in every variable where that dimension is present,
then copies the variable values to the new file.

## See also

[`nc_rcat()`](nc_rcat.md), [`write_ncdf()`](write_ncdf.md)

## Examples

``` r
local({
  input = system.file("extdata",
    "temperature_2001_01.nc",
    package = "nctools",
    mustWork = TRUE)
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  nc = ncdf4::nc_open(input)
  x = tryCatch(ncdf4::ncvar_get(nc, "temperature"), finally = ncdf4::nc_close(nc))
  fixed = tempfile(fileext = ".nc")
  on.exit(unlink(fixed), add = TRUE)
  write_ncdf(x,
    fixed,
    "temperature",
    dim = list(lon = seq(-80,
    -65,
    length.out = 15),
    lat = seq(-25,
    -6,
    length.out = 20),
    time = 0:30),
    compression = NA)
  nc_unlim(fixed, "time", output)
})
```
