test_that("depth profiles and isotherm interpolation match analytical references", {
    local({
        input = system.file("extdata", "temperature_profile.nc", package = "nctools", mustWork = TRUE)
        output = tempfile(fileext = ".nc")
        on.exit(unlink(output))
        nc = ncdf4::nc_open(input)
        field = tryCatch({
            {
                expect_identical(nc$var$temperature$size, c(15L, 20L, 31L))
                expect_true(nc$dim$depth$units == "m")
                expect_true(ncdf4::ncatt_get(nc, "depth", "positive")$value == "down")
            }
            list(lon = nc$dim$lon$vals, lat = nc$dim$lat$vals, depth = nc$dim$depth$vals, x = ncdf4::ncvar_get(nc,
                "temperature"))
        }, finally = ncdf4::nc_close(nc))
        surface = outer(field$lon, field$lat, function(x, y) 24 + 3 * exp(-((x + 72)^2/16 +
            (y + 15)^2/36)) + (y + 25)/19)
        scale = outer(field$lon, field$lat, function(x, y) 50 + 25 * ((x + 80)/15 + (y + 25)/19))
        expected = array(NA_real_, dim(field$x))
        for (k in seq_along(field$depth)) {
            expected[, , k] = 8 + (surface - 8) * exp(-field$depth[k]/scale)
        }
        expected[1:2, 1:2, ] = NA_real_
        {
            expect_identical(as.numeric(field$depth), as.numeric(seq(0, 300, 10)))
            expect_identical(is.na(field$x), is.na(expected))
            expect_equal(field$x, expected, tolerance = 1e-06)
            expect_true(all(apply(field$x, c(1, 2), function(x) all(diff(x) < 0)), na.rm = TRUE))
        }
        nc_loc(input, "temperature", "depth", loc = 20, output = output)
        nc = ncdf4::nc_open(output)
        actual = tryCatch({
            {
                expect_true(nc$var$depth$units == "m")
            }
            ncdf4::ncvar_get(nc, "depth")
        }, finally = ncdf4::nc_close(nc))
        analytical = scale * log((surface - 8)/12)
        analytical[1:2, 1:2] = NA_real_
        {
            expect_identical(dim(actual), c(15L, 20L))
            expect_identical(is.na(actual), is.na(analytical))
            expect_true(max(abs(actual - analytical), na.rm = TRUE) < 0.26)
        }
    })
})
