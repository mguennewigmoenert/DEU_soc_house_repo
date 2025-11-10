from pathlib import Path
import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LogNorm
import matplotlib.cm as cm
from matplotlib.ticker import FixedLocator, FixedFormatter

# ── 1)  FOLDERS ------------------------------------------------------------
BASE      = (Path.home() / "Library" / "CloudStorage" / "Dropbox" /
             "Projects" / "DEU Housing Project")
RAW_DIR   = BASE / "data" / "raw"
TEMP_DIR  = BASE / "data" / "temp"
OUT_DIR   = Path("/Users/maxmonert/Desktop/Research/Projects/SocialHousing/output")
OUT_DIR.mkdir(parents=True, exist_ok=True)          # make sure it exists

# ── 2)  READ DATA ----------------------------------------------------------
lor_gdf  = gpd.read_file(RAW_DIR / "lor_planungsraeume_2021.shp")[["PLR_ID", "geometry"]]
social   = pd.read_stata(TEMP_DIR / "socialhousing_analysis.dta")

# ── 3)  BUILD CHANGE TABLE -------------------------------------------------
wide = (
    social.loc[social["jahr"].isin([2010, 2019]), ["PLR_ID", "jahr", "socialh"]]
          .pivot(index="PLR_ID", columns="jahr", values="socialh")
          .rename(columns={2010: "u2010", 2019: "u2019"})
          .assign(abs_change=lambda d: d["u2019"] - d["u2010"],
                  abs_val   =lambda d: d["abs_change"].abs())
          .reset_index()
)

lor_change  = lor_gdf.merge(wide, on="PLR_ID", how="left")
gdf_zero    = lor_change[lor_change["abs_change"] == 0]
gdf_nonzero = lor_change[lor_change["abs_change"] != 0]

# ── 4)  PLOT ---------------------------------------------------------------
fig, ax = plt.subplots(figsize=(10, 9))

# non-zero polygons (log-scaled Blues)
if not gdf_nonzero.empty:
    vmax = gdf_nonzero["abs_val"].max()
    norm = LogNorm(vmin=1, vmax=vmax)
    gdf_nonzero.plot(
        column="abs_val", cmap="Blues", norm=norm,
        linewidth=0.25, edgecolor="grey",
        ax=ax, legend=False
    )

# zero-change polygons in grey
if not gdf_zero.empty:
    gdf_zero.plot(color="lightgrey", linewidth=0.25,
                  edgecolor="grey", ax=ax)

# colour-bar with custom ticks
sm   = cm.ScalarMappable(norm=norm, cmap="Blues"); sm._A = []
cbar = fig.colorbar(sm, ax=ax, fraction=0.03, pad=0.02)
ticks = [1, 10, 100, 1000] + ([int(vmax)] if vmax > 1000 else [])
cbar.set_ticks(ticks)
cbar.set_ticklabels([f"{t:,}" for t in ticks])
cbar.set_label("|Δ units|  (log scale)",
               fontsize=16, labelpad=12)
cbar.ax.tick_params(labelsize=14)       # tick-label font

# grey legend patch (larger font)
legend_patch = mpatches.Patch(color="lightgrey", label="No change (0)")
leg = ax.legend(handles=[legend_patch],
                loc="lower left", framealpha=0.9)
for txt in leg.get_texts():
    txt.set_fontsize(14)

# title (large, bold)
ax.set_title("Change in Social-Housing Units by PLR  (2010 → 2019)",
             fontsize=18, fontweight="bold", pad=16)

ax.axis("off")
plt.tight_layout()

# save
out_file = OUT_DIR / "socialhousing_change_2010_2019.png"
fig.savefig(out_file, dpi=300, bbox_inches="tight")
print("Map saved to:", out_file)

plt.show()
# ── 5)  SAVE ---------------------------------------------------------------
out_file = OUT_DIR / "socialhousing_change_2010_2019.png"
fig.savefig(out_file, dpi=300, bbox_inches="tight")
print("Map saved to:", out_file)

plt.show()

from matplotlib.colors import TwoSlopeNorm

# ── 6)  SHARE-OF-SOCIAL HOUSING -------------------------------------------
# a) build wide table for socialh and total housing (wohnungen)
sub2 = social.loc[social["jahr"].isin([2010, 2019]),
                  ["PLR_ID", "jahr", "socialh", "wohnungen"]]

wide2 = (
    sub2.pivot(index="PLR_ID", columns="jahr")
        .swaplevel(axis=1)                         # columns → ('jahr', var)
)

# extract columns and compute shares
share2010 = wide2[2010]["socialh"] / wide2[2010]["wohnungen"]
share2019 = wide2[2019]["socialh"] / wide2[2019]["wohnungen"]

share_df = (
    pd.DataFrame({
        "PLR_ID"      : share2010.index,
        "share_2010"  : share2010,
        "share_2019"  : share2019,
        "share_change": share2019 - share2010     # Δ in share (percentage points if *100)
    })
)

# ensure PLR_ID is NOT an index level in either table
lor_gdf   = lor_gdf.reset_index(drop=True)      # just in case
share_df  = share_df.reset_index(drop=True)     # removes index name & keeps column

# merge with geometry
lor_share = lor_gdf.merge(share_df, on="PLR_ID", how="left")

# ── keep only drops and take absolute value ─────────────────────────
lor_share["drop_mag"] = (
    lor_share["share_change"]
    .where(lor_share["share_change"] < 0, np.nan)   # keep only negatives
    .abs()                                          # magnitude of the drop
)

drop_zero    = lor_share[lor_share["drop_mag"].isna()]       # no drop (NaN)
drop_nonzero = lor_share[lor_share["drop_mag"].notna()]

# ── 7)  PLOT absolute %-point drop (log-coloured Blues) ──────────────────
fig2, ax2 = plt.subplots(figsize=(10, 9))

# drop magnitude in percentage-points
lor_share["drop_pct"] = lor_share["drop_mag"] * 100          # NaN → no drop
drop_nonzero = lor_share[lor_share["drop_pct"].notna()]
drop_zero    = lor_share[lor_share["drop_pct"].isna()]

if not drop_nonzero.empty:
    vmax   = drop_nonzero["drop_pct"].max()
    norm_d = LogNorm(vmin=1, vmax=vmax)                      # 1 pp min colour
    drop_nonzero.plot(column="drop_pct", cmap="Blues", norm=norm_d,
                      linewidth=0.25, edgecolor="grey", ax=ax2, legend=False)

if not drop_zero.empty:
    drop_zero.plot(color="lightgrey", linewidth=0.25,
                   edgecolor="grey", ax=ax2)

# colour-bar with custom ticks
sm_d  = cm.ScalarMappable(norm=norm_d, cmap="Blues"); sm_d._A = []
cbar2 = fig2.colorbar(sm_d, ax=ax2, fraction=0.03, pad=0.02)
ticks = [1, 10, 30, 60, 120]
ticks = [t for t in ticks if t <= vmax]          # keep ticks ≤ max
cbar2.set_ticks(ticks)
cbar2.set_ticklabels([f"{t:.0f}" for t in ticks])
cbar2.set_label("Drop in share (percentage-points)",
                fontsize=16, labelpad=14, rotation=90)
cbar2.ax.tick_params(labelsize=14)

# legend (grey patch) – bigger font
legend_patch = mpatches.Patch(color="lightgrey", label="No drop (0)")
leg2 = ax2.legend(handles=[legend_patch], loc="lower left",
                  framealpha=0.9)
for txt in leg2.get_texts():
    txt.set_fontsize(14)

# title – larger, bold
ax2.set_title("Drop in Social-Housing Share by PLR  (2010 → 2019)",
              fontsize=18, fontweight="bold", pad=16)

ax2.axis("off")
plt.tight_layout()

# ── 8)  SAVE ─────────────────────────────────────────────────────────────
share_file = OUT_DIR / "share_drop_socialhousing_2010_2019.png"
fig2.savefig(share_file, dpi=300, bbox_inches="tight")
print("Share-drop map saved to:", share_file)

plt.show()