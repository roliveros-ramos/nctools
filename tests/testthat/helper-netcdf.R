small_field = function() {
  x = array(as.numeric(1:60), c(3, 4, 5))
  x[1, 1, 1] = NA_real_
  return(list(x = x, y = x + 100,
              coordinates = list(lon = c(-75, -72, -69), lat = -20:-17, time = 0:4)))
}

create_transform_fixture = function(path) {
  field = small_field()
  dims = Map(function(name, vals) ncdf4::ncdim_def(name, "", vals),
             names(field$coordinates), field$coordinates)
  vars = lapply(c("temperature", "anomaly"), function(name)
    ncdf4::ncvar_def(name, "degree_C", dims, missval = -9999, prec = "double"))
  nc = ncdf4::nc_create(path, vars, force_v4 = TRUE)
  on.exit(ncdf4::nc_close(nc))
  ncdf4::ncvar_put(nc, "temperature", field$x)
  ncdf4::ncvar_put(nc, "anomaly", field$y)
  ncdf4::ncatt_put(nc, 0, "title", "Transformation fixture")
  return(invisible(NULL))
}

expect_netcdf_values = function(path, variables, coordinates) {
  expect_true(file.exists(path))
  nc = ncdf4::nc_open(path)
  on.exit(ncdf4::nc_close(nc))
  expect_setequal(names(nc$var), names(variables))
  for (name in names(variables)) {
    actual = ncdf4::ncvar_get(nc, name, collapse_degen = FALSE)
    expect_identical(dim(actual), dim(variables[[name]]))
    expect_identical(is.na(actual), is.na(variables[[name]]))
    expect_equal(actual, variables[[name]], tolerance = 1e-6)
  }
  expect_setequal(names(nc$dim), names(coordinates))
  for (name in names(coordinates)) {
    expect_equal(as.numeric(nc$dim[[name]]$vals), as.numeric(coordinates[[name]]))
  }
  return(invisible(NULL))
}
