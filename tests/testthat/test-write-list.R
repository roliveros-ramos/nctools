test_that("list writing infers names and dimensions and recycles metadata", {
  field = small_field()
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  write_ncdf(list(temperature = field$x, anomaly = field$y), output,
             units = "degree_C", longname = "Synthetic field")
  expect_netcdf_values(output, list(temperature = small_field()$x, anomaly = small_field()$y),
                       list(dim1 = 1:3, dim2 = 1:4, dim3 = 1:5))
  nc = ncdf4::nc_open(output)
  on.exit(ncdf4::nc_close(nc), add = TRUE, after = FALSE)
  for (variable in nc$var) {
    expect_identical(variable$units, "degree_C")
    expect_identical(variable$longname, "Synthetic field")
    expect_identical(variable$prec, "float")
  }
})

test_that("list writing supports explicit names and variables using a subset of dimensions", {
  field = small_field()
  surface = field$x[, , 1]
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  write_ncdf(list(field$x, surface), output, varid = c("temperature", "surface"),
    dim = unname(field$coordinates), dim.names = names(field$coordinates),
    dim.units = c("degrees_east", "degrees_north", "days"),
    dim.longname = c("Longitude", "Latitude", "Time"),
    units = c("degree_C", "K"), longname = c("Full field", "Surface field"),
    prec = c("double", "float"), global = list(title = "Multiple variables"))
  expect_netcdf_values(output,
    list(temperature = small_field()$x, surface = small_field()$x[, , 1]), field$coordinates)
  nc = ncdf4::nc_open(output)
  on.exit(ncdf4::nc_close(nc), add = TRUE, after = FALSE)
  expect_identical(nc$var$temperature$prec, "double")
  expect_identical(nc$var$surface$prec, "float")
  expect_identical(nc$var$surface$units, "K")
  expect_identical(nc$var$surface$longname, "Surface field")
  expect_identical(ncdf4::ncatt_get(nc, 0, "title")$value, "Multiple variables")
})

test_that("writers reject incompatible dimensions and metadata lengths", {
  x = small_field()$x
  output = tempfile(fileext = ".nc")
  on.exit(unlink(output))
  expect_error(write_ncdf(x, output, "x", global = 1), "must be a list")
  expect_error(write_ncdf(x, output, "x", dim = list(1:3)), "does not match")
  expect_error(write_ncdf(x, output, "x", dim.units = "m"), "dim units")
  expect_error(write_ncdf(x, output, "x", dim.longname = "X"), "dim longnames")
  variables = list(a = x, b = x)
  expect_error(write_ncdf(variables, output, global = 1), "must be a list")
  expect_error(write_ncdf(variables, output, varid = "a"), "One 'varid'")
  expect_error(write_ncdf(variables, output, dim = list(1:2, 1:4, 1:5)), "incompatible")
  for (argument in c("units", "longname", "prec", "dim.units", "dim.longname")) {
    args = list(x = variables, filename = output)
    args[[argument]] = rep("invalid", 4)
    expect_error(do.call(write_ncdf, args),
                 if (argument == "dim.units") "dim units" else
                   if (argument == "dim.longname") "dim longnames" else "One")
  }
  expect_false(file.exists(output))
})
