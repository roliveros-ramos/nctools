
#' Standardise longitude values to a selected prime meridian convention
#'
#' Converts longitude values to either the `[-180, 180]` convention or the
#' `[0, 360]` convention.
#'
#' @param x Numeric vector of longitude values.
#' @param primeMeridian Character string specifying the target longitude
#'   convention. Use `"center"` for longitudes in the `[-180, 180]` range and
#'   `"left"` for longitudes in the `[0, 360]` range.
#' @param sort Logical. If `TRUE`, sort the output values after conversion.
#' @param ... Additional arguments. Currently unused.
#'
#' @details
#' Longitude values are modified only when needed. For `primeMeridian =
#' "center"`, values greater than `180` are shifted by subtracting `360`. For
#' `primeMeridian = "left"`, negative values are shifted by adding `360`.
#'
#' @return A numeric vector of longitude values expressed in the requested
#'   convention.
#'
#' @seealso [findPrimeMeridian()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' lon <- c(170, 180, 190, 350)
#'
#' checkLongitude(lon, primeMeridian = "center")
#' checkLongitude(lon, primeMeridian = "left")
#' }
checkLongitude = function(x, primeMeridian="center", sort=FALSE, ...) {

  primeMeridian = match.arg(arg=primeMeridian, choices=c("center", "left"))

  .longitude2Center = function(x, ...) {
    if (!any(x > 180))
      return(x)
    x[x > 180] = x[x > 180] - 360
    return(x)
  }

  .longitude2Left = function(x, ...) {
    if (!any(x < 0))
      return(x)
    x[x < 0] = x[x < 0] + 360
    return(x)
  }

  out = switch(primeMeridian,
               center = .longitude2Center(x, ...),
               left = .longitude2Left(x, ...))

  if(isTRUE(sort)) out = sort(out)

  return(out)
}


#' Identify the prime meridian convention from longitude values
#'
#' Infers whether a longitude vector is expressed using the `[-180, 180]`
#' convention or the `[0, 360]` convention.
#'
#' @param x Numeric vector of longitude values.
#'
#' @details
#' The function returns `"center"` if any longitude is negative, and `"left"`
#' if any longitude is greater than `180`. If neither condition is met, the
#' convention cannot be determined unambiguously and the function returns
#' `NULL` with a warning.
#'
#' @return A character string, either `"center"` or `"left"`, or `NULL` if the
#'   convention cannot be determined.
#'
#' @seealso [checkLongitude()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' findPrimeMeridian(c(-10, 0, 20))
#' findPrimeMeridian(c(10, 180, 350))
#' }
findPrimeMeridian = function(x) {
  if(any(x<0)) return("center")
  if(any(x>180)) return("left")
  warning("Indeterminate Prime Meridian from longitude values.")
  return(NULL)
}

