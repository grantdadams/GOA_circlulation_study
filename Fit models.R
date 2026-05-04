library(Rceattle)


# Arrowtooth ----
mydata_atf <- Rceattle::read_data( file = "data/2023_GOA_arrowtooth.xlsx")
goa_atf <- Rceattle::fit_mod(data_list = mydata_atf,
                                inits = NULL, # Initial parameters = 0
                                file = NULL, # Don't save
                                estimateMode = 0, # Estimate
                                random_rec = FALSE, # No random recruitment
                                msmMode = 0, # Single species mode
                                verbose = 1,
                                phase = TRUE,
                                initMode = 1)
