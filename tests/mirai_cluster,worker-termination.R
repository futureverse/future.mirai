source("incl/start.R")

message("*** mirai_multisession() - terminating workers ...")

plan(mirai_multisession, workers = 2L)

all <- nbrOfWorkers()
message("Number of workers: ", all)
stopifnot(all == 2L)
free <- nbrOfFreeWorkers()
message("Number of free workers: ", all)
stopifnot(free == 2L)

## Don't test on MS Windows, because that will leave behind a
## stray Rscript<hexcode> file, which 'R CMD check --as-cran'
## will complain about. /HB 2024-04-12
if (.Platform$OS.type != "windows") {
  ## Force R worker to quit
  f <- future({ tools::pskill(pid = Sys.getpid()) })
  res <- tryCatch(value(f), error = identity)
  print(res)
  stopifnot(inherits(res, "FutureError"))

  ## FIXME: nbrOfWorkers()/nbrOfFreeWorkers() can throw a FutureError,
  ## cf. https://github.com/HenrikBengtsson/future.mirai/issues/7
  nworkers <- tryCatch(nbrOfWorkers(), error = identity)
  print(nworkers)
  if (!inherits(nworkers, "error")) {
    message("Number of workers: ", nworkers)
    stopifnot(nworkers == all - 1L)
  }

  nfreeworkers <- tryCatch(nbrOfFreeWorkers(), error = identity)
  print(nfreeworkers)
  if (!inherits(nfreeworkers, "error")) {
    message("Number of free workers: ", nfreeworkers)
    stopifnot(nfreeworkers == free - 1L)
  }
}

message("*** mirai_multisession() - terminating workers ... DONE")

source("incl/end.R")
