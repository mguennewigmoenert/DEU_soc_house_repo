#****************************************#
#************ LOR correction ************#
#******** crosswalk and weights *********#
#****************************************#

# libraries ---------------------------------------------------------------
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

# empty old environment ----------------------------------------------------
rm(list = ls())

# define paths -------------------------------------------------------------
path <- "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/"
data <- str_c(path, "data/")

#-------------------------------------------------------------------------------
# 1. Upload non-spatial data
#-------------------------------------------------------------------------------

# microm grid-level panel (source geometry data)
panelSUF  <- data.frame(read_dta(str_c(data, "raw/Socioeconomic Data/microm_panelSUF_05-21.dta")))

# LOR population from Berlin Open Data (target population, original counts)
ewr_final <- data.frame(fread(str_c(data, "temp/ewr_final.csv")))

#-------------------------------------------------------------------------------
# 2. Upload spatial data (LORs and 1km grid)
#-------------------------------------------------------------------------------

# LOR polygons (target geometries)
lor_2021 <- st_read(str_c(data, "raw/lor_planungsraeume_2021.shp/lor_planungsraeume_2021.shp"))

# 1km rectangles for Germany (source geometries, RWI grid)
rect_1km <- st_read(str_c(data, "raw/Socioeconomic Data/Raster_Shapefiles/ger_1km_rectangle.shp"))

#-------------------------------------------------------------------------------
# 3. CRS harmonization and validity checks
#-------------------------------------------------------------------------------

lor_2021 <- st_transform(st_as_sf(lor_2021), crs = 25833) |> st_make_valid()
rect_1km <- st_transform(st_as_sf(rect_1km), crs = 25833) |> st_make_valid()

#-------------------------------------------------------------------------------
# 4. Compute area size for each geometry
#-------------------------------------------------------------------------------

# Target area A_t for each LOR
lor_2021$area_21  <- as.numeric(st_area(lor_2021))

# Source area for each 1km grid cell
rect_1km$area_1km <- as.numeric(st_area(rect_1km))

#-------------------------------------------------------------------------------
# 5. Spatially intersect source (grid) and target (LOR) geometries
#-------------------------------------------------------------------------------

int_lor_2021_rect_1km <- st_intersection(rect_1km, lor_2021) |>
  as_tibble()

# Overlap area A_st for each grid–LOR pair
int_lor_2021_rect_1km$area_int <- as.numeric(
  st_area(st_as_sf(int_lor_2021_rect_1km))
)

#-------------------------------------------------------------------------------
# 6. Pure area-based weights (geometric, not TDW)
#-------------------------------------------------------------------------------

int_lor_2021_rect_1km$weights <- int_lor_2021_rect_1km$area_int /
  int_lor_2021_rect_1km$area_1km

# Quick check: number of unique LORs present in the intersection
int_lor_2021_rect_1km |>
  distinct(PLR_ID) |>
  nrow()

#-------------------------------------------------------------------------------
# 7. Target-Density Weights (TDW) using true LOR population
#-------------------------------------------------------------------------------

# This MUST match the column name in ewr_final that contains LOR population.
POP_COL <- "E_E"     # <--- change if needed

years <- sort(unique(ewr_final$year))

# Add LOR area (A_t) into the intersection table
# IMPORTANT: rename to avoid name clashes -> area_21_lor
int_x <- int_lor_2021_rect_1km |>
  left_join(
    lor_2021 |>
      st_set_geometry(NULL) |>
      dplyr::select(PLR_ID, area_21_lor = area_21),
    by = "PLR_ID"
  ) |>
  mutate(
    PLR_ID = as.numeric(PLR_ID)  # ensure same type as in ewr_final
  )

# Build TDW per year using target-density weights -----------------------------
tdw_panel_list <- lapply(years, function(y) {
  
  # --- 7.1 Get target population POP_t for year y ---------------------------
  year_pop <- ewr_final |>
    dplyr::filter(year == y) |>
    dplyr::select(PLR_ID, POP = all_of(POP_COL))
  
  # --- 7.2 Join population to overlaps and compute TDW numerator -----------
  # tdw_num = POP_t * (A_st / A_t), with A_t = area_21_lor
  int_y <- int_x |>
    left_join(year_pop, by = "PLR_ID") |>
    mutate(
      tdw_num = if_else(
        !is.na(POP) & area_21_lor > 0,
        POP * (area_int / area_21_lor),  # POP_t * (A_st / A_t)
        0
      )
    )
  
  # --- 7.3 Denominator: sum over all target LORs τ for each source grid s ---
  denom <- int_y |>
    group_by(idm) |>
    summarise(
      tdw_denom = sum(tdw_num, na.rm = TRUE),
      .groups   = "drop"
    )
  
  # --- 7.4 Normalise: w_{st} = tdw_num / Σ_τ tdw_num ------------------------
  out <- int_y |>
    left_join(denom, by = "idm") |>
    mutate(
      weight_tdw = if_else(tdw_denom > 0, tdw_num / tdw_denom, NA_real_),
      year       = y
    ) |>
    select(idm, PLR_ID, year, weight_tdw)
  
  return(out)
})

tdw_panel <- bind_rows(tdw_panel_list)

#-------------------------------------------------------------------------------
# 8. Sanity checks for TDW
#-------------------------------------------------------------------------------

tdw_panel |>
  group_by(year, idm) |>
  summarise(sum_w = sum(weight_tdw, na.rm = TRUE), .groups = "drop") |>
  summarise(
    frac_ok = mean(abs(sum_w - 1) < 1e-6)  # share of grids with sum(w) ≈ 1
  )

tdw_panel |>
  group_by(year) |>
  summarise(num_lors = n_distinct(PLR_ID), .groups = "drop") |>
  arrange(year)

#-------------------------------------------------------------------------------
# 9. Clean up and save crosswalks
#-------------------------------------------------------------------------------

int_lor_2021_rect_1km$geometry <- NULL

int_lor_2021_rect_1km <- int_lor_2021_rect_1km |>
  dplyr::select(idm, id, weights, PLR_ID) |>
  dplyr::rename(
    source_id2 = id,
    source_id  = idm,
    target_id  = PLR_ID
  )

fwrite(
  int_lor_2021_rect_1km,
  str_c(data, "raw/crosswalk/int_w_lor_2021_rect_1km.csv")
)

fwrite(
  tdw_panel,
  str_c(data, "raw/crosswalk/int_tdw_lor_2021_rect_1km.csv")
)

#-------------------------------------------------------------------------------
# 10. Example usage (commented)
#-------------------------------------------------------------------------------
# lor_panel <- panelSUF |>
#   left_join(tdw_panel, by = c("idm", "year")) |>
#   group_by(PLR_ID, year) |>
#   summarise(
#     x_lor = sum(x * weight_tdw, na.rm = TRUE),
#     .groups = "drop"
#   )
#-------------------------------------------------------------------------------