

# Arrowtooth ----
atfsem = "
  # link, lag, param_name, start_value
  # --------------------------------------------
  # GOADI
  # --------------------------------------------
  GOADI.JFMAM -> WGOA.SST.LL.spr.shelfedge, 0, GOADI_to_wSST, 0
  GOADI.JFMAM -> EGOA.SST.LL.spr.shelfedge, 0, GOADI_to_eSST, 0
  GOADI.JFMAM -> BakunUpwellN57W137_JFMAM, 0, GOADI_to_Up, 0
  GOADI.JFMAM -> Neocalanus.biom.LnP.WinSpr, 0, GOADI_to_Cal, 0

  # --------------------------------------------
  # NGAO
  # --------------------------------------------
  NGAO.JFMAM -> WGOA.SST.LL.spr.shelfedge, 0, NGAO_to_wSST, 0
  NGAO.JFMAM -> EGOA.SST.LL.spr.shelfedge, 0, NGAO_to_eSST, 0
  NGAO.JFMAM -> BakunUpwellN57W137_JFMAM, 0, NGAO_to_Up, 0
  NGAO.JFMAM -> Neocalanus.biom.LnP.WinSpr, 0, NGAO_to_Cal, 0

  # --------------------------------------------
  # Intermediaries
  # --------------------------------------------
  WGOA.SST.LL.spr.shelfedge -> Neocalanus.biom.LnP.WinSpr, 0, SST_to_Cal, 0

  # --------------------------------------------
  # Recruitment
  # --------------------------------------------
  WGOA.SST.LL.spr.shelfedge -> recdevs1, 1, wSST_to_R, 0
  EGOA.SST.LL.spr.shelfedge -> recdevs1, 1, eSST_to_R, 0
  BakunUpwellN57W137_JFMAM -> recdevs1, 1, Up_to_R, 0
  Neocalanus.biom.LnP.WinSpr -> recdevs1, 1, Cal_to_R, 0
  NGAO.JFMAM -> recdevs1, 1, NGAO_to_R, 0
  GOADI.JFMAM -> recdevs1, 1, GOADI_to_R, 0

  recdevs1 <-> recdevs1, 0, sigmaR1, 1
"

# Northern rockfish ----
norksem = "
  # link, lag, param_name, start_value
  # --------------------------------------------
  # GOADI
  # --------------------------------------------
  GOADI.JFMAM -> EGOA.SST.LL.spr.shelfedge, 0, GOADI_to_eSST, 0
  GOADI.JFMAM -> BakunUpwellN57W137_JFMAM, 0, GOADI_to_Up, 0
  GOADI.JFMAM -> WGOA.SST.LL.spr.shelfedge, 0, GOADI_to_wSST, 0
  GOADI.JFMAM -> Neocalanus.biom.LnP.WinSpr, 0, GOADI_to_Cal, 0

  # --------------------------------------------
  # NGAO
  # --------------------------------------------
  NGAO.JFMAM -> EGOA.SST.LL.spr.shelfedge, 0, NGAO_to_eSST, 0
  NGAO.JFMAM -> BakunUpwellN57W137_JFMAM, 0, NGAO_to_Up, 0
  NGAO.JFMAM -> WGOA.SST.LL.spr.shelfedge, 0, NGAO_to_wSST, 0
  NGAO.JFMAM -> Neocalanus.biom.LnP.WinSpr, 0, NGAO_to_Cal, 0

  # --------------------------------------------
  # Intermediaries
  # --------------------------------------------
  BakunUpwellN57W137_JFMAM -> WGOA.SST.LL.spr.shelfedge, 0, Up_to_SST, 0
  WGOA.SST.LL.spr.shelfedge -> Neocalanus.biom.LnP.WinSpr, 0, SST_to_Cal, 0

  # --------------------------------------------
  # Recruitment
  # --------------------------------------------
  EGOA.SST.LL.spr.shelfedge -> recdevs1, 1, eSST_to_R, 0
  BakunUpwellN57W137_JFMAM -> recdevs1, 1, Up_to_R, 0
  WGOA.SST.LL.spr.shelfedge -> recdevs1, 1, wSST_to_R, 0
  Neocalanus.biom.LnP.WinSpr -> recdevs1, 1, Cal_to_R, 0
  NGAO.JFMAM -> recdevs1, 1, NGAO_to_R, 0
  GOADI.JFMAM -> recdevs1, 1, GOADI_to_R, 0

  NGAO.OND -> recdevs1, 2, fallNGAO_to_R, 0
  GOADI.OND -> recdevs1, 2, fallGOADI_to_R, 0

  recdevs1 <-> recdevs1, 0, sigmaR1, 1
"

# Pollock ----
pollocksem = "
  # link, lag, param_name, start_value
  # --------------------------------------------
  # GOADI
  # --------------------------------------------
  GOADI.JFMAM -> SSTwgoaFMA, 0, GOADI_to_SST, 0
  GOADI.JFMAM -> SHEL.APRMAY.WINDDIR, 0, GOADI_to_Wind, 0
  GOADI.JFMAM -> BakunUpwellN60W149_JFMAM, 0, GOADI_to_Up, 0
  GOADI.JFMAM -> SWDLN.SM.CAL.COP.SPR, 0, GOADI_to_Cop, 0

  # --------------------------------------------
  # NGAO
  # --------------------------------------------
  NGAO.JFMAM -> SSTwgoaFMA, 0, NGAO_to_SST, 0
  NGAO.JFMAM -> SHEL.APRMAY.WINDDIR, 0, NGAO_to_Wind, 0
  NGAO.JFMAM -> BakunUpwellN60W149_JFMAM, 0, NGAO_to_Up, 0
  NGAO.JFMAM -> SWDLN.SM.CAL.COP.SPR, 0, NGAO_to_Cop, 0

  # --------------------------------------------
  # Intermediaries
  # --------------------------------------------
  SSTwgoaFMA -> SWDLN.SM.CAL.COP.SPR, 0, SST_to_Cop, 0


  # --------------------------------------------
  # Recruitment
  # --------------------------------------------
  SSTwgoaFMA -> recdevs1, 1, SST_to_R, 0
  SHEL.APRMAY.WINDDIR -> recdevs1, 1, Wind_to_R, 0
  SWDLN.SM.CAL.COP.SPR -> recdevs1, 1, Cop_to_R, 0
  BakunUpwellN60W149_JFMAM -> recdevs1, 1, Up_to_R, 0
  NGAO.JFMAM -> recdevs1, 1, NGAO_to_R, 0
  GOADI.JFMAM -> recdevs1, 1, GOADI_to_R, 0

  recdevs1 <-> recdevs1, 0, sigmaR1, 1
"

# Pcod ----
pcodsem = "
  # link, lag, param_name, start_value
  # --------------------------------------------
  # GOADI
  # --------------------------------------------
  GOADI.JFMAM -> SSTwgoaFMA, 0, GOADI_to_SST, 0
  GOADI.JFMAM -> Bot.temp.Shel.Win.MACE, 0, GOADI_to_BT, 0
  GOADI.JFMAM -> BakunUpwellN60W149_JFMAM, 0, GOADI_to_Up, 0
  GOADI.JFMAM -> SWDLN.SM.CAL.COP.SPR, 0, GOADI_to_Cop, 0

  # --------------------------------------------
  # NGAO
  # --------------------------------------------
  NGAO.JFMAM -> SSTwgoaFMA, 0, NGAO_to_SST, 0
  NGAO.JFMAM -> Bot.temp.Shel.Win.MACE, 0, NGAO_to_BT, 0
  NGAO.JFMAM -> BakunUpwellN60W149_JFMAM, 0, NGAO_to_Up, 0
  NGAO.JFMAM -> SWDLN.SM.CAL.COP.SPR, 0, NGAO_to_Cop, 0

  # --------------------------------------------
  # Intermediaries
  # --------------------------------------------
  SSTwgoaFMA -> SWDLN.SM.CAL.COP.SPR, 0, SST_to_Cop, 0
  BakunUpwellN60W149_JFMAM -> Bot.temp.Shel.Win.MACE, 0, Up_to_BT, 0

  # --------------------------------------------
  # Recruitment
  # --------------------------------------------
  SSTwgoaFMA -> recdevs1, 1, SST_to_R, 0
  Bot.temp.Shel.Win.MACE -> recdevs1, 1, BT_to_R, 0
  SWDLN.SM.CAL.COP.SPR -> recdevs1, 1, Cop_to_R, 0
  BakunUpwellN60W149_JFMAM -> recdevs1, 1, Up_to_R, 0
  NGAO.JFMAM -> recdevs1, 1, NGAO_to_R, 0
  GOADI.JFMAM -> recdevs1, 1, GOADI_to_R, 0

  recdevs1 <-> recdevs1, 0, sigmaR1, 1
"
