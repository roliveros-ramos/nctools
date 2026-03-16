
#' Compute sample quantiles of a netCDF variable
#'
#' Applies [stats::quantile()] to a variable in a netCDF file over the
#' dimensions not listed in `MARGIN`, and writes the result to a new netCDF
#' file.
#'
#' @inheritParams nc_apply
#' @param na.rm Logical. If `TRUE`, missing values are removed before computing
#'   the quantiles.
#' @param probs Numeric vector of probabilities in `[0, 1]` passed to
#'   [stats::quantile()].
#'
#' @details
#' The output retains the dimensions specified in `MARGIN`. An additional
#' dimension is appended to store the quantiles defined by `probs`.
#'
#' @return Invisibly returns `output`.
#'
#' @seealso [nc_apply()], [stats::quantile()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc_quantile(
#'   filename = "input.nc",
#'   varid = "temp",
#'   MARGIN = c("lon", "lat"),
#'   probs = c(0.1, 0.5, 0.9),
#'   output = "temp_quantiles.nc"
#' )
#' }
nc_quantile = function(filename, varid, MARGIN=c(1,2), na.rm=TRUE, probs=c(0, 0.5, 1),
                       output=NULL, drop=TRUE, compression=NA, verbose=FALSE,
                       force_v4=TRUE, ignore.case=FALSE) {

  if(!is.numeric(probs)) stop("Argument 'probs' must be numeric.")

  nc_apply(filename=filename, varid=varid, MARGIN=MARGIN, FUN=quantile,
           na.rm=na.rm, probs=probs, output=output, drop=drop, newdim = probs,
           name=NULL, longname=NULL, units=NULL, compression=compression, verbose=verbose,
           force_v4=force_v4, ignore.case=ignore.case)

}



#' Compute summary statistics of a netCDF variable
#'
#' Applies a summary function to a variable in a netCDF file over the
#' dimensions not listed in `MARGIN`, and writes the result to a new netCDF
#' file.
#'
#' `nc_mean()` applies [base::mean()], `nc_min()` applies [base::min()], and
#' `nc_max()` applies [base::max()].
#'
#' @inheritParams nc_apply
#' @param na.rm Logical. If `TRUE`, missing values are removed before computing
#'   the statistic.
#' @param trim Numeric scalar giving the fraction of observations to be trimmed
#'   from each end before computing the mean. Passed to [base::mean()]. Used
#'   only by `nc_mean()`.
#'
#' @details
#' The output retains the dimensions specified in `MARGIN`.
#'
#' @return Invisibly returns `output`.
#'
#' @seealso [nc_apply()], [base::mean()], [base::min()], [base::max()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' nc_mean(
#'   filename = "input.nc",
#'   varid = "temp",
#'   MARGIN = c("lon", "lat"),
#'   na.rm = TRUE,
#'   output = "temp_mean.nc"
#' )
#'
#' nc_min(
#'   filename = "input.nc",
#'   varid = "temp",
#'   MARGIN = c("lon", "lat"),
#'   na.rm = TRUE,
#'   output = "temp_min.nc"
#' )
#'
#' nc_max(
#'   filename = "input.nc",
#'   varid = "temp",
#'   MARGIN = c("lon", "lat"),
#'   na.rm = TRUE,
#'   output = "temp_max.nc"
#' )
#' }
nc_mean = function(filename, varid, MARGIN=c(1,2), na.rm=TRUE, trim=0,
                   output=NULL, drop=TRUE, compression=NA, verbose=FALSE,
                   force_v4=TRUE, ignore.case=FALSE) {

  nc_apply(filename=filename, varid=varid, MARGIN=MARGIN, FUN=mean,
           na.rm=na.rm, trim=trim, output=output, drop=drop, newdim = NULL,
           name=NULL, longname=NULL, units=NULL, compression=compression, verbose=verbose,
           force_v4=force_v4, ignore.case=ignore.case)

}


#' @rdname nc_mean
#' @export
nc_min = function(filename, varid, MARGIN=c(1,2), na.rm=TRUE,
                  output=NULL, drop=TRUE, compression=NA, verbose=FALSE,
                  force_v4=TRUE, ignore.case=FALSE) {

  nc_apply(filename=filename, varid=varid, MARGIN=MARGIN, FUN=min,
           na.rm=na.rm, output=output, drop=drop, newdim = NULL,
           name=NULL, longname=NULL, units=NULL, compression=compression, verbose=verbose,
           force_v4=force_v4, ignore.case=ignore.case)

}



#' @rdname nc_mean
#' @export
nc_max = function(filename, varid, MARGIN=c(1,2), na.rm=TRUE,
                  output=NULL, drop=TRUE, compression=NA, verbose=FALSE,
                  force_v4=TRUE, ignore.case=FALSE) {

  nc_apply(filename=filename, varid=varid, MARGIN=MARGIN, FUN=max,
           na.rm=na.rm, output=output, drop=drop, newdim = NULL,
           name=NULL, longname=NULL, units=NULL, compression=compression, verbose=verbose,
           force_v4=force_v4, ignore.case=ignore.case)

}
