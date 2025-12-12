import numpy as np
import matplotlib.pyplot as plt

# ======================================================
# 1. PARAMETERS
# ======================================================

params = {
    # Housing and populations
    "H": 1.0,          # total housing stock in C (normalize to 1)
    "pi_E": 1.5,       # mass of eligibles
    "pi_N": 1.0,       # mass of non-eligibles

    # Preferences
    "alpha_1": 1.0,    # weight on composition θ in amenity
    "alpha_2": 1.0,    # weight on average quality \bar q in amenity
    "sigma": 0.3,      # logit scale
    "A_O": 0.0,        # amenity in outside region O (P in theory)
    "r_O": 0.0,        # rent in O (can be normalized or chosen)

    # Social housing (only enters via s and avg rent, not in logit)
    "r_S": 0.2,        # social rent in C (fixed)

    # Incomes (used only for expenditure shares)
    "y_E": 2.0,        # income of eligibles
    "y_N": 4.0,        # income of non-eligibles

    # Quality
    "q_M0": 1.0,       # quality of pre-existing market units
    "q_S": 0.3,        # quality of social units
    "q_conv": 1.5,     # quality of converted social units after renovation

    # Baseline social share
    "s0": 0.5          # initial social share
}

# ======================================================
# 2. BASIC MASS / PROBABILITY OBJECTS IN C
# ======================================================

def residual_eligibles(s, p):
    """
    Residual eligibles who compete for market units (after social units are filled).
    """
    H    = p["H"]
    pi_E = p["pi_E"]
    return pi_E - s * H

def market_capacity(s, p):
    """
    Total number of market units in C.
    """
    return (1.0 - s) * p["H"]

def effective_market_population(s, p):
    """
    Total mass of households who can rent in the private market in C:
    residual eligibles + non-eligibles.
    """
    return residual_eligibles(s, p) + p["pi_N"]

def P_C(s, p):
    """
    Equilibrium *logit* probability of choosing C among agents
    who are in the private market, implied by market clearing:

      D_C(r_C) = (π_E - sH + π_N) P(C) = (1-s)H = Q(s).

    This gives:
      P*(s) = Q(s) / (π_E - sH + π_N).
    """
    Qs       = market_capacity(s, p)
    mass_eff = effective_market_population(s, p)
    return Qs / mass_eff

def theta_C(s, p):
    """
    Composition: share of non-eligibles among *all* units in C.
      n_N,C = π_N * P(C)
      θ = n_N,C / H = (π_N / H) * P(C).
    """
    H    = p["H"]
    pi_N = p["pi_N"]
    return (pi_N / H) * P_C(s, p)


# ======================================================
# 3. QUALITY BLOCK: q̄_M(s) AND TOTAL AVERAGE q̄(s)
# ======================================================

def qM_mix(s, p, q_conv=None):
    """
    Average market quality q̄_M(s) under a simple conversion + renovation story.

    For s >= s0: no conversion, all market units are original quality q_M0.
    For s < s0 : convert (s0 - s)H units from social to market with higher quality q_conv.
    """
    H   = p["H"]
    s0  = p["s0"]
    q0  = p["q_M0"]

    if q_conv is None:
        q_conv = p["q_conv"]

    if s >= s0:
        # No conversion: market stock is the original set
        return q0

    # If social share falls below s0, convert social to high-quality market units
    H_M0   = (1.0 - s0) * H          # initial market units
    H_Ms   = (1.0 - s) * H           # new market units
    H_conv = H_Ms - H_M0             # converted units = (s0 - s)H

    numer = H_M0 * q0 + H_conv * q_conv
    return numer / H_Ms

def qbar_total(s, p):
    """
    Total average quality in C:
      \bar q(s) = (1-s) \bar q_M(s) + s q_S.
    """
    qM = qM_mix(s, p)
    qS = p["q_S"]
    return (1.0 - s) * qM + s * qS


# ======================================================
# 4. LOGIT + MARKET CLEARING → r_C(s)
# ======================================================

def logit_index_star(s, p):
    """
    ΔV*(s) = logit index consistent with market clearing and logit choice.

    From logit:
        P(C) = 1 / [1 + exp(-ΔV)]
      ⇒ ΔV = log( P / (1-P) ).

    From market clearing:
        P*(s) = Q(s) / (π_E - sH + π_N).

    Combining, we get:
        ΔV*(s) = log( P*(s) / (1 - P*(s)) ).
    """
    P = P_C(s, p)
    odds = P / (1.0 - P)
    return np.log(odds)

def psi_C(s, p):
    """
    Policy / outside-option term ψ(s) coming purely from:

      ΔV = (A_C - r_C - (A_O - r_O)) / σ.

    Rearranging:
      r_C = A_C - (A_O - r_O) - σ ΔV.

    Writing r_C = α1 θ + α2 \bar q + ψ(s),
      ψ(s) = - (A_O - r_O) - σ ΔV*(s).

    This function returns ψ(s). Dependence on θ and \bar q is separated out.
    """
    A_O  = p["A_O"]
    r_O  = p["r_O"]
    sig  = p["sigma"]
    dV   = logit_index_star(s, p)
    return -(A_O - r_O) - sig * dV

def r_C(s, p):
    """
    Equilibrium *market rent* in C:

      r_C(s) = α1 θ*(s) + α2 \bar q(s) + ψ(s),

    where θ*(s) is composition implied by P*(s),
    and \bar q(s) is the total average quality.
    """
    alpha1 = p["alpha_1"]
    alpha2 = p["alpha_2"]

    theta = theta_C(s, p)
    qbar  = qbar_total(s, p)
    psi   = psi_C(s, p)

    return alpha1 * theta + alpha2 * qbar + psi

def avg_r_C(s, p):
    """
    Average rent in region C, mixing social and market units:

      r̄(s) = (1-s) r_C(s) + s r_S.
    """
    rM = r_C(s, p)
    rS = p["r_S"]
    return (1.0 - s) * rM + s * rS


# ======================================================
# 5. DEMAND CURVES (FOR FIGURES)
# ======================================================

def demand_C(r, s, p, theta=None, qbar=None):
    """
    Market demand in C as a function of price r, holding θ and \bar q fixed.

    Logit utilities (for residual eligibles and non-eligibles competing for market units):

      ΔV(r) = [α1 θ + α2 \bar q - r - (A_O - r_O)] / σ

      P(C | r) = 1 / (1 + exp(-ΔV(r))).

      D_C(r) = (π_E - sH + π_N) * P(C | r).
    """
    pi_E   = p["pi_E"]
    pi_N   = p["pi_N"]
    alpha1 = p["alpha_1"]
    alpha2 = p["alpha_2"]
    A_P    = p["A_O"]
    r_P    = p["r_O"]
    sigma  = p["sigma"]

    if theta is None:
        theta = theta_C(s, p)
    if qbar is None:
        qbar = qbar_total(s, p)

    DeltaV = (alpha1 * theta + alpha2 * qbar - r - (A_P - r_P)) / sigma
    P_Cr   = 1.0 / (1.0 + np.exp(-DeltaV))

    mass_eff = residual_eligibles(s, p) + pi_N
    return mass_eff * P_Cr

def supply_Q(s, p):
    """
    Market supply of housing: just the number of private units (1-s)H.
    """
    return market_capacity(s, p)


# ======================================================
# 6. EQUILIBRIA AT s0 AND s1
# ======================================================

s0 = params["s0"]   # old equilibrium social share
s1 = 0.25           # new equilibrium: drop in social housing

# ---- OLD equilibrium (s0) ----
theta0 = theta_C(s0, params)
qM0    = qM_mix(s0, params)
qbar0  = qbar_total(s0, params)
r0     = r_C(s0, params)
P0     = P_C(s0, params)
Qs0    = supply_Q(s0, params)
avg_r0 = avg_r_C(s0, params)

eq0 = {
    "s": s0,
    "theta": theta0,
    "q_M": qM0,
    "q_bar": qbar0,
    "r_C": r0,
    "P_C": P0,
    "Q_S": Qs0,
    "avg_r": avg_r0
}

# ---- NEW equilibrium (s1) ----
theta1 = theta_C(s1, params)
qM1    = qM_mix(s1, params)
qbar1  = qbar_total(s1, params)
r1     = r_C(s1, params)
P1     = P_C(s1, params)
Qs1    = supply_Q(s1, params)
avg_r1 = avg_r_C(s1, params)

eq1 = {
    "s": s1,
    "theta": theta1,
    "q_M": qM1,
    "q_bar": qbar1,
    "r_C": r1,
    "P_C": P1,
    "Q_S": Qs1,
    "avg_r": avg_r1
}

print("OLD equilibrium (s0):", eq0)
print("NEW equilibrium (s1):", eq1)


# ======================================================
# 7. SOCIAL OCCUPANCY + EXPENDITURE SHARES
# ======================================================

H    = params["H"]
pi_E = params["pi_E"]
pi_N = params["pi_N"]
r_S  = params["r_S"]
r_O  = params["r_O"]
y_E  = params["y_E"]
y_N  = params["y_N"]

# --- (i) Social housing occupancy in C ---

n_E_CS0 = s0 * H   # all social units filled by eligibles
n_E_CS1 = s1 * H

print("\n--- Social housing occupancy in C ---")
print(f"Old equilibrium (s0 = {s0}): n_E,C_S = {n_E_CS0:.3f}")
print(f"New equilibrium (s1 = {s1}): n_E,C_S = {n_E_CS1:.3f}")

# --- (ii) Location masses by type ---

# OLD
n_E_CM0 = residual_eligibles(s0, params) * P0
n_E_O0  = residual_eligibles(s0, params) * (1.0 - P0)

n_N_CM0 = pi_N * P0
n_N_O0  = pi_N * (1.0 - P0)

# NEW
n_E_CM1 = residual_eligibles(s1, params) * P1
n_E_O1  = residual_eligibles(s1, params) * (1.0 - P1)

n_N_CM1 = pi_N * P1
n_N_O1  = pi_N * (1.0 - P1)

print("\n--- Location masses by type (old vs new) ---")
print(f"Old:  E in C_S = {n_E_CS0:.3f}, E in C_M = {n_E_CM0:.3f}, E in O = {n_E_O0:.3f}")
print(f"      N in C_M = {n_N_CM0:.3f}, N in O   = {n_N_O0:.3f}")
print(f"New:  E in C_S = {n_E_CS1:.3f}, E in C_M = {n_E_CM1:.3f}, E in O = {n_E_O1:.3f}")
print(f"      N in C_M = {n_N_CM1:.3f}, N in O   = {n_N_O1:.3f}")

# --- (iii) Expenditure shares (housing / income) ---

# Old / new market rents
rC0 = r0
rC1 = r1

# Average rent for eligibles in C (mix of social and market)
n_E_C0    = n_E_CS0 + n_E_CM0
n_E_C1    = n_E_CS1 + n_E_CM1
avg_r_EC0 = (n_E_CS0 * r_S + n_E_CM0 * rC0) / n_E_C0
avg_r_EC1 = (n_E_CS1 * r_S + n_E_CM1 * rC1) / n_E_C1

share_EC0 = avg_r_EC0 / y_E
share_EC1 = avg_r_EC1 / y_E
share_NC0 = rC0 / y_N
share_NC1 = rC1 / y_N

# Outside region O (with r_O normalization)
share_EO0 = r_O / y_E
share_EO1 = r_O / y_E
share_NO0 = r_O / y_N
share_NO1 = r_O / y_N

print("\n--- Expenditure shares (housing / income) ---")
print("Conditional on living in C:")
print(f"  Eligibles in C: old = {share_EC0:.3f}, new = {share_EC1:.3f}")
print(f"  Non-eligibles in C: old = {share_NC0:.3f}, new = {share_NC1:.3f}")
print("In O (with r_O normalization):")
print(f"  Eligibles in O: old = {share_EO0:.3f}, new = {share_EO1:.3f}")
print(f"  Non-eligibles in O: old = {share_NO0:.3f}, new = {share_NO1:.3f}")


# ======================================================
# 8. SUPPLY–DEMAND DIAGRAM WITH POINTS A, C, B
# ======================================================

r_min = min(r0, r1) - 0.5
r_max = max(r0, r1) + 0.5
r_grid = np.linspace(r_min, r_max, 400)

Qd0 = np.array([demand_C(r, s0, params, theta=theta0, qbar=qbar0) for r in r_grid])
Qd1 = np.array([demand_C(r, s1, params, theta=theta1, qbar=qbar1) for r in r_grid])

fig, ax = plt.subplots(figsize=(8, 6))

ax.plot(Qd0, r_grid, label="Demand s0")
ax.plot(Qd1, r_grid, label="Demand s1", linestyle="--")

ax.axvline(Qs0, label=f"Supply, s={s0}", linestyle="-")
ax.axvline(Qs1, label=f"Supply, s={s1}", linestyle="--")

# Equilibria A (s0) and C (s1)
ax.scatter([Qs0], [r0], color="black")
ax.text(Qs0, r0, "  A", va="center", ha="left")

ax.scatter([Qs1], [r1], color="black")
ax.text(Qs1, r1, "  C", va="center", ha="left")

# Point B: OLD demand with NEW supply
r_B = np.interp(Qs1, Qd0[::-1], r_grid[::-1])
ax.scatter([Qs1], [r_B], color="red")
ax.text(Qs1, r_B, "  B", va="center", ha="left", color="red")

# Horizontal guides
ax.hlines(r0, xmin=0, xmax=Qs0, color="black", linestyle="--", alpha=0.6)
ax.text(-0.01, r0, " A", va="center", ha="right")

ax.hlines(r1, xmin=0, xmax=Qs1, color="black", linestyle="--", alpha=0.6)
ax.text(-0.01, r1, " B", va="center", ha="right")

ax.hlines(r_B, xmin=0, xmax=Qs1, color="red", linestyle="--", alpha=0.6)
ax.text(-0.01, r_B, " C", va="center", ha="right", color="red")

# Clean axes
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
ax.set_xlim(0, 1.25)
plt.tight_layout()
plt.show()


# ======================================================
# 9. SORTING BLOCK PARAMETERS θ_r, θ_q AND κ (total), ψ_s
# ======================================================

def sorting_block_params(s, p):
    """
    Compute φ(s), θ_r(s), θ_q(s) from the linearized sorting block:

      φ   = (π_N/H) * P(C)(1-P(C)) / σ
      θ_r = - φ / (1 - α_1 φ)
      θ_q =  α_2 φ / (1 - α_1 φ).

    Here θ_q is the response of θ to *total average quality* \bar q.
    """
    H      = p["H"]
    pi_N   = p["pi_N"]
    sigma  = p["sigma"]
    alpha1 = p["alpha_1"]
    alpha2 = p["alpha_2"]

    P   = P_C(s, p)
    phi = (pi_N / H) * (P * (1.0 - P)) / sigma

    theta_r = -phi / (1.0 - alpha1 * phi)
    theta_q =  alpha2 * phi / (1.0 - alpha1 * phi)

    return phi, theta_r, theta_q

def kappa_numeric(s, p, h=1e-4):
    """
    Numerical derivative of total average quality \bar q(s) with respect to s:

      κ_total(s) ≈ [ \bar q(s + h) - \bar q(s - h) ] / (2h).
    """
    return (qbar_total(s + h, p) - qbar_total(s - h, p)) / (2.0 * h)

def kappa_M_numeric(s, p, h=1e-4):
    """
    Numerical derivative of market average quality \bar q_M(s) with respect to s:

      κ_M(s) ≈ [ \bar q_M(s + h) - \bar q_M(s - h) ] / (2h).
    """
    return (qM_mix(s + h, p) - qM_mix(s - h, p)) / (2.0 * h)

def psi_s_numeric(s, p, h=1e-4):
    """
    Numerical derivative ψ_s(s) = dψ/ds (logit/outside term), via finite differences.
    (Kept for reference; decomposition below uses closed-form.)
    """
    return (psi_C(s + h, p) - psi_C(s - h, p)) / (2.0 * h)

def psi_s_decomposed(s, p):
    """
    Closed-form decomposition of ψ_s(s) into:

      ψ_s(s) = σ/(1-s)   - σ * H / (tilde_pi_E + pi_N)
             = ψ_s_supply + ψ_s_demand,

    where:
      ψ_s_supply   = σ/(1-s)               (pure supply: more private units)
      ψ_s_demand   = -σ * H / (tilde_pi_E + pi_N)
                     (extra private demand from displaced eligibles).
    """
    sigma = p["sigma"]
    H     = p["H"]
    pi_E  = p["pi_E"]
    pi_N  = p["pi_N"]

    pi_E_tilde = pi_E - s * H
    mass_eff   = pi_E_tilde + pi_N   # effective private market mass

    psi_supply = sigma / (1.0 - s)
    psi_demand = - sigma * H / mass_eff

    return psi_supply, psi_demand, psi_supply + psi_demand


for s_label, s_val in [("s0", s0), ("s1", s1)]:
    phi, theta_r, theta_q = sorting_block_params(s_val, params)
    kappa_val = kappa_numeric(s_val, params)
    print(f"\nSorting / quality parameters at {s_label} = {s_val}:")
    print(f"  φ({s_label})       = {phi:.4f}")
    print(f"  θ_r({s_label})     = {theta_r:.4f}")
    print(f"  θ_q({s_label})     = {theta_q:.4f}")
    print(f"  κ_total({s_label}) (d q̄/ds) = {kappa_val:.4f}")


# ======================================================
# 10. MARKET-RENT DECOMPOSITION: dr_C/ds WITH ψ SPLIT
# ======================================================

alpha_1 = params["alpha_1"]
alpha_2 = params["alpha_2"]

def drC_components_at_s(s, p):
    """
    Compute marginal components of dr_C/ds at a given s using:

      dr_C/ds = 1/(1 - α1 θ_r) [ ψ_s + α2 κ_total + α1 θ_q κ_total ],

    where:
      κ_total = d\bar q / ds  (total average quality response).

    Decompose ψ_s into:
      ψ_s = ψ_s_supply + ψ_s_demand,

    with:
      ψ_s_supply  = σ/(1-s)                (pure supply)
      ψ_s_demand  = -σ H /(tilde_π_E+π_N)  (displaced eligibles).

    Returns FOUR pieces:
      - supply_marg        : from ψ_s_supply
      - displaced_marg     : from ψ_s_demand
      - renov_marg         : from α2 κ_total
      - composition_marg   : from α1 θ_q κ_total
    """
    _, theta_r, theta_q = sorting_block_params(s, p)
    kappa_total = kappa_numeric(s, p)

    psi_sup, psi_dem, _ = psi_s_decomposed(s, p)

    prefactor = 1.0 / (1.0 - p["alpha_1"] * theta_r)

    supply_marg      = prefactor * psi_sup
    displaced_marg   = prefactor * psi_dem
    renov_marg       = prefactor * p["alpha_2"] * kappa_total
    composition_marg = prefactor * p["alpha_1"] * theta_q * kappa_total

    return supply_marg, displaced_marg, renov_marg, composition_marg


# ---- Path-integration of dr_C/ds from s0 to s1 ---- #

delta_r_true = r1 - r0
delta_r_sup = r_B - r0
N_steps = 400
s_grid = np.linspace(s0, s1, N_steps + 1)
ds = s_grid[1] - s_grid[0]
s_mid = 0.5 * (s_grid[:-1] + s_grid[1:])

supply_dr      = 0.0     # pure supply ψ_s_supply
demand_dr      = 0.0     # displaced eligibles ψ_s_demand
renov_dr       = 0.0     # α2 κ_total
composition_dr = 0.0     # α1 θ_q κ_total

for s_val in s_mid:
    sm_sup, sm_dem, rm, cm = drC_components_at_s(s_val, params)
    supply_dr      += sm_sup * ds
    demand_dr      += sm_dem * ds
    renov_dr       += rm * ds
    composition_dr += cm * ds

delta_r_approx = supply_dr + demand_dr + renov_dr + composition_dr

print("\nMarket rent decomposition via PATH-INTEGRATED structural formula:")
print(f"  True Δr_C                      = {delta_r_true:.6f}")
print(f"  Approx Δr_C (sum of pieces)    = {delta_r_approx:.6f}")

print(f"Supply effect holding Demand constant = {delta_r_sup:.6f}")
      
print("\nComponents:")
print(f"    Pure supply (ψ_s_supply)           = {supply_dr:.6f}")
print(f"    Displaced eligibles (ψ_s_demand)   = {demand_dr:.6f}")
print(f"    Renovation (α2 κ_total)            = {renov_dr:.6f}")
print(f"    Composition (α1 θ_q κ_total)       = {composition_dr:.6f}")

residual = delta_r_true - delta_r_approx
print(f"\n    Residual                           = {residual:.6f}")

# ======================================================
# 11. GEOMETRIC DECOMPOSITION OF Δr_C: A→B VS B→C
# ======================================================

# A -> B: pure supply effect, holding demand fixed at its old shape
delta_r_sup_geo = r_B - r0

# B -> C: total demand-side effect (all demand shifters combined)
delta_r_dem_geo = r1 - r_B

# Structural demand-side contributions (from path-integrated dr_C/ds)
demand_side_struct = demand_dr + renov_dr + composition_dr

if np.isclose(demand_side_struct, 0.0):
    # Avoid division by zero; if demand-side structure is zero, just set all shares to zero
    share_disp = 0.0
    share_qual = 0.0
    share_comp = 0.0
else:
    # Shares of each mechanism in the structural demand-side change
    share_disp = demand_dr      / demand_side_struct
    share_qual = renov_dr       / demand_side_struct
    share_comp = composition_dr / demand_side_struct

# Map structural shares into geometric B -> C segment
disp_geo  = share_disp * delta_r_dem_geo      # geometric displaced-eligibles effect
qual_geo  = share_qual * delta_r_dem_geo      # geometric quality / renovation effect
comp_geo  = share_comp * delta_r_dem_geo      # geometric composition / sorting effect

print("\nGeometric decomposition of Δr_C:")
print(f"  Supply-only (A→B, demand fixed)            = {delta_r_sup_geo:.6f}")
print(f"  Total demand-side (B→C)                    = {delta_r_dem_geo:.6f}")
print("  Split of demand-side (geo, via structural shares):")
print(f"    → displaced eligibles (geo)              = {disp_geo:.6f}")
print(f"    → quality / renovation (geo)             = {qual_geo:.6f}")
print(f"    → composition / sorting (geo)            = {comp_geo:.6f}")


# ======================================================
# FIGURE MAIN (SUPPLY–DEMAND + GEOMETRIC BARS)
# ======================================================
fig4, ax4 = plt.subplots(figsize=(8, 6))

# ---- Color definitions ----
col_s0        = "tab:gray"   # baseline curves
col_s1        = "#4C72B0"    # mid blue for s1
col_supply    = "#8B0000"    # maroon
col_renov     = "#001A57"    # navy
col_comp      = "#228B22"    # forest green
col_disp      = "#E18800"     # Stata s2 orange  (displaced eligibles)

# Demand and supply curves
ax4.plot(Qd0, r_grid, color=col_s0, zorder=1)
ax4.axvline(Qs0, color=col_s0, zorder=1)

ax4.plot(Qd1, r_grid, color=col_s1, linestyle="--", zorder=1)
ax4.axvline(Qs1, color=col_s1, linestyle="--", zorder=1)

# Points A, C, B with HIGH zorder
# --- A ---
ax4.scatter([Qs0], [r0], color="black", s=40, zorder=10)
ax4.text(Qs0+0.02, r0+0.015, "A",
         va="center", ha="left",
         fontsize=14, fontweight="bold",
         zorder=11)

# --- C (new equilibrium) ---
ax4.scatter([Qs1], [r1], color="black", s=40, zorder=10)
ax4.text(Qs1+0.02, r1+0.015, "C",
         va="center", ha="left",
         fontsize=14, fontweight="bold",
         zorder=11)

# --- B (intermediate, old demand with new supply) ---
ax4.scatter([Qs1], [r_B], color="black", s=40, zorder=10)
ax4.text(Qs1+0.02, r_B-0.015, "B",
         va="center", ha="left",
         fontsize=14, fontweight="bold",
         zorder=11)

# Inline labels for curves (D0, S0, D1, S1)
mid_idx0 = len(r_grid) // 3
mid_idx1 = len(r_grid) // 2

# D0 on old demand
ax4.text(1.15, 
         r_grid[mid_idx0]-0.3, r"$D_0$",
         color=col_s0,
         va="bottom", ha="left",
         fontsize=17,
         zorder=5)

# D1 on new demand
ax4.text(1.15, 
         r_grid[mid_idx1]-0.05, 
         r"$D_1$",
         color=col_s1,
         va="bottom", ha="left",
         fontsize=17,
         zorder=5)

# S0 on old supply
ax4.text(Qs0 - 0.01, 2, r"$S_0$",
         color=col_s0,
         va="center", 
         ha="right",
         fontsize=17,
         zorder=5)

# S1 on new supply
ax4.text(Qs1 - 0.01, 2, r"$S_1$",
         color=col_s1,
         va="center", 
         ha="right",
         fontsize=17,
         zorder=5)

# Horizontal guides
ax4.hlines(r0, xmin=0,   xmax=Qs1, color="black", linestyle="--", alpha=0.6, zorder=0)
ax4.hlines(r_B, xmin=0,  xmax=Qs1, color="black", linestyle="--", alpha=0.6, zorder=0)
ax4.hlines(r1, xmin=0,   xmax=Qs1, color="black", linestyle="--", alpha=0.6, zorder=0)

# Custom axis labels (these stay even when ticks are off)
ax4.text(-0.01, r0,  r"$r_{old}$", va="center", ha="right", fontsize=15)
ax4.text(-0.01, r1,  r"$r_{new}$", va="center", ha="right", fontsize=15)
ax4.text(-0.01, r_B, r"$r'$", va="center", ha="right", fontsize=15)

# ---------- Geometric decomposition A→B and B→C ----------

# Total geometric effects
supply_geo = r_B - r0         # A → B (supply only)
disp_geo   = disp_geo         # displaced eligibles (B → C)
renov_geo  = qual_geo         # renovation component (B → C)
comp_geo   = comp_geo         # composition/sorting (B → C)

# Point where bars sit
bar_x = Qs1
bar_w = 0.035
label_off = 0.06

# 1) SUPPLY EFFECT A→B
ax4.bar(bar_x - 0.018,
        height=supply_geo,
        bottom=r0,
        width=bar_w,
        color=col_supply,
        alpha=1,
        zorder=8)

ax4.text(bar_x - label_off,
         r0 + supply_geo/2,
         r"$\text{Supply}$",
         va="center", ha="right",
         fontsize=15,
         color=col_supply)

# 2) DISPLACED ELIGIBLES (DEMAND SHIFT)
ax4.bar(bar_x + 0.018,
        height=disp_geo,
        bottom=r_B,
        width=bar_w,
        color=col_disp,
        alpha=1,
        zorder=8)

ax4.text(bar_x + label_off,
         r_B + disp_geo/2,
         r"$\text{Displaced}$",
         va="center", ha="left",
         fontsize=15,
         color=col_disp)

# 3) RENOVATION
ax4.bar(bar_x + 0.018,
        height=renov_geo,
        bottom=r_B + disp_geo,
        width=bar_w,
        color=col_renov,
        alpha=1,
        zorder=8)

ax4.text(bar_x + label_off,
         r_B + disp_geo + renov_geo/2,
         r"$\text{Renovation}$",
         va="center", ha="left",
         fontsize=15,
         color=col_renov)

# 4) COMPOSITION / SORTING
ax4.bar(bar_x + 0.018,
        height=comp_geo,
        bottom=r_B + disp_geo + renov_geo,
        width=bar_w,
        color=col_comp,
        alpha=1,
        zorder=8)

ax4.text(bar_x + label_off,
         r_B + disp_geo + renov_geo + comp_geo/2,
         r"$\text{Amenities}$",
         va="center", ha="left",
         fontsize=15,
         color=col_comp)

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

ax4.set_xlim(left=0, right=1.25)              
ax4.set_ylim(bottom=r_min, top=2.2)

# No legend
ax4.legend().remove()

plt.tight_layout()

plt.savefig(
    "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/output/graphs/market_rent_decomposition.png",
    dpi=300, bbox_inches="tight"
)

plt.show()


# ======================================================
# 12. NEW FIGURE: d r_C / d s DECOMPOSITION OVER s ∈ (0,1)
# ======================================================

# We implement:
#   dr_C/ds =
#   [ ψ_s^{(supply)} + ψ_s^{(displaced)}
#     + (α2 + α1 θ_q) (q_S - q_M(s))
#     + (α2 + α1 θ_q) (1-s) κ_M(s) ] / (1 - α1 θ_r)
#
# where κ_M = d \bar q_M / ds.

s_grid_dec = np.linspace(0.01, 0.99, 400)  # avoid endpoints where ψ_s_supply blows up

dr_supply_arr   = []
dr_disp_arr     = []
dr_qcomp_arr    = []
dr_renov_arr    = []

for s_val in s_grid_dec:
    _, theta_r, theta_q = sorting_block_params(s_val, params)
    psi_sup, psi_dem, _ = psi_s_decomposed(s_val, params)

    qM_s = qM_mix(s_val, params)
    qS   = params["q_S"]
    kappa_M = kappa_M_numeric(s_val, params)

    denom = 1.0 - params["alpha_1"] * theta_r
    if np.isclose(denom, 0.0):
        dr_supply_arr.append(np.nan)
        dr_disp_arr.append(np.nan)
        dr_qcomp_arr.append(np.nan)
        dr_renov_arr.append(np.nan)
        continue

    # Components
    term_sup   = psi_sup / denom
    term_disp  = psi_dem / denom
    term_qcomp = (alpha_2 + alpha_1 * theta_q) * (qS - qM_s) / denom
    term_renov = (alpha_2 + alpha_1 * theta_q) * (1.0 - s_val) * kappa_M / denom

    dr_supply_arr.append(term_sup)
    dr_disp_arr.append(term_disp)
    dr_qcomp_arr.append(term_qcomp)
    dr_renov_arr.append(term_renov)

dr_supply_arr = np.array(dr_supply_arr)
dr_disp_arr   = np.array(dr_disp_arr)
dr_qcomp_arr  = np.array(dr_qcomp_arr)
dr_renov_arr  = np.array(dr_renov_arr)

fig5, ax5 = plt.subplots(figsize=(8, 6))

ax5.axhline(0, color="black", linewidth=1, alpha=0.5)

ax5.plot(s_grid_dec, dr_supply_arr, label="Pure supply", linestyle="-")
ax5.plot(s_grid_dec, dr_disp_arr, label="Displaced eligibles", linestyle="--")
ax5.plot(s_grid_dec, dr_qcomp_arr, label="Quality–composition", linestyle="-.")
ax5.plot(s_grid_dec, dr_renov_arr, label="Renovation & sorting response", linestyle=":")

ax5.set_xlabel("Social housing share s")
ax5.set_ylabel(r"$\frac{dr_C}{ds}$")

ax5.set_title("Decomposition of marginal rent effect $dr_C/ds$ over $s$")

ax5.spines["top"].set_visible(False)
ax5.spines["right"].set_visible(False)

ax5.legend()
plt.tight_layout()

plt.savefig(
    "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/output/graphs/drCds_decomposition.png",
    dpi=300, bbox_inches="tight"
)

plt.show()

# ======================================================
# 13. EQUILIBRIUM r_C(s) AS A FUNCTION OF SOCIAL SHARE s
# ======================================================

# Grid of social-housing shares
s_grid_full = np.linspace(0.0, 1.0, 501)

# Compute equilibrium market rents for each s
rC_grid = np.array([r_C(s_val, params) for s_val in s_grid_full])

# ---- Find the minimizing share s* ----
idx_star = np.argmin(rC_grid)
s_star   = s_grid_full[idx_star]
r_star   = rC_grid[idx_star]
print(f"Minimizing social share s* = {s_star:.4f},  r_C(s*) = {r_star:.4f}")

fig6, ax6 = plt.subplots(figsize=(8, 6))

# Main curve in BLUE
ax6.plot(s_grid_full, rC_grid, linewidth=2, color=col_s0)

# ---- Mark the two equilibria: A (s0) and C (s1) ----
ax6.scatter([s0], [r0], color="black", zorder=5)
ax6.text(s0, r0+0.01, "  A", va="center", ha="left", 
         fontsize=14, fontweight="bold")

ax6.scatter([s1], [r1], color="black", zorder=5)
ax6.text(s1, r1, "  C", va="center", ha="left", 
         fontsize=14, fontweight="bold")

# ---- Mark the minimizing point s* ----
ax6.scatter([s_star], [r_star], color=col_supply, s=70, zorder=6)
ax6.text(s_star, r_star+0.025, "  $s^*$", color=col_supply,
         va="center", ha="left", fontsize=14, fontweight="bold")


# Horizontal guides
ax6.hlines(r0, xmin=0,   xmax=s0, color="black", linestyle="--", alpha=0.6, zorder=0)
ax6.hlines(r1, xmin=0,   xmax=s1, color="black", linestyle="--", alpha=0.6, zorder=0)

# Custom axis labels (these stay even when ticks are off)
ax6.text(-0.01, r0,  r"$r_{old}$", va="center", ha="right", fontsize=15)
ax6.text(-0.01, r1,  r"$r_{new}$", va="center", ha="right", fontsize=15)

# Labels
ax6.set_xlabel("Social housing share $s$", fontsize=16, ha="left")
ax6.annotate("Rent r",
             xy=(-0.06, 0.95), xycoords="axes fraction",
             va="bottom", ha="center", fontsize=16)

# Clean axes
ax6.spines["top"].set_visible(False)
ax6.spines["right"].set_visible(False)

ax6.set_xlim(left=0, right=1)              
ax6.set_ylim(bottom=r_min, top=2.2)

# Optional: remove tick labels (your style)
ax6.set_yticks([])
ax6.set_yticklabels([])

plt.tight_layout()

plt.savefig(
    "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/output/graphs/rC_vs_s.png",
    dpi=300, bbox_inches="tight"
)

plt.show()

ax4.annotate("Quantity of private housing",
             xy=(0.56, -.03), xycoords="axes fraction",
             va="center", ha="left", fontsize=16)



