january_field = function() {
  lon = seq(-80, -65, length.out = 15)
  lat = seq(-25, -6, length.out = 20)
  days = 0:30
  spatial = outer(lon, lat, function(x, y)
    16 + 6 * exp(-((x + 72)^2 / 16 + (y + 15)^2 / 36)) - 0.15 * (y + 15))
  temperature = outer(spatial, days, function(field, day)
    field + 2 * sin(2 * pi * day / 365) + 0.2 * sin(2 * pi * day / 7))
  temperature[1:2, 1:2, ] = NA_real_
  return(list(x = temperature, coordinates = list(lon = lon, lat = lat, time = days)))
}

expect_temperature_file = function(path, expected, coordinates) {
  expect_true(file.exists(path))
  expect_gt(file.info(path)$size, 0)
  nc = ncdf4::nc_open(path)
  on.exit(ncdf4::nc_close(nc))
  expect_identical(names(nc$var), "temperature")
  expect_equal(nc$var$temperature$size, c(15, 20, 31))
  expect_identical(vapply(nc$var$temperature$dim, function(x) x$name, ""),
                   names(coordinates))
  for (name in names(coordinates)) {
    expect_equal(as.numeric(ncdf4::ncvar_get(nc, name)),
                 as.numeric(coordinates[[name]]))
  }
  actual = ncdf4::ncvar_get(nc, "temperature", collapse_degen = FALSE)
  expect_identical(dim(actual), c(15L, 20L, 31L))
  expect_identical(is.na(actual), is.na(expected))
  expect_equal(actual, expected, tolerance = 1e-6)
  return(invisible(NULL))
}

test_that("quick defaults write January data with index dimensions", {
  field = january_field()
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  write_ncdf(field$x, filename = output, varid = "temperature")
  expect_temperature_file(output, january_field()$x,
    list(dim1 = 1:15, dim2 = 1:20, dim3 = 1:31))
  nc = ncdf4::nc_open(output)
  on.exit(ncdf4::nc_close(nc), add = TRUE, after = FALSE)
  expect_identical(nc$var$temperature$prec, "float")
  expect_false(any(vapply(nc$dim, function(x) x$unlim, logical(1))))
})

test_that("named coordinates and metadata accompany unchanged January data", {
  field = january_field()
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  units = c("degrees_east", "degrees_north", "days since 2001-01-01")
  write_ncdf(field$x, filename = output, varid = "temperature",
    dim = field$coordinates, dim.units = units,
    longname = "Synthetic daily temperature", units = "degree_C")
  expect_temperature_file(output, january_field()$x, field$coordinates)
  nc = ncdf4::nc_open(output)
  on.exit(ncdf4::nc_close(nc), add = TRUE, after = FALSE)
  expect_identical(unname(vapply(nc$dim, function(x) x$units, "")), units)
  expect_identical(nc$var$temperature$units, "degree_C")
  expect_identical(nc$var$temperature$longname, "Synthetic daily temperature")
})

test_that("rich attributes and storage settings preserve January data", {
  field = january_field()
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  descriptions = c("Longitude", "Latitude", "Time")
  global = list(title = "Synthetic temperature for January 2001",
    source = "Spatial gradient and Gaussian centre with annual and weekly cycles",
    comment = "Synthetic data, not observations; a fixed corner patch is missing.")
  write_ncdf(field$x, filename = output, varid = "temperature",
    dim = field$coordinates,
    dim.units = c("degrees_east", "degrees_north", "days since 2001-01-01"),
    dim.longname = descriptions,
    longname = "Synthetic daily temperature", units = "degree_C",
    unlim = "time", prec = "float", missval = -9999,
    compression = 4, force_v4 = TRUE, global = global)
  # Recompute the reference: ncdf4 may replace NAs in its input buffer in place.
  expect_temperature_file(output, january_field()$x, field$coordinates)
  nc = ncdf4::nc_open(output)
  on.exit(ncdf4::nc_close(nc), add = TRUE, after = FALSE)
  expect_true(nc$dim$time$unlim)
  expect_false(nc$dim$lon$unlim)
  expect_false(nc$dim$lat$unlim)
  expect_identical(nc$var$temperature$prec, "float")
  expect_equal(nc$var$temperature$compression, 4)
  expect_equal(ncdf4::ncatt_get(nc, "temperature", "_FillValue")$value, -9999)
  for (i in seq_along(descriptions)) {
    expect_identical(ncdf4::ncatt_get(nc, names(field$coordinates)[i], "long_name")$value,
                     descriptions[i])
  }
  for (name in names(global)) {
    expect_identical(ncdf4::ncatt_get(nc, 0, name)$value, global[[name]])
  }
  history = ncdf4::ncatt_get(nc, 0, "history")
  expect_true(history$hasatt)
  expect_match(history$value, "write_ncdf", fixed = TRUE)
  expect_match(history$value, "nctools version", fixed = TRUE)
})
