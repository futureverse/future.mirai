source("incl/start.R")

message("*** nbrOfWorkers() ...")

ncores <- availableCores()

plan(mirai_multisession)

n <- nbrOfWorkers()
message("Number of workers: ", n)
stopifnot(n == ncores)

plan(sequential)

message("*** nbrOfWorkers() ... DONE")

source("incl/end.R")
