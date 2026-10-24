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
mirai::daemons(0)


message("*** nbrOfFreeWorkers() when tasks exceed workers ...")

mirai::daemons(1, dispatcher = TRUE)
plan(future.mirai::mirai_cluster)
stopifnot(nbrOfWorkers() == 1L)
stopifnot(nbrOfFreeWorkers() == 1L)

## Launch more tasks than daemon workers (tasks queued at dispatcher)
m1 <- mirai::mirai(Sys.sleep(1.0))
m2 <- mirai::mirai(Sys.sleep(1.0))
Sys.sleep(0.1)
free <- nbrOfFreeWorkers()
message("Number of free workers: ", free)
stopifnot(free == 0L)

plan(sequential)
mirai::daemons(0)

message("*** nbrOfFreeWorkers() when tasks exceed workers ... DONE")


message("*** nbrOfWorkers() ... DONE")

