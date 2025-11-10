#****************************************#
#************ LOR correction ************#
#******** crosswalk and weights *********#
#****************************************#
#*
# libraries
library(tidyverse)
library(ggplot2)
library(stringr)
library(data.table)
library(readxl)
library(dplyr)
library(purrr)

# empty old environment
rm(list = ls())

# how many NYC tracts
path = "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/"
data = str_c(path, "data/")

# ---- Upload Wohnlage data frames ---------------------------------------------------
# Define the file path template
file_path_whnlage_l20 <- str_c(data, "raw/Wohnlage/WHNLAGE_L20_%d_Matrix.csv")

# Load all files into a list
df_list_whnlage_l20 <- lapply(2010:2019, function(year) {
  file_path <- sprintf(file_path_whnlage_l20, year)  # Generate file path
  
  if (file.exists(file_path)) {
    df <- fread(file_path)  # Read CSV file using fread()
    df[, year := year]  # Add year column (data.table syntax)
    return(df)
  } else {
    warning(sprintf("File not found: %s", file_path))
    return(NULL)
  }
})

# Combine all data frames into one
whnlage_all_years <- rbindlist(df_list_whnlage_l20, fill = TRUE)  # Automatically aligns columns

# check number of lors by year
table(whnlage_all_years$year)
#

# ---- Upload SGB12 data frames ---------------------------------------------------
# Define the file path template
file_path_sgb12 <- str_c(data, "raw/SGB12/sgb12_%d.csv")

# Load all files into a list
df_list_sgb12 <- lapply(2010:2019, function(year) {
  file_path <- sprintf(file_path_sgb12, year)  # Generate file path
  
  if (file.exists(file_path)) {
    df <- fread(file_path)  # Read CSV file using fread()
    df[, year := year]  # Add year column (data.table syntax)
    return(df)
  } else {
    warning(sprintf("File not found: %s", file_path))
    return(NULL)
  }
})

# Combine all data frames into one
sgb12_all_years <- rbindlist(df_list_sgb12, fill = TRUE)  # Automatically aligns columns

# check number of lors by year
table(sgb12_all_years$year)
#
# ---- Upload Early Wohndauer data frames ---------------------------------------------------
# Define the file path template
file_path_whndauer_l20 <- str_c(data, "raw/Wohndauer/WHNDAUER_L20_%d_Matrix.csv")

# Load all files into a list
df_list_whndauer_l20 <- lapply(2010:2013, function(year) {
  file_path <- sprintf(file_path_whndauer_l20, year)  # Generate file path
  
  if (file.exists(file_path)) {
    df <- fread(file_path)  # Read CSV file using fread()
    df[, year := year]  # Add year column (data.table syntax)
    return(df)
  } else {
    warning(sprintf("File not found: %s", file_path))
    return(NULL)
  }
})

# Combine all data frames into one
whndauer_l20 <- rbindlist(df_list_whndauer_l20, fill = TRUE)  # Automatically aligns columns

# check number of lors by year
table(whndauer_l20$year)
#
# ---- Upload Later Wohndauer data frames ---------------------------------------------------
# Define the file path template
file_path_whndauer_l21 <- str_c(data, "raw/Wohndauer/WHNDAUER_L21_%d_Matrix.csv")

# Load all files into a list
df_list_whndauer_l21 <- lapply(2014:2023, function(year) {
  file_path <- sprintf(file_path_whndauer_l21, year)  # Generate file path
  
  if (file.exists(file_path)) {
    df <- fread(file_path)  # Read CSV file using fread()
    df[, year := year]  # Add year column (data.table syntax)
    return(df)
  } else {
    warning(sprintf("File not found: %s", file_path))
    return(NULL)
  }
})

# Combine all data frames into one
whndauer_l21 <- rbindlist(df_list_whndauer_l21, fill = TRUE)  # Automatically aligns columns

# check number of lors by year
table(whndauer_l21$year)
#
# ---- Upload Early Einwohner data frames ---------------------------------------------------
# Define the file path template
file_path_ewr_l20 <- str_c(data, "raw/Einwohner/EWR_L20_%d12E_Matrix.csv")

# Load all files into a list
df_list_ewr_l20 <- lapply(c(2010:2020), function(year) {
  file_path <- sprintf(file_path_ewr_l20, year)  # Generate file path
  
  if (file.exists(file_path)) {
    df <- fread(file_path)  # Read CSV file using fread()
    df[, year := year]  # Add year column (data.table syntax)
    return(df)
  } else {
    warning(sprintf("File not found: %s", file_path))
    return(NULL)
  }
})

# Combine all data frames into one
ewr_l20 <- rbindlist(df_list_ewr_l20, fill = TRUE)  # Automatically aligns columns

# check number of lors by year
print(table(ewr_l20$ZEIT))
#
# ---- Upload Later Einwohner data frames ---------------------------------------------------
# Define the file path template
file_path_ewr_l21 <- str_c(data, "raw/Einwohner/EWR_L21_%d12E_Matrix.csv")

# Load all files into a list
df_list_ewr_l21 <- lapply(2014:2023, function(year) {
  file_path <- sprintf(file_path_ewr_l21, year)  # Generate file path
  
  if (file.exists(file_path)) {
    df <- fread(file_path)  # Read CSV file using fread()
    df[, year := year]  # Add year column (data.table syntax)
    return(df)
  } else {
    warning(sprintf("File not found: %s", file_path))
    return(NULL)
  }
})

# NOTE: 2016 is not in the cleaned data, need to be aggreated see above
# Combine all data frames into one
ewr_l21 <- rbindlist(df_list_ewr_l21, fill = TRUE)  # Automatically aligns columns

# check number of lors by year
print(table(ewr_l21$year))
#
# ---- Upload crosswalk ---------------------------------------------------
int_lor_2021_lor_2020 = data.frame(fread(str_c(data, "raw/crosswalk/int_lor_2021_lor_2020.csv")))

# count the number of unique target dataframes
int_lor_2021_lor_2020 |>
  distinct(target_id) |>
  nrow()
#

int_lor_2021_lor_2020 |> 
  group_by(target_id) |> 
  summarize(total_weight_after = sum(weights, na.rm = TRUE))

# ---- Clean merge columns (LOR names) --------------------------------------------------------------
sgb12_all_years <- sgb12_all_years %>%
  mutate(lor_name = Name, 
         lor_name = str_replace_all(lor_name, "(?<=\\p{L})str\\.?$", "straße"),  # Handles attached "str."
         lor_name = str_replace_all(lor_name, "\\s+Str\\.?\\b", " Straße"),
         lor_name = str_replace_all(lor_name, "([A-Za-zäöüÄÖÜß]+)-Str\\.?\\b", "\\1-Straße"),  # Fixes hyphenated names
         lor_name = str_replace_all(lor_name, "Töpch. Weg", "Töpchiner Weg"),
         lor_name = str_replace_all(lor_name, "Gleisdreieck/Entwickl.-gebiet", "Gleisdreieck/Entwicklungsgebiet"),
         lor_name = str_replace_all(lor_name, "Gewerbegeb. Köllnische Heide", "Gewerbegebiet Köllnische Heide"),
         lor_name = str_replace_all(lor_name, "Komp.-viertel Weißensee", "Komponistenviertel Weißensee"),
         lor_name = str_replace_all(lor_name, "Kölln. Vorstadt", "Köllnische Vorstadt"),
         lor_name = str_replace_all(lor_name, "Alt-Lichtenrade/Töpch. Weg", "Alt-Lichtenrade/Töpchiner Weg"),
         lor_name = str_replace_all(lor_name, "Horstwald. Straße./Paplitzer Straße", "Horstwalder Straße/Paplitzer Straße"),
         lor_name = str_replace_all(lor_name, "Nördl. Landwehrkanal", "Nördlicher Landwehrkanal"),
         lor_name = str_replace_all(lor_name, "Schmöckw./Rauchf.-werder", "Schmöckwitz/Rauchfangswerder"),
         lor_name = str_replace_all(lor_name, "Volkspark \\(Rud\\.\\-Wilde-Park\\)", "Volkspark (Rudolf-Wilde-Park)"),
         lor_name = str_replace_all(lor_name, "Wittenbergpl./Vikt.-Luise-Pl.", "Wittenbergplatz/Viktoria-Luise-Platz"),
         lor_name = str_replace_all(lor_name, "Wriezener Bahnh./Entwickl.-geb.", "Wriezener Bahnhof/Entwicklungsgebiet"),
         lor_name = str_replace_all(lor_name, "Biesdorf-Süd", "Biesdorf Süd"),
         lor_name = str_replace_all(lor_name, "Westl. Müllerstraße", "Westliche Müllerstraße"),
         lor_name = str_replace_all(lor_name, "Franziusweg/ Rohrbachstraße", "Franziusweg/Rohrbachstraße"),
         lor_name = str_replace_all(lor_name, "Humboldthain NW", "Humboldthain Nordwest"),
         lor_name = str_replace_all(lor_name, "Gewerbegeb. Bitterfelder Straße", "Gewerbegebiet Bitterfelder Straße"),
         lor_name = str_replace_all(lor_name, "Tiefenwerder", "Tiefwerder"),
         lor_name = str_replace_all(lor_name, "Karlhorst West", "Karlshorst West")
  )  # Handles spaced "Str."

# remove all remaining dots in SGB12 dataframe
sgb12_all_years <- sgb12_all_years %>%
  mutate(lor_name = str_replace_all(lor_name, "\\.", ""))

# remove all hyphens in SGB12 dataframe
sgb12_all_years = 
sgb12_all_years %>%
  mutate(lor_name = str_replace_all(lor_name, "-", " "))

# remove all hyphens in crosswalk
int_lor_2021_lor_2020 = 
int_lor_2021_lor_2020 %>%
  mutate(source_id = str_replace_all(source_id, "-", " "))

sgb12_all_years <- sgb12_all_years |> 
  mutate(lor_name = case_when(
    str_detect(Kennung, "4030417") ~ str_replace_all(lor_name, "Schloßstraße", "Schloßstraße_1"), 
    str_detect(Kennung, "6010102") ~ str_replace_all(lor_name, "Schloßstraße", "Schloßstraße_2"),
    TRUE ~ lor_name  # Keeps the original value if no match
  ))

int_lor_2021_lor_2020 <- int_lor_2021_lor_2020 |> 
  mutate(source_id = case_when(
    str_detect(BEZIRKSNAM, "Charlottenburg-Wilmersdorf") ~ str_replace_all(source_id, "Schloßstraße", "Schloßstraße_1"), 
    str_detect(BEZIRKSNAM, "Steglitz-Zehlendorf") ~ str_replace_all(source_id, "Schloßstraße", "Schloßstraße_2"),
    TRUE ~ source_id  # Keeps the original value if no match
  ))

# ---- QUALITY CONTROL ------------------------------------------------------
# show all unique source name 
# data.frame(unique_lor_name = unique(sgb12_all_years$lor_name))
# data.frame(unique_source_id = unique(int_lor_2021_lor_2020$source_id))

# Get unique values from each dataset
source_ids <- unique(int_lor_2021_lor_2020$source_id)
lor_names <- unique(sgb12_all_years$lor_name)

# Find `lor_name` values that are NOT in `source_id`
missing_lor_names <- setdiff(lor_names, source_ids)

# Find `source_id` values that are NOT in `lor_name`
missing_source_ids <- setdiff(source_ids, lor_names)

# Print missing values
print(missing_lor_names)  # `lor_name` values missing in `source_id`
print(missing_source_ids)  # `source_id` values missing in `lor_name`

# ---- merge population to SGB12 data ------------------------------------------------------------
sgb12_all_years =
merge(sgb12_all_years, 
      ewr_l20 |>
        mutate(year = as.numeric(str_extract(ZEIT, "^\\d{4}"))
        ) |>
        dplyr::select(E_E, RAUMID, year),
      by.x=c("Kennung", "year"),
      by.y=c("RAUMID", "year"))

# recover total SGBXII recipients from data
sgb12_all_years =
  sgb12_all_years |>
  mutate(tot_sgb12 = (as.numeric(sgb12) * as.numeric(E_E))/100)


# ---- Generate weighted SGB12 data --------------------------------------------------------------
# merge sgb12 to LOR crosswalk
int_lor_2021_lor_2020_sgb12 = merge(int_lor_2021_lor_2020, 
                                    sgb12_all_years, 
                                    by.x = "source_id", by.y = "lor_name", all.x=T)


int_lor_2021_lor_2020_sgb12 |> 
  group_by(year, target_id) |> 
  mutate(weights = sum(weights, na.rm = TRUE)) |> 
  ungroup()

# aggregate on new level
sgb12_final =
  int_lor_2021_lor_2020_sgb12 |>
  dplyr::mutate(sgb12 = as.numeric(sgb12)) |>
  mutate(
    sgb12 = replace_na(sgb12, 0),
    tot_sgb12 = replace_na(tot_sgb12, 0)
  ) |>
  dplyr::group_by(year, target_id) |>
  dplyr::summarize(sgb12_w = sum(weights*sgb12, na.rm=T),
                   tot_sgb12_w = sum(weights*tot_sgb12, na.rm=T))

# check number of LORs by year
table(int_lor_2021_lor_2020_sgb12$year)
table(sgb12_final$year)

# check SGB12 by year
sgb12_final |>
  group_by(year) |>
  dplyr::summarise(sum(tot_sgb12_w, na.rm=T))

# ---- Generate weighted Einwohner data --------------------------------------------------------------
# adjust to dataframe
ewr_l20 <- ewr_l20 |>
  data.frame()

table(ewr_l20$year)
# merge OLD lor name information to 
# merge sgb12 lor names to Wohndauer dataframe
ewr_l20 = merge(ewr_l20, 
                sgb12_all_years |>
                  dplyr::filter(year == 2010) |> # select only for one year
                  dplyr::select(Kennung, lor_name), # keep only merge columns
                by.x = "RAUMID", by.y = "Kennung", all.x=T
)

# merge Wohndauer to old LOR format
int_lor_2021_lor_2020_ewr = merge(int_lor_2021_lor_2020, ewr_l20, by.x = "source_id", by.y = "lor_name", all.x=T)

# aggregate on new level
int_lor_2021_lor_2020_ewr <- int_lor_2021_lor_2020_ewr |>
  group_by(year, target_id) |>
  summarize(across(8:51, ~ sum(weights * as.numeric(.), na.rm = TRUE), .names = "{.col}")) # apply the weighted sum operation on columns 8 to 51

# check if all variable are aggregated to new level
table(int_lor_2021_lor_2020_ewr$year)

# 
int_lor_2021_lor_2020_ewr |>
  group_by(year) |>
  dplyr::summarise(sum(E_E, na.rm=T))

#
# ---- Generate weighted Wohnlage data --------------------------------------------------------------
# adjust to dataframe
whnlage_all_years <- whnlage_all_years |>
  data.frame()

table(whnlage_all_years$year)
# merge OLD lor name information to 
# merge sgb12 lor names to Wohndauer dataframe
whnlage_all_years = merge(whnlage_all_years, 
                sgb12_all_years |>
                          dplyr::filter(year == 2010) |> # select only for one year
                          dplyr::select(Kennung, lor_name), # keep only merge columns
                by.x = "RAUMID", by.y = "Kennung", all.x=T
                )

# merge Wohndauer to old LOR format
int_lor_2021_lor_2020_whnlage = merge(int_lor_2021_lor_2020, whnlage_all_years, by.x = "source_id", by.y = "lor_name", all.x=T)

# aggregate on new level
whnlage_final <- int_lor_2021_lor_2020_whnlage |>
  dplyr::group_by(year, target_id) |>
  dplyr::summarize(
    WLEINFoL = sum(weights * as.numeric(WLEINFoL), na.rm = TRUE),
    WLEINFmL = sum(weights * as.numeric(WLEINFmL), na.rm = TRUE),
    WLGUTFoL = sum(weights * as.numeric(WLGUTFoL), na.rm = TRUE),
    WLGUTFmL = sum(weights * as.numeric(WLGUTFmL), na.rm = TRUE),
    WLMITFoL = sum(weights * as.numeric(WLMITFoL), na.rm = TRUE),
    WLMITFmL = sum(weights * as.numeric(WLMITFmL), na.rm = TRUE),
    WLGUTmL = sum(weights * as.numeric(WLGUTmL), na.rm = TRUE),
    WLGUToL = sum(weights * as.numeric(WLGUToL), na.rm = TRUE),
    WLMITmL = sum(weights * as.numeric(WLMITmL), na.rm = TRUE),
    WLMIToL = sum(weights * as.numeric(WLMIToL), na.rm = TRUE),
    WLNZORD = sum(weights * as.numeric(WLNZORD), na.rm = TRUE)
  )

# check if all variable are aggregated to new level
table(whnlage_final$year)

# ---- Generate weighted Wohndauer data --------------------------------------------------------------
# adjust to dataframe
whndauer_l20 <- whndauer_l20 |>
  data.frame()

# merge OLD lor name information to 
# merge sgb12 lor names to Wohndauer dataframe
whndauer_l20 = merge(whndauer_l20, 
                     sgb12_all_years |>
                               dplyr::filter(year == 2010) |> # select only for one year
                               dplyr::select(Kennung, lor_name), # keep only merge columns
                     by.x = "RAUMID", by.y = "Kennung", all.x=T
                     )

# merge Wohndauer to old LOR format
int_lor_2021_lor_2020_whndauer = merge(int_lor_2021_lor_2020, whndauer_l20, by.x = "source_id", by.y = "lor_name", all.x=T)

# aggregate on new level
int_lor_2021_lor_2020_whndauer <- int_lor_2021_lor_2020_whndauer |>
  group_by(year, target_id) |>
  summarize(
    EINW10 = sum(weights * as.numeric(EINW10), na.rm = TRUE),
    EINW5 = sum(weights * as.numeric(EINW5), na.rm = TRUE),
    DAU10 = sum(weights * as.numeric(DAU10), na.rm = TRUE),
    DAU5 = sum(weights * as.numeric(DAU5), na.rm = TRUE)
  )

# check if all variable are aggregated to new level
table(int_lor_2021_lor_2020_whndauer$year)

# upload 
# ---- Generate all years dataframes for Einwohner and Wohndauer ---------------------------
# check number of LORs bei year in two dataframes
table(int_lor_2021_lor_2020_whndauer$year)
table(whndauer_l21$year)

# adjsust weighted dataframe for merging
int_lor_2021_lor_2020_whndauer <- int_lor_2021_lor_2020_whndauer |> 
                            dplyr::rename(
                                  PLR_ID = target_id,  # Rename `target_id` → `RAUMID`
                                  Dau5 = DAU5,
                                  Dau10 = DAU10)
# add weightening note
int_lor_2021_lor_2020_whndauer$note = "weighted"

# adjust unweighted datafrem for merging
whndauer_l21 = whndauer_l21 |>
                            dplyr::rename(
                                  PLR_ID = RAUMID,  # Rename `target_id` → `RAUMID`
                            ) |> 
                            dplyr::select(PLR_ID, year, EINW10, EINW5, Dau10, Dau5)  # Keep only selected columns

# add weightening note
whndauer_l21$note = "not weighted"

whndauer_final <- bind_rows(whndauer_l21, int_lor_2021_lor_2020_whndauer)
table(whndauer_final$year)

# check number of LORs bei year in two dataframes
table(int_lor_2021_lor_2020_ewr$year)
table(ewr_l21$year)

# adjsust weighted dataframe for merging
int_lor_2021_lor_2020_ewr <- int_lor_2021_lor_2020_ewr |> 
  dplyr::rename(
    PLR_ID = target_id,  # Rename `target_id` → `RAUMID`
  )
# add weightening note
int_lor_2021_lor_2020_ewr$note = "weighted"

# adjust unweighted datafrem for merging
ewr_l21 = ewr_l21 |>
  dplyr::rename(
    PLR_ID = RAUMID,  # Rename `target_id` → `RAUMID`
  ) |> 
  dplyr::select(PLR_ID, year, matches("^E_E")) # Keep only selected columns

# add weightening note
ewr_l21$note = "not weighted"

ewr_final <- bind_rows(ewr_l21, int_lor_2021_lor_2020_ewr |>
                                    filter(year<2014 | year ==2016))
table(ewr_final$year)

#
##----safe data from dflist in seperate data frames in data file ---------------------------
fwrite(ewr_final, str_c(data, "temp/ewr_final.csv"))
fwrite(whndauer_final, str_c(data, "temp/whndauer_final.csv"))
fwrite(sgb12_final, str_c(data, "temp/sgb12_final.csv"))
fwrite(whnlage_final, str_c(data, "temp/whnlage_final.csv"))

