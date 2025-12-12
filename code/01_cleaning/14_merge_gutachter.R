# ---- Setup ----
library(readxl)
library(dplyr)
library(stringr)
library(sf)
library(tmap)
library(fixest)
library(data.table)
library(haven)

# ---- Project + data directories ----
proj_dir  <- "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project"
data_dir  <- file.path(proj_dir, "data")
raw_dir   <- file.path(data_dir, "raw")
geo_dir   <- file.path(raw_dir, "geodata")
temp_dir   <- file.path(data_dir, "temp")

# specific raw sub-folders / files
gutachter_dir <- file.path(raw_dir, "Gutachterauschuss")
blocks_dir    <- file.path(geo_dir, "blocks_shp")
lors_path     <- file.path(geo_dir, "lor_planungsraeume_2021.shp")

# ---- Load ----

# Gutachterausschuss
gutachter <- readxl::read_xlsx(
  file.path(gutachter_dir, "Gutachter.xlsx")
)

# statistical blocks
blocks_rbs <- sf::read_sf(
  file.path(blocks_dir, "blocks_rbs.shp")
)

# Berlin LORs
lors_berlin <- sf::read_sf(
  file.path(lors_path, "lor_planungsraeume_2021.shp")
)

# Reproject to Berlin CRS (meters)
lors_berlin <- st_transform(lors_berlin, 25833)
blocks_rbs  <- st_transform(blocks_rbs, 25833)

# Generate block centroids
blocks_rbs_cent <- st_centroid(blocks_rbs)

# Attach LOR IDs to block centroids (point-in-polygon)
blocks_with_lor_sf <- st_join(blocks_rbs_cent, lors_berlin, join = st_within)

# Drop geometry for later merges
blocks_with_lor <- blocks_with_lor_sf |>
  st_drop_geometry() |>
  as_tibble()

# prepare for merging
blocks_with_lor$Block = as.numeric(blocks_with_lor$blknr)

# Merge Gutachter to LOR–block mapping
df_final = merge(gutachter, blocks_with_lor, by = "Block" )

# merge gutachter data to lor_block_merge
# then 
# aggregate Numbers on Lor level
df_final_agg <- df_final |>
  group_by(PLR_ID, Jahr) |>
  summarise(
    n_transactions = n(),
    avg_price_sqm  = mean(KP, na.rm = TRUE),
    med_price_sqm  = median(KP, na.rm = TRUE),
    p25_price_sqm  = quantile(KP, 0.25, na.rm = TRUE, type = 7),
    p75_price_sqm  = quantile(KP, 0.75, na.rm = TRUE, type = 7),
    .groups = "drop"
  )

# Save df_final_agg as Stata .dta
haven::write_dta(df_final_agg,
                 file.path(temp_dir, "df_final_agg.dta"))


