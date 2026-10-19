# Use outline to navigate

# Which Rceattle to run this with ----
#   remotes::install_version("dsem", version = "3.0.0")
#   remotes::install_github("afsc-assessments/Rceattle", ref = "dev-DSEM")

library(Rceattle)   # dev-DSEM, >= 5.57.0.9001
library(dplyr)


# Load data ----
dir.create("Results", showWarnings = FALSE)
source("Setup environmental data.R")
source("SEMs.R")

# * Rceattle data ----
atfdata <- Rceattle::read_data( file = "Data/2023_GOA_arrowtooth.xlsx")
pkdata <- Rceattle::read_data( file = "Data/2024_GOA_pollock.xlsx")
# Pcod uses a SS3-bridging setup, not the workbook
codbundle <- readRDS("Data/goa_cod_ss3_bridged.rds")
pcoddata  <- codbundle$data_list
nrdata <- Rceattle::read_data(file = "Data/2024_GOA_northern_rockfish.xlsx")
nrdata$styr <- 1987 # original 1978 but shortened to 1987 to help DSEM converge

# * Combine stock and environmental data ----
# envdata goes back to 1968, earlier than any of the four stocks start, so
# each stock's env_data is trimmed to its own styr.
atfdata$env_data <- atfdata$env_data %>%
  select(Year, BTempC) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year) %>%
  filter(Year >= atfdata$styr)

pkdata$env_data <- pkdata$env_data %>%
  select(Year, QcovPol) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year) %>%
  filter(Year >= pkdata$styr)

# Cod keeps every column
pcoddata$env_data <- pcoddata$env_data %>%
  select(-any_of("post2014")) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year) %>%
  filter(Year >= pcoddata$styr)

nrdata$env_data <- nrdata$env_data %>%
  select(Year, Temp, StartDateDev, Interaction) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year) %>%
  filter(Year >= nrdata$styr)

plot_data(nrdata)

# * Forecast setup for the skill comparison ----
rec_dsem <- build_srr(proj_mean_rec = FALSE)

# - Cod has some other initial setups
cod_recFun <- codbundle$recFun
cod_recFun$proj_mean_rec <- FALSE

# * Trim projection for speed ----
atfdata$projyr <- atfdata$endyr
nrdata$projyr <- nrdata$endyr
pcoddata$projyr <- pcoddata$endyr
pkdata$projyr <- pkdata$endyr


# Fit models ----
# Within a species, all six models share the same settings and differ only in
# their SEM. Each fit_<species>() function holds those settings, so the calls
# below show just which SEM goes into each model. Each fit is saved to Models/
# so it can be reloaded later without refitting.

# * Arrowtooth ----
fit_atf <- function(sem) {
  model <- Rceattle::fit_mod(data_list = atfdata,
                             estimateMode = 0, # Estimate
                             random_rec = TRUE,
                             recFun = rec_dsem,
                             dsem = build_DSEM(
                               sem = sem,
                               family = "fixed",
                               sigmaR_prior_sd = 0.5
                             ),
                             msmMode = 0, # Single species mode
                             initMode = 1,
                             fit_control = fit_control(
                               verbose = 1,
                               phase = TRUE))
  gc() # clear memory
  model
}

atf_iid_mod <- fit_atf(atfiidsem)
save(atf_iid_mod, file = "Models/atf_iid_mod.Rdata")

atf_direct_mod <- fit_atf(atfdirectsem)
save(atf_direct_mod, file = "Models/atf_direct_mod.Rdata")

atf_full_mod <- fit_atf(atfsem)
save(atf_full_mod, file = "Models/atf_full_mod.Rdata")

atf_sem_tran <- fit_atf(atfsem_tran)
save(atf_sem_tran, file = "Models/atf_sem_tran.Rdata")

atf_sem_prey <- fit_atf(atfsem_prey)
save(atf_sem_prey, file = "Models/atf_sem_prey.Rdata")

atf_sem_hab <- fit_atf(atfsem_hab)
save(atf_sem_hab, file = "Models/atf_sem_hab.Rdata")


# * Northern rockfish ----
# - Estimate M with lognormal prior (urm: mean_M = 0.06, cv_M = 0.05).
fit_nork <- function(sem) {
  model <- Rceattle::fit_mod(data_list = nrdata,
                             estimateMode = 0, # Estimate
                             random_rec = TRUE,
                             recFun = rec_dsem,
                             msmMode = 0, # Single species mode
                             initMode = 2,
                             dsem = build_DSEM(
                               sem = sem,
                               family = "fixed",
                               sigmaR_prior_sd = 0.5
                             ),
                             M1Fun = build_M1(updateM1 = FALSE, M1_model = 0),
                             fit_control = fit_control(
                               verbose = 1,
                               phase = TRUE))
  gc() # clear memory
  model
}

nork_iid_mod <- fit_nork(norkiidsem)
save(nork_iid_mod, file = "Models/nork_iid_mod.Rdata")

nork_direct_mod <- fit_nork(norkdirectsem)
save(nork_direct_mod, file = "Models/nork_direct_mod.Rdata")

nork_full_mod <- fit_nork(norksem)
save(nork_full_mod, file = "Models/nork_full_mod.Rdata")

nork_sem_tran <- fit_nork(norksem_tran)
save(nork_sem_tran, file = "Models/nork_sem_tran.Rdata")

nork_sem_prey <- fit_nork(norksem_prey)
save(nork_sem_prey, file = "Models/nork_sem_prey.Rdata")

nork_sem_hab <- fit_nork(norksem_hab)
save(nork_sem_hab, file = "Models/nork_sem_hab.Rdata")


# * Pollock ----
fit_pk <- function(sem) {
  model <- Rceattle::fit_mod(data_list = pkdata,
                             estimateMode = 0, # Estimate
                             random_rec = TRUE,
                             recFun = rec_dsem,
                             msmMode = 0, # Single species mode
                             initMode = 1, # Unfished equilibrium with init_dev's turned off
                             dsem = build_DSEM(
                               sem = sem,
                               family = "fixed",
                               sigmaR_prior_sd = 0.5
                             ),
                             fit_control = fit_control(
                               verbose = 1,
                               phase = TRUE))
  gc() # clear memory
  model
}

pk_iid_mod <- fit_pk(pollockiidsem)
save(pk_iid_mod, file = "Models/pk_iid_mod.Rdata")

pk_direct_mod <- fit_pk(pollockdirectsem)
save(pk_direct_mod, file = "Models/pk_direct_mod.Rdata")

pk_full_mod <- fit_pk(pollocksem)
save(pk_full_mod, file = "Models/pk_full_mod.Rdata")

pk_sem_tran <- fit_pk(pollocksem_tran)
save(pk_sem_tran, file = "Models/pk_sem_tran.Rdata")

pk_sem_prey <- fit_pk(pollocksem_prey)
save(pk_sem_prey, file = "Models/pk_sem_prey.Rdata")

pk_sem_hab <- fit_pk(pollocksem_hab)
save(pk_sem_hab, file = "Models/pk_sem_hab.Rdata")


# * Pcod ----
# Cod starts from SS3's MLE (no phasing) and uses the
# SS3-bridged settings in codbundle. cod_map() pins the selectivity
# coefficients the data cannot inform -- see "Cod pinning notes.md".

# ** Cod initial parameters ----
# - defaults lead to the optimizing ending in a local minima
nyr_cod  <- length(pcoddata$styr:pcoddata$endyr)
nenv_cod <- ncol(pcoddata$env_data) - 1L
cod_inits <- codbundle$inits
cod_inits$rec_dev      <- cod_inits$rec_dev[, seq_len(nyr_cod), drop = FALSE]
cod_inits$log_M1_dev   <- cod_inits$log_M1_dev[, , , seq_len(nyr_cod), drop = FALSE]
cod_inits$M1_beta      <- array(0, c(dim(cod_inits$M1_beta)[1:2], nenv_cod))
cod_inits$index_q_beta <- matrix(0, nrow(cod_inits$index_q_beta), nenv_cod)

# ** Cod map ----
# Plateau width (top_logit) and descending-limb width (descend_se).
cod_uninformed_sel <- c(
  "s1p2_pre", "s1p2_blk1990", "s1p2_blk2005", "s1p2_blk2007", "s1p2_blk2017",
  "s2p2_pre", "s2p2_blk1990", "s2p2_blk2005", "s2p2_blk2007", "s2p2_blk2017",
  "s3p2_pre", "s3p2_blk2017", "s4p2_pre", "s4p2_blk1996", "s4p2_blk2006",
  "s1p4_pre", "s1p4_blk1990", "s1p4_blk2005", "s1p4_blk2007", "s1p4_blk2017",
  "s4p4_blk1996", "s4p4_blk2006")

cod_map <- function(sem) {
  m <- Rceattle::fit_mod(
    data_list = pcoddata, inits = cod_inits, estimateMode = 3,
    initMode  = codbundle$initMode, growthFun = codbundle$growthFun,
    M1Fun     = codbundle$M1Fun,    selFun    = codbundle$selFun,
    qFun      = codbundle$qFun,
    dsem = build_DSEM(sem = sem, family = "fixed", sigmaR_prior_sd = 0.5),
    random_rec = TRUE, recFun = cod_recFun,
    fit_control = fit_control(verbose = 0, phase = FALSE))

  # Fix them at SS3 initial value
  lt   <- as.data.frame(m$data_list$linkage_table)
  flat <- which(lt$design_col %in% cod_uninformed_sel)
  stopifnot(length(flat) > 0, all(cod_uninformed_sel %in% lt$design_col))

  mp <- m$map
  mp$mapList$beta_linkage[flat] <- NA

  # 6 and 12 are end_logit for FshTrawl and FshLL, which SS3 fixes at 10. 26 is LLSrv's top_logit base, the 23rd uninformed coefficient and the only one that lives in sel_dn6 rather than the linkage table.
  mp$mapList$sel_dn6[c(6, 12, 26)] <- NA
  for (b in c("beta_linkage", "sel_dn6")) {
    mp$mapFactor[[b]] <- factor(mp$mapList[[b]])
  }
  mp
}


fit_cod <- function(sem) {
  model <- Rceattle::fit_mod(data_list = pcoddata,
                             inits = cod_inits, # SS3's MLE
                             map = cod_map(sem),
                             estimateMode = 0, # Estimate
                             initMode  = codbundle$initMode,
                             growthFun = codbundle$growthFun,
                             M1Fun     = codbundle$M1Fun,
                             selFun    = codbundle$selFun,
                             qFun      = codbundle$qFun,
                             dsem = build_DSEM(
                               sem = sem,
                               family = "fixed",
                               sigmaR_prior_sd = 0.5
                             ),
                             random_rec = TRUE,
                             recFun = cod_recFun,
                             fit_control = fit_control(
                               verbose = 1,
                               phase = FALSE)) # warm start
  gc() # clear memory
  model
}

cod_iid_mod <- fit_cod(pcodiidsem)
save(cod_iid_mod, file = "Models/cod_iid_mod.Rdata")

cod_direct_mod <- fit_cod(pcoddirectsem)
save(cod_direct_mod, file = "Models/cod_direct_mod.Rdata")

cod_full_mod <- fit_cod(pcodsem)
save(cod_full_mod, file = "Models/cod_full_mod.Rdata")

# Transport converges once cod_map() pins the uninformed selectivity
# coefficients; before that it ran 1.5-2.5 hours without converging, four
# times. 9.1 min, gradient 1e-03, full standard errors.
cod_sem_tran <- fit_cod(pcodsem_tran)
save(cod_sem_tran, file = "Models/cod_sem_tran.Rdata")

cod_sem_prey <- fit_cod(pcodsem_prey)
save(cod_sem_prey, file = "Models/cod_sem_prey.Rdata")

cod_sem_hab <- fit_cod(pcodsem_hab)
save(cod_sem_hab, file = "Models/cod_sem_hab.Rdata")


# Load models ----
# # * Arrowtooth ----
# load("Models/atf_iid_mod.Rdata")
# load("Models/atf_direct_mod.Rdata")
# load("Models/atf_full_mod.Rdata")
# load("Models/atf_sem_tran.Rdata")
# load("Models/atf_sem_prey.Rdata")
# load("Models/atf_sem_hab.Rdata")

# * Northern rockfish ----
# load("Models/nork_iid_mod.Rdata")
# load("Models/nork_direct_mod.Rdata")
# load("Models/nork_full_mod.Rdata")
# load("Models/nork_sem_tran.Rdata")
# load("Models/nork_sem_prey.Rdata")
# load("Models/nork_sem_hab.Rdata")

# * Pollock ----
# load("Models/pk_iid_mod.Rdata")
# load("Models/pk_direct_mod.Rdata")
# load("Models/pk_full_mod.Rdata")
# load("Models/pk_sem_tran.Rdata")
# load("Models/pk_sem_prey.Rdata")
# load("Modelspk_sem_hab.Rdata")

# * Pcod ----
# load("Models/cod_iid_mod.Rdata")
# load("Models/cod_direct_mod.Rdata")
# load("Models/cod_full_mod.Rdata")
# load("Models/cod_sem_tran.Rdata")
# load("Models/cod_sem_prey.Rdata")
# load("Models/cod_sem_hab.Rdata")


# Summarize models ----
# For each species, stack the coefficient tables of its six models and add the
# AIC, recruitment SD (sigmaR), and change in sigmaR relative to the IID model.

# Summarize one fitted model: one row per coefficient.
# iid_Rsd is sigmaR from the same species' IID model.
summarize_model <- function(model, model_name, species, iid_Rsd) {
  model_summary <- summary(model)
  Rsd <- model_summary$recruitment_sd$R_sd # recruitment SD (sigmaR)

  model_summary$coefficients %>%
    dplyr::mutate(Model = model_name,
                  Species = species,
                  AIC = AIC(model),
                  Rec_sd = Rsd,
                  deltaRsd = iid_Rsd - Rsd) # > 0 means sigmaR dropped relative to IID
}

# Summarize all models for one species and save to a csv.
# The first model in `models` must be the IID model.
summarize_species <- function(models, species, file) {
  iid_Rsd <- summary(models[[1]])$recruitment_sd$R_sd

  results <- list()
  for (model_name in names(models)) {
    results[[model_name]] <- summarize_model(models[[model_name]], model_name, species, iid_Rsd)
  }
  results <- dplyr::bind_rows(results)

  write.csv(results, file = file)
  results
}

# - ATF
results_ATF <- summarize_species(
  models = list("IID"         = atf_iid_mod,
                "Direct DSEM" = atf_direct_mod,
                "Full DSEM"   = atf_full_mod,
                "Transport"   = atf_sem_tran,
                "Prey"        = atf_sem_prey,
                "Habitat"     = atf_sem_hab),
  species = "ATF",
  file = "Results/Initial_DSEM_atf.csv")

# - NORK
results_NORK <- summarize_species(
  models = list("IID"         = nork_iid_mod,
                "Direct DSEM" = nork_direct_mod,
                "Full DSEM"   = nork_full_mod,
                "Transport"   = nork_sem_tran,
                "Prey"        = nork_sem_prey,
                "Habitat"     = nork_sem_hab),
  species = "NORK",
  file = "Results/Initial_DSEM_nork.csv")

# - Pollock
results_pk <- summarize_species(
  models = list("IID"         = pk_iid_mod,
                "Direct DSEM" = pk_direct_mod,
                "Full DSEM"   = pk_full_mod,
                "Transport"   = pk_sem_tran,
                "Prey"        = pk_sem_prey,
                "Habitat"     = pk_sem_hab),
  species = "Pollock",
  file = "Results/Initial_DSEM_pk.csv")

# - Cod
results_cod <- summarize_species(
  models = list("IID"         = cod_iid_mod,
                "Direct DSEM" = cod_direct_mod,
                "Full DSEM"   = cod_full_mod,
                "Transport"   = cod_sem_tran,
                "Prey"        = cod_sem_prey,
                "Habitat"     = cod_sem_hab),
  species = "Cod",
  file = "Results/Initial_DSEM_cod.csv")

# Forecast skill ----
# Moved to its own script: retrospective forecast skill, DSEM rule against
# mean recruitment, for all 24 fits. It takes hours, so run it separately.
#   source("Forecast skill.R")
