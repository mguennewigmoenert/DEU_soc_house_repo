# ---- Setup ----
library(readxl)
library(dplyr)
library(stringr)
library(sf)
library(tmap)
library(fixest)
library(data.table)

# Working + data dirs
wd   <- "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Supply"
data <- "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Supply/data"
setwd(wd)

# upload multibuffer function
source(file.path(wd, "code/prep/fun_multibuffer.R") )

# ---- Load ----
# If multiple sheets, set sheet = "SheetName"
df_raw <- readxl::read_xlsx( file.path( data, "raw", "berlin_workhouse.xlsx") )

# load Gutachterausschuss
gutachter = readxl::read_xlsx( file.path(data, "raw", "Gutachterauschuss", "Gutachter.xlsx") )

# load statistical blocks
blocks_rbs = read_sf( file.path(data, "raw", "blocks_shp", "blocks_rbs.shp") )

# assume df has `longitude`, `latitude`
df_raw_sf <- df_raw %>%
  filter(!is.na(longitude), !is.na(latitude)) %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326,
    remove = FALSE
  )

# Reproject to Berlin CRS (meters)
df_raw_sf <- st_transform(df_raw_sf, 25833)
blocks_rbs <- st_transform(blocks_rbs, 25833)

# generate block centroids
blocks_rbs_cent = st_centroid(blocks_rbs)

# check property locations
tmap_mode("view")

tm_shape( df_raw_sf |> filter( Wohnen == 1 ) ) +
  tm_symbols(fill = "red", size = .3)

# plot buffers
df_raw_buf_200 = st_multibuffer(st_sf( df_raw_sf ), 200, 400, 200)

tm_shape(df_raw_buf_200 |> filter( Wohnen == 1 ) ) +
  tm_polygons(fill = "red", alpha = 0.3, border.col = "black") +
  tm_shape(df_raw_sf) +
  tm_symbols(fill = "blue", size = 0.2)

# merge rings with block centroids
df_raw_buf_merge = as_tibble( st_intersection( st_make_valid( st_sf( df_raw_buf_200  ) ), 
                                               st_make_valid( st_sf( blocks_rbs_cent ) ) ) )

# identify sutva violation
df_raw_buf_merge <- df_raw_buf_merge %>%
  group_by(blknr) %>%
  mutate(ring_const = as.integer(n_distinct(ring, na.rm = TRUE) == 1L & any(!is.na(ring))),
         ring_dubl = sum(ring_const) ) %>%
  ungroup()

x = df_raw_buf_merge[c("prjct_id", "blknr", "ring_const", "ring_dubl")]

#
df_raw_buf_merge_clean = df_raw_buf_merge |>
                            filter(ring_dubl == 0)

# prepare for merging
df_raw_buf_merge_clean$Block = as.numeric(df_raw_buf_merge_clean$blknr)

# merge gutachter data
df_final = merge(df_raw_buf_merge_clean, gutachter, by = "Block" )

# generate completion year
df_final$year_bauende <- format(
  as.Date(df_final$bauende, format = "%Y-%m-%d"),
  "%Y"
)

# generate year
df_final$year <- format(
  as.Date(df_final$Datum, format = "%Y-%m-%d"),
  "%Y"
)

# time to treatment
df_final = df_final |>
  mutate(# set columns to numeric
         year         = as.numeric(year),
         year_bauende = as.numeric(year_bauende),
         Wohnungen    = as.numeric(Wohnungen),
         # time to treatment
         time         = year - year_bauende, 
         # treatment group dummy
         treated      = case_when(ring == 1 ~ 1,
                                  ring == 2 ~ 0)
         )

# Convert to data.table
setDT(df_final)

# Calculate number of treated units per ring and project proposed by Wing, Freedman, & Hollingsworth (2024) 
tatt_weights_2 <- df_final[treated == 1,
                           .(N_D = .N),
                           by = .(prjct_id)]

# Total number of treated units across all sub-experiments
N_D_total <- tatt_weights_2[, sum(N_D)]

# Compute weights
tatt_weights_2[, tatt_weight := N_D / N_D_total]

# View
tatt_weights_2[]

# Join weights back to original data
df_final <- tatt_weights_2[df_final, on = .(prjct_id)]


iplot( 
  feols(log( Kaufpreis ) ~
          i(time, treated, ref = "-1") 
        + log(`WF od. NF`) 
        | prjct_id^year 
        + prjct_id^blknr, 
        cluster = ~ prjct_id,
        weights = ~ tatt_weight,
        data = 
          df_final 
        |> filter(time %in% -3:3,
                  # Wohnen == 1
                  ))
)

df_final$
df_final$prjct_id

iplot( 
  feols(log1p(Kaufpreis) ~
          i(time, treated*(Wohnungen/100), ref = -1) 
        + log(`WF od. NF`) 
        | prjct_id^year  
        + prjct_id^blknr
        + prjct_id^ewk, 
        cluster = ~ prjct_id,
        weights = ~ tatt_weight,
        data = 
          df_final 
        |> filter(time %in% -3:3 ,
                  Wohnungen>0
        ))
)



