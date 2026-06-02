library(Rceattle)

# Load data ----
# * Rceattle data ----
mydata_atf <- Rceattle::read_data( file = "data/2023_GOA_arrowtooth.xlsx")
pkdata <- Rceattle::read_data( file = "Data/2024_GOA_pollock.xlsx")
pcoddata <- Rceattle::read_data( file = "Data/2024_GOA_pcod.xlsx")
nrdata <- Rceattle::read_data(file = "Data/2024_GOA_northern_rockfish.xlsx")


# Arrowtooth ----
goa_atf <- Rceattle::fit_mod(data_list = mydata_atf,
                                inits = NULL, # Initial parameters = 0
                                file = NULL, # Don't save
                                estimateMode = 0, # Estimate
                                random_rec = TRUE,
                                msmMode = 0, # Single species mode
                                verbose = 1,
                                phase = TRUE,
                                initMode = 1)


# Northern rockfish ----
# - Estimate M with lognormal prior (urm: mean_M = 0.06, cv_M = 0.05).
#   urm ESTIMATES M (log_M is a free parameter with this prior), so this is the
#   configuration directly comparable to the urm reference model.
#   M_prior_sd is log-scale (= cv_M = 0.05), matching urm's dnorm(log(M), ...).
goa_nork <- Rceattle::fit_mod(data_list = nrdata,
                            inits = NULL,
                            file = NULL,
                            estimateMode = 0,
                            random_rec = TRUE,
                            msmMode = 0,
                            verbose = 1,
                            phase = TRUE,
                            initMode = 1,
                            M1Fun = build_M1(updateM1 = TRUE,
                                             M1_model     = 1,
                                             M1_use_prior = TRUE,
                                             M_prior      = 0.06,
                                             M_prior_sd   = 0.05))


# Pollock ----
goa_pk <- fit_mod(data_list = pkdata,
                        inits = NULL,       # Initial parameters = 0
                        file = NULL,        # Don't save
                        estimateMode = 0,   # Estimate
                        random_rec = TRUE,
                        msmMode = 0,        # Single species mode
                        verbose = 1,        # Minimal messages
                        initMode = 1,       # Unfished equilibrium with init_dev's turned off
                        phase = TRUE)       # Phase

# Pcod ----
Rceattle::fit_mod(data_list = pcod24,
                  inits = NULL, # Initial parameters = 0
                  estimateMode = 0, # Estimate
                  M1Fun = build_M1(M1_model = 1,
                                   M1_use_prior = FALSE,
                                   M2_use_prior = FALSE),
                  random_rec = TRUE,
                  verbose = 1,
                  phase = TRUE)
