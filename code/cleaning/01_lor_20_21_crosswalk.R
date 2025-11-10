#****************************************#
#************ LOR correction ************#
#******** crosswalk and weights *********#
#****************************************#
#*
# libraries
library(sf)
library(tidyverse)
library(ggplot2)
library(stringr)
library(data.table)
library(readxl)
library(dplyr)
library(purrr)
library(tmap)

# empty old environment
rm(list = ls())

# how many NYC tracts
path = "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/"
data = str_c(path, "data/")

# ---- Upload spatial data ---------------------------------------------------
# historic census tract
lor_2021 <- st_read("/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/data/raw/lor_planungsraeume_2021.shp/lor_planungsraeume_2021.shp")
lor_2020 <- st_read('/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/data/raw/lor_planungsraeume_2020.shp/lor_planungsraeume_2020.shp')

# ---- GENERATE 2010 TRACT WEIGHTED DATA SETS FOR HISTORICAL CENSUS ---------------------------------------------------
# spatially match historic and 2010 census tracts
# dopar let system to collapse
# census_list_int = foreach (i=1:(length(census_list_crs)-1)) %dopar% {
#  as_tibble(st_intersection(st_make_valid(st_sf(census_list_crs[[i]])), st_make_valid(st_sf(tract2010))))
#}

# harmonize crs across nta, tracts and mcd's
lor_2021 <- st_transform(st_as_sf(lor_2021), crs = 25833)
lor_2020 <- st_transform(st_as_sf(lor_2020), crs = 25833)

# overlay both shapefiles
tmap_mode("view")
tm_shape(st_make_valid(st_sf(lor_2021))) + 
  tm_borders(col = "blue") +
tm_shape(st_make_valid(st_sf(lor_2020))) + 
  tm_borders(col = "red")

# tract_1940 <- st_transform(st_as_sf(tract_1940), crs = 4269)
# tract2010  <- st_transform(st_as_sf(tract2010), crs = 4269)

lor_2021 <- st_make_valid(st_sf(lor_2021))
lor_2020 <- st_make_valid(st_sf(lor_2020))

# compute area  size for census of the respective years
lor_2021$area_21 <- as.numeric(st_area(st_sf(lor_2021$geometry)))
lor_2020$area_20 <- as.numeric(st_area(st_sf(lor_2020$geometry)))

# spatially match historic and 2010 census tracts
int_lor_2021_lor_2020 <- as_tibble(st_intersection(st_sf(lor_2020), st_sf(lor_2021)))

# compute area of intersections between historic and 2010 census tracts
int_lor_2021_lor_2020$area_int <- as.numeric(st_area(int_lor_2021_lor_2020$geometry))

# weight each intersection area by the total area of the census tract
int_lor_2021_lor_2020$weights <- int_lor_2021_lor_2020$area_int/int_lor_2021_lor_2020$area_20

# check if weights sum up to one
int_lor_2021_lor_2020 |>
  data.frame() |>
  dplyr::group_by(PLR_ID) |>
  dplyr::summarize(sum(weights))

# check spatially merged shapefile
tm_shape(st_make_valid(st_sf(int_lor_2021_lor_2020))) + 
  tm_polygons() +
  tm_shape(st_make_valid(st_sf(lor_2020))) + 
  tm_borders(col = "blue", lwd = 4) +
  tm_shape(st_make_valid(st_sf(lor_2021))) + 
  tm_borders(col = "red")


# count the number of unique target dataframes
int_lor_2021_lor_2020 |>
  distinct(PLR_ID) |>
  nrow()

# count the number of unique source dataframes
int_lor_2021_lor_2020 |>
  distinct(PLANUNGSRA) |>
  nrow()

# check number of unique values in both dataframes
length(sort(unique(int_lor_2021_lor_2020$PLANUNGSRA)))
length(sort(lor_2020$PLANUNGSRA))

# Check for Duplicates in lor_2020$PLANUNGSRA
sum(duplicated(lor_2020$PLANUNGSRA))

# Find the Duplicate Entry
lor_2020$PLANUNGSRA[duplicated(lor_2020$PLANUNGSRA)]

# -> There is one Schloßstraße in Charlottenburg-Wilmersdorf and one in Steglitz-Zehlendorf
# -> thus, keep BEZIRKSNAM in data to distinguish

# delete geometry column
int_lor_2021_lor_2020$geometry <- NULL

# keep only certain variables and rename
int_lor_2021_lor_2020 = 
int_lor_2021_lor_2020 |>
  dplyr::select(BEZIRKSNAM, PLANUNGSRA, weights, PLR_ID) |>
  dplyr::rename(
    BEZIRKSNAM = BEZIRKSNAM,
    source_id = PLANUNGSRA,
    weights = weights,
    target_id = PLR_ID
  )

##----save crosswalk ---------------------------
# save 
fwrite(int_lor_2021_lor_2020, str_c(data, "raw/crosswalk/int_lor_2021_lor_2020.csv"))
