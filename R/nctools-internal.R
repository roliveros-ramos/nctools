#' Internal netCDF helpers
#'
#' Developer-facing helper functions used internally by `nctools` for variable
#' validation, dimension matching, and renaming variables or dimensions in
#' netCDF files.
#'
#' These functions are not part of the public API and may change without notice.
#'
#' @name nctools-internal
#' @keywords internal
NULL


#' @rdname nctools-internal
#'
#' @description
#' `.replaceInDim()` replaces one component of a named dimension inside a
#' variable definition.
#'
#' @param x A variable definition object, typically an object of class
#'   `ncvar4`.
#' @param dim Character string giving the dimension name to modify.
#' @param id Character string giving the component of the dimension object to
#'   replace, for example `"name"`.
#' @param value Replacement value for the selected component.
#'
#' @return A modified variable definition object.
.replaceInDim = function(x, dim, id, value) {
  .repInDim = function(x, dim, id, value) {
    if(x$name != dim) return(x)
    x[[id]] = value
    return(x)
  }
  x$dim = lapply(x$dim, FUN=.repInDim, dim=dim,
                 id=id, value=value)
  return(x)
}

#' @rdname nctools-internal
#'
#' @description
#' `.nc_renameDim()` rewrites a netCDF file with one or more dimensions
#' renamed.
#'
#' @param filename Character string giving the path to the input netCDF file.
#' @param oldname Character vector giving the existing dimension names.
#' @param newname Character vector giving the replacement dimension names. Must
#'   have the same length and order as `oldname`.
#' @param output Character string giving the path to the output netCDF file.
#' @param verbose Logical. If `TRUE`, report progress while rewriting the file.
#'
#' @details
#' The file is rebuilt from the variable definitions in `filename`, with the
#' requested dimensions renamed before writing the output file.
#'
#' @return Invisibly returns `output`.
.nc_renameDim = function(filename, oldname, newname, output, verbose=FALSE) {

  tmp = paste(output, "temp", sep=".")
  on.exit(if(file.exists(tmp)) file.remove(tmp))

  if(length(oldname)!=length(newname))
    stop("oldname and newname must have the same length.")

  nc = nc_open(filename)
  is_v4 = grepl(x=nc$format, pattern="NETCDF4")

  if(is_v4) {
    varids = names(nc$var)
    for(varid in varids) {
      if(is.na(ncvar_compression(nc, varid)))
        nc = ncvar_change_compression(nc, varid, compression = 9)
    }
  }

  x = nc$var

  for(i in seq_along(oldname)) {
    x = lapply(x, FUN=.replaceInDim, dim=oldname[i],
               id="name", value=newname[i])
  }


  ncNew = nc_create(filename = tmp, vars = x, verbose=verbose,
                    force_v4 = is_v4)

  for(varid in names(x))
    ncvar_put(ncNew, varid=varid, vals=ncvar_get(nc, varid=varid),
              verbose=verbose)

  # copy global attributes from original nc file.
  ncatt_put_all(ncNew, varid=0, attval=ncatt_get(nc, varid=0))

  nc_close(ncNew)
  nc_close(nc)

  renamed = file.rename(tmp, output)

  if(!renamed) {
    file.remove(output)
    renamed = file.rename(tmp, output)
    if(!renamed) {
      file.remove(tmp)
      stop(sprintf("Couldn't write %s.", output))
    }
  }

  return(invisible(output))

}

#' @rdname nctools-internal
#'
#' @description
#' `.nc_renameVar()` renames one or more variables in a netCDF file.
#'
#' @inheritParams .nc_renameDim
#'
#' @details
#' If `output` differs from `filename`, the input file is first copied to
#' `output`, and the renaming is applied there.
#'
#' @return Invisibly returns `output`.
.nc_renameVar = function(filename, oldname, newname, output, verbose=FALSE) {

  if(length(oldname)!=length(newname))
    stop("oldname and newname must have the same length.")

  if(output!=filename) {
    file.copy(from=filename, to=output, overwrite = TRUE)
    filename = output
  }

  nc = nc_open(filename, write=TRUE)
  on.exit(try(nc_close(nc), silent = TRUE))

  for(i in seq_along(oldname)) {

    nc = ncvar_rename(nc, old_varname = oldname[i], new_varname = newname[i],
                      verbose=verbose)

  }

  # nc_close(nc)

  return(invisible(output))

}

#' Internal helper to extract variable compression
#' @noRd
.getCompression = function(x) return(x$compression)

#' Internal helper to set variable compression
#' @noRd
.setCompression = function(x, compression) {
  x$compression = compression
  x$chunksizes = NA
  return(x)
}

# Argument checking -------------------------------------------------------


#' @rdname nctools-internal
#'
#' @description
#' `.checkVarid()` validates a variable identifier against an open netCDF file
#' and resolves the default variable when the file contains a single variable.
#'
#' @param varid Variable identifier supplied by the user. This can be a
#'   character string, an object of class `ncvar4`, or `NA`/missing when the
#'   file contains a single variable.
#' @param nc An open netCDF connection created with [ncdf4::nc_open()].
#'
#' @return A validated variable name as a character string.
.checkVarid = function(varid, nc) {

  if(missing(varid)) varid = NA

  if(is.na(varid)) {
    if(length(nc$var)==1) varid = nc$var[[1]]$name
    msg = sprintf("Several variables found in %s, must specify 'varid'.", nc$filename)
    if(length(nc$var)>1) stop(msg)
  }

  if(inherits(varid, "ncvar4")) varid = varid$name

  if(!is.character(varid))
    stop("varid must be a string or an object of class 'ncvar4'.")

  varExists = varid %in% names(nc$var)

  msg = sprintf("Variable '%s' not found in '%s'.", varid, nc$filename)
  if(!varExists) stop(msg)

  return(varid)

}

#' @rdname nctools-internal
#'
#' @description
#' `.getDimensions()` matches the dimensions of an array to a target netCDF
#' dimension-size vector.
#'
#' @param x Array-like object.
#' @param dimsize Numeric vector giving the target dimension sizes.
#'
#' @details
#' Matching is based on dimension lengths. When more than one candidate match
#' exists, the first match is used.
#'
#' @return An integer vector giving the matched dimension positions.
.getDimensions = function(x, dimsize) {
  mydim = dim(x)
  out = NA_real_*numeric(length(mydim))
  for(i in seq_along(mydim)) {
    ind = which(dimsize %in% mydim[i])
    if(length(ind)<1) stop("Array incompatible with dimension sizes.")
    if(length(ind)>1) ind = min(ind)
    out[i] = ind
    dimsize[seq_len(ind)] = -1
  }
  return(out)
}
