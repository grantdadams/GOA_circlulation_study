iidsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- Recruitment ---
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# Arrowtooth ----
atfsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_EGOA_spring,          0,  GOADI_to_eSST,    0
  GOADI_spring            ->  Upwelling_EGOA_spring,    0,  GOADI_to_Up,      0
  GOADI_spring            ->  Neocalanus_winterspring,  0,  GOADI_to_Cal,     0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_EGOA_spring,          0,  NGAO_to_eSST,     0
  NGAO_spring             ->  Upwelling_EGOA_spring,    0,  NGAO_to_Up,       0
  NGAO_spring             ->  Neocalanus_winterspring,  0,  NGAO_to_Cal,      0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 1,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  Neocalanus_winterspring ->  recdevs1,                 1,  Cal_to_R,         0
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

atfsem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  Upwelling_EGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  Upwelling_EGOA_spring,    0,  NGAO_to_Up,       0

  # --- Recruitment ---
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

atfsem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_EGOA_spring,          0,  GOADI_to_eSST,    0
  GOADI_spring            ->  Neocalanus_winterspring,  0,  GOADI_to_Cal,     0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_EGOA_spring,          0,  NGAO_to_eSST,     0
  NGAO_spring             ->  Neocalanus_winterspring,  0,  NGAO_to_Cal,      0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  Neocalanus_winterspring ->  recdevs1,                 1,  Cal_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"
atfsem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_EGOA_spring,          0,  GOADI_to_eSST,    0
  GOADI_spring            ->  Upwelling_EGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_EGOA_spring,          0,  NGAO_to_eSST,     0
  NGAO_spring             ->  Upwelling_EGOA_spring,    0,  NGAO_to_Up,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 1,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"


# Northern rockfish ----
norksem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_EGOA_spring,          0,  GOADI_to_SST,     0
  GOADI_spring            ->  Neocalanus_winterspring,  0,  GOADI_to_Cal,     0
  GOADI_spring            ->  Upwelling_EGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_EGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  Neocalanus_winterspring,  0,  NGAO_to_Cal,      0
  NGAO_spring             ->  Upwelling_EGOA_spring,    0,  NGAO_to_Up,       0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 1,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  Neocalanus_winterspring ->  recdevs1,                 1,  Cal_to_R,         0
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Fall drivers (lag 2) ---
  NGAO_fall               ->  recdevs1,                 2,  fallNGAO_to_R,    0
  GOADI_fall              ->  recdevs1,                 2,  fallGOADI_to_R,   0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

norksem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  Upwelling_EGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  Upwelling_EGOA_spring,    0,  NGAO_to_Up,       0

  # --- Recruitment ---
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

norksem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_EGOA_spring,          0,  GOADI_to_SST,     0
  GOADI_spring            ->  Neocalanus_winterspring,  0,  GOADI_to_Cal,     0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_EGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  Neocalanus_winterspring,  0,  NGAO_to_Cal,      0

  # --- Intermediaries ---
  SST_EGOA_spring         ->  Neocalanus_winterspring,  0,  SST_to_Cal,       0

  # --- Recruitment ---
  Neocalanus_winterspring ->  recdevs1,                 1,  Cal_to_R,         0

  # --- Fall drivers (lag 2) ---
  NGAO_fall               ->  recdevs1,                 2,  fallNGAO_to_R,    0
  GOADI_fall              ->  recdevs1,                 2,  fallGOADI_to_R,   0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

norksem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_EGOA_spring,          0,  GOADI_to_SST,     0
  GOADI_spring            ->  Upwelling_EGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_EGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  Upwelling_EGOA_spring,    0,  NGAO_to_Up,       0

  # --- Recruitment ---
  SST_EGOA_spring         ->  recdevs1,                 1,  eSST_to_R,        0
  Upwelling_EGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Fall drivers (lag 2) ---
  NGAO_fall               ->  recdevs1,                 2,  fallNGAO_to_R,    0
  GOADI_fall              ->  recdevs1,                 2,  fallGOADI_to_R,   0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"


# Pollock ----
pollocksem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_WGOA_spring,          0,  GOADI_to_SST,     0
  GOADI_spring            ->  Wind_WGOA_spring,         0,  GOADI_to_Wind,    0
  GOADI_spring            ->  Upwelling_WGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_WGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  Wind_WGOA_spring,         0,  NGAO_to_Wind,     0
  NGAO_spring             ->  Upwelling_WGOA_spring,    0,  NGAO_to_Up,       0
  NGAO_spring             ->  Copepods_small_spring,    0,  NGAO_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0
  Wind_WGOA_spring        ->  recdevs1,                 1,  Wind_to_R,        0
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"
pollocksem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  Wind_WGOA_spring,         0,  GOADI_to_Wind,    0
  GOADI_spring            ->  Upwelling_WGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  Wind_WGOA_spring,         0,  NGAO_to_Wind,     0
  NGAO_spring             ->  Upwelling_WGOA_spring,    0,  NGAO_to_Up,       0

  # --- Recruitment ---
  Wind_WGOA_spring        ->  recdevs1,                 1,  Wind_to_R,        0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

pollocksem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_WGOA_spring,          0,  GOADI_to_SST,     0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_WGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  Copepods_small_spring,    0,  NGAO_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0

  # --- Recruitment ---
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

pollocksem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_WGOA_spring,          0,  GOADI_to_SST,     0
  GOADI_spring            ->  Wind_WGOA_spring,         0,  GOADI_to_Wind,    0
  GOADI_spring            ->  Upwelling_WGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_WGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  Wind_WGOA_spring,         0,  NGAO_to_Wind,     0
  NGAO_spring             ->  Upwelling_WGOA_spring,    0,  NGAO_to_Up,       0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

# Pcod ----
pcodsem = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_WGOA_spring,          0,  GOADI_to_SST,     0
  GOADI_spring            ->  BottomTemp_WGOA_winter,   0,  GOADI_to_BT,      0
  GOADI_spring            ->  Upwelling_WGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_WGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  BottomTemp_WGOA_winter,   0,  NGAO_to_BT,       0
  NGAO_spring             ->  Upwelling_WGOA_spring,    0,  NGAO_to_Up,       0
  NGAO_spring             ->  Copepods_small_spring,    0,  NGAO_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0
  Upwelling_WGOA_spring   ->  BottomTemp_WGOA_winter,   0,  Up_to_BT,         0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0
  BottomTemp_WGOA_winter  ->  recdevs1,                 1,  BT_to_R,          0
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"
pcodsem_tran = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) --
  GOADI_spring            ->  Upwelling_WGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  Upwelling_WGOA_spring,    0,  NGAO_to_Up,       0

  # --- Recruitment ---
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

pcodsem_prey = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_WGOA_spring,          0,  GOADI_to_SST,     0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_WGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  Copepods_small_spring,    0,  NGAO_to_Cop,      0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0

  # --- Recruitment ---
  Copepods_small_spring   ->  recdevs1,                 1,  Cop_to_R,         0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"

pcodsem_hab = "
  # source                  link  target,                    lag param_name        start
  # ------------------------------------------------------------------------------------
  # --- GOADI (spring) ---
  GOADI_spring            ->  SST_WGOA_spring,          0,  GOADI_to_SST,     0
  GOADI_spring            ->  BottomTemp_WGOA_winter,   0,  GOADI_to_BT,      0
  GOADI_spring            ->  Upwelling_WGOA_spring,    0,  GOADI_to_Up,      0

  # --- NGAO (spring) ---
  NGAO_spring             ->  SST_WGOA_spring,          0,  NGAO_to_SST,      0
  NGAO_spring             ->  BottomTemp_WGOA_winter,   0,  NGAO_to_BT,       0
  NGAO_spring             ->  Upwelling_WGOA_spring,    0,  NGAO_to_Up,       0

  # --- Intermediaries ---
  SST_WGOA_spring         ->  Copepods_small_spring,    0,  SST_to_Cop,       0
  Upwelling_WGOA_spring   ->  BottomTemp_WGOA_winter,   0,  Up_to_BT,         0

  # --- Recruitment ---
  SST_WGOA_spring         ->  recdevs1,                 1,  SST_to_R,         0
  BottomTemp_WGOA_winter  ->  recdevs1,                 1,  BT_to_R,          0
  Upwelling_WGOA_spring   ->  recdevs1,                 1,  Up_to_R,          0
  NGAO_spring             ->  recdevs1,                 1,  NGAO_to_R,        0
  GOADI_spring            ->  recdevs1,                 1,  GOADI_to_R,       0

  # --- Recruitment variance ---
  recdevs1 <-> recdevs1,                                0,  sigmaR1,          1
"
