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

Invisibly returns \`output\`.

## Details

All files must contain the selected variable and must be compatible in
all non-unlimited dimensions. The unlimited dimension is appended in the
order given by \`filenames\`.

## See also

\[nc_unlim()\], \[write_ncdf()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc_rcat(
  filenames = c("part1.nc", "part2.nc", "part3.nc"),
  varid = "temp",
  output = "combined.nc"
)
} # }
```
