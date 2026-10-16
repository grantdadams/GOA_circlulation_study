# Forecast skill: does a DSEM forecast recruitment better than mean recruitment?
#
# For each fitted model, project the peeled years twice -- once with the DSEM latent states and once at the historical mean.
#
# Run after "Rceattle DSEM models - Grant.R" has saved the 24 fits. Hours, not
# minutes: 24 models x 2 rules x 5 peels, and every peel is a refit.
#
# Writes Results/forecast_skill*.csv.

library(Rceattle)   # dev-DSEM, >= 5.57.0.9001
library(dplyr)
dir.create("Results", showWarnings = FALSE)


# Settings ----

# Peel DEPTHS, not a count: the 3- to 7-year peels. Recruitment in the last two
# years is already well estimated, so peeling only 1-2 years back barely moves
# it and the two rules have nothing to disagree about.
skill_peels <- 3:7

# Models fitted with phase = FALSE. retrospective() defaults to TRUE and a fit
# does not record what it used, so without this a peel is phased when its parent
# was not. Keep in step with the fitting script.
unphased <- c(paste("Pcod", c("iid", "direct", "full", "tran", "prey", "hab")),
              "NORK prey")


# The fitted models ----

model_objects <- c(
  "ATF iid"      = "atf_iid_mod",   "ATF direct"     = "atf_direct_mod",
  "ATF full"     = "atf_full_mod",  "ATF tran"       = "atf_sem_tran",
  "ATF prey"     = "atf_sem_prey",  "ATF hab"        = "atf_sem_hab",
  "NORK iid"     = "nork_iid_mod",  "NORK direct"    = "nork_direct_mod",
  "NORK full"    = "nork_full_mod", "NORK tran"      = "nork_sem_tran",
  "NORK prey"    = "nork_sem_prey", "NORK hab"       = "nork_sem_hab",
  "Pollock iid"  = "pk_iid_mod",    "Pollock direct" = "pk_direct_mod",
  "Pollock full" = "pk_full_mod",   "Pollock tran"   = "pk_sem_tran",
  "Pollock prey" = "pk_sem_prey",   "Pollock hab"    = "pk_sem_hab",
  "Pcod iid"     = "cod_iid_mod",   "Pcod direct"    = "cod_direct_mod",
  "Pcod full"    = "cod_full_mod",  "Pcod tran"      = "cod_sem_tran",
  "Pcod prey"    = "cod_sem_prey",  "Pcod hab"       = "cod_sem_hab")

for (obj in model_objects) {
  if (file.exists(paste0(obj, ".Rdata"))) load(paste0(obj, ".Rdata"))
}
fitted <- vapply(model_objects, exists, logical(1))
if (any(!fitted)) {
  message("Not fitted, skipped: ", paste(names(model_objects)[!fitted], collapse = ", "))
}
skill_models <- lapply(model_objects[fitted], get)


# Score every model under both rules ----

# One retrospective per rule, as ?hindcast_skill requires. The two differ only
# because every model is fitted with proj_mean_rec = FALSE.
#
# rescale = TRUE is NOT optional. Under family = "fixed" the covariate columns
# of the DSEM state ARE the environmental data, and a peel warm-started from the
# parent would inherit them for years AFTER the peel -- handing the covariate
# models the future. rescale = TRUE restandardizes on the peel's own years.
#
# Each model is saved as it finishes, so an interrupted run resumes. Delete
# forecast_skill.Rdata to recompute.
skill <- NULL
if (file.exists("forecast_skill.Rdata")) load("forecast_skill.Rdata")

for (nm in setdiff(names(skill_models), skill$model)) {
  rows <- lapply(c("model", "mean"), function(rule) {
    hs <- try(hindcast_skill(skill_models[[nm]], peels = skill_peels,
                             forecast_rec = rule, rescale = TRUE,
                             fit_control = fit_control(phase = !nm %in% unphased)),
              silent = TRUE)
    if (inherits(hs, "try-error")) {
      message("FAILED: ", nm, " (", rule, ") -- ",
              conditionMessage(attr(hs, "condition")))
      return(NULL)
    }
    # Squared error beside hindcast_skill()'s absolute error, from the same
    # peels. Both score against `reference`: what the full-time-series fit says
    # that year's recruitment (or biomass, or SSB) was. "mse" is mean squared
    # error here, not Management Strategy Evaluation.
    squared <- hs$by_year %>%
      group_by(Object, species, `Forecast year`) %>%
      summarise(mse_forecast = mean((forecast - reference)^2, na.rm = TRUE),
                mse_naive    = mean((naive    - reference)^2, na.rm = TRUE),
                .groups = "drop") %>%
      mutate(rmsse = sqrt(mse_forecast / mse_naive))

    cbind(model = nm, rule = rule,
          merge(hs$mase, squared, by = c("Object", "species", "Forecast year")))
  })

  # Both rules or neither: one rule alone has nothing to compare against.
  if (any(vapply(rows, is.null, logical(1)))) next
  skill <- rbind(skill, do.call(rbind, rows))
  save(skill, file = "forecast_skill.Rdata")
  message("done: ", nm)
}


# Compare the two rules ----

# Relabelled "dsem"/"mean" so the pivot does not collide with the model column.
# `ratio` below 1 means the model's own forecast beat mean recruitment. It uses
# the raw errors, not the two MASEs: each rule fits its own peels, so each MASE
# is scaled by a different baseline.
paired <- names(which(tapply(skill$rule, skill$model,
                             function(r) length(unique(r))) == 2L))

skill_cmp <- skill %>%
  filter(model %in% paired) %>%
  mutate(rule = ifelse(rule == "model", "dsem", "mean")) %>%
  select(model, rule, Object, `Forecast year`, species,
         mase, rmsse, mae_forecast, mse_forecast) %>%
  tidyr::pivot_wider(names_from = rule,
                     values_from = c(mase, rmsse, mae_forecast, mse_forecast)) %>%
  mutate(stock     = sub(" .*", "", model),
         submodel  = sub("^[^ ]+ ", "", model),
         ratio     = mae_forecast_dsem / mae_forecast_mean,
         ratio_mse = mse_forecast_dsem / mse_forecast_mean)

write.csv(skill_cmp, "Results/forecast_skill.csv", row.names = FALSE)


# By forecast horizon ----

# Recruitment shows it first; SSB is what it propagates into. At horizon 1 the
# SSB ratio should be ~1 -- that year's recruits are not yet mature -- which is
# a check that the two rules are being told apart at all.
skill_by_horizon <- skill_cmp %>%
  group_by(Object, `Forecast year`) %>%
  summarise(n                = sum(is.finite(ratio)),
            median_ratio     = median(ratio, na.rm = TRUE),
            median_ratio_mse = median(ratio_mse, na.rm = TRUE),
            dsem_better      = sum(ratio < 1, na.rm = TRUE), .groups = "drop")

write.csv(skill_by_horizon, "Results/forecast_skill_by_horizon.csv", row.names = FALSE)
print(as.data.frame(skill_by_horizon))


# By stock and submodel ----

# Read this table, not the pooled one. The two rules differ in LEVEL as well as
# in information -- the model rule projects at predicted recruitment, the mean
# rule at the arithmetic mean of realised recruitment -- and that gap is shared
# by every submodel of a stock, so it dominates a pooled ratio. The `iid`
# submodel carries no covariate path, so it is the null: only a submodel that
# beats IT is gaining anything from its covariates. `mase` and `rmsse` are each
# submodel's own scaled scores and do not share the level confound.
skill_by_submodel <- skill_cmp %>%
  filter(Object == "R") %>%
  group_by(stock, submodel) %>%
  summarise(n          = sum(is.finite(ratio)),
            ratio      = median(ratio, na.rm = TRUE),
            ratio_mse  = median(ratio_mse, na.rm = TRUE),
            mase_dsem  = median(mase_dsem, na.rm = TRUE),
            rmsse_dsem = median(rmsse_dsem, na.rm = TRUE), .groups = "drop")

write.csv(skill_by_submodel, "Results/forecast_skill_by_submodel.csv", row.names = FALSE)
print(as.data.frame(skill_by_submodel))
