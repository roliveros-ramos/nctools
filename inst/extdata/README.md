Synthetic daily temperature, January–March 2001

The grid has 15 longitudes (-80 to -65), 20 latitudes (-25 to -6), and
31, 28, or 31 daily records. Time is unlimited, with standard calendar and
units days since 2001-01-01. Temperature units are degree_C.

Values are 16 + 6 exp(-((lon+72)^2/16 + (lat+15)^2/36)) - 0.15(lat+15)
+ 2 sin(2 pi day/365) + 0.2 sin(2 pi day/7), with day starting at zero.
The first two longitude and latitude positions form a permanent missing patch.
All-missing cells remain missing under temporal summaries.

Regenerate from the repository root with:
Rscript --vanilla data-raw/generate-example-files.R

These files are synthetic, not observations. Copy them before editing.

temperature_profile.nc uses the same horizontal grid and depths 0:300 m at
10 m intervals (positive downward). Profiles follow
T(z) = 8 + (surface - 8) exp(-z / scale), where
surface = 24 + 3 exp(-((lon+72)^2/16 + (lat+15)^2/36)) + (lat+25)/19
and scale = 50 + 25 ((lon+80)/15 + (lat+25)/19).
The same corner patch is missing at every depth. The exact 20 degree isotherm
depth is scale * log((surface - 8)/12).
Regenerate with Rscript --vanilla data-raw/generate-profile.R.
