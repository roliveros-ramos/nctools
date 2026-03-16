# Standardise longitude values to a selected prime meridian convention

Converts longitude values to either the \`\[-180, 180\]\` convention or
the \`\[0, 360\]\` convention.

## Usage

``` r
checkLongitude(x, primeMeridian = "center", sort = FALSE, ...)
```

## Arguments

- x:

  Numeric vector of longitude values.

- primeMeridian:

  Character string specifying the target longitude convention. Use
  \`"center"\` for longitudes in the \`\[-180, 180\]\` range and
  \`"left"\` for longitudes in the \`\[0, 360\]\` range.

- sort:

  Logical. If \`TRUE\`, sort the output values after conversion.

- ...:

  Additional arguments. Currently unused.

## Value

A numeric vector of longitude values expressed in the requested
convention.

## Details

Longitude values are modified only when needed. For \`primeMeridian =
"center"\`, values greater than \`180\` are shifted by subtracting
\`360\`. For \`primeMeridian = "left"\`, negative values are shifted by
adding \`360\`.

## See also

\[findPrimeMeridian()\]

## Examples

``` r
if (FALSE) { # \dontrun{
lon <- c(170, 180, 190, 350)

checkLongitude(lon, primeMeridian = "center")
checkLongitude(lon, primeMeridian = "left")
} # }
```
