import numpy as np
import matplotlib.pyplot as plt

# ======================================================
# 1. Parameters
# ======================================================
params = {
    # Housing and populations
    "H": 1.0,          # total housing stock in A (normalize to 1)
    "pi_E": 1.5,       # mass of eligibles
    "pi_N": 1.0,       # mass of non-eligibles

    # Preferences
    "alpha_1": 1.0,    # weight on composition θ
    "alpha_2": 1.0,    # weight on quality q_M
    "sigma": 0.3,      # logit scale
    "A_O": 0.0,        # amenity outside A
    "r_O": 0.0,        # rent outside A (normalization)
    "r_S": 0.2,        # social rent in A

    # Quality
    "q_M0": 1.0,       # quality of pre-existing market units
    "q_S": 0.3,        # (market) quality of social units
    "q_conv": 1.5,     # quality of converted social units after renovation

    # Baseline social share
    "s0": 0.35         # old equilibrium s
}

# ======================================================
# 2. Core equilibrium functions in A
# ======================================================

def P_A(s, p):
    H = p["H"]
    pi_E = p["pi_E"]
    pi_N = p["pi_N"]
    return (1 - s) * H / (pi_E + pi_N - s * H)

def theta_A(s, p):
    H = p["H"]
    pi_N = p["pi_N"]
    return (pi_N / H) * P_A(s, p)

def psi_A(s, p):
    H = p["H"]
    pi_E = p["pi_E"]
    pi_N = p["pi_N"]
    A_O = p["A_O"]
    r_O = p["r_O"]
    sigma = p["sigma"]

    numer = (1 - s) * H
    denom = pi_E + pi_N - H
    return -(A_O - r_O) - sigma * np.log(numer / denom)

def qM_mix(s, p, q_conv=None):
    """
    Average market quality q_M(s) under a simple conversion + renovation story.
    """
    H = p["H"]
    s0 = p["s0"]
    q_M0 = p["q_M0"]

    if q_conv is None:
        q_conv = p["q_conv"]

    if s >= s0:
        return q_M0

    H_M0 = (1 - s0) * H
    H_Ms = (1 - s) * H
    H_conv = H_Ms - H_M0  # = (s0 - s)*H

    numer = H_M0 * q_M0 + H_conv * q_conv
    return numer / H_Ms

def r_A(s, p):
    theta  = theta_A(s, p)
    q_M    = qM_mix(s, p)
    psi    = psi_A(s, p)
    alpha1 = p["alpha_1"]
    alpha2 = p["alpha_2"]
    return alpha1 * theta + alpha2 * q_M + psi

def avg_r_A(s, p):
    rA = r_A(s, p)
    rS = p["r_S"]
    return (1 - s) * rA + s * rS

# ======================================================
# 3. Demand and supply curves
# ======================================================

def demand_A(r, s, p, theta=None, qM=None):
    H      = p["H"]
    pi_E   = p["pi_E"]
    pi_N   = p["pi_N"]
    alpha1 = p["alpha_1"]
    alpha2 = p["alpha_2"]
    A_O    = p["A_O"]
    r_O    = p["r_O"]
    sigma  = p["sigma"]

    if theta is None:
        theta = theta_A(s, p)
    if qM is None:
        qM = qM_mix(s, p)

    DeltaV = (alpha1 * theta + alpha2 * qM - r - (A_O - r_O)) / sigma
    P_Ar   = 1 / (1 + np.exp(-DeltaV))

    mass_eff = pi_E - s * H + pi_N
    return mass_eff * P_Ar

def supply_Q(s, p):
    return (1 - s) * p["H"]

# ======================================================
# 4. Equilibria at s0 and s1
# ======================================================

s0 = params["s0"]   # old equilibrium
s1 = 0.10           # new equilibrium: drop in social housing

# OLD equilibrium
theta0 = theta_A(s0, params)
qM0    = qM_mix(s0, params)
r0     = r_A(s0, params)
P0     = P_A(s0, params)
Qs0    = supply_Q(s0, params)
avg_r0 = avg_r_A(s0, params)

eq0 = {
    "s": s0,
    "theta": theta0,
    "q_M": qM0,
    "r_A": r0,
    "P_A": P0,
    "Q_S": Qs0,
    "avg_r": avg_r0
}

# NEW equilibrium
theta1 = theta_A(s1, params)
qM1    = qM_mix(s1, params)
r1     = r_A(s1, params)
P1     = P_A(s1, params)
Qs1    = supply_Q(s1, params)
avg_r1 = avg_r_A(s1, params)

eq1 = {
    "s": s1,
    "theta": theta1,
    "q_M": qM1,
    "r_A": r1,
    "P_A": P1,
    "Q_S": Qs1,
    "avg_r": avg_r1
}

print("OLD equilibrium (s0):", eq0)
print("NEW equilibrium (s1):", eq1)

# ======================================================
# 5. Supply–demand diagram with A, B, C
# ======================================================

r_min = min(r0, r1) - 0.5
r_max = max(r0, r1) + 0.5
r_grid = np.linspace(r_min, r_max, 400)

Qd0 = np.array([demand_A(r, s0, params, theta=theta0, qM=qM0) for r in r_grid])
Qd1 = np.array([demand_A(r, s1, params, theta=theta1, qM=qM1) for r in r_grid])

fig, ax = plt.subplots(figsize=(8, 6))

ax.plot(Qd0, r_grid, label="Demand s0")
ax.plot(Qd1, r_grid, label="Demand s1", linestyle="--")

ax.axvline(Qs0, label=f"Supply, s = {s0}")
ax.axvline(Qs1, label=f"Supply, s = {s1}", linestyle="--")

# equilibria A, B
ax.scatter([Qs0], [r0], color="black")
ax.text(Qs0, r0, "  A", va="center", ha="left")

ax.scatter([Qs1], [r1], color="black")
ax.text(Qs1, r1, "  B", va="center", ha="left")

# point C: OLD demand with NEW supply
r_C = np.interp(Qs1, Qd0[::-1], r_grid[::-1])
ax.scatter([Qs1], [r_C], color="red")
ax.text(Qs1, r_C, "  C", va="center", ha="left", color="red")

# horizontal guides
ax.hlines(r0, xmin=0, xmax=Qs0, color="black", linestyle="--", alpha=0.6)
ax.text(-0.01, r0, " A", va="center", ha="right")

ax.hlines(r1, xmin=0, xmax=Qs1, color="black", linestyle="--", alpha=0.6)
ax.text(-0.01, r1, " B", va="center", ha="right")

ax.hlines(r_C, xmin=0, xmax=Qs1, color="red", linestyle="--", alpha=0.6)
ax.text(-0.01, r_C, " C", va="center", ha="right", color="red")

# clean axes
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_position(("data", 0))
ax.yaxis.set_ticks_position("left")
ax.xaxis.set_ticks_position("bottom")

ax.annotate("Quantity of private housing",
            xy=(0.65, -.08), xycoords="axes fraction",
            va="center", ha="left", fontsize=12)

ax.annotate("Rent r",
            xy=(-0.01, 0.95), xycoords="axes fraction",
            va="bottom", ha="center", fontsize=12)

ax.legend()
plt.tight_layout()
plt.show()

# ======================================================
# 6. Sorting block parameters θ_r, θ_q and κ
# ======================================================

def sorting_block_params(s, p):
    """
    Compute φ(s), θ_r(s), θ_q(s) from the linearized sorting block:
      φ   = (π_N/H) * P(A)(1-P(A)) / σ
      θ_r = - φ / (1 - α_1 φ)
      θ_q = α_2 φ / (1 - α_1 φ)
    """
    H      = p["H"]
    pi_N   = p["pi_N"]
    sigma  = p["sigma"]
    alpha1 = p["alpha_1"]
    alpha2 = p["alpha_2"]

    P = P_A(s, p)
    phi = (pi_N / H) * (P * (1 - P)) / sigma

    theta_r = -phi / (1 - alpha1 * phi)
    theta_q =  alpha2 * phi / (1 - alpha1 * phi)

    return phi, theta_r, theta_q

def kappa_numeric(s, p, h=1e-4):
    """
    Numerical derivative of q̄_M(s) with respect to s:
      κ(s) ≈ [ q̄_M(s + h) - q̄_M(s - h) ] / (2h)
    """
    return (qM_mix(s + h, p) - qM_mix(s - h, p)) / (2 * h)

def psi_s_numeric(s, p, h=1e-4):
    """
    Numerical derivative ψ_s(s) = dψ/ds.
    """
    return (psi_A(s + h, p) - psi_A(s - h, p)) / (2 * h)

for s_label, s_val in [("s0", s0), ("s1", s1)]:
    phi, theta_r, theta_q = sorting_block_params(s_val, params)
    kappa_val = kappa_numeric(s_val, params)
    print(f"\nSorting / quality parameters at {s_label} = {s_val}:")
    print(f"  φ({s_label})       = {phi:.4f}")
    print(f"  θ_r({s_label})     = {theta_r:.4f}")
    print(f"  θ_q({s_label})     = {theta_q:.4f}")
    print(f"  κ({s_label})       = {kappa_val:.4f}")


# ======================================================
# 9. Market-rent decomposition using
#    dr_A/ds = 1/(1-α1 θ_r) [ ψ_s + α2 κ + α1 θ_q κ ]
#    and stacked bar between A and B at Qs1
# ======================================================

# True change in MARKET rent from s0 → s1
delta_r_true = r1 - r0
Delta_s = s1 - s0   # < 0

alpha_1 = params["alpha_1"]
alpha_2 = params["alpha_2"]

def drA_components_at_s(s, p):
    """
    Compute marginal components of dr_A/ds at a given s:
      dr_A/ds = 1/(1 - α1 θ_r) [ ψ_s + α2 κ + α1 θ_q κ ]
    and return the three pieces:
      supply_marg      = 1/(1 - α1 θ_r) * ψ_s
      renov_marg       = 1/(1 - α1 θ_r) * α2 κ
      composition_marg = 1/(1 - α1 θ_r) * α1 θ_q κ
    """
    _, theta_r, theta_q = sorting_block_params(s, p)
    kappa_val = kappa_numeric(s, p)
    psi_s_val = psi_s_numeric(s, p)

    prefactor_m = 1.0 / (1.0 - alpha_1 * theta_r)

    supply_marg      = prefactor_m * psi_s_val
    renov_marg       = prefactor_m * alpha_2 * kappa_val
    composition_marg = prefactor_m * alpha_1 * theta_q * kappa_val

    return supply_marg, renov_marg, composition_marg

# ---- Path-integration of dr_A/ds from s0 to s1 ---- #

N_steps = 400  # finer grid → better approximation
s_grid = np.linspace(s0, s1, N_steps + 1)
ds = s_grid[1] - s_grid[0]
s_mid = 0.5 * (s_grid[:-1] + s_grid[1:])  # midpoints

supply_dr      = 0.0
renov_dr       = 0.0
composition_dr = 0.0

for s_val in s_mid:
    sm, rm, cm = drA_components_at_s(s_val, params)
    supply_dr      += sm * ds
    renov_dr       += rm * ds
    composition_dr += cm * ds

delta_r_approx = supply_dr + renov_dr + composition_dr

print("\nMarket rent decomposition via PATH-INTEGRATED structural formula:")
print(f"  True Δr_A          = {delta_r_true:.6f}")
print(f"  Approx Δr_A (sum)  = {delta_r_approx:.6f}")
print(f"    Supply (ψ_s)     = {supply_dr:.6f}")
print(f"    Renovation (α2κ) = {renov_dr:.6f}")
print(f"    Composition      = {composition_dr:.6f}")
print(f"    Residual         = {delta_r_true - delta_r_approx:.6f}")

# -------- Supply–demand figure with geometric stacked bar (A→C, C→B) -------- #

fig4, ax4 = plt.subplots(figsize=(8, 6))

# ---- Color definitions ----
col_s0        = "tab:gray"   # baseline curves
col_s1        = "#4C72B0"    # emidblue-style mid blue for s1 (Stata s2 vibe)
col_supply    = "#8B0000"    # maroon (s2-like)
col_renov     = "#001A57"    # navy
col_comp      = "#228B22"    # forest green

# Demand and supply curves
ax4.plot(Qd0, r_grid, color=col_s0, 
         # label="Demand (s0)", 
         zorder=1)

ax4.axvline(Qs0, color=col_s0, 
            # label="Supply (s0)", 
            zorder=1)

ax4.plot(Qd1, r_grid, color=col_s1, linestyle="--", 
         #label="Demand (s1)", 
         zorder=1)
ax4.axvline(Qs1, color=col_s1, linestyle="--", 
            # label="Supply (s1)", 
            zorder=1)

# Points A, C, B with HIGH zorder
# --- A ---
ax4.scatter([Qs0], [r0], color="black", s=40, zorder=10)
ax4.text(Qs0+0.02, r0+0.015, "A",
         va="center", ha="left",
         fontsize=14, fontweight="bold",
         zorder=11)

# --- B ---
ax4.scatter([Qs1], [r1], color="black", s=40, zorder=10)
ax4.text(Qs1+0.02, r1+0.015, "B",
         va="center", ha="left",
         fontsize=14, fontweight="bold",
         zorder=11)

# --- C ---
ax4.scatter([Qs1], [r_C], color="black", s=40, zorder=10)
ax4.text(Qs1+0.02, r_C-0.015, "C",
         va="center", ha="left",
         fontsize=14, fontweight="bold",
         zorder=11)

# Inline labels for curves (D0, S0, D1, S1)
mid_idx0 = len(r_grid) // 3
mid_idx1 = len(r_grid) // 2

# D0 on old demand
ax4.text(Qd0[mid_idx0]+0.2, r_grid[mid_idx0]-0.11, r"$D_0$",
         color=col_s0,
         va="bottom", ha="left",
         fontsize=17,
         zorder=5)

# D1 on new demand
ax4.text(Qd1[mid_idx1]+0.5, r_grid[mid_idx1]-0.25, r"$D_1$",
         color=col_s1,
         va="bottom", ha="left",
         fontsize=17,
         zorder=5)


# S0 on old supply
# OLD Y shifter (r_min + r_max) / 2
ax4.text(Qs0 - 0.01, 2, r"$S_0$",
         color=col_s0,
         va="center", 
         ha="right",
         fontsize=17,
         zorder=5)

# S1 on new supply
# OLD y shifter (r_min + r_max) / 2
ax4.text(Qs1 - 0.01, 2, r"$S_1$",
         color=col_s1,
         va="center", 
         ha="right",
         fontsize=17,
         zorder=5)

# Horizontal guides
ax4.hlines(r0, xmin=0,   xmax=Qs1, color="black", linestyle="--", alpha=0.6, zorder=0)
ax4.hlines(r_C, xmin=0,  xmax=Qs1, color="black", linestyle="--", alpha=0.6, zorder=0)
ax4.hlines(r1, xmin=0,   xmax=Qs1, color="black", linestyle="--", alpha=0.6, zorder=0)

# Custom axis labels (these stay even when ticks are off)
ax4.text(-0.01, r0,  r"$r_0$", va="center", ha="right", fontsize=15)
ax4.text(-0.01, r1,  r"$r_1$", va="center", ha="right", fontsize=15)
ax4.text(-0.01, r_C, r"$r_C$", va="center", ha="right", fontsize=15)

# ---------- Geometric decomposition of A→B into supply (A→C) and quality/sorting (C→B) ----------

# Pure geometric movements
supply_geo      = r_C - r0           # A → C (typically negative)
quality_geo_tot = r1 - r_C           # C → B (positive)

# Use structural pieces ONLY to split C→B into renovation vs composition
quality_struct = renov_dr + composition_dr
if quality_struct != 0:
    share_renov = renov_dr / quality_struct
    share_comp  = composition_dr / quality_struct
else:
    share_renov = 0.5
    share_comp  = 0.5

renov_geo = share_renov * quality_geo_tot
comp_geo  = share_comp  * quality_geo_tot

# --- Bars overlaid at Qs1 ---
bar_x  = Qs1
bar_w  = 0.03
x_label_offset = 0.05   # horizontal offset for text labels

# 1) Supply part: A → C (maroon), from r_C up to r0
ax4.bar(bar_x-0.015,
        r0 - r_C,
        width=bar_w,
        bottom=r_C,
        color=col_supply,
        alpha=1,
        zorder=6,
        label="Demand")

# Label for supply bar
ax4.text(bar_x - x_label_offset,
         r_C + (r0 - r_C)/2,
         r"$\psi_s$",
         va="center", ha="right",
         fontsize=17, 
         color=col_supply,
         zorder=7)

# 2) Renovation part (navy)
height_renov = renov_geo
ax4.bar(bar_x+0.015,
        height_renov,
        width=bar_w,
        bottom=r_C,
        color=col_renov,
        alpha=1,
        zorder=7)

# Label for renovation bar
ax4.text(bar_x + x_label_offset,
         r_C + height_renov/2,
         r"$\alpha_2 \kappa$",
         va="center", ha="left",
         fontsize=17, color=col_renov,
         zorder=8)

# 3) Composition part (green)
height_comp = comp_geo
ax4.bar(bar_x+0.015,
        height_comp,
        width=bar_w,
        bottom=r_C + height_renov,
        color=col_comp,
        alpha=1,
        zorder=8)

# Label for composition bar
ax4.text(bar_x + x_label_offset,
         r_C + height_renov + height_comp/2,
         r"$\alpha_1 \theta_q \kappa$",
         va="center", ha="left",
         fontsize=17, 
         color=col_comp,
         zorder=9)

# Clean axes
ax4.spines["top"].set_visible(False)
ax4.spines["right"].set_visible(False)
ax4.spines["left"].set_position(("data", 0))
ax4.yaxis.set_ticks_position("left")
ax4.xaxis.set_ticks_position("bottom")

ax4.annotate("Quantity of private housing",
             xy=(0.56, -.03), xycoords="axes fraction",
             va="center", ha="left", fontsize=16)

ax4.annotate("Rent r",
             xy=(-0.06, 0.95), xycoords="axes fraction",
             va="bottom", ha="center", fontsize=16)


# No axis ticks / labels
ax4.set_xticks([])
ax4.set_xticklabels([])
ax4.set_yticks([])
ax4.set_yticklabels([])

# >>> INSERT LIMITS HERE <<<
ax4.set_xlim(left=0)              # x-axis starts at zero
ax4.set_ylim(bottom=r_min, top=r_max)   # y-axis constrained to plotted range
# Optional padding:
# ax4.set_ylim(bottom=r_min - 0.05, top=r_max + 0.05)

# No legend
ax4.legend().remove()

plt.tight_layout()


# Avoid duplicate legend entries
# handles, labels_leg = ax4.get_legend_handles_labels() # Get all existing legend items
# unique = dict(zip(labels_leg, handles)) # Remove duplicates
# ax4.legend(unique.values(), unique.keys(), loc="best")

plt.tight_layout()

# --- Save ---
plt.savefig("/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/output/graphs/market_rent_decomposition.png", dpi=300, bbox_inches="tight")


plt.show()