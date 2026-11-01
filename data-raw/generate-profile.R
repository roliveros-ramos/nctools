# Run from the package root: Rscript --vanilla data-raw/generate-profile.R
local({
  dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)
  lon = seq(-80, -65, length.out = 15)
  lat = seq(-25, -6, length.out = 20)
  depth = seq(0, 300, by = 10)
  surface = outer(lon, lat, function(x, y)
    24 + 3 * exp(-((x + 72)^2 / 16 + (y + 15)^2 / 36)) + (y + 25) / 19)
  scale = outer(lon, lat, function(x, y) 50 + 25 * ((x + 80) / 15 + (y + 25) / 19))
  temperature = array(NA_real_, c(15, 20, length(depth)))
  for (k in seq_along(depth)) {
    temperature[, , k] = 8 + (surface - 8) * exp(-depth[k] / scale)
  }
  temperature[1:2, 1:2, ] = NA_real_
  dims = list(ncdf4::ncdim_def("lon", "degrees_east", lon),
              ncdf4::ncdim_def("lat", "degrees_north", lat),
              ncdf4::ncdim_def("depth", "m", depth))
  variable = ncdf4::ncvar_def("temperature", "degree_C", dims,
    missval = -9999, longname = "Synthetic temperature profile", prec = "float")
  nc = ncdf4::nc_create("inst/extdata/temperature_profile.nc", variable)
  on.exit(ncdf4::nc_close(nc))
  ncdf4::ncvar_put(nc, variable, temperature)
  ncdf4::ncatt_put(nc, "depth", "positive", "down")
  ncdf4::ncatt_put(nc, 0, "title", "Synthetic exponential temperature profiles")
  ncdf4::ncatt_put(nc, 0, "source", "data-raw/generate-profile.R; not observations")
})
