#' @tags nbrOfWorkers
#' @tags detritus-files
#' @tags mirai_multisession

library(future)

message("*** nbrOfWorkers() ...")

ncores <- availableCores()

plan(future.mirai::mirai_multisession)

n <- nbrOfWorkers()
message("Number of workers: ", n)
stopifnot(n == ncores)

plan(sequential)

message("*** nbrOfWorkers() ... DONE")

