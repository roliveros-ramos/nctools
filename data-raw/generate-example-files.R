# Run from the package root: Rscript --vanilla data-raw/generate-example-files.R
dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)
lon = seq(-80, -65, length.out = 15)
lat = seq(-25, -6, length.out = 20)
spatial = outer(lon, lat, function(x, y)
  16 + 6 * exp(-((x + 72)^2 / 16 + (y + 15)^2 / 36)) - 0.15 * (y + 15))
for (month in 1:3) {
  days = switch(month, 0:30, 31:58, 59:89)
  temperature = outer(spatial, days, function(field, day)
    field + 2 * sin(2 * pi * day / 365) + 0.2 * sin(2 * pi * day / 7))
  temperature[1:2, 1:2, ] = NA_real_
  dims = list(ncdf4::ncdim_def("lon", "degrees_east", lon),
              ncdf4::ncdim_def("lat", "degrees_north", lat),
              ncdf4::ncdim_def("time", "days since 2001-01-01", days,
                               unlim = TRUE, calendar = "standard"))
  variable = ncdf4::ncvar_def("temperature", "degree_C", dims,
    missval = -9999, longname = "Synthetic daily temperature", prec = "float")
  nc = ncdf4::nc_create(sprintf("inst/extdata/temperature_2001_%02d.nc", month), variable)
  tryCatch({
    ncdf4::ncvar_put(nc, variable, temperature)
    ncdf4::ncatt_put(nc, 0, "title", "Synthetic temperature demonstration data")
    ncdf4::ncatt_put(nc, 0, "source", "Deterministic formula in data-raw/generate-example-files.R")
  }, finally = ncdf4::nc_close(nc))
}
