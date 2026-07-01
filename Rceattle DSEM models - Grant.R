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
load("atf_iid_mod.Rdata")
load("atf_direct_mod.Rdata")
load("atf_full_mod.Rdata")
load("atf_sem_tran.Rdata")
load("atf_sem_prey.Rdata")
load("atf_sem_hab.Rdata")
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
save(atf_iid_mod, file = "atf_iid_mod.Rdata")
gc() #clear memory

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
save(atf_direct_mod, file = "atf_direct_mod.Rdata")
gc() #clear memory

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
save(atf_full_mod, file = "atf_full_mod.Rdata")
gc() #clear memory

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
save(atf_sem_tran, file = "atf_sem_tran.Rdata")
gc() #clear memory

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
save(atf_sem_prey, file = "atf_sem_prey.Rdata")
gc() #clear memory

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
save(atf_sem_hab, file = "atf_sem_hab.Rdata")
gc() #clear memory

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
save(nork_iid_mod, file = "nork_iid_mod.Rdata")
gc() #clear memory

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
save(nork_direct_mod, file = "nork_direct_mod.Rdata")
gc() #clear memory

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
save(nork_full_mod, file = "nork_full_mod.Rdata")
gc() #clear memory

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
save(nork_sem_tran, file = "nork_sem_tran.Rdata")
gc() #clear memory

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
save(nork_sem_prey, file = "nork_sem_prey.Rdata")
gc() #clear memory

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
save(nork_sem_hab, file = "nork_sem_hab.Rdata")
gc() #clear memory

# * Pollock ----
load("pk_iid_mod.Rdata")
load("pk_direct_mod.Rdata")
load("pk_full_mod.Rdata")
load("pk_sem_tran.Rdata")
load("pk_sem_prey.Rdata")
load("pk_sem_hab.Rdata")
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
save(pk_iid_mod, file = "pk_iid_mod.Rdata")
gc() #clear memory


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
save(pk_direct_mod, file = "pk_direct_mod.Rdata")
gc() #clear memory

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
save(pk_full_mod, file = "pk_full_mod.Rdata")
gc() #clear memory

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
save(pk_sem_tran, file = "pk_sem_tran.Rdata")
gc() #clear memory

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
save(pk_sem_prey, file = "pk_sem_prey.Rdata")
gc() #clear memory

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
save(pk_sem_hab, file = "pk_sem_hab.Rdata")
gc() #clear memory
# * Pcod ----
load("cod_iid_mod.Rdata")
load("cod_direct_mod.Rdata")
load("cod_full_mod.Rdata")
load("cod_sem_tran.Rdata")
load("cod_sem_prey.Rdata")
load("cod_sem_hab.Rdata")

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
save(cod_iid_mod, file = "cod_iid_mod.Rdata")
gc() #clear memory


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
save(cod_direct_mod, file = "cod_direct_mod.Rdata")
gc() #clear memory

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
save(cod_full_mod, file = "cod_full_mod.Rdata")
gc() #clear memory


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
save(cod_sem_tran, file = "cod_sem_tran.Rdata")
gc() #clear memory

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
save(cod_sem_prey, file = "cod_sem_prey.Rdata")
gc() #clear memory

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
save(cod_sem_hab, file = "cod_sem_hab.Rdata")
gc() #clear memory

# Summaries ----
# - ATF
summ_atf_iid <- summary(atf_iid_mod)$coefficients %>% dplyr::mutate(Model = "Base",
                                                              Species = "ATF")
atf_iid_AIC <- rep(AIC(atf_iid_mod),length(summ_atf_iid[,1]))
summ_atf_dir <- summary(atf_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                                  Species = "ATF")
atf_dir_AIC <- rep(AIC(atf_direct_mod),length(summ_atf_dir[,1]))
summ_atf_sem <- summary(atf_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                      Species = "ATF")
atf_sem_AIC <- rep(AIC(atf_full_mod),length(summ_atf_sem[,1]))
summ_atf_sem_tran <- summary(atf_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                              Species = "ATF")
atf_tran_AIC <- rep(AIC(atf_sem_tran),length(summ_atf_sem_tran[,1]))
summ_atf_sem_prey <- summary(atf_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                              Species = "ATF")
atf_prey_AIC <- rep(AIC(atf_sem_prey),length(summ_atf_sem_prey[,1]))
summ_atf_sem_hab <- summary(atf_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                            Species = "ATF")
atf_hab_AIC <- rep(AIC(atf_sem_hab),length(summ_atf_sem_hab[,1]))

AICmod_ATF <- c(atf_iid_AIC, atf_dir_AIC, atf_sem_AIC, atf_tran_AIC, atf_prey_AIC, atf_hab_AIC)
results_ATF <- do.call("rbind", list(summ_atf_iid, summ_atf_dir, summ_atf_sem, summ_atf_sem_tran, summ_atf_sem_prey, summ_atf_sem_hab))
results_ATF$AIC <- AICmod_ATF
write.csv(results_ATF, file = "Results/Initial_DSEM_atf.csv")

# - NORK
summ_nork_iid <- summary(nork_iid_mod)$coefficients %>% dplyr::mutate(Model = "IID",
                                                                      Species = "NORK")
nork_iid_AIC <- rep(AIC(nork_sem_iid),length(summ_nork_iid[,1]))
summ_nork_dir <- summary(nork_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                                  Species = "NORK")
nork_dir_AIC <- rep(AIC(nork_sem_dir),length(summ_nork_dir[,1]))
summ_nork_sem <- summary(nork_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                   Species = "NORK")
nork_full_AIC <- rep(AIC(nork_sem_full),length(summ_nork_sem[,1]))
summ_nork_sem_tran <- summary(nork_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                                Species = "NORK")
nork_tran_AIC <- rep(AIC(nork_sem_tran),length(summ_nork_sem_tran[,1]))
summ_nork_sem_prey <- summary(nork_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                                Species = "NORK")
nork_prey_AIC <- rep(AIC(nork_sem_prey),length(summ_nork_sem_prey[,1]))
summ_nork_sem_hab <- summary(nork_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                              Species = "NORK")
nork_hab_AIC <- rep(AIC(nork_sem_hab),length(summ_nork_sem_hab[,1]))
AICmod_NORK <- c(nork_iid_AIC,nork_dir_AIC, nork_sem_AIC, nork_tran_AIC, nork_prey_AIC, nork_hab_AIC)
results_NORK <- do.call("rbind", list(summ_nork, summ_nork_iid, summ_nork_sem, summ_nork_sem_tran, summ_nork_sem_prey, summ_nork_sem_hab))
results_NORK$AIC <- AICmod_NORK
write.csv(results_NORK, file = "Results/Initial_DSEM_nork.csv")

# - Pollock
summ_pk_iid <- summary(pk_iid_mod)$coefficients %>% dplyr::mutate(Model = "IID",
                                                          Species = "Pollock")
pk_iid_AIC <- rep(AIC(pk_iid_mod),length(summ_pk_iid[,1]))
summ_pk_dir <- summary(pk_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                          Species = "Pollock")
pk_dir_AIC <- rep(AIC(pk_direct_mod),length(summ_pk_dir[,1]))
summ_pk_sem <- summary(pk_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                   Species = "Pollock")
pk_full_AIC <- rep(AIC(pk_full_mod),length(summ_pk_sem[,1]))
summ_pk_sem_tran <- summary(pk_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                             Species = "Pollock")
pk_tran_AIC <- rep(AIC(pk_sem_tran),length(summ_pk_sem_tran[,1]))
summ_pk_sem_prey <- summary(pk_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                             Species = "Pollock")
pk_prey_AIC <- rep(AIC(pk_sem_prey),length(summ_pk_sem_prey[,1]))
summ_pk_sem_hab <- summary(pk_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                           Species = "Pollock")
pk_hab_AIC <- rep(AIC(pk_sem_hab),length(summ_pk_sem_hab[,1]))

AICmod_pk <- c(pk_iid_AIC,pk_dir_AIC, pk_full_AIC, pk_tran_AIC, pk_prey_AIC, pk_hab_AIC)
results_pk <- do.call("rbind", list(summ_pk_iid, summ_pk_dir, summ_pk_sem, summ_pk_sem_tran, summ_pk_sem_prey, summ_pk_sem_hab))
results_pk$AIC <- AICmod_pk
write.csv(results_pk, file = "Results/Initial_DSEM_pk.csv")

# - Cod
summ_cod_iid <- summary(cod_iid_mod)$coefficients %>% dplyr::mutate(Model = "IID",
                                                          Species = "Cod")
cod_iid_AIC <- rep(AIC(cod_iid_mod),length(summ_cod_iid[,1]))
summ_cod_dir <- summary(cod_direct_mod)$coefficients %>% dplyr::mutate(Model = "Direct DSEM",
                                                                  Species = "Cod")
cod_dir_AIC <- rep(AIC(cod_direct_mod),length(summ_cod_dir[,1]))
summ_cod_sem <- summary(cod_full_mod)$coefficients %>% dplyr::mutate(Model = "Full DSEM",
                                                                   Species = "Cod")
cod_full_AIC <- rep(AIC(cod_full_mod),length(summ_cod_sem[,1]))
summ_cod_sem_tran <- summary(cod_sem_tran)$coefficients %>% dplyr::mutate(Model = "Transport",
                                                                               Species = "Cod")
cod_tran_AIC <- rep(AIC(cod_sem_tran),length(summ_cod_sem_tran[,1]))
summ_cod_sem_prey <- summary(cod_sem_prey)$coefficients %>% dplyr::mutate(Model = "Prey",
                                                                               Species = "Cod")
cod_prey_AIC <- rep(AIC(cod_sem_prey),length(summ_cod_sem_prey[,1]))
summ_cod_sem_hab <- summary(cod_sem_hab)$coefficients %>% dplyr::mutate(Model = "Habitat",
                                                                             Species = "Cod")
cod_hab_AIC <- rep(AIC(cod_sem_hab),length(summ_cod_sem_hab[,1]))
AICmod_cod <- c(cod_iid_AIC,cod_dir_AIC, cod_full_AIC, cod_tran_AIC, cod_prey_AIC, cod_hab_AIC)
results_cod <- do.call("rbind", list(summ_cod_iid, summ_cod_dir, summ_cod_sem, summ_cod_sem_tran, summ_cod_sem_prey, summ_cod_sem_hab))
results_cod$AIC <- AICmod_cod
write.csv(results_cod, file = "Results/Initial_DSEM_cod.csv")



