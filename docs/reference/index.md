# Package index

## Create and write netCDF files

Functions to create new netCDF files and write data or attributes.

- [`write_ncdf()`](write_ncdf.md) : Write data to a netCDF file

## Inspect netCDF structure

Functions to inspect variables, dimensions, compression, and attributes.

- [`ncvar_dim()`](ncvar_dim.md) : Get variable dimensions from a netCDF
  file
- [`ncvar_size()`](ncvar_size.md) : Get variable sizes from a netCDF
  file
- [`ncdim_size()`](ncdim_size.md) : Get dimension lengths from a netCDF
  file
- [`ncdim_isUnlim()`](ncdim_isUnlim.md) : Test whether dimensions are
  unlimited
- [`ncvar_compression()`](ncvar_compression.md) : Get variable
  compression settings from a netCDF file
- [`ncatt_get_all()`](ncatt_get_all.md) : Get all attributes from
  variables or dimensions

## Modify netCDF structure

Functions to rename, reconfigure, or update structural properties of
existing files.

- [`nc_rename()`](nc_rename.md) : Rename variables and dimensions in a
  netCDF file
- [`nc_unlim()`](nc_unlim.md) : Set a dimension as unlimited
- [`ncvar_change_compression()`](ncvar_change_compression.md) : Change
  variable compression settings in a netCDF object
- [`ncatt_put_all()`](ncatt_put_all.md) : Write multiple attributes to a
  netCDF variable or file

## Extract and transform variables

Functions to extract, subset, concatenate, or transform variables in
netCDF files.

- [`nc_extract()`](nc_extract.md) : Extract a variable to a new netCDF
  file
- [`nc_subset()`](nc_subset.md) : Subset a variable in a netCDF file
- [`nc_rcat()`](nc_rcat.md) : Concatenate records of a variable across
  netCDF files
- [`nc_apply()`](nc_apply.md) : Apply a function over margins of a
  netCDF variable
- [`nc_loc()`](nc_loc.md) : Locate the depth where a variable reaches a
  given value
- [`nc_changePrimeMeridian()`](nc_changePrimeMeridian.md) : Change the
  prime meridian of a variable in a netCDF file

## Summary statistics

Functions to compute summary statistics over margins of netCDF
variables.

- [`nc_mean()`](nc_mean.md) [`nc_min()`](nc_mean.md)
  [`nc_max()`](nc_mean.md) : Compute summary statistics of a netCDF
  variable
- [`nc_quantile()`](nc_quantile.md) : Compute sample quantiles of a
  netCDF variable

## Longitude utilities

Helpers to detect and standardise longitude conventions.

- [`checkLongitude()`](checkLongitude.md) : Standardise longitude values
  to a selected prime meridian convention
- [`findPrimeMeridian()`](findPrimeMeridian.md) : Identify the prime
  meridian convention from longitude values
