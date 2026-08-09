# This script contains 3 nested SEMs for each species:
# - 1) an IID sem with AR1 processes for each environmental variable to maintain AIC comparison
# - 2) a "direct" sem that links GOADI and NGAO directly to recruitment AND AR1 processes for each environmental variable to maintain AIC comparison
# - 3) the "full" sem that links GOADI and NGAO via intermediate paths to recruitment AND AR1 processes for each environmental variable to maintain AIC comparison
# - 4) a tranport mechanistic model connecting the GOADI and NGAO to recruitment AND AR1 processes for each environmental variable to maintain AIC comparison
# - 5) a prey mechanistic model connecting the GOADI and NGAO to recruitment AND AR1 processes for each environmental variable to maintain AIC comparison
# - 6) a habitat mechanistic model connecting the GOADI and NGAO to recruitment AND AR1 processes for each environmental variable to maintain AIC comparison

# Arrowtooth ----
# * IID sem ----
atfiidsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring           ->  GOADIr_spring,            1,  GOADIr_spring_AR1,            0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  NGAOr_spring            ->  NGAOr_spring,             1,  NGAOr_spring_AR1,             0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Direct sem ----
atfdirectsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring           ->  GOADIr_spring,            1,  GOADIr_spring_AR1,            0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  NGAOr_spring            ->  NGAOr_spring,             1,  NGAOr_spring_AR1,             0

  # --- Recruitment ---
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Full sem ----
atfsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring           ->  GOADIr_spring,            1,  GOADIr_spring_AR1,            0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  NGAOr_spring            ->  NGAOr_spring,             1,  NGAOr_spring_AR1,             0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_EGOA_spring,          0,  GOADIr_to_eSST,    0
  GOADIr_spring            ->  Upwelling_EGOA_spring,    0,  GOADIr_to_Up,      0
  GOADIr_spring            ->  Neocalanus_winterspring,  0,  GOADIr_to_Cal,     0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_EGOA_spring,          0,  NGAOr_to_eSST,     0
  NGAOr_spring             ->  Upwelling_EGOA_spring,    0,  NGAOr_to_Up,       0
  NGAOr_spring             ->  Neocalanus_winterspring,  0,  NGAOr_to_Cal,      0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 1,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  Neocalanus_winterspring ->  recdevs1,                 1,  Cal_to_R,         0
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Transport sem ----
atfsem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  Upwelling_EGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  Upwelling_EGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Recruitment ---
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Prey sem ----
atfsem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_EGOA_spring,          0,  GOADIr_to_eSST,    0
  GOADIr_spring            ->  Neocalanus_winterspring,  0,  GOADIr_to_Cal,     0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_EGOA_spring,          0,  NGAOr_to_eSST,     0
  NGAOr_spring             ->  Neocalanus_winterspring,  0,  NGAOr_to_Cal,      0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  Neocalanus_winterspring ->  recdevs1,                 1,  Cal_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Habitat sem ----
atfsem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_EGOA_spring,          0,  GOADIr_to_eSST,    0
  GOADIr_spring            ->  Upwelling_EGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_EGOA_spring,          0,  NGAOr_to_eSST,     0
  NGAOr_spring             ->  Upwelling_EGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 1,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# Northern rockfish ----
# * IID sem ----
norkiidsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,           1,  GOADIr_spring_AR1,            0
  SST_EGOA_spring          ->  SST_EGOA_spring,         1,  SST_EGOA_spring_AR1,          0
  Neocalanus_winterspring  ->  Neocalanus_winterspring, 1,  Neocalanus_winterspring_AR1,  0
  Upwelling_EGOA_spring    ->  Upwelling_EGOA_spring,   1,  Upwelling_EGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,            1,  NGAOr_spring_AR1,             0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Direct sem ----
norkdirectsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,           1,  GOADIr_spring_AR1,            0
  SST_EGOA_spring          ->  SST_EGOA_spring,         1,  SST_EGOA_spring_AR1,          0
  Neocalanus_winterspring  ->  Neocalanus_winterspring, 1,  Neocalanus_winterspring_AR1,  0
  Upwelling_EGOA_spring    ->  Upwelling_EGOA_spring,   1,  Upwelling_EGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,            1,  NGAOr_spring_AR1,             0

  # --- Recruitment ---
  NGAOr_spring             ->  recdevs1,                 2,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 2,  GOADIr_to_R,       0


  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Full sem ----
norksem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,           1,  GOADIr_spring_AR1,            0
  SST_EGOA_spring          ->  SST_EGOA_spring,         1,  SST_EGOA_spring_AR1,          0
  Neocalanus_winterspring  ->  Neocalanus_winterspring, 1,  Neocalanus_winterspring_AR1,  0
  Upwelling_EGOA_spring    ->  Upwelling_EGOA_spring,   1,  Upwelling_EGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,            1,  NGAOr_spring_AR1,             0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_EGOA_spring,          0,  GOADIr_to_SST,     0
  GOADIr_spring            ->  Neocalanus_winterspring,  0,  GOADIr_to_Cal,     0
  GOADIr_spring            ->  Upwelling_EGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_EGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  Neocalanus_winterspring,  0,  NGAOr_to_Cal,      0
  NGAOr_spring             ->  Upwelling_EGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 2,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 2,  Up_to_R,          0
  Neocalanus_winterspring ->  recdevs1,                 2,  Cal_to_R,         0
  NGAOr_spring             ->  recdevs1,                 2,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 2,  GOADIr_to_R,       0


  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Transport sem ----
norksem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
   # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  Upwelling_EGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  Upwelling_EGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Recruitment ---
  Upwelling_EGOA_spring   ->  recdevs1,                 2,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Prey sem ----
norksem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
   # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_EGOA_spring,          0,  GOADIr_to_SST,     0
  GOADIr_spring            ->  Neocalanus_winterspring,  0,  GOADIr_to_Cal,     0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_EGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  Neocalanus_winterspring,  0,  NGAOr_to_Cal,      0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  Neocalanus_winterspring ->  recdevs1,                 2,  Cal_to_R,         0


  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Habitat sem ----
norksem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_EGOA_spring         ->  SST_EGOA_spring,          1,  SST_EGOA_spring_AR1,          0
  Neocalanus_winterspring ->  Neocalanus_winterspring,  1,  Neocalanus_winterspring_AR1,  0
  Upwelling_EGOA_spring   ->  Upwelling_EGOA_spring,    1,  Upwelling_EGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_EGOA_spring,          0,  GOADIr_to_SST,     0
  GOADIr_spring            ->  Upwelling_EGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_EGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  Upwelling_EGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 2,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 2,  Up_to_R,          0
  NGAOr_spring             ->  recdevs1,                 2,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 2,  GOADIr_to_R,       0


  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"


# Pollock ----
# * IID sem ----
pollockiidsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  Wind_WGOA_spring        ->  Wind_WGOA_spring,         1,  Wind_WGOA_spring_AR1,         0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Direct sem ----
pollockdirectsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  Wind_WGOA_spring        ->  Wind_WGOA_spring,         1,  Wind_WGOA_spring_AR1,         0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- Recruitment ---
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Full sem ----
pollocksem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  Wind_WGOA_spring        ->  Wind_WGOA_spring,         1,  Wind_WGOA_spring_AR1,         0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_WGOA_spring,          0,  GOADIr_to_SST,     0
  GOADIr_spring            ->  Wind_WGOA_spring,         0,  GOADIr_to_Wind,    0
  GOADIr_spring            ->  Upwelling_WGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_WGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  Wind_WGOA_spring,         0,  NGAOr_to_Wind,     0
  NGAOr_spring             ->  Upwelling_WGOA_spring,    0,  NGAOr_to_Up,       0
  NGAOr_spring             ->  Copepods_small_spring,    0,  NGAOr_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0
  Wind_WGOA_spring        ->  recdevs1,                 1,  Wind_to_R,        0
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Transport sem ----
pollocksem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
   # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  Wind_WGOA_spring        ->  Wind_WGOA_spring,         1,  Wind_WGOA_spring_AR1,         0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  Wind_WGOA_spring,         0,  GOADIr_to_Wind,    0
  GOADIr_spring            ->  Upwelling_WGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  Wind_WGOA_spring,         0,  NGAOr_to_Wind,     0
  NGAOr_spring             ->  Upwelling_WGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Recruitment ---
  Wind_WGOA_spring        ->  recdevs1,                 1,  Wind_to_R,        0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Prey sem ----
pollocksem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  Wind_WGOA_spring        ->  Wind_WGOA_spring,         1,  Wind_WGOA_spring_AR1,         0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_WGOA_spring,          0,  GOADIr_to_SST,     0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_WGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  Copepods_small_spring,    0,  NGAOr_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0

  # --- Recruitment ---
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Habitat sem ----
pollocksem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  Wind_WGOA_spring        ->  Wind_WGOA_spring,         1,  Wind_WGOA_spring_AR1,         0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_WGOA_spring,          0,  GOADIr_to_SST,     0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_WGOA_spring,          0,  NGAOr_to_SST,      0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# Pcod ----
# * IID sem ----
pcodiidsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  BottomTemp_WGOA_winter  ->  BottomTemp_WGOA_winter,   1,  BottomTemp_WGOA_winter_AR1,   0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Direct sem ----
pcoddirectsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  BottomTemp_WGOA_winter  ->  BottomTemp_WGOA_winter,   1,  BottomTemp_WGOA_winter_AR1,   0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- Recruitment ---
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Full sem ----
pcodsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  BottomTemp_WGOA_winter  ->  BottomTemp_WGOA_winter,   1,  BottomTemp_WGOA_winter_AR1,   0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_WGOA_spring,          0,  GOADIr_to_SST,     0
  GOADIr_spring            ->  BottomTemp_WGOA_winter,   0,  GOADIr_to_BT,      0
  GOADIr_spring            ->  Upwelling_WGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_WGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  BottomTemp_WGOA_winter,   0,  NGAOr_to_BT,       0
  NGAOr_spring             ->  Upwelling_WGOA_spring,    0,  NGAOr_to_Up,       0
  NGAOr_spring             ->  Copepods_small_spring,    0,  NGAOr_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0
  Upwelling_WGOA_spring   ->  BottomTemp_WGOA_winter,   0,  Up_to_BT,         0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0
  BottomTemp_WGOA_winter  ->  recdevs1,                 1,  BT_to_R,          0
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Transport sem ----
pcodsem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  BottomTemp_WGOA_winter  ->  BottomTemp_WGOA_winter,   1,  BottomTemp_WGOA_winter_AR1,   0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) --
  GOADIr_spring            ->  Upwelling_WGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  Upwelling_WGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Recruitment ---
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Prey sem ----
pcodsem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  BottomTemp_WGOA_winter  ->  BottomTemp_WGOA_winter,   1,  BottomTemp_WGOA_winter_AR1,   0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_WGOA_spring,          0,  GOADIr_to_SST,     0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_WGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  Copepods_small_spring,    0,  NGAOr_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0

  # --- Recruitment ---
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# * Habitat sem ----
pcodsem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- AR1 processes (one per environmental variable) ---
  GOADIr_spring            ->  GOADIr_spring,             1,  GOADIr_spring_AR1,             0
  SST_WGOA_spring         ->  SST_WGOA_spring,          1,  SST_WGOA_spring_AR1,          0
  BottomTemp_WGOA_winter  ->  BottomTemp_WGOA_winter,   1,  BottomTemp_WGOA_winter_AR1,   0
  Upwelling_WGOA_spring   ->  Upwelling_WGOA_spring,    1,  Upwelling_WGOA_spring_AR1,    0
  NGAOr_spring             ->  NGAOr_spring,              1,  NGAOr_spring_AR1,              0
  Copepods_small_spring   ->  Copepods_small_spring,    1,  Copepods_small_spring_AR1,    0

  # --- GOADI (spring) ---
  GOADIr_spring            ->  SST_WGOA_spring,          0,  GOADIr_to_SST,     0
  GOADIr_spring            ->  BottomTemp_WGOA_winter,   0,  GOADIr_to_BT,      0
  GOADIr_spring            ->  Upwelling_WGOA_spring,    0,  GOADIr_to_Up,      0

  # --- NGAO (spring) ---
  NGAOr_spring             ->  SST_WGOA_spring,          0,  NGAOr_to_SST,      0
  NGAOr_spring             ->  BottomTemp_WGOA_winter,   0,  NGAOr_to_BT,       0
  NGAOr_spring             ->  Upwelling_WGOA_spring,    0,  NGAOr_to_Up,       0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0
  Upwelling_WGOA_spring   ->  BottomTemp_WGOA_winter,   0,  Up_to_BT,         0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0
  BottomTemp_WGOA_winter  ->  recdevs1,                 1,  BT_to_R,          0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAOr_spring             ->  recdevs1,                 1,  NGAOr_to_R,        0
  GOADIr_spring            ->  recdevs1,                 1,  GOADIr_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"


