#' @tags MiraiFutureBackend
#' @tags detritus-files
#' @tags mirai_cluster mirai_multisession

library(future)
library(future.mirai)

options(future.mirai.debug = TRUE)
options(future.debug = TRUE)

message("*** MiraiFutureBackend ...")


## ---------------------------------------------------------
## mirai_version()
## ---------------------------------------------------------
message("- mirai_version() ...")

v <- mirai_version()
stopifnot(inherits(v, "package_version"))
message("  mirai version: ", v)

## Second call should use cached value
v2 <- mirai_version()
stopifnot(identical(v, v2))

message("- mirai_version() ... DONE")


## ---------------------------------------------------------
## get_mirai_daemons() and mirai_daemons_nworkers()
## ---------------------------------------------------------
message("- get_mirai_daemons() and mirai_daemons_nworkers() ...")

## Setup daemons
mirai::daemons(2)

daemons <- get_mirai_daemons()
message("  daemons class: ", class(daemons)[1])
stopifnot(is.data.frame(daemons) || is.numeric(daemons))

nworkers <- mirai_daemons_nworkers()
message("  nworkers: ", nworkers)
stopifnot(is.numeric(nworkers), nworkers >= 1)

mirai::daemons(0)

message("- get_mirai_daemons() and mirai_daemons_nworkers() ... DONE")


## ---------------------------------------------------------
## tweak.mirai_cluster()
## ---------------------------------------------------------
message("- tweak.mirai_cluster() ...")

plan(future.mirai::mirai_multisession, workers = 2)
stopifnot(nbrOfWorkers() == 2L)

## Create a future to verify backend works after tweak
f <- future(42)
v <- value(f)
stopifnot(v == 42)

r <- resolved(f)
message("Resolved: ", r)

r <- result(f)
print(r)

plan(sequential)

message("- tweak.mirai_cluster() ... DONE")


## ---------------------------------------------------------
## Global variables that clash with mirai::mirai() formals
## ---------------------------------------------------------
message("- globals that clash with mirai::mirai() formals ...")

plan(future.mirai::mirai_multisession, workers = 2)

## '.args' is a formal argument of mirai::mirai()
## This should produce an error
res <- tryCatch({
  .args <- 42
  f <- future(.args)
  value(f)
}, error = identity)
print(res)
stopifnot(inherits(res, "FutureError"))
stopifnot(grepl("clash with argument names of mirai::mirai", conditionMessage(res)))

plan(sequential)

message("- globals that clash with mirai::mirai() formals ... DONE")


## ---------------------------------------------------------
## interruptFuture.MiraiFutureBackend() via cancel()
## ---------------------------------------------------------
message("- interruptFuture.MiraiFutureBackend() via cancel() ...")

plan(future.mirai::mirai_multisession, workers = 2)

## Create a long-running future
f <- future({
  Sys.sleep(60)
  42
})

r <- resolved(f)
message("Resolved: ", r)
stopifnot(!isTRUE(r))

## Cancel/interrupt the future
f <- cancel(f, interrupt = TRUE)
stopifnot(f[["state"]] == "canceled")

r <- resolved(f)
message("Resolved: ", r)

## Trying to get the value should produce a FutureInterruptError
res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "FutureInterruptError"))

plan(sequential)

message("- interruptFuture.MiraiFutureBackend() via cancel() ... DONE")


message("- stopWorkers.MiraiFutureBackend() with active futures ...")

plan(future.mirai::mirai_multisession, workers = 2, interrupts = FALSE)

message("nbrOfWorkers(): ", nbrOfWorkers())
message("nbrOfFreeWorkers(): ", nbrOfFreeWorkers())

## Create a long-running future
f <- future({
  Sys.sleep(60)
  42
})

r <- resolved(f)
message("Resolved: ", r)
stopifnot(!isTRUE(r))

plan(sequential)

message("- stopWorkers.MiraiFutureBackend() with active futures ... DONE")


## ---------------------------------------------------------
## Error when no mirai daemons are available
## ---------------------------------------------------------
message("- Error when no mirai daemons ...")

## Make sure no daemons are running
mirai::daemons(0)

## Try to create a MiraiFutureBackend without daemons
MiraiFutureBackend <- future.mirai:::MiraiFutureBackend
res <- tryCatch({
  MiraiFutureBackend()
}, error = identity)
print(res)
stopifnot(inherits(res, "FutureError"))
stopifnot(grepl("at least one mirai daemon", conditionMessage(res)))

message("- Error when no mirai daemons ... DONE")


## ---------------------------------------------------------
## mirai_cluster() function should always error when called directly
## ---------------------------------------------------------
message("- mirai_cluster() direct call ...")

res <- tryCatch({
  future.mirai::mirai_cluster()
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))
stopifnot(grepl("must never be called directly", conditionMessage(res)))

message("- mirai_cluster() direct call ... DONE")


## ---------------------------------------------------------
## resolved.MiraiFuture() with lazy future (state = "created")
## ---------------------------------------------------------
message("- resolved.MiraiFuture() for lazy future ...")

plan(future.mirai::mirai_multisession, workers = 2)

## Create a lazy future - it stays in "created" state until resolved
f <- future({ 42 }, lazy = TRUE)
stopifnot(f[["state"]] == "created")

## resolved() should launch the future
r <- resolved(f)
message("  resolved: ", r)
## After resolved() is called on a lazy future, it should be submitted
stopifnot(f[["state"]] %in% c("running", "finished"))

## Get the value
v <- value(f)
stopifnot(v == 42)

plan(sequential)

message("- resolved.MiraiFuture() for lazy future ... DONE")


## ---------------------------------------------------------
## nbrOfFreeWorkers.MiraiFutureBackend()
## ---------------------------------------------------------
message("- nbrOfFreeWorkers.MiraiFutureBackend() ...")

plan(future.mirai::mirai_multisession, workers = 2)

free <- nbrOfFreeWorkers()
message("  free workers: ", free)
stopifnot(is.numeric(free), free >= 0, free <= nbrOfWorkers())

## Create a future that takes some time
f <- future({ Sys.sleep(2); 42 })

## Check free workers while future is running
Sys.sleep(0.5)
free_during <- nbrOfFreeWorkers()
message("  free workers during execution: ", free_during)

## Wait for future to complete
v <- value(f)
stopifnot(v == 42)

## Check free workers after completion
free_after <- nbrOfFreeWorkers()
message("  free workers after: ", free_after)
stopifnot(free_after == nbrOfWorkers())

plan(sequential)

message("- nbrOfFreeWorkers.MiraiFutureBackend() ... DONE")


message("*** MiraiFutureBackend ... DONE")
