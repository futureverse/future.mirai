#' @tags nbrOfWorkers
#' @tags detritus-files
#' @tags mirai_multisession

library(future)

message("*** mirai_multisession - nbrOfWorkers() ...")

ncores <- availableCores()
plan(future.mirai::mirai_multisession)

n <- nbrOfWorkers()
message("Number of workers: ", n)
stopifnot(n == ncores)

n <- nbrOfFreeWorkers()
message("Number of free workers: ", n)
stopifnot(n == ncores)

plan(sequential)


message("*** mirai_cluster - nbrOfWorkers() ...")

mirai::daemons(2)
print(mirai::status())

plan(future.mirai::mirai_cluster)
print(c(nbrOfWorkers = nbrOfWorkers(), nbrOfFreeWorkers = nbrOfFreeWorkers()))

f <- future({
  Sys.sleep(2)
  42
})
print(c(
  nbrOfWorkers = nbrOfWorkers(),
  nbrOfFreeWorkers = nbrOfFreeWorkers(),
  resolved = resolved(f)
))

print(value(f))

plan(sequential)

message("*** nbrOfWorkers() ... DONE")

