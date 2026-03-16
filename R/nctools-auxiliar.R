
# Generic ncdf auxiliar functions -----------------------------------------


# Variables ---------------------------------------------------------------


#' Get variable dimensions from a netCDF file
#'
#' Returns the dimensions associated with one variable, or with all variables in
#' an open netCDF file.
#'
#' @param nc An open netCDF connection created with [ncdf4::nc_open()].
#' @param varid Variable identifier. This can be a character string giving the
#'   variable name, or an object of class `ncvar4`. If `NULL`, dimensions are
#'   returned for all variables in the file.
#' @param value Logical. If `TRUE`, return the coordinate values of each
#'   dimension instead of only the dimension names.
#'
#' @return
#' If `varid` is `NULL`, a named list with one element per variable. If `varid`
#' is supplied, the dimensions of the selected variable only. When
#' `value = FALSE`, dimensions are returned as character vectors of dimension
#' names. When `value = TRUE`, dimensions are returned as named lists of
#' coordinate values.
#'
#' @seealso [ncvar_size()], [ncdim_size()], [ncdf4::nc_open()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc")
#' on.exit(ncdf4::nc_close(nc))
#'
#' ncvar_dim(nc)
#' ncvar_dim(nc, varid = "temp")
#' ncvar_dim(nc, varid = "temp", value = TRUE)
#' }
ncvar_dim = function(nc, varid=NULL, value=FALSE) {

  if (!inherits(nc, "ncdf4"))
    stop("first argument (nc) is not of class ncdf4!")

  if(isTRUE(value)) {
    .getDimValues = function(x) {
      vals = stats::setNames(lapply(x, function(x) x$vals),
                             sapply(x, function(x) x$name))
    }

    out = lapply(nc$var, function(x) x$dim)
    out = lapply(out, .getDimValues)
  } else {
    out = lapply(nc$var, function(x) names(nc$dim)[x$dimids+1])
  }
  if(!is.null(varid)) out = out[[varid]]
  return(out)
}


#' Get variable sizes from a netCDF file
#'
#' Returns the dimension sizes of a selected variable in an open netCDF file.
#'
#' @inheritParams ncvar_dim
#'
#' @return A numeric vector giving the dimension sizes of the selected variable.
#'   If the file contains a single variable, that variable is used by default.
#'
#' @details
#' If the file contains more than one variable, `varid` must be supplied.
#'
#' @seealso [ncvar_dim()], [ncdim_size()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc")
#' on.exit(ncdf4::nc_close(nc))
#'
#' ncvar_size(nc, varid = "temp")
#' }
ncvar_size = function(nc, varid=NULL) {

  if (!inherits(nc, "ncdf4"))
    stop("first argument (nc) is not of class ncdf4!")

  out = lapply(nc$var, function(x) x$size)
  if(length(out)==1) varid = 1
  if(length(out)>1 & is.null(varid)) stop("Multiple variables found, you must specify 'varid'.")
  if(!is.null(out)) return(out[[varid]])
}


#' Get variable compression settings from a netCDF file
#'
#' Returns the compression setting of one variable, or of all variables, in an
#' open netCDF file.
#'
#' @inheritParams ncvar_dim
#'
#' @param varid Variable identifier. This can be a character string giving the
#'   variable name, or an object of class `ncvar4`. If `NA`, compression
#'   settings are returned for all variables in the file.
#'
#' @return
#' If `varid` is `NA`, a named vector or list with the compression setting of
#' each variable. Otherwise, the compression setting of the selected variable.
#'
#' @seealso [ncvar_change_compression()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc")
#' on.exit(ncdf4::nc_close(nc))
#'
#' ncvar_compression(nc)
#' ncvar_compression(nc, varid = "temp")
#' }
ncvar_compression = function(nc, varid=NA) {
  if(is.na(varid)) return(sapply(nc$var, FUN=.getCompression))
  varid = .checkVarid(varid=varid, nc=nc)
  return(.getCompression(nc$var[[varid]]))
}

#' Change variable compression settings in a netCDF object
#'
#' Modifies the compression setting of one or more variables in an open netCDF
#' object.
#'
#' @inheritParams ncvar_dim
#' @param varid Variable identifier. This can be a character string giving the
#'   variable name, or an object of class `ncvar4`. If `NA`, the compression
#'   setting is changed for all variables in the file.
#' @param compression Numeric compression level to assign.
#'
#' @return The modified netCDF object.
#'
#' @seealso [ncvar_compression()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc")
#' on.exit(ncdf4::nc_close(nc))
#'
#' nc <- ncvar_change_compression(nc, varid = "temp", compression = 4)
#' }
ncvar_change_compression = function(nc, varid=NA, compression) {
  if(is.na(varid)) {
    nc$var = lapply(nc$var, FUN=.setCompression, compression=compression)
    return(nc)
  }
  varid = .checkVarid(varid=varid, nc=nc)
  nc$var[[varid]] = .setCompression(nc$var[[varid]], compression=compression)
  return(nc)
}



# Dimensions --------------------------------------------------------------


#' Get dimension lengths from a netCDF file
#'
#' Returns the lengths of all dimensions in an open netCDF file.
#'
#' @inheritParams ncvar_dim
#'
#' @return A named list giving the length of each dimension.
#'
#' @seealso [ncvar_dim()], [ncdim_isUnlim()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc")
#' on.exit(ncdf4::nc_close(nc))
#'
#' ncdim_size(nc)
#' }
ncdim_size = function(nc) {

  if (!inherits(nc, "ncdf4"))
    stop("first argument (nc) is not of class ncdf4!")

  lapply(nc$dim, function(x) x$len)
}


#' Test whether dimensions are unlimited
#'
#' Returns whether each dimension in an open netCDF file is unlimited.
#'
#' @inheritParams ncvar_dim
#'
#' @return A named logical vector indicating whether each dimension is
#'   unlimited.
#'
#' @seealso [ncdim_size()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc")
#' on.exit(ncdf4::nc_close(nc))
#'
#' ncdim_isUnlim(nc)
#' }
ncdim_isUnlim = function(nc) {

  if (!inherits(nc, "ncdf4"))
    stop("first argument (nc) is not of class ncdf4!")

  sapply(nc$dim, function(x) x$unlim)
}



# Attributes --------------------------------------------------------------

#' Get all attributes from variables or dimensions
#'
#' Returns all attributes associated with variables or dimensions in an open
#' netCDF file.
#'
#' @inheritParams ncvar_dim
#' @param type Character string indicating whether to return attributes for
#'   variables (`"var"`) or dimensions (`"dim"`).
#'
#' @return A named list of attribute lists.
#'
#' @seealso [ncatt_put_all()], [ncdf4::ncatt_get()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc")
#' on.exit(ncdf4::nc_close(nc))
#'
#' ncatt_get_all(nc, type = "var")
#' ncatt_get_all(nc, type = "dim")
#' }
ncatt_get_all = function(nc, type=c("var", "dim")) {

  if (!inherits(nc, "ncdf4"))
    stop("first argument (nc) is not of class ncdf4!")

  type = match.arg(type)
  vars = names(nc[[type]])
  names(vars) = vars
  atts = lapply(vars, FUN=function(var) ncatt_get(nc, var))
  return(atts)

}

#' Write multiple attributes to a netCDF variable or file
#'
#' Writes several attributes to a variable or to the global file metadata of an
#' open netCDF file.
#'
#' @param nc An open netCDF connection created with [ncdf4::nc_open()].
#' @param varid Variable identifier. This can be a character string giving the
#'   variable name, an object of class `ncvar4`, or an integer id. As a special
#'   case, `varid = 0` writes global attributes.
#' @param attname Names of the attributes to write. Alternatively, this may be a
#'   named vector or list of attribute values when `attval` is omitted.
#' @param attval Values of the attributes to write. If omitted, `attname` must
#'   be a named vector or list whose names are used as attribute names.
#' @param prec Optional precision used when writing the attributes. Passed to
#'   [ncdf4::ncatt_put()].
#' @param verbose Logical. If `TRUE`, print additional information while writing
#'   attributes.
#' @param definemode Logical. Passed to [ncdf4::ncatt_put()]. See that function
#'   for details.
#'
#' @details
#' Attributes can be supplied either as parallel `attname` and `attval`
#' arguments, or as a single named vector or list. Missing attribute names are
#' not allowed.
#'
#' @return `NULL`, invisibly.
#'
#' @seealso [ncatt_get_all()], [ncdf4::ncatt_put()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc <- ncdf4::nc_open("input.nc", write = TRUE)
#' on.exit(ncdf4::nc_close(nc))
#'
#' ncatt_put_all(
#'   nc,
#'   varid = "temp",
#'   attname = c("long_name", "units"),
#'   attval = list("Temperature", "degree_C")
#' )
#'
#' ncatt_put_all(
#'   nc,
#'   varid = 0,
#'   attval = list(title = "Example file", source = "nctools")
#' )
#' }
ncatt_put_all = function(nc, varid, attname, attval,
                         prec=NA, verbose=FALSE, definemode=FALSE) {


  if(missing(attname) & missing(attval))
    stop("You must provide values and names for the attributes.")

  if(missing(attname) & !is.null(names(attval)))
    attname = names(attval)

  if(missing(attval) & is.null(names(attname)))
    stop("You must provide values and names for the attributes.")

  if(missing(attval) & !is.null(names(attname))) {
    attval = attname
    attname = names(attname)
  }

  if(any(is.na(attname)))
    stop("Missing names for attributes are not allowed.")

  if(length(attval)!=length(attname))
    stop("An equal number of names and values for attributes must be provided.")

  names(attval) = attname

  .ncatt_put = function(attname, attval, nc, varid, prec, verbose, definemode) {
    ncatt_put(nc, varid=varid, attname=attname, attval=attval[[attname]],
              prec=prec, verbose=verbose, definemode=definemode)
  }

  lapply(attname, FUN=.ncatt_put, attval=attval, nc=nc, varid=varid,
         prec=prec, verbose=verbose, definemode=definemode)

  return(invisible())

}
