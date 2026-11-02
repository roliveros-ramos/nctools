test_that("extraction selects one variable without changing coordinates or values", {
  paths = vapply(1:2, function(i) tempfile(fileext = ".nc"), "")
  on.exit(unlink(paths))
  create_transform_fixture(paths[1])
  field = small_field()
  nc_extract(paths[1], "anomaly", paths[2])
  expect_netcdf_values(paths[2], list(anomaly = field$y), field$coordinates)
  expect_error(nc_extract(paths[1], output = paths[2]), "variable")
  expect_error(nc_extract(paths[1], "missing", paths[2]), "Variable")
})

test_that("subsetting matches R indexing and retains singleton dimensions", {
  paths = vapply(1:3, function(i) tempfile(fileext = ".nc"), "")
  on.exit(unlink(paths))
  create_transform_fixture(paths[1])
  field = small_field()
  nc_subset(paths[1], "temperature", paths[2], newvarid = "subset",
             LON = c(-75, -72), lat = c(-19, -18), ignore.case = TRUE, compression = 4)
  expect_netcdf_values(paths[2], list(subset = field$x[1:2, 2:3, , drop = FALSE]),
                       list(lon = c(-75, -72), lat = -19:-18, time = 0:4))
  nc_subset(paths[1], "temperature", paths[3], lon = -72)
  expect_netcdf_values(paths[3], list(temperature = field$x[2, , , drop = FALSE]),
                       list(lon = -72, lat = -20:-17, time = 0:4))
  nc = ncdf4::nc_open(paths[2])
  on.exit(ncdf4::nc_close(nc), add = TRUE, after = FALSE)
  expect_identical(ncdf4::ncatt_get(nc, 0, "title")$value, "Transformation fixture")
  expect_match(ncdf4::ncatt_get(nc, 0, "history")$value, "nc_subset", fixed = TRUE)
})

test_that("subsetting drops singleton dimensions and handles invalid selections", {
  paths = vapply(1:3, function(i) tempfile(fileext = ".nc"), "")
  on.exit(unlink(paths))
  create_transform_fixture(paths[1])
  field = small_field()
  nc_subset(paths[1], "temperature", paths[2], time = 2, drop = TRUE)
  expect_netcdf_values(paths[2], list(temperature = field$x[, , 3]),
                       field$coordinates[c("lon", "lat")])
  expect_warning(nc_subset(paths[1], "temperature", paths[3], unknown = 1), "don't match")
  expect_false(file.exists(paths[3]))
  expect_error(nc_subset(paths[1], "temperature", paths[3], lon = c(-69, -75)),
                "Upper bound")
  expect_false(file.exists(paths[3]))
})

test_that("renaming dimensions and variables preserves all fields", {
  paths = vapply(1:2, function(i) tempfile(fileext = ".nc"), "")
  on.exit(unlink(c(paths, paste0(paths, ".temp"), paste0(paths, ".temp.temp"))))
  create_transform_fixture(paths[1])
  field = small_field()
  nc_rename(paths[1], c("lon", "temperature"), c("longitude", "temp"), output = paths[2])
  coordinates = field$coordinates
  names(coordinates)[1] = "longitude"
  expect_netcdf_values(paths[2], list(temp = field$x, anomaly = field$y), coordinates)
  expect_netcdf_values(paths[1], list(temperature = field$x, anomaly = field$y), field$coordinates)
  nc_rename(paths[2], "temp", "temperature", overwrite = TRUE)
  expect_netcdf_values(paths[2], list(temperature = field$x, anomaly = field$y), coordinates)
})

test_that("renaming protects existing files and handles unmatched names", {
  paths = vapply(1:3, function(i) tempfile(fileext = ".nc"), "")
  on.exit(unlink(c(paths, paste0(paths, ".temp"))))
  create_transform_fixture(paths[1])
  create_transform_fixture(paths[2])
  before = tools::md5sum(paths[1:2])
  expect_error(nc_rename(paths[1], "temperature", "temp"), "output file is missing")
  expect_error(nc_rename(paths[1], "temperature", "temp", output = paths[2]), "already exists")
  expect_identical(tools::md5sum(paths[1:2]), before)
  expect_message(nc_rename(paths[1], "absent", "new", output = paths[3]), "Nothing to change")
  expect_false(file.exists(paths[3]))
  expect_warning(nc_rename(paths[1], c("temperature", "absent"), c("temp", "new"),
                           output = paths[3]), "not found")
  field = small_field()
  expect_netcdf_values(paths[3], list(temp = field$x, anomaly = field$y), field$coordinates)
})

test_that("unlimited conversion preserves both variables and coordinates", {
  paths = vapply(1:2, function(i) tempfile(fileext = ".nc"), "")
  on.exit(unlink(c(paths, paste0(paths, ".temp"))))
  create_transform_fixture(paths[1])
  nc_unlim(paths[1], "time", output = paths[2])
  field = small_field()
  expect_netcdf_values(paths[2], list(temperature = field$x, anomaly = field$y), field$coordinates)
  nc = ncdf4::nc_open(paths[2])
  on.exit(ncdf4::nc_close(nc), add = TRUE, after = FALSE)
  expect_true(nc$dim$time$unlim)
  expect_false(nc$dim$lon$unlim)
  expect_false(nc$dim$lat$unlim)
  expect_netcdf_values(paths[1], list(temperature = field$x, anomaly = field$y), field$coordinates)
})
