# Internal netCDF helpers

Developer-facing helper functions used internally by \`nctools\` for
variable validation, dimension matching, and renaming variables or
dimensions in netCDF files.

\`.replaceInDim()\` replaces one component of a named dimension inside a
variable definition.

\`.nc_renameDim()\` rewrites a netCDF file with one or more dimensions
renamed.

\`.nc_renameVar()\` renames one or more variables in a netCDF file.

\`.checkVarid()\` validates a variable identifier against an open netCDF
file and resolves the default variable when the file contains a single
variable.

\`.getDimensions()\` matches the dimensions of an array to a target
netCDF dimension-size vector.

## Usage

``` r
.replaceInDim(x, dim, id, value)

.nc_renameDim(filename, oldname, newname, output, verbose = FALSE)

.nc_renameVar(filename, oldname, newname, output, verbose = FALSE)

.checkVarid(varid, nc)

.getDimensions(x, dimsize)
```

## Arguments

- x:

  Array-like object.

- dim:

  Character string giving the dimension name to modify.

- id:

  Character string giving the component of the dimension object to
  replace, for example \`"name"\`.

- value:

  Replacement value for the selected component.

- filename:

  Character string giving the path to the input netCDF file.

- oldname:

  Character vector giving the existing dimension names.

- newname:

  Character vector giving the replacement dimension names. Must have the
  same length and order as \`oldname\`.

- output:

  Character string giving the path to the output netCDF file.

- verbose:

  Logical. If \`TRUE\`, report progress while rewriting the file.

- varid:

  Variable identifier supplied by the user. This can be a character
  string, an object of class \`ncvar4\`, or \`NA\`/missing when the file
  contains a single variable.

- nc:

  An open netCDF connection created with \[ncdf4::nc_open()\].

- dimsize:

  Numeric vector giving the target dimension sizes.

## Value

A modified variable definition object.

Invisibly returns \`output\`.

Invisibly returns \`output\`.

A validated variable name as a character string.

An integer vector giving the matched dimension positions.

## Details

These functions are not part of the public API and may change without
notice.

The file is rebuilt from the variable definitions in \`filename\`, with
the requested dimensions renamed before writing the output file.

If \`output\` differs from \`filename\`, the input file is first copied
to \`output\`, and the renaming is applied there.

Matching is based on dimension lengths. When more than one candidate
match exists, the first match is used.
