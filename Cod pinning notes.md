# GOA Pacific cod: why the DSEM fits pin what they pin

Working notes behind `cod_map()` in *Rceattle DSEM models - Grant.R*. Moved out of
the script on 2026-10-17 so the script stays readable; nothing here is edited.
The pin set itself and the measurements are from the SS3 bridge work in
`../Rceattle-models/GOA cod/Bridging/pin_uninformed_sel.R`.

---

This map holds exactly what the SS3 bridge's 307-parameter fit holds, so this
cod model IS that model with a DSEM on recruitment. What is held beyond
build_map()'s own doing is `cod_uninformed_sel` plus sel_dn6[6], [12] and [26]
-- see `cod_map()` below, which also records the measurement that retired the
three earlier pins.

Those three are kept here as the record of why they were added, NOT as a
description of what runs. Two corrections to that record, both measured:
  * "together they are why cod reported no standard errors at all" is wrong.
    The cause was an indefinite Hessian concentrated in `top_logit` and
    `descend_se`; holding those alone returns 268 of 268 standard errors with
    all three earlier pins removed.
  * L1's stated mechanism is wrong. A parameter on a bound does NOT by itself
    prevent sdreport: this model fits with L1 on its 1e-3 bound and returns
    pdHess TRUE with 268 SEs, and SS3's own goa_pcod run has L_at_Amin at
    status LO with an SE of 0.5226 and a full covar.sso. What L1 on the bound
    DOES cost is biological: 0.001 cm at age 0.5 against SS3's 1.3007 moves
    length at age 1 from 11.00 to 9.82 cm and ages 2-3 by ~1 cm, which shifts
    the age-length key. It is left free here by decision, to match the bridge.

The original notes, retained:
  * L1, length at age 1. Estimated here it runs to its lower bound of 0.001 cm
    (SS3 gets 1.3007). Fixed at SS3's value, which cod_inits carries. K and
    Linf still estimate.
  * the selectivity deviates whose fleet-year has no composition data. Nothing
    in the likelihood touches them; freed they are flat directions.
  * sel_dn6[6] and [12], the double-normal end_logit for FshTrawl and FshLL.
    SS3 holds both at 10 (selectivity at the last bin is 1, i.e. no descending
    cut-off) and these are the ONLY two parameters SS3 fixes that this script
    would otherwise estimate. check_estimability() independently flags one of
    them, and cod_inits carries SS3's 10.
  * `cod_flat_sel`, selectivity deviates that check_estimability() flags as
    non-identifiable and that are ~0 BOTH here and in SS3, so holding them at
    SS3's value removes a flat direction without moving the model. Diagnosed
    on cod_sem_hab, the best-converged of the five; all five share the same
    selectivity structure. Deliberately NOT included: the flagged terms that
    are large (s1p1_pre 60.3, s1p4_dev1985 -42.0, s3p3_blk2017 16.0 ...),
    which are confounded base/block pairs trading off against each other, and
    s2p3_blk2007 / s2p3_blk2017, which are ~0 here but 5.3 and 5.5 in SS3 --
    pinning either kind would change the model rather than tidy it.
Built per model because the DSEM adds its own entries to the map.
cod_flat_sel <- c("s1p1_dev1981", "s1p1_dev1984", "s1p1_dev1987", "s1p1_dev1989",
                  "s2p1_dev1983", "s1p3_dev1977", "s2p3_dev1978")

`cod_uninformed_sel`, the plateau width (`top_logit`, p2) and descending-limb
width (`descend_se`, p4) wherever the curve cannot respond to them. Disjoint
from cod_flat_sel above, which holds deviates on peak and ascend_se.
Two structural reasons, both from SS3's own control file:
  * ASYMPTOTIC CURVE. SS3 fixes end_logit at 10 for FshTrawl, FshLL and Srv's
    1996 and 2006 blocks -- selectivity 0.99995 at the last length bin. With
    the final point at 1 the descending limb is flat at 1, so neither its
    width nor the plateau width above the peak changes the curve at all.
  * SATURATED PLATEAU. peak2 = peak + binwidth + (0.99 x_last - peak -
    binwidth)/(1 + exp(-top_logit)), so a sufficiently negative top_logit puts
    peak2 on its floor one population bin above the peak. SS3's own values
    leave FshPot, LLSrv and Srv pre-1996 with a plateau of 2e-4 to 2e-3 cm
    against a 1 cm grid -- already collapsed.
Measured on the SS3-parity fit (`GOA cod/Bridging/pin_uninformed_sel.R`): the
Hessian diagonal of all 23 is below 1e-2, holding them at SS3's values moves
selectivity-at-age by 4.9e-05 and SSB by 0.0002%, and it takes that fit's
Hessian from indefinite -- so `chol()` fails and TMBhelper returns before
calling sdreport -- to positive definite, with 307 standard errors reported.
SS3 agrees about which: on its runs that invert, all 23 carry standard errors
of 46 to 500, while the three top_logit/descend_se coefficients left free
carry 0.97, 0.39 and 0.34.

Verified in THIS model, not only in the bridge: from the free DSEM MLE, where
these coefficients had drifted up to 17 units from SS3's values, moving all 27
rows back changes the objective by -2.9e-05, selectivity-at-age by 5.4e-05,
SSB by 0.0002% and catch by 0.0008%.

Checked and closed (2026-10-17). 19 of the 23 are inert because `end_logit`
is fixed at 10. The other 4 -- s3p2_pre, s3p2_blk2017, s4p2_pre and
sel_dn6[26] -- are the top_logit coefficients on fleets whose limb descends,
and they are inert because top_logit is a logistic that has stopped acting:
s3p2_pre, s4p2_pre and sel_dn6[26] sit on its floor with no plateau at all,
s3p2_blk2017 against its cap with a 31 cm plateau. A DSEM could in principle
undo the floor cases by moving `peak`. Freed and refitted on the IID and
Habitat SEMs, it does not: `peak` does not move, the realised curve is
unchanged, SSB and R0 are unchanged to 5 significant figures, and the
objective gains 2.3e-04 nats for 4 parameters, so AIC is worse by exactly
8.00. They come back with standard errors of 80-139 on a parameter whose
operative range is about [-8, +5], i.e. still unidentified. The data reject a
plateau on the floor cases outright: forcing those top_logits to 0 opens
4-8 cm plateaus and costs 244 nats.

Read a block coefficient as the realised value, NOT as a base plus a block.
Under RCE_SEL_REPLACE the sel_dn6 base is masked at 0 and each parameter's
year columns are a partition -- s3p2_pre covers 1977-2016, s3p2_blk2017 covers
2017-2024, and no year carries both. Adding them is how this note first put
s3p2_blk2017 on the floor branch instead of the cap.

Note Srv pre-1996 is ALREADY a dome (selectivity 0.21 at 104.5 cm) in both
versions -- s4p2_pre controls the flat top, not the dome, so pinning it
forbids nothing the fit wants.

---

## The three pins that were dropped

The three pins dropped above, kept for their reasoning rather than deleted.
Re-enable them only together with a re-measurement: each one made this model
differ from the SS3-parity fit, and the comparison in `cod_map()`'s header is
what retired them.

  comps  <- unique(m$data_list$comp_data[, c("Fleet_code", "Year")])
  year   <- suppressWarnings(as.integer(sub(".*_dev", "", lt$design_col)))
  nodata <- which(lt$process == "sel" & grepl("_dev", lt$design_col) &
                  !mapply(function(f, y) isTRUE(any(comps$Fleet_code == f &
                                                    comps$Year == y)),
                          lt$fleet, year))
  mp$mapList$beta_linkage[c(nodata, which(lt$design_col %in% cod_flat_sel))] <- NA
  mp$mapList$log_growth_pars[2] <- NA


---

## The cod transport fit, removed 2026-10-16

Not fitted: four attempts of 1.5-2.5 hours each failed to converge, where the other
five cod models take 10-25 minutes. Capped at 400 iterations it reached 2247.08 with
a gradient of 375, against 2213.6-2239.2 for its siblings. An unconverged objective is
biased high, so reporting its AIC would have argued against the transport hypothesis on
an optimiser artefact rather than on the data. Its two simultaneous covariates explain
3% of the variance in the Upwelling series they point at (neither significant), and that
near-null series is the sole lag-1 driver of recruitment -- a coefficient with no
information is a flat direction, which is the likely cause.

```r
cod_sem_tran <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = cod_inits,
                                  map = cod_map(pcodsem_tran),
                                  estimateMode = 0,
                                  initMode  = codbundle$initMode,
                                  growthFun = codbundle$growthFun,
                                  M1Fun     = codbundle$M1Fun,
                                  selFun    = codbundle$selFun,
                                  qFun      = codbundle$qFun,
                                  dsem = build_DSEM(sem = pcodsem_tran,
                                                    family = "fixed",
                                                    sigmaR_prior_sd = 0.5),
                                  random_rec = TRUE,
                                  recFun = cod_recFun,
                                  fit_control = fit_control(verbose = 1, phase = FALSE))
save(cod_sem_tran, file = "Models/cod_sem_tran.Rdata")
```
