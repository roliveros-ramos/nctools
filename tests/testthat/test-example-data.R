test_that("monthly fields, staged concatenation and means preserve expected values", {
    files = system.file("extdata", sprintf("temperature_2001_%02d.nc", 1:3), package = "nctools",
        mustWork = TRUE)
    read_field = function(path) {
        nc = ncdf4::nc_open(path)
        on.exit(ncdf4::nc_close(nc))
        {
            expect_true(nc$dim$time$unlim)
            expect_true(nc$dim$time$units == "days since 2001-01-01")
            expect_true(nc$var$temperature$units == "degree_C")
        }
        return(list(x = ncdf4::ncvar_get(nc, "temperature"), time = nc$dim$time$vals))
    }
    fields = lapply(files, read_field)
    lon = seq(-80, -65, length.out = 15)
    lat = seq(-25, -6, length.out = 20)
    spatial = outer(lon, lat, function(x, y) 16 + 6 * exp(-((x + 72)^2/16 + (y + 15)^2/36)) -
        0.15 * (y + 15))
    for (i in 1:3) {
        day = fields[[i]]$time
        expected = outer(spatial, day, function(x, d) x + 2 * sin(2 * pi * d/365) + 0.2 * sin(2 *
            pi * d/7))
        expected[1:2, 1:2, ] = NA_real_
        {
            expect_identical(dim(expected), dim(fields[[i]]$x))
            expect_identical(is.na(expected), is.na(fields[[i]]$x))
            expect_equal(expected, fields[[i]]$x, tolerance = 1e-06)
        }
    }
    {
        expect_identical(as.numeric(unlist(lapply(fields, `[[`, "time"))), as.numeric(0:89))
    }
    local({
        first = tempfile(fileext = ".nc")
        full = tempfile(fileext = ".nc")
        summary = tempfile(fileext = ".nc")
        on.exit(unlink(c(first, full, summary)))
        nc_rcat(files[1:2], "temperature", first)
        {
            expect_true(length(read_field(first)$time) == 59)
        }
        nc_rcat(c(first, files[3]), "temperature", full)
        result = read_field(full)
        {
            expect_identical(as.numeric(result$time), as.numeric(0:89))
        }
        for (i in 1:3) {
            {
                expect_identical(result$x[, , fields[[i]]$time + 1], fields[[i]]$x)
            }
        }
        nc_mean(files[1], "temperature", c("lon", "lat"), output = summary)
        nc = ncdf4::nc_open(summary)
        actual = tryCatch(ncdf4::ncvar_get(nc, "temperature"), finally = ncdf4::nc_close(nc))
        expected = apply(fields[[1]]$x, c(1, 2), mean, na.rm = TRUE)
        expected[is.nan(expected)] = NA_real_
        {
            expect_equal(actual, expected, tolerance = 1e-06)
        }
    })
})
