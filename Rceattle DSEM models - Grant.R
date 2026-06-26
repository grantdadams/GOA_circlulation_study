# Use outline to navigate

# Libraries ----
# remotes::install_version("dsem", version = "3.0.0") # Need this version
# remotes::install_github("grantdadams/Rceattle@dev-DSEM")
library(Rceattle) # dev-DSEM
library(dplyr)


# Load data ----
source("Setup environmental data.R")
source("SEMs.R")

# * Rceattle data ----
atfdata <- Rceattle::read_data( file = "data/2023_GOA_arrowtooth.xlsx")
pkdata <- Rceattle::read_data( file = "Data/2024_GOA_pollock.xlsx")
pcoddata <- Rceattle::read_data( file = "Data/2024_GOA_pcod.xlsx")
nrdata <- Rceattle::read_data(file = "Data/2024_GOA_northern_rockfish.xlsx")

# * Combine stock and environmental data ----
atfdata$env_data <- atfdata$env_data %>%
  select(Year, BTempC) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year)

pkdata$env_data <- pkdata$env_data %>%
  select(Year, QcovPol) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year)

pcoddata$env_data <- pcoddata$env_data %>%
  select(Year, CFSR_2022) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year)

nrdata$env_data <- nrdata$env_data %>%
  select(Year, Temp, StartDateDev, Interaction) %>%
  full_join(envdata, by = "Year") %>%
  arrange(Year)

plot_data(nrdata)

atfdata$projyr <- atfdata$endyr
nrdata$projyr <- nrdata$endyr
pcoddata$projyr <- pcoddata$endyr
pkdata$projyr <- pkdata$endyr


# Fit models ----
# * Arrowtooth ----
atf_iid_mod <- Rceattle::fit_mod(data_list = atfdata,
                             inits = NULL, # Initial parameters = 0
                             file = NULL, # Don't save
                             estimateMode = 0, # Estimate
                             random_rec = TRUE,
                             dsem = build_DSEM(
                               sem = atfiidsem,
                               family = "fixed",
                               sigmaR_prior_sd = 0.5
                             ),
                             msmMode = 0, # Single species mode
                             initMode = 1,
                             fit_control = fit_control(
                               verbose = 1,
                               phase = TRUE))

atf_direct_mod <- Rceattle::fit_mod(data_list = atfdata,
                                 inits = NULL, # Initial parameters = 0
                                 file = NULL, # Don't save
                                 estimateMode = 0, # Estimate
                                 random_rec = TRUE,
                                 dsem = build_DSEM(
                                   sem = atfdirectsem,
                                   family = "fixed",
                                   sigmaR_prior_sd = 0.5
                                 ),
                                 msmMode = 0, # Single species mode
                                 initMode = 1,
                                 fit_control = fit_control(
                                   verbose = 1,
                                   phase = TRUE))

atf_full_mod <- Rceattle::fit_mod(data_list = atfdata,
                                 inits = NULL, # Initial parameters = 0
                                 file = NULL, # Don't save
                                 estimateMode = 0, # Estimate
                                 random_rec = TRUE,
                                 dsem = build_DSEM(
                                   sem = atfsem,
                                   family = "fixed",
                                   sigmaR_prior_sd = 0.5
                                 ),
                                 msmMode = 0, # Single species mode
                                 initMode = 1,
                                 fit_control = fit_control(
                                   verbose = 1,
                                   phase = TRUE))

atf_sem_tran <- Rceattle::fit_mod(data_list = atfdata,
                                  inits = NULL, # Initial parameters = 0
                                  file = NULL, # Don't save
                                  estimateMode = 0, # Estimate
                                  random_rec = TRUE,
                                  dsem = build_DSEM(
                                    sem = atfsem_tran,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  msmMode = 0, # Single species mode
                                  initMode = 1,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

atf_sem_prey <- Rceattle::fit_mod(data_list = atfdata,
                                   inits = NULL, # Initial parameters = 0
                                   file = NULL, # Don't save
                                   estimateMode = 0, # Estimate
                                   random_rec = TRUE,
                                   dsem = build_DSEM(
                                     sem = atfsem_prey,
                                     family = "fixed",
                                     sigmaR_prior_sd = 0.5
                                   ),
                                   msmMode = 0, # Single species mode
                                   initMode = 1,
                                   fit_control = fit_control(
                                     verbose = 1,
                                     phase = TRUE))

atf_sem_hab <- Rceattle::fit_mod(data_list = atfdata,
                                   inits = NULL, # Initial parameters = 0
                                   file = NULL, # Don't save
                                   estimateMode = 0, # Estimate
                                   random_rec = TRUE,
                                   dsem = build_DSEM(
                                     sem = atfsem_hab,
                                     family = "fixed",
                                     sigmaR_prior_sd = 0.5
                                   ),
                                   msmMode = 0, # Single species mode
                                   initMode = 1,
                                   fit_control = fit_control(
                                     verbose = 1,
                                     phase = TRUE))


# * Northern rockfish ----
# - Estimate M with lognormal prior (urm: mean_M = 0.06, cv_M = 0.05).
#   urm ESTIMATES M (log_M is a free parameter with this prior), so this is the
#   configuration directly comparable to the urm reference model.
#   M_prior_sd is log-scale (= cv_M = 0.05), matching urm's dnorm(log(M), ...).
nork_iid_mod <- Rceattle::fit_mod(data_list = nrdata,
                              estimateMode = 0,
                              random_rec = TRUE,
                              msmMode = 0,
                              initMode = 2,
                              dsem = build_DSEM(
                                sem = norkiidsem,
                                family = "fixed",
                                sigmaR_prior_sd = 0.5
                              ),
                              M1Fun = build_M1(updateM1 = TRUE,
                                               M1_model     = 1,
                                               M1_use_prior = TRUE,
                                               M_prior      = 0.06,
                                               M_prior_sd   = 0.05),
                              fit_control = fit_control(
                                verbose = 1,
                                phase = TRUE))


nork_direct_mod <- Rceattle::fit_mod(data_list = nrdata,
                                  estimateMode = 0,
                                  random_rec = TRUE,
                                  msmMode = 0,
                                  initMode = 2,
                                  dsem = build_DSEM(
                                    sem = norkdirectsem,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  M1Fun = build_M1(updateM1 = TRUE,
                                                   M1_model     = 1,
                                                   M1_use_prior = TRUE,
                                                   M_prior      = 0.06,
                                                   M_prior_sd   = 0.05),
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))


nork_full_mod <- Rceattle::fit_mod(data_list = nrdata,
                                  estimateMode = 0,
                                  random_rec = TRUE,
                                  msmMode = 0,
                                  initMode = 2,
                                  dsem = build_DSEM(
                                    sem = norksem,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  M1Fun = build_M1(updateM1 = TRUE,
                                                   M1_model     = 1,
                                                   M1_use_prior = TRUE,
                                                   M_prior      = 0.06,
                                                   M_prior_sd   = 0.05),
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

nork_sem_tran <- Rceattle::fit_mod(data_list = nrdata,
                                   estimateMode = 0,
                                   random_rec = TRUE,
                                   msmMode = 0,
                                   initMode = 2,
                                   dsem = build_DSEM(
                                     sem = norksem_tran,
                                     family = "fixed",
                                     sigmaR_prior_sd = 0.5
                                   ),
                                   M1Fun = build_M1(updateM1 = TRUE,
                                                    M1_model     = 1,
                                                    M1_use_prior = TRUE,
                                                    M_prior      = 0.06,
                                                    M_prior_sd   = 0.05),
                                   fit_control = fit_control(
                                     verbose = 1,
                                     phase = TRUE))

nork_sem_prey <- Rceattle::fit_mod(data_list = nrdata,
                                   estimateMode = 0,
                                   random_rec = TRUE,
                                   msmMode = 0,
                                   initMode = 2,
                                   dsem = build_DSEM(
                                     sem = norksem_prey,
                                     family = "fixed",
                                     sigmaR_prior_sd = 0.5
                                   ),
                                   M1Fun = build_M1(updateM1 = TRUE,
                                                    M1_model     = 1,
                                                    M1_use_prior = TRUE,
                                                    M_prior      = 0.06,
                                                    M_prior_sd   = 0.05),
                                   fit_control = fit_control(
                                     verbose = 1,
                                     phase = TRUE))

nork_sem_hab <- Rceattle::fit_mod(data_list = nrdata,
                                   estimateMode = 0,
                                   random_rec = TRUE,
                                   msmMode = 0,
                                   initMode = 2,
                                   dsem = build_DSEM(
                                     sem = norksem_hab,
                                     family = "fixed",
                                     sigmaR_prior_sd = 0.5
                                   ),
                                   M1Fun = build_M1(updateM1 = TRUE,
                                                    M1_model     = 1,
                                                    M1_use_prior = TRUE,
                                                    M_prior      = 0.06,
                                                    M_prior_sd   = 0.05),
                                   fit_control = fit_control(
                                     verbose = 1,
                                     phase = TRUE))

# * Pollock ----
pk_iid_mod <- fit_mod(data_list = pkdata,
                  estimateMode = 0,   # Estimate
                  random_rec = TRUE,
                  msmMode = 0,        # Single species mode
                  initMode = 1,       # Unfished equilibrium with init_dev's turned off
                  dsem = build_DSEM(
                    sem = pollockiidsem,
                    family = "fixed", sigmaR_prior_sd = 0.5
                  ),
                  fit_control = fit_control(
                    verbose = 1,
                    phase = TRUE))


pk_direct_mod <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = pollockdirectsem,
                         family = "fixed",
                         sigmaR_prior_sd = 0.5
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))

pk_full_mod <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = pollocksem,
                         family = "fixed",
                         sigmaR_prior_sd = 0.5
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))

pk_sem_tran <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = pollocksem_tran,
                         family = "fixed",
                         sigmaR_prior_sd = 0.5
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))

pk_sem_prey <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = pollocksem_prey,
                         family = "fixed",
                         sigmaR_prior_sd = 0.5
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))

pk_sem_hab <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = pollocksem_hab,
                         family = "fixed",
                         sigmaR_prior_sd = 0.5
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))
# * Pcod ----
cod_iid_mod <- Rceattle::fit_mod(data_list = pcoddata,
                             inits = NULL, # Initial parameters = 0
                             estimateMode = 0, # Estimate

                             M1Fun        = M1_block,
                             dsem = build_DSEM(
                               sem = pcodiidsem,
                               family = "fixed",
                               sigmaR_prior_sd = 0.5
                             ),
                             random_rec = TRUE,
                             fit_control = fit_control(
                               verbose = 1,
                               phase = TRUE))


cod_direct_mod <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = pcoddirectsem,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

cod_full_mod <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = pcodsem,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

cod_sem_tran <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = pcodsem_tran,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

cod_sem_prey <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = pcodsem_prey,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

cod_sem_hab <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = pcodsem_hab,
                                    family = "fixed",
                                    sigmaR_prior_sd = 0.5
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

# Summaries ----
# - ATF
summ_atf <- summary(atf_iid_mod)$coefficients %>% dplyr::mutate(Model = "Base",
                                                              Species = "ATF")
summ_atf_iid <- summary(atf_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                                  Species = "ATF")
summ_atf_sem <- summary(atf_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                      Species = "ATF")
summ_atf_sem_tran <- summary(atf_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                              Species = "ATF")

summ_atf_sem_prey <- summary(atf_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                              Species = "Prey")

summ_atf_sem_hab <- summary(atf_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                            Species = "ATF")
results <- do.call("rbind", list(summ_atf, summ_atf_iid, summ_atf_sem, summ_atf_sem_tran, summ_atf_sem_prey, summ_atf_sem_hab))
write.csv(results, file = "Results/Initial_DSEM_atf.csv")

# - NORK
summ_nork <- summary(nork_iid_mod)$coefficients %>% dplyr::mutate(Model = "IID",
                                                          Species = "NORK")
summ_nork_iid <- summary(nork_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                                  Species = "NORK")
summ_nork_sem <- summary(nork_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                   Species = "NORK")
summ_nork_sem_tran <- summary(nork_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                                Species = "NORK")

summ_nork_sem_prey <- summary(nork_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                                Species = "NORK")

summ_nork_sem_hab <- summary(nork_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                              Species = "NORK")
results <- do.call("rbind", list(summ_nork, summ_nork_iid, summ_nork_sem, summ_nork_sem_tran, summ_nork_sem_prey, summ_nork_sem_hab))

write.csv(results, file = "Results/Initial_DSEM_nork.csv")

# - Pollock
summ_pk <- summary(pk_iid_mod)$coefficients %>% dplyr::mutate(Model = "IID",
                                                          Species = "Pollock")
summ_pk_iid <- summary(pk_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                          Species = "Pollock")
summ_pk_sem <- summary(pk_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                   Species = "Pollock")

summ_pk_sem_tran <- summary(pk_dsem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                             Species = "Pollock")
summ_pk_sem_prey <- summary(pk_dsem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                             Species = "Pollock")
summ_pk_sem_hab <- summary(pk_dsem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                           Species = "Pollock")
results <- do.call("rbind", list(summ_pk, summ_pk_iid, summ_pk_sem, summ_pk_sem_tran, summ_pk_sem_prey, summ_pk_sem_hab))

write.csv(results, file = "Results/Initial_DSEM_pk.csv")

# - Cod
summ_cod <- summary(cod_iid_mod)$coefficients %>% dplyr::mutate(Model = "IID",
                                                          Species = "Cod")
summ_cod_iid <- summary(cod_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                                  Species = "Cod")
summ_cod_sem <- summary(cod_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                   Species = "Cod")
summ_cod_sem_tran <- summary(cod_dsem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                               Species = "Cod")
summ_cod_sem_prey <- summary(cod_dsem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                               Species = "Cod")
summ_cod_sem_hab <- summary(cod_dsem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                             Species = "Cod")
results <- do.call("rbind", list(summ_cod, summ_cod_iid, summ_cod_sem, summ_cod_sem_tran, summ_cod_sem_prey, summ_cod_sem_hab))

write.csv(results, file = "Results/Initial_DSEM_cod.csv")



