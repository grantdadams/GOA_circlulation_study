# Libraries ----
library(Rceattle)
library(dplyr)
library(lubridate)
library(tidyr)

# 1) Data ----
# * Load environmental data ----
# Reconstruction NGAO labeled pc1) and GOADI (labeled pc2).
goadi <- read.csv("Data/HauriIndex_outDW.csv") %>%
    mutate(Date = as.Date(paste(Date, "-01", sep=""))) %>%
    dplyr::select(-X)
goadi_recon <- read.table("Data/pc2_timeseries.txt") %>%
    mutate(Date = as.Date(paste(V1, "-01", sep=""))) %>%
    dplyr::rename(GOADI = V2) %>%
    dplyr::select(-V1)
goadi <- rbind(goadi, goadi_recon)


ngao <- read.csv("Data/HauriIndex_outNGAO.csv") %>%
    mutate(Date = as.Date(paste(Date, "-01", sep=""))) %>%
    dplyr::select(-X)
ngao_recon <- read.table("Data/pc1_timeseries.txt") %>%
    mutate(Date = as.Date(paste(V1, "-01", sep=""))) %>%
    dplyr::rename(NGAO = V2) %>%
    dplyr::select(-V1)
ngao <- rbind(ngao, ngao_recon)


# * Create seasonal indices ----
seasons <- data.frame(Season = c("Winter", "Winter",
                                 "Spring", "Spring", "Spring",
                                 "Summer", "Summer", "Summer",
                                 "Fall", "Fall", "Fall",
                                 "Winter"),
                      Month = 1:12)

# This is currently set it up so winter is associated with age-0
ngao_annual <- ngao %>%
    mutate(Month = lubridate::month(Date),
           Year = lubridate::year(Date),
           Year = ifelse(Month == 12, Year + 1, Year)) %>% # Set year up one for Dec winter
    full_join(seasons) %>%
    dplyr::group_by(Year, Season) %>%
    dplyr::summarise(Index = mean(NGAO)) %>%
    dplyr::mutate(Year = ifelse(Season == "Fall", Year + 2, Year + 1)) %>% # Adding lag
    pivot_wider(names_from = Season, values_from = Index) %>%
    dplyr::rename(Fall_lagged2_NGAO = Fall,
                  Spring_lagged1_NGAO = Spring,
                  Summer_lagged1_NGAO = Summer,
                  Winter_lagged1_NGAO = Winter)

goadi_annual <- goadi %>%
    mutate(Month = lubridate::month(Date),
           Year = lubridate::year(Date),
           Year = ifelse(Month == 12, Year + 1, Year)) %>% # Set year up one for Dec winter
    full_join(seasons) %>%
    dplyr::group_by(Year, Season) %>%
    dplyr::summarise(Index = mean(GOADI)) %>%
    dplyr::mutate(Year = ifelse(Season == "Fall", Year + 2, Year + 1)) %>% # Adding lag
    pivot_wider(names_from = Season, values_from = Index) %>%
    dplyr::rename(Fall_lagged2_GOADI = Fall,
                  Spring_lagged1_GOADI = Spring,
                  Summer_lagged1_GOADI = Summer,
                  Winter_lagged1_GOADI = Winter)


# * Load stock data ----
atf23 <- Rceattle::read_data( file = "data/2023_GOA_arrowtooth.xlsx")
pollock24 <- Rceattle::read_data( file = "Data/2024_GOA_pollock.xlsx")
pcod24 <- Rceattle::read_data( file = "Data/2024_GOA_pcod.xlsx")
nrfish24 <- Rceattle::read_data(file = "Data/2024_GOA_northern_rockfish.xlsx")

atf23$fleet_control$Estimate_index_sd <- 0
atf23$fleet_control$Index_sd_prior <- 1


# * Combine stock and environmental data ----
pcod24$env_data <- pcod24$env_data %>%
    full_join(goadi_annual) %>%
    full_join(ngao_annual)

pollock24$env_data <- pollock24$env_data %>%
    full_join(goadi_annual) %>%
    full_join(ngao_annual)

atf23$env_data <- atf23$env_data %>%
    full_join(goadi_annual) %>%
    full_join(ngao_annual)

nrfish24$env_data <- nrfish24$env_data %>%
    full_join(goadi_annual) %>%
    full_join(ngao_annual)


# 2) Fit models ----

# Pcod ----
cod_models <- list()

# Cod: winter, spring, summer
cod_indices <- c(5,3,4,9,7,8)

pcod24$maturity[1,2:13] <- 2
pcod24$estDynamics[1] = 0
# - Using same length comp data as 2023 because marginals werent output in 2024

# * Base ----
# - Adjust future F proportion to each fleet
cod_models[[1]] <- Rceattle::fit_mod(data_list = pcod24,
                                     inits = NULL, # Initial parameters = 0
                                     estimateMode = 0, # Estimate
                                     M1Fun = build_M1(M1_model = 1,
                                                      M1_use_prior = FALSE,
                                                      M2_use_prior = FALSE),
                                     random_rec = TRUE, # No random recruitment
                                     verbose = 1,
                                     phase = TRUE)


avg_F <- (exp(cod_models[[1]]$estimated_params$ln_F)) # Average F from last 2 years
avg_F <- rowMeans(avg_F[,(ncol(avg_F)-2) : ncol(avg_F)])
f_ratio <- avg_F/sum(avg_F)
pcod24$fleet_control$proj_F_prop <- f_ratio

# - Fit with projection
cod_models[[1]] <- Rceattle::fit_mod(data_list = pcod24,
                                     inits = NULL, # Initial parameters = 0
                                     estimateMode = 0, # Estimate
                                     M1Fun = build_M1(M1_model = 1,
                                                      M1_use_prior = FALSE,
                                                      M2_use_prior = FALSE),
                                     random_rec = TRUE, # No random recruitment
                                     verbose = 1,
                                     phase = TRUE,
                                     HCR = build_hcr(HCR = 5, # Tier3 HCR
                                                     Ftarget = 0.4, # F40%
                                                     Flimit = 0.35, # F35%
                                                     Plimit = 0, # No fishing limit
                                                     Alpha = 0.05))


# * Fit environmental models ----
for(i in 1:length(cod_indices)){
    cod_models[[i+1]] <- fit_mod(data_list = pcod24,
                                 inits = cod_models[[1]]$estimated_params, # Initial parameters = 0
                                 estimateMode = 0, # Estimate
                                 M1Fun = build_M1(M1_model = 1,
                                                  M1_use_prior = FALSE,
                                                  M2_use_prior = FALSE),
                                 random_rec = TRUE, # No random recruitment
                                 recFun = build_srr(
                                     srr_fun = 1,
                                     srr_indices = c(cod_indices[i])), # Winter_GOADI
                                 initMode = 1,
                                 phase = FALSE,
                                 HCR = build_hcr(HCR = 5, # Tier3 HCR
                                                 Ftarget = 0.4, # F40%
                                                 Flimit = 0.35, # F35%
                                                 Plimit = 0, # No fishing limit
                                                 Alpha = 0.05))
}


# Pollock ----
pk_models <- list()

# Pollock: winter, spring, summer
pk_indices <- c(5,3,4,9,7,8)

# * Base ----
pollock24$fleet_control$proj_F_prop <- 1
pk_models[[1]] <- fit_mod(data_list = pollock24,
                          inits = NULL, # Initial parameters = 0

                          estimateMode = 0, # Estimate
                          random_rec = TRUE, # No random recruitment

                          verbose = 1,
                          initMode = 1,
                          phase = FALSE,
                          HCR = build_hcr(HCR = 5, # Tier3 HCR
                                          Ftarget = 0.4, # F40%
                                          Flimit = 0.35, # F35%
                                          Plimit = 0, # No fishing limit
                                          Alpha = 0.05))

# * Fit environmental models ----
for(i in 1:length(pk_indices)){
    pk_models[[i+1]] <- fit_mod(data_list = pollock24,
                                inits = NULL, # Initial parameters = 0
                                estimateMode = 0, # Estimate
                                random_rec = TRUE, # No random recruitment

                                verbose = 1,
                                recFun = build_srr(
                                    srr_fun = 1,
                                    srr_indices = c(pk_indices[i])),
                                initMode = 1,
                                phase = FALSE,
                                HCR = build_hcr(HCR = 5, # Tier3 HCR
                                                Ftarget = 0.4, # F40%
                                                Flimit = 0.35, # F35%
                                                Plimit = 0, # No fishing limit
                                                Alpha = 0.05))
}


# Arrowtooth ----
atf_models <- list()
atf_indices <- c(5,3,4,9,7,8)

# ATF: fall ( of year prior to spawn or lag1) winter, spring, summer

# * Base ----
atf23$fleet_control$proj_F_prop <- 1
atf_models[[1]] <- Rceattle::fit_mod(data_list = atf23,
                                     inits = NULL, # Initial parameters = 0
                                     file = NULL , #"Models/ss", # Don't save
                                     estimateMode = 0, # Estimate
                                     random_rec = FALSE, # No random recruitment
                                     verbose = 1,
                                     phase = FALSE,
                                     initMode = 2)
atf_models[[1]] <- Rceattle::fit_mod(data_list = atf23,
                                     inits = atf_models[[1]]$estimated_params, # Initial parameters = 0
                                     file = NULL , #"Models/ss", # Don't save
                                     estimateMode = 0, # Estimate
                                     random_rec = TRUE, # No random recruitment
                                     verbose = 1,
                                     phase = FALSE,
                                     initMode = 2)


# * Fit environmental models ----
for(i in 1:length(atf_indices)){
    atf_models[[i+1]] <- Rceattle::fit_mod(data_list = atf23,
                                           inits = NULL, # Initial parameters = 0
                                           file = NULL , #"Models/ss", # Don't save
                                           estimateMode = 0, # Estimate
                                           random_rec = FALSE, # No random recruitment
                                           recFun = build_srr(
                                               srr_fun = 1, # R_y = R_mu * exp(B * X + e_y)
                                               srr_indices = c(atf_indices[i])),
                                           verbose = 1,
                                           phase = FALSE,
                                           initMode = 2,
                                           HCR = build_hcr(HCR = 5, # Tier3 HCR
                                                           Ftarget = 0.4, # F40%
                                                           Flimit = 0.35, # F35%
                                                           Plimit = 0, # No fishing limit
                                                           Alpha = 0.05))

    atf_models[[i+1]] <- Rceattle::fit_mod(data_list = atf23,
                                           inits = atf_models[[i+1]]$estimated_params, # Initial parameters = 0
                                           file = NULL , #"Models/ss", # Don't save
                                           estimateMode = 0, # Estimate
                                           random_rec = TRUE, # No random recruitment
                                           recFun = build_srr(
                                               srr_fun = 1, # R_y = R_mu * exp(B * X + e_y)
                                               srr_indices = c(atf_indices[i])),
                                           verbose = 1,
                                           phase = FALSE,
                                           initMode = 2,
                                           HCR = build_hcr(HCR = 5, # Tier3 HCR
                                                           Ftarget = 0.4, # F40%
                                                           Flimit = 0.35, # F35%
                                                           Plimit = 0, # No fishing limit
                                                           Alpha = 0.05))
}


# Northern rockfish ----
# N. rock sole: winter, spring, summer
nrfish24$env_data  <- nrfish24$env_data %>%
    dplyr::select(-Temp, -StartDateDev, - Interaction)
nrfish_indices <- c(4,2,3,8,6,7)

nrfish_models <- list()
nrfish24$fleet_control$proj_F_prop <- 1
nrfish_models[[1]] <- Rceattle::fit_mod(data_list = nrfish24,
                                        inits = NULL, # Initial parameters = 0
                                        file = NULL, # Don't save
                                        estimateMode = 0, # Estimate
                                        random_rec = TRUE, # No random recruitment
                                        msmMode = 0, # Single species mode
                                        verbose = 1,
                                        phase = TRUE,
                                        initMode = 1, # Assume unfished equilibrium
                                        M1Fun = build_M1(updateM1 = TRUE,
                                                         M1_model = 1,
                                                         M1_use_prior = TRUE,
                                                         M_prior = 0.06,
                                                         M_prior_sd = 0.05),
                                        HCR = build_hcr(HCR = 5, # Tier3 HCR
                                                        Ftarget = 0.4, # F40%
                                                        Flimit = 0.35, # F35%
                                                        Plimit = 0, # No fishing limit
                                                        Alpha = 0.05)
)


# * Fit environmental models ----
for(i in 1:length(nrfish_indices)){
    nrfish_models[[i+1]] <- fit_mod(data_list = nrfish24,
                                    inits = nrfish_models[[1]]$estimated_params,
                                    map = NULL,
                                    estimateMode = 0, # Estimate
                                    random_rec = TRUE, # No random recruitment
                                    verbose = 1,
                                    recFun = build_srr(
                                        srr_fun = 1,
                                        srr_indices = c(nrfish_indices[i])),
                                    initMode = 1, # Assume unfished equilibrium
                                    M1Fun = build_M1(updateM1 = TRUE,
                                                     M1_model = 1,
                                                     M1_use_prior = TRUE,
                                                     M_prior = 0.06,
                                                     M_prior_sd = 0.05),
                                    phase = FALSE,
                                    HCR = build_hcr(HCR = 5, # Tier3 HCR
                                                    Ftarget = 0.4, # F40%
                                                    Flimit = 0.35, # F35%
                                                    Plimit = 0, # No fishing limit
                                                    Alpha = 0.05))
}



# 3) Performance metrics ----
# Function to get ABC
get_ABC <- function(model, year = 1){
    catch_data <- model$data_list$catch_data
    catch_data$Projected = model$quantities$catch_hat
    ABC = catch_data %>%
        dplyr::filter(Year == model$data_list$endyr + year) %>%
        dplyr::summarise(ABC = sum(Projected)) %>%
        dplyr::pull(ABC)

    return(ABC)
}


# * Cod ----
# cod_retro <- lapply(cod_models, function(x) retrospective(x, peels = 10))
cod_pm <- data.frame(Species = "Cod",
                     Model = c("Base", colnames(pcod24$env_data)[cod_indices+1]),
                     AIC = sapply(cod_models, function(x) x$opt$AIC),
                     dAIC = sapply(cod_models, function(x) x$opt$AIC) - min(sapply(cod_models, function(x) x$opt$AIC)),
                     Beta = sapply(cod_models, function(x) sum(x$estimated_params$beta_rec_pars)), # Using sum because no other betas are used
                     SigmaR = sapply(cod_models, function(x) exp(x$estimated_params$R_ln_sd)),
                     ABC_1yr = sapply(cod_models, function(x) get_ABC(x, year = 1)),
                     ABC_2yr = sapply(cod_models, function(x) get_ABC(x, year = 2))
                     # Mohns_SSB = sapply(cod_retro, function(x) x$mohns[5,4]),
                     # Mohns_B = sapply(cod_retro, function(x) x$mohns[1,4]),
                     # Mohns_R = sapply(cod_retro, function(x) x$mohns[9,4]),
                     # Mohns_R_1yr = sapply(cod_retro, function(x) x$mohns[10,4]),
                     # Mohns_R_2yr = sapply(cod_retro, function(x) x$mohns[11,4]),
                     # Mohns_beta = sapply(cod_retro, function(x)  sum(x$mohns[18:25,4], na.rm = TRUE))
)

# - Save
write.csv(cod_pm, file = "Results/Performance metric results cod.csv")

# - Plots
plot_biomass(cod_models, model_names = cod_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Cod")
plot_recruitment(cod_models, model_names = cod_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Cod")
plot_ssb(cod_models, model_names = cod_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Cod")

# for(i in 1:length(cod_models)){
#     plot_biomass(cod_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                  file = paste0("Results/Retrospectives/Cod_",cod_pm$Model[i])
#     )
#
#     plot_recruitment(cod_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                      file = paste0("Results/Retrospectives/Cod_",cod_pm$Model[i]))
# }


# * Pollock ----
# pk_retro <- lapply(pk_models, function(x) retrospective(x, peels = 10))
pk_pm <- data.frame(Species = "Pollock",
                    Model = c("Base", colnames(pollock24$env_data)[pk_indices+1]),
                    AIC = sapply(pk_models, function(x) x$opt$AIC),
                    dAIC = sapply(pk_models, function(x) x$opt$AIC) - min(sapply(pk_models, function(x) x$opt$AIC)),
                    Beta = sapply(pk_models, function(x) sum(x$estimated_params$beta_rec_pars)), # Using sum because no other betas are used
                    SigmaR = sapply(pk_models, function(x) exp(x$estimated_params$R_ln_sd)),
                    ABC_1yr = sapply(pk_models, function(x) get_ABC(x, year = 1)),
                    ABC_2yr = sapply(pk_models, function(x) get_ABC(x, year = 2))
                    # Mohns_SSB = sapply(pk_retro, function(x) x$mohns[5,4]),
                    # Mohns_B = sapply(pk_retro, function(x) x$mohns[1,4]),
                    # Mohns_R = sapply(pk_retro, function(x) x$mohns[9,4]),
                    # Mohns_R_1yr = sapply(pk_retro, function(x) x$mohns[10,4]),
                    # Mohns_R_2yr = sapply(pk_retro, function(x) x$mohns[11,4]),
                    # Mohns_beta = sapply(pk_retro, function(x)  sum(x$mohns[18:25,4], na.rm = TRUE))
)

# - Save
write.csv(pk_pm, file = "Results/Performance metric results pollock.csv")

# - Plots
plot_biomass(pk_models, model_names = pk_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Pollock")
plot_recruitment(pk_models, model_names = pk_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Pollock")
plot_ssb(pk_models, model_names = pk_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Pollock")

# for(i in 1:length(pk_models)){
#     plot_biomass(pk_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                  file = paste0("Results/Retrospectives/Pollock_",pk_pm$Model[i])
#     )
#
#     plot_recruitment(pk_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                      file = paste0("Results/Retrospectives/Pollock_",pk_pm$Model[i]))
# }


# * ATF ----
atf_retro <- lapply(atf_models, function(x) retrospective(x, peels = 10))
atf_pm <- data.frame(Species = "ATF",
                     Model = c("Base", colnames(atf23$env_data)[atf_indices+1]),
                     AIC = sapply(atf_models, function(x) x$opt$AIC),
                     dAIC = sapply(atf_models, function(x) x$opt$AIC) - min(sapply(atf_models, function(x) x$opt$AIC)),
                     Beta = sapply(atf_models, function(x) sum(x$estimated_params$beta_rec_pars)), # Using sum because no other betas are used
                     SigmaR = sapply(atf_models, function(x) exp(x$estimated_params$R_ln_sd)),
                     ABC_1yr = sapply(atf_models, function(x) get_ABC(x, year = 1)),
                     ABC_2yr = sapply(atf_models, function(x) get_ABC(x, year = 2)),
                     Mohns_SSB = sapply(atf_retro, function(x) x$mohns[5,4]),
                     Mohns_B = sapply(atf_retro, function(x) x$mohns[1,4]),
                     Mohns_R = sapply(atf_retro, function(x) x$mohns[9,4]),
                     Mohns_R_1yr = sapply(atf_retro, function(x) x$mohns[10,4]),
                     Mohns_R_2yr = sapply(atf_retro, function(x) x$mohns[11,4]),
                     Mohns_beta = sapply(atf_retro, function(x)  sum(x$mohns[18:25,4], na.rm = TRUE))
)

# - Save
write.csv(atf_pm, file = "Results/Performance metric results atf.csv")

# - Plots
plot_biomass(atf_models, model_names = atf_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/ATF")
plot_recruitment(atf_models, model_names = atf_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/ATF")
plot_ssb(atf_models, model_names = atf_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/ATF")

# for(i in 1:length(atf_models)){
#     plot_biomass(atf_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                  file = paste0("Results/Retrospectives/ATF_",atf_pm$Model[i])
#     )
#
#     plot_recruitment(atf_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                      file = paste0("Results/Retrospectives/ATF_",atf_pm$Model[i]))
# }


# * Northern rockfish ----
# nrfish_retro <- lapply(nrfish_models, function(x) retrospective(x, peels = 10))
nrfish_pm <- data.frame(Species = "Northern rock fish",
                        Model = c("Base", colnames(nrfish24$env_data)[nrfish_indices+1]),
                        AIC = sapply(nrfish_models, function(x) x$opt$AIC),
                        dAIC = sapply(nrfish_models, function(x) x$opt$AIC) - min(sapply(nrfish_models, function(x) x$opt$AIC)),
                        Beta = sapply(nrfish_models, function(x) sum(x$estimated_params$beta_rec_pars)), # Using sum because no other betas are used
                        SigmaR = sapply(nrfish_models, function(x) exp(x$estimated_params$R_ln_sd)),
                        ABC_1yr = sapply(nrfish_models, function(x) get_ABC(x, year = 1)),
                        ABC_2yr = sapply(nrfish_models, function(x) get_ABC(x, year = 2))
                        # Mohns_SSB = sapply(nrfish_retro, function(x) x$mohns[5,4]),
                        # Mohns_B = sapply(nrfish_retro, function(x) x$mohns[1,4]),
                        # Mohns_R = sapply(nrfish_retro, function(x) x$mohns[9,4]),
                        # Mohns_R_1yr = sapply(nrfish_retro, function(x) x$mohns[10,4]),
                        # Mohns_R_2yr = sapply(nrfish_retro, function(x) x$mohns[11,4]),
                        # Mohns_beta = sapply(nrfish_retro, function(x)  sum(x$mohns[18:25,4], na.rm = TRUE))
)

# - Save
write.csv(nrfish_pm, file = "Results/Performance metric results northern rockfish.csv")

# - Plots
plot_biomass(nrfish_models, model_names = nrfish_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Northern rockfish")
plot_recruitment(nrfish_models, model_names = nrfish_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Northern rockfish")
plot_ssb(nrfish_models, model_names = nrfish_pm$Model, incl_proj = TRUE, maxyr = 2025, file = "Results/Figures/Northern rockfish")

# for(i in 1:length(nrfish_models)){
#     plot_biomass(nrfish_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                  file = paste0("Results/Retrospectives/Northern rockfish_",nrfish_pm$Model[i])
#     )
#
#     plot_recruitment(nrfish_retro[[i]]$Rceattle_list, model_names = c(paste0("Peel", 9:1), "Base"), line_col = c(1, paste0("grey", round(seq(80,20, length.out = 9)))),
#                      file = paste0("Results/Retrospectives/Northern rockfish_",nrfish_pm$Model[i]))
# }

# * Save ----
write.csv(do.call("rbind", list(cod_pm, pk_pm, atf_pm, nrfish_pm)), file = "Results/Performance metric results.csv")
