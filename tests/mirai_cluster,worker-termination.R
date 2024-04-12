source("incl/start.R")

message("*** mirai_multisession() - terminating workers ...")

plan(mirai_multisession, workers = 2L)

all <- nbrOfWorkers()
message("Number of workers: ", all)
stopifnot(all == 2L)
free <- nbrOfFreeWorkers()
message("Number of free workers: ", all)
stopifnot(free == 2L)


## Force R worker to quit
f <- future({ tools::pskill(pid = Sys.getpid()) })
res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "FutureError"))

stopifnot(
  nbrOfWorkers() == all - 1L,
  nbrOfFreeWorkers() == free - 1L
)

message("*** mirai_multisession() - terminating workers ... DONE")

source("incl/end.R")
