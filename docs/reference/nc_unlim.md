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
  \`NULL\`, the input file is replaced.

## Value

Invisibly returns the list of variable definitions used to create the
new file.

## Details

The function rebuilds the file definition with the requested dimension
marked as unlimited in every variable where that dimension is present,
then copies the variable values to the new file.

## See also

\[nc_rcat()\], \[write_ncdf()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nc_unlim(
  filename = "input.nc",
  unlim = "time",
  output = "time_unlimited.nc"
)
} # }
```
