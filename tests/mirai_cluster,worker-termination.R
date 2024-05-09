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

  message("Number of workers: ", nbrOfWorkers())
  message("Number of free workers: ", nbrOfFreeWorkers())

  ## We skip assertion on CRAN, because this test seems unreliable, e.g.
  ## nbrOfWorkers() == all - 1L might not be true, which could be due to
  ## timing issues [1] /HB 2024-05-09
  ## [1] https://github.com/HenrikBengtsson/future.mirai/issues/7
  if (interactive() || isTRUE(Sys.getenv("NOT_CRAN", NA_character_))) {
    stopifnot(
      nbrOfWorkers() == all - 1L,
      nbrOfFreeWorkers() == free - 1L
    )
  }
}

message("*** mirai_multisession() - terminating workers ... DONE")

source("incl/end.R")
