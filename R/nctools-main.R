
# Main functions for ncdf files -------------------------------------------

#' Extract a variable to a new netCDF file
#'
#' Creates a new netCDF file containing a single variable copied from an
#' existing file.
#'
#' @param filename Character string giving the path to the input netCDF file.
#' @param varid Character string giving the name of the variable to extract. If
#'   missing and the file contains a single variable, that variable is used.
#' @param output Character string giving the path to the output netCDF file to
#'   create.
#'
#' @return Invisibly returns `output`.
#' @seealso [write_ncdf()], [nc_subset()], [nc_apply()]
#' @export
#'
#' @examples
#' \dontrun{
#' nc_extract(
#'   filename = "input.nc",
#'   varid = "temp",
#'   output = "temp_only.nc"
#' )
#' }
nc_extract = function(filename, varid, output) {
  nc = nc_open(filename)
  on.exit(nc_close(nc))
  varid = .checkVarid(varid=varid, nc=nc)
  ncNew = nc_create(filename=output, vars=nc$var[[varid]])
  ncvar_put(ncNew, varid, ncvar_get(nc, varid, collapse_degen=FALSE))
  nc_close(ncNew)
  return(invisible(output))
}

#' Rename variables and dimensions in a netCDF file
#'
#' Renames one or more variables and/or dimensions in an existing netCDF file,
#' optionally writing the result to a new file.
#'
#' @param filename Character string giving the path to the input netCDF file.
#' @param oldnames Character vector with the current names of variables or
#'   dimensions to rename.
#' @param newnames Character vector with the replacement names. Must be in the
#'   same order and of the same length as `oldnames`.
#' @param output Optional character string giving the path to the output file.
#'   If omitted, `overwrite = TRUE` must be used and the original file is
#'   replaced.
#' @param verbose Logical. If `TRUE`, print the renaming operations performed.
#' @param overwrite Logical. If `TRUE`, allow overwriting an existing output
#'   file. Use this when modifying the original file in place.
#'
#' @details
#' Names in `oldnames` that do not match either a variable or a dimension in the
#' file are ignored with a warning. If none of the requested names are found,
#' the function exits without making changes.
#'
#' @return Invisibly returns the path to the modified file, or `NULL`
#'   invisibly if nothing was changed.
#' @seealso [nc_extract()], [write_ncdf()]
#' @export
#'
#' @examples
#' \dontrun{
#' nc_rename(
#'   filename = "input.nc",
#'   oldnames = c("lon", "lat", "temp"),
#'   newnames = c("longitude", "latitude", "temperature"),
#'   output = "renamed.nc"
#' )
#' }
nc_rename = function(filename, oldnames, newnames, output, verbose=FALSE, overwrite=FALSE) {

  if(missing(output) & !isTRUE(overwrite))
    stop("output file is missing. Set 'overwrite' to TRUE to make changes in the original file.")

  if(missing(output)) output = filename

  if(file.exists(output) & !isTRUE(overwrite))
    stop("output file already exists. Set 'overwrite' to TRUE.")

  tmp = paste(output, ".temp", sep="")
  on.exit(if(file.exists(tmp)) file.remove(tmp))

  ncc = nc_open(filename)

  vars = names(ncc$var)
  dims = names(ncc$dim)

  nc_close(ncc)

  gv = which(oldnames %in% vars)
  gd = which(oldnames %in% dims)

  if(length(gv)==0 & length(gd)==0) {
    message("Nothing to change. Exiting...")
    return(invisible())
  }

  nm = which(!(oldnames %in% c(vars, dims)))

  msgV = paste(sQuote(oldnames[gv]), sQuote(newnames[gv]), sep=" -> ", collapse="\n")
  msgD = paste(sQuote(oldnames[gd]), sQuote(newnames[gd]), sep=" -> ", collapse="\n")
  msgN = sprintf("Some of the 'oldnames' (%s) were not found in variables or dimensions.",
                 paste(sQuote(oldnames[nm]), collapse=", "))

  if(length(nm)>0) warning(msgN)

  old_varname = oldnames[gv]
  new_varname = newnames[gv]
  old_dimname = oldnames[gd]
  new_dimname = newnames[gd]


  if(length(old_dimname)>0) {

    if(isTRUE(verbose)) cat("Changing dimension names:\n", msgD, "\n",sep="")

    filename  = .nc_renameDim(filename=filename, oldname=old_dimname,
                            newname=new_dimname, output=tmp, verbose=FALSE)

  }

  if(length(old_varname)>0) {

    if(isTRUE(verbose)) cat("Changing variable names:\n", msgV, "\n",sep="")

    filename = .nc_renameVar(filename=filename, oldname=old_varname,
                             newname=new_varname, output=tmp, verbose=FALSE)

  }

  if(file.exists(output)) file.remove(output)
  file.rename(tmp, output)

  return(invisible(output))

}


#' Concatenate records of a variable across netCDF files
#'
#' Concatenates the records of the same variable from multiple netCDF files
#' along the unlimited dimension and writes the result to a new file.
#'
#' @param filenames Character vector with the paths to the input netCDF files.
#' @param varid Character string giving the name of the variable to
#'   concatenate. If missing, the variable is inferred from the first file when
#'   possible.
#' @param output Character string giving the path to the output netCDF file to
#'   create.
#'
#' @details
#' All files must contain the selected variable and must be compatible in all
#' non-unlimited dimensions. The unlimited dimension is appended in the order
#' given by `filenames`.
#'
#' @return Invisibly returns `output`.
#'
#' @seealso [nc_unlim()], [write_ncdf()]
#' @export
#'
#' @examples
#' \dontrun{
#' nc_rcat(
#'   filenames = c("part1.nc", "part2.nc", "part3.nc"),
#'   varid = "temp",
#'   output = "combined.nc"
#' )
#' }
nc_rcat = function(filenames, varid, output) {
  # add function validation
  # check for unlim
  for(i in seq_along(filenames)) {
    nc = nc_open(filenames[i])
    if(!any(ncdim_isUnlim(nc))) stop("No file have an unlimited dimension.")
    if(i==1) {
      varid = .checkVarid(varid=varid, nc=nc)
      isUnlim  = ncdim_isUnlim(nc)[ncvar_dim(nc)[[varid]]]
      unlimDim = names(nc$dim)[which(ncdim_isUnlim(nc))]
      ncNew = nc_create(filename=output, vars=nc$var[[varid]])
      start = rep(1, length(isUnlim))
      refSize = nc$var[[varid]]$size[which(!isUnlim)]
    }
    if(!(varid %in% names(nc$var))) {
      msg = sprintf("Variable '%s' not found in '%s'.", varid, nc$filename)
      stop(msg)
    }
    ncSize = nc$var[[varid]]$size
    if(!identical(ncSize[which(!isUnlim)], refSize))
      stop("File dimensions doesn't match.")
    count = ncSize*isUnlim -1*!isUnlim
    # add values to varid
    ncvar_put(ncNew, varid, ncvar_get(nc, varid, collapse_degen=FALSE),
              start=start, count=ncSize)
    # add values to unlimited dimension
    ncvar_put(ncNew, varid=unlimDim, ncvar_get(nc, varid=unlimDim),
              start=start[which(isUnlim)], count=ncSize[which(isUnlim)])
    start = start + ncSize*isUnlim
    nc_close(nc)
  }
  nc_close(ncNew)
  return(invisible(output))
}


#' Subset a variable in a netCDF file
#'
#' Extracts a subset of a variable from a netCDF file using coordinate bounds
#' supplied for one or more dimensions, and writes the result to a new file.
#'
#' @param filename Character string giving the path to the input netCDF file.
#' @param varid Character string giving the name of the variable to subset. If
#'   missing and the file contains a single variable, that variable is used.
#' @param output Character string giving the path to the output netCDF file to
#'   create.
#' @param newvarid Optional character string giving the name of the variable in
#'   the output file. By default, the original variable name is used.
#' @param compression Optional numeric compression level for the output
#'   variable. Supplying this typically requires netCDF4 output.
#' @param force_v4 Logical. If `TRUE`, force creation of a netCDF4 output file.
#' @param ... Named bounds for dimensions to subset. Each argument name must
#'   match a dimension name. Values should be numeric vectors of length two
#'   giving lower and upper bounds. A length-one value is treated as an exact
#'   coordinate and expanded internally to `c(x, x)`.
#' @param ignore.case Logical. If `TRUE`, ignore case when matching dimension
#'   names supplied in `...`.
#' @param drop Logical. If `TRUE`, drop dimensions of length one in the output.
#'
#' @details
#' Only dimensions named in `...` are subset; all others are kept in full. The
#' output file contains the subsetted variable, with updated dimension values.
#' Global attributes from the source file are copied to the output file, and the
#' global `history` attribute is updated with the function call.
#'
#' @return Invisibly returns `output`, or `NULL` invisibly if none of the
#'   supplied dimension names match the variable dimensions.
#'
#' @seealso [nc_extract()], [write_ncdf()]
#' @export
#'
#' @examples
#' \dontrun{
#' nc_subset(
#'   filename = "input.nc",
#'   varid = "temp",
#'   output = "subset.nc",
#'   lon = c(-80, -70),
#'   lat = c(-20, -10),
#'   depth = c(0, 100)
#' )
#' }
nc_subset = function(filename, varid, output, newvarid, compression,
                     force_v4=FALSE, ..., ignore.case=FALSE, drop=FALSE) {

  bounds = list(...)
  bounds = lapply(bounds, FUN = function(x) if(length(x)==1) return(rep(x, 2)) else return(x))

  if(isTRUE(ignore.case)) names(bounds) = tolower(names(bounds))
  nc = nc_open(filename)
  on.exit(nc_close(nc))

  varid = .checkVarid(varid=varid, nc=nc)
  if(missing(newvarid)) newvarid = varid

  dims = ncvar_dim(nc, varid, value=TRUE)
  dimNames = names(dims)

  if(isTRUE(ignore.case)) names(dims) = tolower(names(dims))

  check = any(names(bounds) %in% names(dims), na.rm=TRUE)

  if(!isTRUE(check)) {
    warning("Dimensions to subset don't match, nothing to do.")
    return(invisible())
  }

  bound = NULL # to make CRAN test happy
  .getIndex = function(x, bound, FUN, default=1) {
    FUN = match.fun(FUN)
    # longitude in a torus
    if(is.null(bound)) return(default)
    if(diff(bound)<0) stop("Upper bound is lower than lower bound.")
    out = which((x>=bound[1]) & (x<=bound[2]))
    return(FUN(out))
  }

  count = setNames(sapply(names(dims),
                          function(x) .getIndex(dims[[x]], bounds[[x]], FUN=length, default=-1)),
                   names(dims))

  if(any(count==0)) {
    msg = sprintf("All index are out of bounds: (%s).", paste(bound, collapse=", "))
    warning(msg)
  }

  index = setNames(lapply(names(dims),
                          function(x) .getIndex(dims[[x]], bounds[[x]], FUN=identity, default=TRUE)),
                   dimNames) # keep original names

  start = setNames(sapply(names(dims),
                          function(x) .getIndex(dims[[x]], bounds[[x]], FUN=min, default=1)),
                   names(dims))

  x  = ncvar_get(nc, varid, collapse_degen=FALSE, start=start, count=count)

  newVar = nc$var[[varid]]
  newVar$size = dim(x)
  newVar$name = newvarid
  if(!missing(compression)) newVar$compression = compression
  newVar$chunksizes = NA

  .modifyDim = function(x, dim, index) {
    if(isTRUE(index[[x]])) return(dim[[x]])
    if(length(index[[x]])==1 & isTRUE(drop)) return(NULL)
    dim[[x]]$size = length(index[[x]])
    dim[[x]]$len = length(index[[x]])
    dim[[x]]$vals = dim[[x]]$vals[index[[x]]]
    return(dim[[x]])
  }

  newVar$dim = lapply(names(nc$dim), FUN=.modifyDim, dim=nc$dim, index=index)
  ind = newVar$dimids + 1
  if(isTRUE(drop)) ind = ind[dim(x)>1]
  newVar$dim = newVar$dim[ind]
  if(isTRUE(drop)) x = drop(x)

  newVar = ncvar_def(name=newVar$name, units = newVar$units,
                     missval = newVar$missval, dim = newVar$dim,
                     longname = newVar$longname, prec = newVar$prec,
                     compression = newVar$compression)

  ncNew = nc_create(filename=output, vars=newVar, force_v4=force_v4)
  on.exit(nc_close(ncNew), add=TRUE)

  ncvar_put(ncNew, newvarid, x)

  globalAtt = ncatt_get(nc, varid=0)

  xcall = paste(gsub(x=gsub(x=capture.output(match.call()),
                     pattern="^[ ]*", replacement=""), pattern="\"",
               replacement="'"), collapse="")

  oldHistory = if(!is.null(globalAtt$history)) globalAtt$history else NULL

  newHistory = sprintf("%s: %s [nctools version %s, %s]",
                       date(), xcall, packageVersion("nctools"), R.version.string)

  globalAtt$history = paste(c(oldHistory, newHistory), collapse="\n")

  # copy global attributes from original nc file.
  ncatt_put_all(ncNew, varid=0, attval=globalAtt)


  return(invisible(output))
}


#' Set a dimension as unlimited
#'
#' Recreates a netCDF file with the selected dimension marked as unlimited.
#'
#' @param filename Character string giving the path to the input netCDF file.
#' @param unlim Character string giving the name of the dimension to set as
#'   unlimited.
#' @param output Optional character string giving the path to the output file.
#'   If `NULL`, the input file is replaced.
#'
#' @details
#' The function rebuilds the file definition with the requested dimension marked
#' as unlimited in every variable where that dimension is present, then copies
#' the variable values to the new file.
#'
#' @return Invisibly returns the list of variable definitions used to create the
#'   new file.
#' @seealso [nc_rcat()], [write_ncdf()]
#' @export
#'
#' @examples
#' \dontrun{
#' nc_unlim(
#'   filename = "input.nc",
#'   unlim = "time",
#'   output = "time_unlimited.nc"
#' )
#' }
nc_unlim = function(filename, unlim, output=NULL) {
  # open ncdf connection
  if(is.null(output)) output = filename
  outputTemp = paste(output, ".temp", sep="")
  nc = nc_open(filename)
  on.exit(nc_close(nc))

  .makeUnlim = function(x, unlim) {
    names(x$dim) = sapply(x$dim, "[[", "name")
    if(is.null(x$dim[[unlim]])) return(x)
    x$dim[[unlim]]$unlim = TRUE
    x$unlim = TRUE
    return(x)
  }

  # new variables with unlimited dimension
  newVars = lapply(nc$var, FUN=.makeUnlim, unlim=unlim)

  ncNew = nc_create(filename=outputTemp, vars=newVars)

  for(iVar in names(newVars))
    ncvar_put(ncNew, iVar, ncvar_get(nc, iVar, collapse_degen=FALSE))

  nc_close(ncNew)

  renameFlag = file.rename(outputTemp, output)

  return(invisible(newVars))

}


#' Apply a function over margins of a netCDF variable
#'
#' Reads a variable from a netCDF file, applies a function over one or more of
#' its dimensions using [base::apply()], and writes the result to a new netCDF
#' file.
#'
#' @param filename Character string giving the path to the input netCDF file.
#' @param varid Character string giving the name of the variable to process. If
#'   missing and the file contains a single variable, that variable is used.
#' @param MARGIN Integer or character vector specifying the dimensions to retain
#'   in the output, as in [base::apply()]. Dimension names may be used.
#' @param FUN Function to apply.
#' @param ... Additional arguments passed to `FUN`.
#' @param output Character string giving the path to the output netCDF file to
#'   create.
#' @param drop Logical. Currently not implemented.
#' @param newdim Optional numeric values for the dimension created when `FUN`
#'   returns a vector of length greater than one.
#' @param name Optional character string giving the name of the output variable.
#'   By default, the original variable name is used.
#' @param longname Optional character string giving the long name of the output
#'   variable. By default, a name based on `FUN` and the original variable long
#'   name is generated.
#' @param units Optional character string giving the units of the output
#'   variable. By default, the units of the input variable are used.
#' @param compression Optional numeric compression level for the output
#'   variable.
#' @param verbose Logical. Currently unused.
#' @param force_v4 Logical. Currently unused internally.
#' @param ignore.case Logical. If `TRUE`, ignore case when matching dimension
#'   names supplied in `MARGIN`.
#'
#' @details
#' The selected variable is read into memory and processed with [base::apply()].
#' The output retains the dimensions specified in `MARGIN`. If `FUN` returns a
#' vector of length greater than one, an additional dimension is appended to the
#' result; its coordinate values are taken from `newdim` when provided, or
#' generated automatically otherwise.
#'
#' @return Invisibly returns `output`.
#'
#' @seealso [nc_subset()], [write_ncdf()], [base::apply()]
#' @export
#'
#' @examples
#' \dontrun{
#' ## Mean over the time dimension
#' nc_apply(
#'   filename = "input.nc",
#'   varid = "temp",
#'   MARGIN = c("lon", "lat"),
#'   FUN = mean,
#'   na.rm = TRUE,
#'   output = "temp_mean.nc"
#' )
#'
#' ## Quantiles over the depth dimension
#' nc_apply(
#'   filename = "input.nc",
#'   varid = "temp",
#'   MARGIN = c("lon", "lat"),
#'   FUN = quantile,
#'   probs = c(0.25, 0.5, 0.75),
#'   newdim = c(25, 50, 75),
#'   output = "temp_quantiles.nc"
#' )
#' }
nc_apply = function(filename, varid, MARGIN, FUN, ..., output=NULL, drop=FALSE,
                    newdim = NULL, name=NULL, longname=NULL, units=NULL,
                    compression=NA, verbose=FALSE, force_v4=TRUE,
                    ignore.case=FALSE) {


  funName = deparse(substitute(FUN))

  if(is.null(output)) stop("You must specify an 'output'file.")

  if(file.exists(output)) {
    oTest = file.remove(output)
    if(!oTest) stop(sprintf("Cannot write on %s.", output))
  }

  FUN = match.fun(FUN)

  nc = nc_open(filename)
  on.exit(nc_close(nc))

  varid = .checkVarid(varid=varid, nc=nc)

  X = ncvar_get(nc, varid, collapse_degen = FALSE)

  dn = ncvar_dim(nc, varid, value=TRUE)
  dnn = if(isTRUE(ignore.case)) tolower(names(dn)) else names(dn)

  if (is.character(MARGIN)) {
    if(isTRUE(ignore.case)) MARGIN = tolower(MARGIN)
    MARGIN = match(MARGIN, dnn)
    if(anyNA(MARGIN))
      stop("not all elements of 'MARGIN' are names of dimensions")
  }

  Y = apply(X=X, MARGIN = MARGIN, FUN = FUN, ...)

  lans = length(Y)/prod(dim(X)[MARGIN]) # length of the answer (FUN)

  if(is.null(newdim)) {

    if(lans>1) {
      vals = suppressWarnings(as.numeric(dimnames(Y)[[1]]))
      newdim = if(all(!is.na(vals))) vals else seq_len(lans)
    } else {
      newdim = seq_len(lans)
    }

  } # make newdim from answer

  if(length(newdim)!=lans) {
    msg = sprintf("The length of newdim (%s) doesn't match answer length (%s), ignoring newdim.",
                  length(newdim), lans)
    warning(msg)
    newdim = seq_len(lans)
  }
  if(!is.numeric(newdim)) {
    warning("The argument newdim must be numeric, ignoring newdim.")
    newdim = seq_len(lans)
  }

  oldVar = nc$var[[varid]]
  newDim = nc$dim[(oldVar$dimids + 1)[MARGIN]]

  if(!is.na(compression)) oldVar$compression = compression

  if(lans>1) {

    Y = aperm(Y, perm = c(seq_along(dim(Y))[-1], 1))

    ansDim = ncdim_def(name=funName, units="", vals=newdim)
    newDim = c(newDim, list(ansDim))
    names(newDim)[length(MARGIN)+1] = funName

  }

  # TODO: drop for tomorrow

  xlongname = sprintf("%s of %s", funName, oldVar$longname)

  varLongname = if(is.null(longname)) xlongname else longname
  varName  = if(is.null(name)) oldVar$name else name
  varUnits = if(is.null(units)) oldVar$units else units

  newVar = ncvar_def(name=varName, units = varUnits,
                     missval = oldVar$missval, dim = newDim,
                     longname = varLongname, prec = oldVar$prec,
                     compression = oldVar$compression)

  ncNew = nc_create(filename=output, vars=newVar, force_v4=force_v4, verbose=verbose)
  ncvar_put(nc=ncNew, varid=varName, vals=Y)
  nc_close(ncNew)

  return(invisible(output))

}


# Extra tools -------------------------------------------------------------

#' Write data to a netCDF file
#'
#' `write_ncdf()` is an S3 generic for writing R objects to a netCDF file.
#' Methods are provided for writing a single array-like object
#' (`write_ncdf.default()`) and a list of arrays (`write_ncdf.list()`).
#'
#' @param x Object to write. Supported methods currently accept either a single
#'   array-like object or a list of array-like objects.
#' @param filename Character string giving the path to the netCDF file to
#'   create.
#' @param ... Additional arguments passed to methods.
#'
#' @return Invisibly returns `filename`.
#'
#' @examples
#' \dontrun{
#' ## Single variable
#' x <- array(rnorm(20 * 10), dim = c(20, 10))
#'
#' write_ncdf(
#'   x,
#'   filename = "example_single.nc",
#'   varid = "temp",
#'   dim = list(lon = seq_len(20), lat = seq_len(10)),
#'   longname = "Temperature",
#'   units = "degree_C"
#' )
#'
#' ## Multiple variables
#' x1 <- array(rnorm(20 * 10), dim = c(20, 10))
#' x2 <- array(rnorm(20 * 10), dim = c(20, 10))
#'
#' write_ncdf(
#'   list(temp = x1, salt = x2),
#'   filename = "example_multi.nc",
#'   varid = c("temp", "salt"),
#'   dim = list(lon = seq_len(20), lat = seq_len(10)),
#'   longname = c("Temperature", "Salinity"),
#'   units = c("degree_C", "psu")
#' )
#' }
#'
#' @export
write_ncdf = function(x, filename, ...) {
  UseMethod("write_ncdf")
}




