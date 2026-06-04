# SEMs results.R --------------------------------------------------------------
# For every DSEM model that CONVERGED, take its SEM specification from SEMs.R and
# rewrite it with the ESTIMATED path coefficients in place of the start values,
# annotating each path with an R-style significance code from its p-value.
#
# Converged models are those present in Results/Initial_DSEM.csv -- the saved
# summary(<fit>)$coefficients table (path, lag, name, start, Estimate, Std_Error,
# z_value, p_value, Model, Species). Non-converged fits were not saved there.
#
# Output (per converged species):
#   - the SEM text with each path's start value replaced by its estimate, and the
#     significance code as a trailing `#` comment. Because the code lives in a
#     comment, the result is still a valid SEM that can be re-sourced (the
#     estimates then act as start values for a refit).
# Results are printed and written to Results/Initial_DSEM_estimated_sems.txt.
# ------------------------------------------------------------------------------

library(dplyr)

# Canonical SEM specifications: atfsem, norksem, pollocksem, pcodsem
source("SEMs.R")

# Estimated coefficients for the converged models
results_csv  <- "Results/Initial_DSEM.csv"
dsem_results <- read.csv(results_csv, row.names = 1, stringsAsFactors = FALSE)

# Significance codes ----------------------------------------------------------
# Mirrors:  summary(<fit>, cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
#                          symbols   = c("***", "**", "*", ".", " "))
# summary.Rceattle() does not apply these itself, so build the code from p_value.
sig_cutpoints <- c(0, 0.001, 0.01, 0.05, 0.1, 1)
sig_symbols   <- c("***", "**", "*", ".", " ")
sig_legend    <- "Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1"
sig_code <- function(p) {
  as.character(stats::symnum(p, corr = FALSE, na = FALSE,
                             cutpoints = sig_cutpoints, symbols = sig_symbols))
}

# Map a Species label in the results file to its SEM specification -------------
sem_for_species <- function(species) {
  key <- tolower(trimws(species))
  if (key %in% c("cod", "pcod", "pacific cod"))                return(pcodsem)
  if (key %in% c("pollock", "walleye pollock"))                return(pollocksem)
  if (key %in% c("nork", "northern rockfish"))                 return(norksem)
  if (key %in% c("atf", "arrowtooth", "arrowtooth flounder"))  return(atfsem)
  warning("No SEM mapped for species: ", species)
  NULL
}

# Rewrite one SEM, substituting estimates for start values --------------------
fill_sem <- function(sem, est_tab) {
  # est_tab: data.frame with columns `name`, `Estimate`, `p_value` for one model.
  lines <- strsplit(sem, "\n", fixed = TRUE)[[1]]

  filled <- vapply(lines, function(line) {
    # Pass comment-only and non-path lines through unchanged
    if (grepl("^[[:space:]]*#", line) || !grepl("->", line)) return(line)

    fields <- strsplit(line, ",", fixed = TRUE)[[1]]
    if (length(fields) < 4) return(line)

    nm  <- trimws(fields[3])
    row <- est_tab[est_tab$name == nm, , drop = FALSE]
    if (nrow(row) == 0) return(line)            # path not in the converged fit

    est  <- row$Estimate[1]
    pval <- row$p_value[1]
    star <- sig_code(pval)

    # Keep the original path/lag/name spacing; replace only the numeric token of
    # the start (4th) field, preserving its leading whitespace so the estimate
    # column stays aligned with the original layout.
    lead <- gsub("[^[:space:]].*$", "", fields[4])
    fields[4] <- paste0(lead, formatC(sprintf("%.4f", est), width = -9))
    sprintf("%s  # %-3s (p = %s)",
            paste(fields, collapse = ","), star, formatC(pval, format = "g", digits = 2))
  }, character(1), USE.NAMES = FALSE)

  paste(filled, collapse = "\n")
}

# Build a filled SEM for each converged model ---------------------------------
converged_species <- unique(dsem_results$Species[dsem_results$Model == "DSEM"])

estimated_sems <- list()
report_chunks  <- character(0)

for (sp in converged_species) {
  sem <- sem_for_species(sp)
  if (is.null(sem)) next

  est_tab <- dsem_results %>%
    dplyr::filter(.data$Species == sp, .data$Model == "DSEM") %>%
    dplyr::select("name", "Estimate", "p_value")

  filled <- fill_sem(sem, est_tab)
  estimated_sems[[sp]] <- filled

  header <- sprintf("# ===== %s (DSEM) -- estimated path coefficients =====\n# %s",
                    sp, sig_legend)
  chunk  <- paste(header, paste0(sp, "_sem_fit = \"", filled, "\""), sep = "\n")
  report_chunks <- c(report_chunks, chunk)

  cat("\n", chunk, "\n", sep = "")
}

# Save all converged models to one file ---------------------------------------
out_file <- file.path("Results", "Initial_DSEM_estimated_sems.txt")
writeLines(paste(report_chunks, collapse = "\n\n\n"), out_file)
message("Wrote estimated SEMs for ", length(estimated_sems), " converged model(s) to ", out_file)
