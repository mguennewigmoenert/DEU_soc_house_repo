#****************************************#
#************ LOR correction ************#
#******** crosswalk and weights *********#
#****************************************#

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
library(haven)

# empty old environment
rm(list = ls())

# define paths
path = "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/"
data = str_c(path, "data/")

# ---- Upload dta frame ---------------------------------------------------
panelSUF <- data.frame(read_dta(str_c(data, 'raw/Socioeconomic Data/microm_panelSUF_05-21.dta')))
ewr_final <- data.frame(fread(str_c(data, 'temp/ewr_final.csv')))

# ---- Upload spatial data ---------------------------------------------------
lor_2021 <- st_read(str_c(data, "raw/lor_planungsraeume_2021.shp/lor_planungsraeume_2021.shp"))
rect_1km <- st_read(str_c(data, 'raw/Socioeconomic Data/Raster_Shapefiles/ger_1km_rectangle.shp'))

# ---- CRS Harmonization and validation -------------------------------------
lor_2021 <- st_transform(st_as_sf(lor_2021), crs = 25833)
rect_1km <- st_transform(st_as_sf(rect_1km), crs = 25833)

lor_2021 <- st_make_valid(st_sf(lor_2021))
rect_1km <- st_make_valid(st_sf(rect_1km))

# ---- Compute area size for each geometry ----------------------------------
lor_2021$area_21 <- as.numeric(st_area(st_sf(lor_2021$geometry)))
rect_1km$area_1km <- as.numeric(st_area(st_sf(rect_1km$geometry)))

# ---- Spatially intersect source and target geometries ---------------------
int_lor_2021_rect_1km <- as_tibble(st_intersection(st_sf(rect_1km), st_sf(lor_2021)))
int_lor_2021_rect_1km$area_int <- as.numeric(st_area(int_lor_2021_rect_1km$geometry))

# ---- Area-based weights ---------------------------------------------------
int_lor_2021_rect_1km$weights <- int_lor_2021_rect_1km$area_int / int_lor_2021_rect_1km$area_1km

# To check the number of unique LORs
int_lor_2021_rect_1km |> 
  distinct(PLR_ID) |> 
  nrow()

# ---- TDW using true LOR population from ewr_final -------------------------
# Assumptions:
# - ewr_final has columns: PLR_ID (target LOR id), year, and ewr (population)
# - int_lor_2021_rect_1km has: idm (source id), PLR_ID (target id), area_int (overlap area)
# - lor_2021 has: PLR_ID and area_21 (target area)

POP_COL <- "ewr"            # <- change if your population column is named differently
years   <- sort(unique(ewr_final$year))

# Add target area to the intersection table
int_x <- int_lor_2021_rect_1km |>
  #left_join(lor_2021 |>
  #            st_set_geometry(NULL) |>
  #            dplyr::select(PLR_ID, area_21),
  #          by = "PLR_ID") |>
    mutate( PLR_ID = as.numeric( PLR_ID ) )

# Build TDW per year using target-density weights
tdw_panel_list <- lapply(years, function(y) {
  
  # Target POP for year y
  POP_COL <- "E_E"
  year_pop <- ewr_final |>
    dplyr::filter(year == y) |>
    dplyr::select(PLR_ID, POP = all_of(POP_COL))
  
  # Join POP to overlaps, compute target density and numerators
  int_y <- int_x |>
    left_join(year_pop, by = "PLR_ID") |>
    mutate(
      rho_target = if_else(!is.na(POP) & area_21 > 0, POP / area_21, 0),
      tdw_num    = rho_target * area_int
    )
  
  # Normalize within each SOURCE id (idm)
  denom <- int_y |>
    group_by(idm) |>
    summarise(tdw_denom = sum(tdw_num, na.rm = TRUE), .groups = "drop")
  
  out <- int_y |>
    left_join(denom, by = "idm") |>
    mutate(
      weight_tdw = if_else(tdw_denom > 0, tdw_num / tdw_denom, NA_real_),
      year = y
    ) |>
    select(idm, PLR_ID, year, weight_tdw)
  
  # ✅ Add area weights back in
  out <- out |>
    left_join(
      int_x |> 
        select(idm, PLR_ID, weights),
      by = c("idm", "PLR_ID")
    )
  
  return(out)
})

tdw_panel <- bind_rows(tdw_panel_list)

# Quick sanity checks
tdw_panel |>
  group_by(year, idm) |>
  summarise(sum_w = sum(weight_tdw, na.rm = TRUE), .groups = "drop") |>
  summarise(frac_ok = mean(abs(sum_w - 1) < 1e-6))

tdw_panel |>
  group_by(year) |>
  summarise(num_lors = n_distinct(PLR_ID), .groups = "drop") |>
  arrange(year)

# ---- Clean up and save crosswalk -----------------------------------------
int_lor_2021_rect_1km$geometry <- NULL

int_lor_2021_rect_1km = int_lor_2021_rect_1km |>
  dplyr::select(idm, id, weights, PLR_ID) |>
  dplyr::rename(
    source_id2 = id,
    source_id = idm,
    target_id = PLR_ID
  )

fwrite(int_lor_2021_rect_1km, str_c(data, "raw/crosswalk/int_w_lor_2021_rect_1km.csv"))
fwrite(tdw_panel, str_c(data, "raw/crosswalk/int_tdw_lor_2021_rect_1km.csv"))
