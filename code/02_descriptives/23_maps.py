"""
Berlin grids + LOR + rent map (qm_miete_kalt, 2010)

Workflow:
- Set up project paths (using pathlib)
- Load 1x1km Germany grid (vector "raster-style" grid)
- Get Berlin boundary from OpenStreetMap via OSMnx API
- Load LOR Planungsräume 2021 from Berlin open data (GeoJSON)
- Load Berlin districts (Bezirke) from Berlin open data (GeoJSON)
- Reproject all geometries to grid CRS
- Intersect grid with LOR polygons (st_intersection analogue)
- Load berlin_data_ph.dta
- Filter to year 2010 and merge with LOR by ID
- Plot:
    1) DE grid + Berlin outline
    2) Berlin boundary + LOR + grid∩LOR
    3) LOR choropleth of qm_miete_kalt (2010) with Bezirke boundaries overlaid
"""

import os
from pathlib import Path

import numpy as np
import geopandas as gpd
import osmnx as ox
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.colors import LogNorm
import matplotlib.cm as cm
import matplotlib.patches as mpatches
import pandas as pd


# ============================================================
# 0. PATHS & CONFIG
# ============================================================

PROJECT_ROOT = Path("/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project")

DATA_DIR = PROJECT_ROOT / "data"
RAW_DIR = DATA_DIR / "raw"
SOCIO_DIR = RAW_DIR / "Socioeconomic Data" / "Raster_Shapefiles"
GEODATA_DIR = RAW_DIR / "geodata"   # store downloaded geodata here
OUTPUT_DIR = PROJECT_ROOT / "output"

# Input shapefiles
GRID_PATH = SOCIO_DIR / "ger_1km_rectangle.shp"   # 1x1km Germany grid
A100_PATH = GEODATA_DIR / "autobahn_ring" / "autobahn_ring_poly.shp"   # 1x1km Germany grid

# Outputs
BERLIN_BOUNDARY_OUT = SOCIO_DIR / "berlin_boundary_osm.shp"
BERLIN_GRID_LOR_OUT = SOCIO_DIR / "ger_1km_rectangle_berlin_lor_intersection.shp"

# LOR Planungsräume 2021 (ODIS)
LOR_URL = (
    "https://tsb-opendata.s3.eu-central-1.amazonaws.com/"
    "lor_planungsgraeume_2021/lor_planungsraeume_2021.geojson"
)

# Bezirke (districts) from ODIS
DISTRICTS_URL = (
    "https://tsb-opendata.s3.eu-central-1.amazonaws.com/"
    "bezirksgrenzen/bezirksgrenzen.geojson"
)
DISTRICTS_PATH = GEODATA_DIR / "berlin_bezirke.geojson"

# Panel data path
TEMP_DIR = DATA_DIR / "temp"

BERLIN_RENT_PANEL_PATH = TEMP_DIR / "berlin_data_ph.dta"
BERLIN_SH_PANEL_PATH = TEMP_DIR / "socialhousing_1_since2008.dta"

# Panel/LOR config
YEAR_VAR = "jahr"          # from panel
LOR_ID_PANEL = "PLR_ID"    # in panel
LOR_ID_SHAPE = "PLR_ID"    # in LOR shapefile
RENT_VAR = "qm_miete_kalt"
SOCH_VAR = "socialh"
MAP_YEAR = 2010

# ============================================================
# 1. LOAD GERMANY 1KM GRID
# ============================================================

print(f"Loading Germany 1km grid from {GRID_PATH} ...")
grid = gpd.read_file(GRID_PATH)

print("Grid CRS:", grid.crs)
print("Number of grid cells:", len(grid))


# ============================================================
# 2. GET BERLIN BOUNDARY FROM OSM
# ============================================================

print("Fetching Berlin boundary from OpenStreetMap via OSMnx...")
berlin_gdf = ox.geocode_to_gdf("Berlin, Germany")

print("Berlin GDF CRS:", berlin_gdf.crs)
print("Berlin geometry type:", berlin_gdf.geometry.iloc[0].geom_type)

# ============================================================
# 2b. LOAD AUTOBAHN RING
# ============================================================

print("Loading A100 from {GRID_PATH} ....")
a100_gdf = gpd.read_file(A100_PATH)

print("Berlin GDF CRS:", a100_gdf.crs)
print("Berlin geometry type:", a100_gdf.geometry.iloc[0].geom_type)

# ============================================================
# 3. LOAD LOR PLANUNGSRAUM 2021
# ============================================================

print(f"Loading LOR Planungsräume 2021 from {LOR_URL} ...")
lor = gpd.read_file(LOR_URL)

print("LOR CRS (original):", lor.crs)
print("Number of LOR polygons:", len(lor))


# ============================================================
# 3b. LOAD / DOWNLOAD BEZIRKE (DISTRICTS)
# ============================================================

GEODATA_DIR.mkdir(parents=True, exist_ok=True)

if DISTRICTS_PATH.exists():
    print(f"Loading Bezirke from local file {DISTRICTS_PATH} ...")
    bezirke = gpd.read_file(DISTRICTS_PATH)
else:
    print(f"Downloading Bezirke GeoJSON from {DISTRICTS_URL} ...")
    bezirke = gpd.read_file(DISTRICTS_URL)
    bezirke.to_file(DISTRICTS_PATH, driver="GeoJSON")
    print(f"Saved Bezirke GeoJSON to {DISTRICTS_PATH}")

print("Bezirke CRS (original):", bezirke.crs)
print("Bezirke columns:", bezirke.columns.tolist())

# ============================================================
# 4. REPROJECT EVERYTHING TO GRID CRS
# ============================================================

target_crs = grid.crs  # canonical CRS

if berlin_gdf.crs != target_crs:
    print("Reprojecting Berlin boundary to grid CRS...")
    berlin_gdf = berlin_gdf.to_crs(target_crs)

if a100_gdf.crs != target_crs:
    print("Reprojecting Berlin boundary to grid CRS...")
    a100_gdf = a100_gdf.to_crs(target_crs)

if lor.crs != target_crs:
    print("Reprojecting LOR to grid CRS...")
    lor = lor.to_crs(target_crs)

if bezirke.crs != target_crs:
    print("Reprojecting Bezirke to grid CRS...")
    bezirke = bezirke.to_crs(target_crs)

print("Berlin CRS (after reprojection):", berlin_gdf.crs)
print("LOR CRS (after reprojection):", lor.crs)
print("Bezirke CRS (after reprojection):", bezirke.crs)

berlin_geom = berlin_gdf.geometry.iloc[0]
berlin_boundary = gpd.GeoDataFrame(
    {"name": ["Berlin"]},
    geometry=[berlin_geom],
    crs=berlin_gdf.crs,
)


# ============================================================
# 5. SAVE BERLIN BOUNDARY (OPTIONAL)
# ============================================================

BERLIN_BOUNDARY_OUT.parent.mkdir(parents=True, exist_ok=True)
berlin_boundary.to_file(BERLIN_BOUNDARY_OUT)
print(f"Saved Berlin boundary shapefile to: {BERLIN_BOUNDARY_OUT}")


# ============================================================
# 6. GRID ∩ LOR INTERSECTION (st_intersection analogue)
# ============================================================

print("Computing union of all LOR polygons...")
lor_union = lor.unary_union

print("Selecting grid cells that intersect any LOR polygon...")
grid_berlin = grid[grid.intersects(lor_union)].copy()
print("Candidate grid cells in/near Berlin:", len(grid_berlin))

print("Running geometric intersection grid ∩ LOR (like st_intersection)...")
berlin_grid_lor = gpd.overlay(grid_berlin, lor, how="intersection")
print("Number of resulting grid–LOR intersection pieces:", len(berlin_grid_lor))

BERLIN_GRID_LOR_OUT.parent.mkdir(parents=True, exist_ok=True)
berlin_grid_lor.to_file(BERLIN_GRID_LOR_OUT)
print(f"Saved Berlin 1km grid ∩ LOR shapefile to: {BERLIN_GRID_LOR_OUT}")


# ============================================================
# 7. LOAD PANEL DATA & MERGE WITH LOR (FOR RENT MAP)
# ============================================================

print(f"Loading Stata panel data from {BERLIN_RENT_PANEL_PATH} ...")
rent_panel = pd.read_stata(BERLIN_RENT_PANEL_PATH)
print("Panel shape:", rent_panel.shape)

# sanity checks
if LOR_ID_PANEL not in rent_panel.columns:
    print("Available panel columns:", rent_panel.columns.tolist())
    raise ValueError(f"LOR_ID_PANEL='{LOR_ID_PANEL}' not found in panel.")

if LOR_ID_SHAPE not in lor.columns:
    print("Available LOR columns:", lor.columns.tolist())
    raise ValueError(f"LOR_ID_SHAPE='{LOR_ID_SHAPE}' not found in LOR.")

if YEAR_VAR not in rent_panel.columns:
    raise ValueError(f"YEAR_VAR='{YEAR_VAR}' not found in panel.")

if RENT_VAR not in rent_panel.columns:
    print("Available panel columns:", rent_panel.columns.tolist())
    raise ValueError(f"RENT_VAR='{RENT_VAR}' not found in panel.")

print(f"Filtering panel to year == {MAP_YEAR} ...")
rent_panel_year = rent_panel[rent_panel[YEAR_VAR] == MAP_YEAR].copy()
print("Panel (year) shape:", rent_panel_year.shape)

print("Merging LOR geometries with rent data...")
lor_year = lor.merge(
    rent_panel_year[[LOR_ID_PANEL, RENT_VAR]],
    left_on=LOR_ID_SHAPE,
    right_on=LOR_ID_PANEL,
    how="left",
)
print("Merged LOR + panel (year) shape:", lor_year.shape)

# ============================================================
# 8. LOAD SOCIAL HOUSING DATA & MERGE WITH LOR (LEVELS + CHANGE)
# ============================================================
print(f"Loading social housing panel from {BERLIN_SH_PANEL_PATH} ...")
sh_panel = pd.read_stata(BERLIN_SH_PANEL_PATH)
print("Social housing panel shape:", sh_panel.shape)

# sanity checks
if LOR_ID_PANEL not in sh_panel.columns:
    print("Available SH panel columns:", sh_panel.columns.tolist())
    raise ValueError(f"LOR_ID_PANEL='{LOR_ID_PANEL}' not found in social housing panel.")

if YEAR_VAR not in sh_panel.columns:
    raise ValueError(f"YEAR_VAR='{YEAR_VAR}' not found in social housing panel.")

if "socialh" not in sh_panel.columns:
    print("Available SH panel columns:", sh_panel.columns.tolist())
    raise ValueError("Column 'socialh' not found in social housing panel.")

# -------- LEVELS in 2010 (MAP_YEAR) --------
print(f"Filtering social housing panel to year == {MAP_YEAR} ...")
sh_panel_year = sh_panel[sh_panel[YEAR_VAR] == MAP_YEAR].copy()
print("Social housing panel (year) shape:", sh_panel_year.shape)

print("Merging LOR geometries with social housing data (levels)...")
lor_sh_year = lor.merge(
    sh_panel_year[[LOR_ID_PANEL, "socialh"]],
    left_on=LOR_ID_SHAPE,
    right_on=LOR_ID_PANEL,
    how="left",
)
print("Merged LOR + social housing (year) shape:", lor_sh_year.shape)

# -------- CHANGE 2010 → 2019 --------
year0, year1 = 2010, 2019

sh_2010 = (
    sh_panel[sh_panel[YEAR_VAR] == year0][[LOR_ID_PANEL, "socialh"]]
    .rename(columns={"socialh": f"socialh_{year0}"})
)

sh_2019 = (
    sh_panel[sh_panel[YEAR_VAR] == year1][[LOR_ID_PANEL, "socialh"]]
    .rename(columns={"socialh": f"socialh_{year1}"})
)

sh_change = sh_2010.merge(sh_2019, on=LOR_ID_PANEL, how="outer")

sh_change["socialh_change"] = (
    sh_change[f"socialh_{year1}"] - sh_change[f"socialh_{year0}"]
)

print("Head of change table (2010→2019):")
print(sh_change[[LOR_ID_PANEL, f"socialh_{year0}", f"socialh_{year1}", "socialh_change"]].head())

# Attach change to LOR geometries
lor_sh_change = lor.merge(
    sh_change[[LOR_ID_PANEL, "socialh_change"]],
    left_on=LOR_ID_SHAPE,
    right_on=LOR_ID_PANEL,
    how="left",
)
print("Merged LOR + social housing change shape:", lor_sh_change.shape)

# ============================================================
# 8. PLOTS
# ============================================================

# ---- MAP 1: Germany 1km grid + Berlin outline ----
fig, ax = plt.subplots(figsize=(8, 8))

grid.plot(
    ax=ax,
    linewidth=0.1,
    edgecolor="lightgrey",
    facecolor="none",
)

berlin_boundary.boundary.plot(
    ax=ax,
    color="black",
    linewidth=1.5,
    label="Berlin boundary",
)

ax.set_title("Germany 1km Grid + Berlin Boundary")
ax.set_axis_off()
ax.legend()
plt.tight_layout()
plt.show()

# ============================================================
# 8a. PLOTS: Berlin boundary + LOR + intersected 1km grid
# ============================================================
fig, ax = plt.subplots(figsize=(7, 7))

# Plot layers (no need for label here since we’ll use custom legend)
berlin_boundary.boundary.plot(
    ax=ax,
    color="black",
    linewidth=2,
)

lor.boundary.plot(
    ax=ax,
    linewidth=0.4,
    color="blue",
    alpha=0.7,
)

berlin_grid_lor.plot(
    ax=ax,
    edgecolor="red",
    facecolor="none",
    linewidth=0.4,
)

# Custom legend handles
legend_elements = [
    # Line2D([0], [0], color="black", lw=2, label="Berlin boundary"),
    Line2D([0], [0], color="red",   lw=1.5, label="1km grid ∩ LOR"),
    Line2D([0], [0], color="blue",  lw=1.5, label="LOR Planungsräume 2021"),
]

# ax.set_title("Berlin: 1km Grid ∩ LOR")
ax.set_axis_off()

# IMPORTANT: use handles=legend_elements
ax.legend(handles=legend_elements, loc="upper right", frameon=True, fontsize=11)

plt.tight_layout()

# Save *before* show
figpath = OUTPUT_DIR / "maps" / "map_grid_lor_intersection.pdf"
figpath.parent.mkdir(parents=True, exist_ok=True)
plt.savefig(figpath, dpi=300, bbox_inches="tight")

plt.show()
print(f"Saved MAP 2 to: {figpath}")


# ============================================================
# 8b. PLOTS: LOR rent choropleth + Bezirke boundaries ----
# ============================================================
# Discrete bins for rent
bins = [5, 7, 9, 11, 13]

lor_year["rent_bin"] = pd.cut(
    lor_year[RENT_VAR],
    bins=[-np.inf] + bins + [np.inf],
    labels=["< 5", "5–7", "7–9", "9–11", "11–13", "13+"]
)

fig, ax = plt.subplots(figsize=(7, 7))

lor_year.plot(
    ax=ax,
    column="rent_bin",
    cmap="YlOrRd",
    legend=True,
    categorical=True,
    legend_kwds={"title": f"€/m² kalt ({MAP_YEAR})"},
    missing_kwds={
        "color": "lightgrey",
        "edgecolor": "none",
        "hatch": "///",
        "label": "No data"
    }
)

# Very light LOR boundaries
lor.boundary.plot(
    ax=ax,
    color="grey",      # or "lightgrey"
    linewidth=0.2,
    alpha=0.6
)

# Bezirke boundaries overlay
bezirke.boundary.plot(
    ax=ax,
    color="black",
    linewidth=1.0,
    alpha=0.9
)

# ax.set_title(f"Berlin Rents by LOR ({MAP_YEAR}) with District Boundaries")
ax.set_axis_off()
plt.tight_layout()

# Save
figpath = OUTPUT_DIR / "maps" /f"map_lor_rents_{MAP_YEAR}_with_districts.pdf"
plt.savefig(figpath, dpi=300, bbox_inches="tight")
plt.show()

print(f"Saved MAP 3 to: {figpath}")


# ============================================================
# 8b. PLOTS: LOR Social Housing choropleth + Bezirke boundaries ----
# ============================================================
bins = [-0.1, 50, 100, 500, 2000, 4000, np.inf]
labels = ["0-50",
          "51–100",
          "101–500",
          "501–2,000",
          "2,001–4,000",
          "4,000+"]

lor_sh_year["socialh_bin"] = pd.cut(
    lor_sh_year["socialh"],
    bins=bins,
    labels=labels,
    include_lowest=True
)

fig, ax = plt.subplots(figsize=(7, 7))

# Choropleth: binned social housing, shades of blue
lor_sh_year.plot(
    ax=ax,
    column="socialh_bin",
    cmap="Blues",
    categorical=True,
    legend=True,
    legend_kwds={"title": f"Social housing ({MAP_YEAR})"},
    missing_kwds={
        "color": "lightgrey",
        "edgecolor": "none",
        "hatch": "///",
        "label": "No data"
    }
)

# Very light LOR boundaries
lor.boundary.plot(
    ax=ax,
    color="grey",      # or "lightgrey"
    linewidth=0.2,
    alpha=0.6
)

# Bezirke boundaries overlay for orientation
bezirke.boundary.plot(
    ax=ax,
    color="black",
    linewidth=1.0,
    alpha=0.9
)

ax.set_axis_off()
plt.tight_layout()

# Save
figpath = OUTPUT_DIR / "maps" /f"map_lor_socialh_{MAP_YEAR}_with_districts.pdf"
plt.savefig(figpath, dpi=300, bbox_inches="tight")
plt.show()

# ============================================================
# 8c. MAP: Absolute change in social-housing units (2010 → 2019)
# ============================================================

lor_sh_change["abs_change"] = lor_sh_change["socialh_change"]
lor_sh_change["abs_val"] = lor_sh_change["abs_change"].abs()

gdf_zero    = lor_sh_change[lor_sh_change["abs_change"] == 0]
gdf_nonzero = lor_sh_change[lor_sh_change["abs_change"] != 0]

fig, ax = plt.subplots(figsize=(10, 9))

# Non-zero polygons (log-scaled Blues)
if not gdf_nonzero.empty:
    vmax = gdf_nonzero["abs_val"].max()
    norm = LogNorm(vmin=1, vmax=vmax)

    gdf_nonzero.plot(
        column="abs_val",
        cmap="Blues",
        norm=norm,
        linewidth=0.25,
        edgecolor="grey",
        ax=ax,
        legend=False
    )
else:
    norm = None
    vmax = 1

# Zero-change polygons in grey
if not gdf_zero.empty:
    gdf_zero.plot(
        color="lightgrey",
        linewidth=0.25,
        edgecolor="grey",
        ax=ax
    )

# --- A100 Autobahn ring overlay ---
a100_gdf.boundary.plot(
    ax=ax,
    color="black",
    linewidth=1.8,
    alpha=0.9,
    zorder=10
)

# ------------------------------------------------------------
# Legend elements
# ------------------------------------------------------------

zero_patch = mpatches.Patch(color="lightgrey", label="No change (Δ = 0)")
a100_line = Line2D([0], [0], color="black", lw=1.5, label="A100 (Autobahn ring)")

legend_handles = [zero_patch, a100_line]

leg = ax.legend(
    handles=legend_handles,
    loc="lower left",
    framealpha=0.9
)

for txt in leg.get_texts():
    txt.set_fontsize(15)

# ------------------------------------------------------------
# Colour bar
# ------------------------------------------------------------

if norm is not None:
    sm = cm.ScalarMappable(norm=norm, cmap="Blues")
    sm._A = []
    cbar = fig.colorbar(sm, ax=ax, fraction=0.03, pad=0.02)

    ticks = [1, 10, 100, 1000]
    if vmax > 1000:
        ticks.append(int(vmax))

    cbar.set_ticks(ticks)
    cbar.set_ticklabels([f"{t:,}" for t in ticks])
    cbar.set_label("|Δ social housing units|  (log scale)", fontsize=16, labelpad=12)
    cbar.ax.tick_params(labelsize=14)

# Title
#ax.set_title(
#    "Change in Social-Housing Units by LOR (2010 → 2019)",
#    fontsize=18,
#    fontweight="bold",
#    pad=16
#)

ax.axis("off")
plt.tight_layout()

# Save
figpath = OUTPUT_DIR / "maps" / "map_socialh_change_2010_2019_with_A100.png"
plt.savefig(figpath, dpi=300, bbox_inches="tight")
plt.show()

print("Saved social housing change map with A100 legend to:", figpath)