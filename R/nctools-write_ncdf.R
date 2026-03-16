#' @rdname write_ncdf
#'
#' @param varid Character string giving the name of the variable to create in
#'   the output file.
#' @param dim A named or unnamed list defining the coordinates of each
#'   dimension. Each element contains the coordinate values for one dimension.
#'   If omitted, dimensions are generated as `seq_len()` for each dimension of
#'   `x`.
#' @param longname Character string giving the long name of the output variable.
#'   Defaults to `""`.
#' @param units Character string giving the units of the output variable.
#'   Defaults to `""`.
#' @param prec Character string giving the storage precision passed to
#'   [ncdf4::ncvar_def()], for example `"short"`, `"integer"`, `"float"` or
#'   `"double"`.
#' @param missval Missing value used in the netCDF variable definition.
#' @param compression Numeric compression level passed to
#'   [ncdf4::ncvar_def()]. Compression usually requires netCDF4 output.
#' @param chunksizes Optional chunk sizes for compressed variables.
#' @param verbose Logical. Should `ncdf4` report progress while creating and
#'   filling the file?
#' @param dim.names Character vector with names for the dimensions when `dim` is
#'   unnamed. Ignored when `dim` already has names.
#' @param dim.units Character vector giving the units of the dimensions. If
#'   omitted, empty strings are used.
#' @param dim.longname Character vector giving the long names of the dimensions.
#'   If omitted, empty strings are used.
#' @param unlim Character string naming the unlimited dimension. Use `FALSE`
#'   for no unlimited dimension.
#' @param global Named list of global attributes to add to the output file.
#'   A `history` attribute documenting the function call is added automatically.
#' @param force_v4 Logical. Should the output file be forced to netCDF4 format?
#'
#' @details
#' `write_ncdf.default()` writes a single object `x` as one variable in a new
#' netCDF file. The dimensions of the variable are defined by `dim`.
#'
#' If `dim` is unnamed, dimension names are taken from `dim.names`, or generated
#' automatically as `"dim1"`, `"dim2"`, and so on. Dimension units and long
#' names can be supplied through `dim.units` and `dim.longname`.
#'
#' @export
write_ncdf.default = function(x, filename, varid, dim, longname, units, prec="float",
                              missval=NA, compression=9, chunksizes=NA, verbose=FALSE,
                              dim.names, dim.units, dim.longname, unlim=FALSE, global=list(),
                              force_v4=FALSE, ...) {

  if(!is.list(global)) stop("'global' must be a list")

  if(missing(dim)) dim = lapply(base::dim(x), seq_len)

  if(length(dim)!=length(dim(x)))
    stop("dim argument does not match data dimension.")

  if(is.null(names(dim))) {
    if(missing(dim.names)) {
      dim = setNames(dim, paste("dim", seq_along(dim), sep=""))
    } else {
      dim = setNames(dim, dim.names)
    }
  }

  if(missing(longname)) longname = ""
  if(missing(units))    units    = ""

  if(missing(dim.units)) dim.units = rep("", length(dim))
  if(length(dim.units)!=length(dim))
    stop("dim units provided are not equal to dimension size.")

  if(missing(dim.longname)) dim.longname = rep("", length(dim))
  if(length(dim.longname)!=length(dim))
    stop("dim longnames provided are not equal to dimension size.")

  dims = list()
  for(i in seq_along(dim))
    dims[[names(dim)[i]]] =
    ncdim_def(name=names(dim)[i], units=dim.units[i], vals=dim[[names(dim)[i]]],
              unlim=names(dim)[i]==unlim, longname=dim.longname[i])

  iVar = ncvar_def(name=varid, units=units, dim=dims, prec=prec ,missval=missval, longname=longname,
                   compression=compression, chunksizes=chunksizes, verbose=verbose)

  ncNew = nc_create(filename=filename, vars=iVar, force_v4=force_v4, verbose=verbose)
  on.exit(nc_close(ncNew))

  ncvar_put(ncNew, varid=iVar, vals=x, verbose=verbose)

  xcall = paste(gsub(x=gsub(x=capture.output(match.call()),
                            pattern="^[ ]*", replacement=""), pattern="\"",
                     replacement="'"), collapse="")
  globalAtt = global
  globalAtt$history = sprintf("File create on %s: %s [nctools version %s, %s]",
                       date(), xcall, packageVersion("nctools"), R.version.string)
  # create global attributes.
  ncatt_put_all(ncNew, varid=0, attval=globalAtt)
  nc_close(ncNew)
  on.exit()

  return(invisible(filename))

}

#' @rdname write_ncdf
#' @inheritParams write_ncdf.default
#'
#' @details
#' `write_ncdf.list()` writes each element of `x` as a separate variable in the
#' same netCDF file.
#'
#' If `varid` is omitted, variable names are taken from `names(x)`. Arguments
#' such as `longname`, `units`, and `prec` can be supplied either as length-one
#' values, to be recycled to all variables, or as one value per variable.
#'
#' The object `dim` defines the full set of dimensions available in the file.
#' Individual variables may use all or a subset of those dimensions, provided
#' their sizes are consistent with the declared dimension lengths.
#'
#' @export
write_ncdf.list = function(x, filename, varid, dim, longname, units, prec="float",
                           missval=NA, compression=9, chunksizes=NA, verbose=FALSE,
                           dim.names, dim.units, dim.longname, unlim=FALSE, global=list(),
                           force_v4=FALSE, ...) {

  if(!is.list(global)) stop("'global' must be a list")

  nvar = length(x)

  if(missing(varid)) varid = names(x)
  if(length(varid)!=nvar) stop("One 'varid' per variable must be provided")

  if(missing(dim)) {
    sdim = sapply(x, FUN = function(x) length(base::dim(x)))
    ind  = which.max(sdim)
    dim = lapply(base::dim(x[[ind]]), seq_len)
  }

  thedims = lapply(x, FUN=.getDimensions, dimsize = sapply(dim, FUN=length))

  # if(length(dim)!=length(dim(x[[1]])))
  #   stop("dim argument does not match data dimension.")

  # ind = lapply(x, dim)
  # ind = sapply(ind, FUN = identical, y=ind[[1]])
  # if(!all(ind)) stop("All arrays to be added to the ncdf file must have the same dimension.")

  if(is.null(names(dim))) {
    if(missing(dim.names)) {
      dim = setNames(dim, paste("dim", seq_along(dim), sep=""))
    } else {
      dim = setNames(dim, dim.names)
    }
  }


  if(missing(longname)) longname = rep("", nvar)
  if(length(longname)==1) longname = rep(longname, nvar)
  if(length(longname)!=nvar) stop("One longname value per variable must be provided.")

  if(missing(units))    units    = rep("", nvar)
  if(length(units)==1) units = rep(units, nvar)
  if(length(units)!=nvar) stop("One units value per variable must be provided.")

  if(length(prec)==1) prec = rep(prec, nvar)
  if(length(prec)!=nvar) stop("One precision value per variable must be provided.")

  if(missing(dim.units)) dim.units = rep("", length(dim))
  if(length(dim.units)!=length(dim))
    stop("dim units provided are not equal to dimension size.")

  if(missing(dim.longname)) dim.longname = rep("", length(dim))
  if(length(dim.longname)!=length(dim))
    stop("dim longnames provided are not equal to dimension size.")

  dims = list()
  for(i in seq_along(dim))
    dims[[names(dim)[i]]] =
    ncdim_def(name=names(dim)[i], units=dim.units[i], vals=dim[[names(dim)[i]]],
              unlim=names(dim)[i]==unlim, longname=dim.longname[i])

  iVar = list()

  for(i in seq_along(x)) {

    iVar[[i]] = ncvar_def(name=varid[i], units=units[i], dim=dims[thedims[[i]]], prec=prec[i], missval=missval,
                          longname=longname[i], compression=compression, chunksizes=chunksizes, verbose=verbose)

  }

  ncNew = nc_create(filename=filename, vars=iVar, force_v4=force_v4, verbose=verbose)
  on.exit(nc_close(ncNew))

  for(i in seq_along(x)) ncvar_put(ncNew, varid=iVar[[i]], vals=x[[i]], verbose=verbose)

  xcall = paste(gsub(x=gsub(x=capture.output(match.call()),
                            pattern="^[ ]*", replacement=""), pattern="\"",
                     replacement="'"), collapse="")

  globalAtt = global
  globalAtt$history = sprintf("File create on %s: %s [nctools version %s, %s]",
                              date(), xcall, packageVersion("nctools"), R.version.string)
  # create global attributes.
  ncatt_put_all(ncNew, varid=0, attval=globalAtt)
  nc_close(ncNew)
  on.exit()

  return(invisible(filename))

}
