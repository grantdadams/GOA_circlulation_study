# Use outline to navigate

# Libraries ----
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
  full_join(envdata)

pkdata$env_data <- pkdata$env_data %>%
  full_join(envdata)

pcoddata$env_data <- pcoddata$env_data %>%
  full_join(envdata)

nrdata$env_data <- nrdata$env_data %>%
  full_join(envdata)

plot_data(nrdata)


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


# * Pollock ----
goa_pk <- fit_mod(data_list = pkdata,
                  estimateMode = 0,   # Estimate
                  random_rec = TRUE,
                  msmMode = 0,        # Single species mode
                  initMode = 1,       # Unfished equilibrium with init_dev's turned off
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

# * Pcod ----
goa_cod <- Rceattle::fit_mod(data_list = pcoddata,
                             inits = NULL, # Initial parameters = 0
                             estimateMode = 0, # Estimate

                             M1Fun        = M1_block,
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
