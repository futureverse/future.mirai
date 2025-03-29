#' @tags termination
#' @tags detritus-files
#' @tags mirai_multisession

library(future.mirai)

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

  ## When using a mirai dispatcher (dispatcher = TRUE), the
  ## workers are relaunched
  print(c(nbrOfWorkers = nbrOfWorkers(), nbrOfFreeWorkers = nbrOfFreeWorkers()))
  print(mirai::status())
}

plan(sequential)

message("*** mirai_multisession() - terminating workers ... DONE")

