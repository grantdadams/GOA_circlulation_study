library(dplyr)
library(tidyr)
library(Rceattle)

# Load environmental data ----
# Reconstruction NGAO labeled pc1) and GOADI (labeled pc2).
# * GOADI ----
goadi <- read.csv("Data/HauriIndex_outDW.csv") %>%
  mutate(Date = as.Date(paste(Date, "-01", sep=""))) %>%
  dplyr::select(-X)
goadi_recon <- read.table("Data/pc2_timeseries.txt") %>%
  mutate(Date = as.Date(paste(V1, "-01", sep=""))) %>%
  dplyr::rename(GOADI = V2) %>%
  dplyr::select(-V1)
goadi <- rbind(goadi, goadi_recon)

# * NGAO ----
ngao <- read.csv("Data/HauriIndex_outNGAO.csv") %>%
  mutate(Date = as.Date(paste(Date, "-01", sep=""))) %>%
  dplyr::select(-X)
ngao_recon <- read.table("Data/pc1_timeseries.txt") %>%
  mutate(Date = as.Date(paste(V1, "-01", sep=""))) %>%
  dplyr::rename(NGAO = V2) %>%
  dplyr::select(-V1)
ngao <- rbind(ngao, ngao_recon)


# * Create seasonal indices ----
seasons <- data.frame(Season = c("Spring", "Spring",
                                 "Spring", "Spring", "Spring",
                                 "Summer", "Summer", "Summer",
                                 "Summer", "Fall", "Fall",
                                 "Fall"),
                      Month = 1:12)


# This is currently set it up so winter is associated with age-0
ngao_annual <- ngao %>%
  mutate(Month = lubridate::month(Date),
         Year = lubridate::year(Date),
         # Year = ifelse(Month == 12, Year + 1, Year) # Set year up one for Dec winter
  ) %>%
  full_join(seasons) %>%
  dplyr::group_by(Year, Season) %>%
  dplyr::summarise(Index = mean(NGAO)) %>%
  pivot_wider(names_from = Season, values_from = Index) %>%
  dplyr::rename(NGAOr_fall = Fall,
                NGAOr_spring = Spring,
                NGAOr_summer = Summer)

goadi_annual <- goadi %>%
  mutate(Month = lubridate::month(Date),
         Year = lubridate::year(Date),
         # Year = ifelse(Month == 12, Year + 1, Year) # Set year up one for Dec winter
  ) %>%
  full_join(seasons) %>%
  dplyr::group_by(Year, Season) %>%
  dplyr::summarise(Index = mean(GOADI)) %>%
  pivot_wider(names_from = Season, values_from = Index) %>%
  dplyr::rename(GOADIr_fall = Fall,
                GOADIr_spring = Spring,
                GOADIr_summer = Summer)

# * Bridgette Indices ----
envdata <- read.csv("Data/RecrClimDSEMdata.csv")

envdata  <- envdata %>%
  dplyr::mutate(post2014 = year >= 2014 & year <= 2016) %>%
  dplyr::rename(Year = year) %>%
  full_join(goadi_annual) %>%
  full_join(ngao_annual) %>%
  # Rename covariates to intuitive names so the SEMs are easier to read ----
  dplyr::rename(
    NGAO_fall                 = NGAO.OND,
    GOADI_fall                = GOADI.OND,
    NGAO_spring               = NGAO.JFMAM,
    GOADI_spring              = GOADI.JFMAM,
    Upwelling_WGOA_spring     = BakunUpwellN60W149_JFMAM,
    Upwelling_EGOA_spring     = BakunUpwellN57W137_JFMAM,
    Wind_WGOA_spring          = SHEL.APRMAY.WINDDIR,
    SST_WGOA_shelfedge_spring = WGOA.SST.LL.spr.shelfedge,
    SST_EGOA_shelfedge_spring = EGOA.SST.LL.spr.shelfedge,
    BottomTemp_WGOA_winter    = Bot.temp.Shel.Win.MACE,
    SST_WGOA_spring           = SSTwgoaFMA,
    SST_EGOA_spring           = SSTegoaFMA,
    Neocalanus_winterspring   = Neocalanus.biom.LnP.WinSpr,
    Copepods_small_spring     = SWDLN.SM.CAL.COP.SPR
  ) %>%
  # Scale and center every covariate (z-score); keep Year/post2014 as-is ----
  dplyr::mutate(dplyr::across(
    -c(Year, post2014),
    ~ as.numeric(scale(.))
  ))






# Cod prior ----
M_prior_rce <- exp(-0.81)
M_prior_sd  <- 0.41

# M block effect: SS3 has a separate prior on the block-replacement value
# `NatM_BLK4repl_2014` (PR_type=3 lognormal, PRIOR=-0.81, PR_SD=0.41) that
# contributes ~1.10 to SS3 Parm_priors. SS3-estimated block value 0.817
# implies a post-2014 log-offset of log(0.817/0.493) ≈ 0.506.
# Wire that as a prior on the linkage coefficient: Normal(0, M_prior_sd)
# centers the offset at 0 (= no change from base) with the same SD as the
# M-base prior, so departures from base are penalized like SS3's per-block
# prior. Init at the SS3 ESTIM value to start in the right place.
m_block_init <- 0.817 - M_prior_rce
M1_block <- build_M1(
  M1_model     = 1,
  M1_use_prior = TRUE,
  M2_use_prior = FALSE,
  M_prior      = M_prior_rce,
  M_prior_sd   = M_prior_sd,
  linkages     = list(M1 = linkage_spec(
    formula = ~ post2014,
    by      = ~ species,
    init    = list(post2014 = m_block_init),
    # SS3 puts its prior on the absolute log(M_block) value at the SAME
    # center as log(M_base) (both N(-0.81, 0.41) independently). The
    # implied prior on the delta is therefore centered at 0 (with sd
    # 0.41*sqrt(2)=0.58 in the joint-independence sense, but here we use
    # the same 0.41 since the M base prior is also being applied).
    priors  = list(post2014 = normal(0, M_prior_sd))
  ))
)

