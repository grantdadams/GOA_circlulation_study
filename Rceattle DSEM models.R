# Use outline to navigate

# Libraries ----
# remotes::install_github("grantdadams/Rceattle@dev-DSEM")
library(Rceattle) # dev-DSEM
library(dplyr)


# Load data ----
source("Setup environmental data.R")
#source("SEMs.R") #older single DSEM model code
source("SEMs multimodel.R")

# * Rceattle data ----
atfdata <- Rceattle::read_data( file = "data/2023_GOA_arrowtooth.xlsx")
pkdata <- Rceattle::read_data( file = "Data/2024_GOA_pollock.xlsx")
pcoddata <- Rceattle::read_data( file = "Data/2024_GOA_pcod.xlsx")
nrdata <- Rceattle::read_data(file = "Data/2024_GOA_northern_rockfish.xlsx")

# * Combine stock and environmental data ----
atfdata$env_data <- atfdata$env_data %>%
  full_join(envdata)

pkdata$env_data <- pkdata$env_data %>%
  full_join(envdata)

pcoddata$env_data <- pcoddata$env_data %>%
  full_join(envdata)

nrdata$env_data <- nrdata$env_data %>%
  full_join(envdata)

plot_data(nrdata)

atfdata$projyr <- atfdata$endyr
nrdata$projyr <- nrdata$endyr
pcoddata$projyr <- pcoddata$endyr
pkdata$projyr <- pkdata$endyr

# Fit models ----
# * Arrowtooth ----
goa_atf <- Rceattle::fit_mod(data_list = atfdata,
                             inits = NULL, # Initial parameters = 0
                             file = NULL, # Don't save
                             estimateMode = 0, # Estimate
                             random_rec = TRUE,
                             msmMode = 0, # Single species mode
                             initMode = 1,
                             fit_control = fit_control(
                               verbose = 1,
                               phase = TRUE))

goa_atf_iid <- Rceattle::fit_mod(data_list = atfdata,
                                 inits = NULL, # Initial parameters = 0
                                 file = NULL, # Don't save
                                 estimateMode = 0, # Estimate
                                 random_rec = TRUE,
                                 dsem = build_DSEM(
                                   sem = iidsem,
                                   family = "normal"
                                 ),
                                 msmMode = 0, # Single species mode
                                 initMode = 1,
                                 fit_control = fit_control(
                                   verbose = 1,
                                   phase = TRUE))

goa_atf_sem <- Rceattle::fit_mod(data_list = atfdata,
                                 inits = NULL, # Initial parameters = 0
                                 file = NULL, # Don't save
                                 estimateMode = 0, # Estimate
                                 random_rec = TRUE,
                                 dsem = build_DSEM(
                                   sem = atfsem,
                                   family = "normal"
                                 ),
                                 msmMode = 0, # Single species mode
                                 initMode = 1,
                                 fit_control = fit_control(
                                   verbose = 1,
                                   phase = TRUE))

goa_atf_sem_tran <- Rceattle::fit_mod(data_list = atfdata,
                                 inits = NULL, # Initial parameters = 0
                                 file = NULL, # Don't save
                                 estimateMode = 0, # Estimate
                                 random_rec = TRUE,
                                 dsem = build_DSEM(
                                   sem = atfsem_tran,
                                   family = "normal"
                                 ),
                                 msmMode = 0, # Single species mode
                                 initMode = 1,
                                 fit_control = fit_control(
                                   verbose = 1,
                                   phase = TRUE))

goa_atf_sem_prey <- Rceattle::fit_mod(data_list = atfdata,
                                 inits = NULL, # Initial parameters = 0
                                 file = NULL, # Don't save
                                 estimateMode = 0, # Estimate
                                 random_rec = TRUE,
                                 dsem = build_DSEM(
                                   sem = atfsem_prey,
                                   family = "normal"
                                 ),
                                 msmMode = 0, # Single species mode
                                 initMode = 1,
                                 fit_control = fit_control(
                                   verbose = 1,
                                   phase = TRUE))

goa_atf_sem_hab <- Rceattle::fit_mod(data_list = atfdata,
                                 inits = NULL, # Initial parameters = 0
                                 file = NULL, # Don't save
                                 estimateMode = 0, # Estimate
                                 random_rec = TRUE,
                                 dsem = build_DSEM(
                                   sem = atfsem_hab,
                                   family = "normal"
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
goa_nork <- Rceattle::fit_mod(data_list = nrdata,
                              estimateMode = 0,
                              random_rec = TRUE,
                              msmMode = 0,
                              initMode = 2,
                              M1Fun = build_M1(updateM1 = TRUE,
                                               M1_model     = 1,
                                               M1_use_prior = TRUE,
                                               M_prior      = 0.06,
                                               M_prior_sd   = 0.05),
                              fit_control = fit_control(
                                verbose = 1,
                                phase = TRUE))


goa_nork_iid <- Rceattle::fit_mod(data_list = nrdata,
                                  estimateMode = 0,
                                  random_rec = TRUE,
                                  msmMode = 0,
                                  initMode = 2,
                                  dsem = build_DSEM(
                                    sem = iidsem,
                                    family = "normal"
                                  ),
                                  M1Fun = build_M1(updateM1 = TRUE,
                                                   M1_model     = 1,
                                                   M1_use_prior = TRUE,
                                                   M_prior      = 0.06,
                                                   M_prior_sd   = 0.05),
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))


goa_nork_sem <- Rceattle::fit_mod(data_list = nrdata,
                                  estimateMode = 0,
                                  random_rec = TRUE,
                                  msmMode = 0,
                                  initMode = 2,
                                  dsem = build_DSEM(
                                    sem = norksem,
                                    family = "normal"
                                  ),
                                  M1Fun = build_M1(updateM1 = TRUE,
                                                   M1_model     = 1,
                                                   M1_use_prior = TRUE,
                                                   M_prior      = 0.06,
                                                   M_prior_sd   = 0.05),
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

goa_nork_sem_tran <- Rceattle::fit_mod(data_list = nrdata,
                                  estimateMode = 0,
                                  random_rec = TRUE,
                                  msmMode = 0,
                                  initMode = 2,
                                  dsem = build_DSEM(
                                    sem = norksem_tran,
                                    family = "normal"
                                  ),
                                  M1Fun = build_M1(updateM1 = TRUE,
                                                   M1_model     = 1,
                                                   M1_use_prior = TRUE,
                                                   M_prior      = 0.06,
                                                   M_prior_sd   = 0.05),
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

goa_nork_sem_prey <- Rceattle::fit_mod(data_list = nrdata,
                                       estimateMode = 0,
                                       random_rec = TRUE,
                                       msmMode = 0,
                                       initMode = 2,
                                       dsem = build_DSEM(
                                         sem = norksem_prey,
                                         family = "normal"
                                       ),
                                       M1Fun = build_M1(updateM1 = TRUE,
                                                        M1_model     = 1,
                                                        M1_use_prior = TRUE,
                                                        M_prior      = 0.06,
                                                        M_prior_sd   = 0.05),
                                       fit_control = fit_control(
                                         verbose = 1,
                                         phase = TRUE))
goa_nork_sem_hab <- Rceattle::fit_mod(data_list = nrdata,
                                       estimateMode = 0,
                                       random_rec = TRUE,
                                       msmMode = 0,
                                       initMode = 2,
                                       dsem = build_DSEM(
                                         sem = norksem_hab,
                                         family = "normal"
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
goa_pk <- fit_mod(data_list = pkdata,
                  estimateMode = 0,   # Estimate
                  random_rec = TRUE,
                  msmMode = 0,        # Single species mode
                  initMode = 1,       # Unfished equilibrium with init_dev's turned off
                  fit_control = fit_control(
                    verbose = 1,
                    phase = TRUE))


goa_pk_iid <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = iidsem,
                         family = "normal"
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))

goa_pk_dsem <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = pollocksem,
                         family = "normal"
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))

goa_pk_dsem_tran <- fit_mod(data_list = pkdata,
                       estimateMode = 0,   # Estimate
                       random_rec = TRUE,
                       msmMode = 0,        # Single species mode
                       initMode = 1,
                       dsem = build_DSEM(
                         sem = pollocksem_tran,
                         family = "normal"
                       ),
                       fit_control = fit_control(
                         verbose = 1,
                         phase = TRUE))

goa_pk_dsem_prey <- fit_mod(data_list = pkdata,
                            estimateMode = 0,   # Estimate
                            random_rec = TRUE,
                            msmMode = 0,        # Single species mode
                            initMode = 1,
                            dsem = build_DSEM(
                              sem = pollocksem_prey,
                              family = "normal"
                            ),
                            fit_control = fit_control(
                              verbose = 1,
                              phase = TRUE))

goa_pk_dsem_hab <- fit_mod(data_list = pkdata,
                            estimateMode = 0,   # Estimate
                            random_rec = TRUE,
                            msmMode = 0,        # Single species mode
                            initMode = 1,
                            dsem = build_DSEM(
                              sem = pollocksem_hab,
                              family = "normal"
                            ),
                            fit_control = fit_control(
                              verbose = 1,
                              phase = TRUE))

# * Pcod ----
goa_cod <- Rceattle::fit_mod(data_list = pcoddata,
                             inits = NULL, # Initial parameters = 0
                             estimateMode = 0, # Estimate

                             M1Fun        = M1_block,
                             random_rec = TRUE,
                             fit_control = fit_control(
                               verbose = 1,
                               phase = TRUE))


goa_cod_iid <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = iidsem,
                                    family = "normal"
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

goa_cod_dsem <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = pcodsem,
                                    family = "normal"
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

#GOA Cod transport only model
goa_cod_dsem_tran <- Rceattle::fit_mod(data_list = pcoddata,
                                  inits = NULL, # Initial parameters = 0
                                  estimateMode = 0, # Estimate

                                  M1Fun        = M1_block,
                                  dsem = build_DSEM(
                                    sem = pcodsemtran,
                                    family = "normal"
                                  ),
                                  random_rec = TRUE,
                                  fit_control = fit_control(
                                    verbose = 1,
                                    phase = TRUE))

goa_cod_dsem_prey <- Rceattle::fit_mod(data_list = pcoddata,
                                       inits = NULL, # Initial parameters = 0
                                       estimateMode = 0, # Estimate

                                       M1Fun        = M1_block,
                                       dsem = build_DSEM(
                                         sem = pcodsem_prey,
                                         family = "normal"
                                       ),
                                       random_rec = TRUE,
                                       fit_control = fit_control(
                                         verbose = 1,
                                         phase = TRUE))

goa_cod_dsem_hab <- Rceattle::fit_mod(data_list = pcoddata,
                                       inits = NULL, # Initial parameters = 0
                                       estimateMode = 0, # Estimate

                                       M1Fun        = M1_block,
                                       dsem = build_DSEM(
                                         sem = pcodsem_hab,
                                         family = "normal"
                                       ),
                                       random_rec = TRUE,
                                       fit_control = fit_control(
                                         verbose = 1,
                                         phase = TRUE))

# Summaries ----
# - ATF
summ_atf <- summary(goa_atf)$coefficients %>% dplyr::mutate(Model = "Base",
                                                              Species = "ATF")
summ_atf_iid <- summary(goa_atf_iid)$coefficients %>% dplyr::mutate(Model = "IID",
                                                                  Species = "ATF")
summ_atf_sem <- summary(goa_atf_sem)$coefficients %>% dplyr::mutate(Model = "DSEM",
                                                                      Species = "ATF")

summ_atf_sem_tran <- summary(goa_atf_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                    Species = "ATF")

summ_atf_sem_prey <- summary(goa_atf_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                              Species = "Prey")

summ_atf_sem_hab <- summary(goa_atf_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                              Species = "ATF")

results <- do.call("rbind", list(summ_atf, summ_atf_iid, summ_atf_sem, summ_atf_sem_tran, summ_atf_sem_prey, summ_atf_sem_hab))
write.csv(results, file = "Results/Multi_DSEM_atf.csv")

# - NORK
summ_nork <- summary(goa_nork)$coefficients %>% dplyr::mutate(Model = "Base",
                                                          Species = "NORK")
summ_nork_iid <- summary(goa_nork_iid)$coefficients %>% dplyr::mutate(Model = "IID",
                                                                  Species = "NORK")
summ_nork_sem <- summary(goa_nork_sem)$coefficients %>% dplyr::mutate(Model = "DSEM",
                                                                   Species = "NORK")
summ_nork_sem_tran <- summary(goa_nork_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                      Species = "NORK")

summ_nork_sem_prey <- summary(goa_nork_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                      Species = "NORK")

summ_nork_sem_hab <- summary(goa_nork_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                                Species = "NORK")

results <- do.call("rbind", list(summ_nork, summ_nork_iid, summ_nork_sem, summ_nork_sem_tran, summ_nork_sem_prey, summ_nork_sem_hab))
write.csv(results, file = "Results/Multi_DSEM_nork.csv")

# - Pollock
summ_pk <- summary(goa_pk)$coefficients %>% dplyr::mutate(Model = "Base",
                                                          Species = "Pollock")
summ_pk_iid <- summary(goa_pk_iid)$coefficients %>% dplyr::mutate(Model = "IID",
                                                          Species = "Pollock")
summ_pk_sem <- summary(goa_pk_dsem)$coefficients %>% dplyr::mutate(Model = "DSEM",
                                                                   Species = "Pollock")
summ_pk_sem_tran <- summary(goa_pk_dsem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                   Species = "Pollock")
summ_pk_sem_prey <- summary(goa_pk_dsem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                   Species = "Pollock")
summ_pk_sem_hab <- summary(goa_pk_dsem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                   Species = "Pollock")
results <- do.call("rbind", list(summ_pk, summ_pk_iid, summ_pk_sem, summ_pk_sem_tran, summ_pk_sem_prey, summ_pk_sem_hab))
write.csv(results, file = "Results/Multi_DSEM_pk.csv")

# - Cod
summ_cod <- summary(goa_cod)$coefficients %>% dplyr::mutate(Model = "Base",
                                                          Species = "Cod")
summ_cod_iid <- summary(goa_cod_iid)$coefficients %>% dplyr::mutate(Model = "IID",
                                                                  Species = "Cod")
summ_cod_sem <- summary(goa_cod_dsem)$coefficients %>% dplyr::mutate(Model = "DSEM",
                                                                   Species = "Cod")
summ_cod_sem_tran <- summary(goa_cod_dsem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                     Species = "Cod")
summ_cod_sem_prey <- summary(goa_cod_dsem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                               Species = "Cod")
summ_cod_sem_hab <- summary(goa_cod_dsem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                               Species = "Cod")


results <- do.call("rbind", list(summ_cod, summ_cod_iid, summ_cod_sem, summ_cod_sem_tran, summ_cod_sem_prey, summ_cod_sem_hab))
write.csv(results, file = "Results/Initial_DSEM_cod.csv")



