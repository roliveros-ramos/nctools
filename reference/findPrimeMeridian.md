# Identify the prime meridian convention from longitude values

Infers whether a longitude vector is expressed using the `[-180, 180]`
convention or the `[0, 360]` convention.

## Usage

``` r
findPrimeMeridian(x)
```

## Arguments

- x:

  Numeric vector of longitude values.

## Value

A character string, either `"center"` or `"left"`, or `NULL` if the
convention cannot be determined.

## Details

The function returns `"center"` if any longitude is negative, and
`"left"` if any longitude is greater than `180`. If neither condition is
met, the convention cannot be determined unambiguously and the function
returns `NULL` with a warning.

## See also

[`checkLongitude()`](checkLongitude.md)

## Examples

``` r
local({
  findPrimeMeridian(c(-80, -70, -60))
})
#> [1] "center"
```
