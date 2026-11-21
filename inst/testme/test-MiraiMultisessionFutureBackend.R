#' @tags MiraiMultisessionFutureBackend
#' @tags detritus-files
#' @tags mirai_multisession

library(future)
library(future.mirai)

message("*** MiraiMultisessionFutureBackend ...")


## ---------------------------------------------------------
## mirai_multisession() function should always error when called directly
## ---------------------------------------------------------
message("- mirai_multisession() direct call ...")

res <- tryCatch({
  future.mirai::mirai_multisession()
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))
stopifnot(grepl("must never be called directly", conditionMessage(res)))

message("- mirai_multisession() direct call ... DONE")


## ---------------------------------------------------------
## MiraiMultisessionFutureBackend() called directly
## ---------------------------------------------------------
message("- MiraiMultisessionFutureBackend() direct call ...")

MiraiMultisessionFutureBackend <- future.mirai:::MiraiMultisessionFutureBackend

## Invalid 'workers'
res <- tryCatch(MiraiMultisessionFutureBackend(workers = "2"), error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch(MiraiMultisessionFutureBackend(workers = 0L), error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch(MiraiMultisessionFutureBackend(workers = c(2L, 2L)), error = identity)
print(res)
stopifnot(inherits(res, "error"))

## A single worker falls back to a sequential backend
backend <- MiraiMultisessionFutureBackend(workers = 1L)
print(backend)
stopifnot(inherits(backend, "SequentialFutureBackend"))

## 'workers' as a function, which launches new mirai daemons
mirai::daemons(0)
backend <- MiraiMultisessionFutureBackend(workers = function() 2L)
print(backend)
stopifnot(
  inherits(backend, "MiraiMultisessionFutureBackend"),
  nbrOfWorkers(backend) == 2L,
  nbrOfFreeWorkers(backend) == 2L,
  mirai::status()[["connections"]] == 2L
)

## Same number of workers re-uses the existing mirai daemons
backend2 <- MiraiMultisessionFutureBackend(workers = 2L)
stopifnot(
  inherits(backend2, "MiraiMultisessionFutureBackend"),
  nbrOfWorkers(backend2) == 2L
)

## Shut down the mirai daemons
stopWorkers(backend2)
stopifnot(mirai::status()[["connections"]] == 0L)

message("- MiraiMultisessionFutureBackend() direct call ... DONE")


## ---------------------------------------------------------
## Futures that do not capture conditions
## ---------------------------------------------------------
message("- future(..., conditions = NULL) ...")

plan(future.mirai::mirai_multisession, workers = 2)

f <- future({ message("hello"); 42 }, conditions = NULL)
v <- value(f)
stopifnot(v == 42)

plan(sequential)

message("- future(..., conditions = NULL) ... DONE")


## ---------------------------------------------------------
## Relaying of immediateCondition:s
## ---------------------------------------------------------
message("- Relaying of immediateCondition:s ...")

plan(future.mirai::mirai_multisession, workers = 2)

f <- future({
  m <- simpleMessage("IM\n")
  class(m) <- c(class(m), "immediateCondition")
  message(m)
  message("M")
  42L
})

## Wait for the future to be resolved; immediate conditions are
## relayed by resolved()
msgs <- character(0L)
withCallingHandlers({
  while (!resolved(f)) Sys.sleep(0.1)
}, message = function(c) {
  msgs <<- c(msgs, conditionMessage(c))
  invokeRestart("muffleMessage")
})
print(msgs)
stopifnot(identical(msgs, "IM\n"))

## The relayed immediate conditions are part of the result
r <- result(f)
classes <- lapply(r[["conditions"]], FUN = function(c) class(c[["condition"]]))
str(classes)
stopifnot(sum(vapply(classes, FUN = function(x) "immediateCondition" %in% x, FUN.VALUE = FALSE)) == 1L)

## value() does not relay immediate conditions a second time
msgs <- character(0L)
withCallingHandlers({
  v <- value(f)
}, message = function(c) {
  msgs <<- c(msgs, conditionMessage(c))
  invokeRestart("muffleMessage")
})
print(msgs)
stopifnot(identical(v, 42L), identical(msgs, "M\n"))

plan(sequential)

message("- Relaying of immediateCondition:s ... DONE")


## ---------------------------------------------------------
## result() on an interrupted future re-signals the error
## ---------------------------------------------------------
message("- result() on interrupted future ...")

plan(future.mirai::mirai_multisession, workers = 2)

f <- future({ Sys.sleep(60); 42 })
stopifnot(!resolved(f))
f <- cancel(f, interrupt = TRUE)
r <- resolved(f)
res <- tryCatch(value(f), error = identity)
print(res)
stopifnot(inherits(res, "FutureInterruptError"))
message("Future state: ", sQuote(f[["state"]]))

## Calling result() a second time gives the same error
res2 <- tryCatch(result(f), error = identity)
print(res2)
stopifnot(inherits(res2, "FutureInterruptError"))

plan(sequential)

message("- result() on interrupted future ... DONE")


## ---------------------------------------------------------
## mirai daemons without a dispatcher
## ---------------------------------------------------------
message("- mirai daemons without dispatcher ...")

## Set up a valid backend first, using a dispatcher
mirai::daemons(0)
mirai::daemons(n = 1L, dispatcher = TRUE)
backend <- future.mirai:::MiraiFutureBackend()
stopifnot(nbrOfWorkers(backend) == 1L)

## Relaunch daemons without a dispatcher
mirai::daemons(0)
mirai::daemons(n = 1L, dispatcher = FALSE)

## Without a dispatcher, there are no workers available to futures
stopifnot(nbrOfWorkers(backend) == 0L)
stopifnot(nbrOfFreeWorkers(backend) == 0L)

## Creating a new backend requires a dispatcher
res <- tryCatch(future.mirai:::MiraiFutureBackend(), error = identity)
print(res)
stopifnot(inherits(res, "FutureError"))
stopifnot(grepl("dispatcher", conditionMessage(res)))

mirai::daemons(0)

message("- mirai daemons without dispatcher ... DONE")


message("*** MiraiMultisessionFutureBackend ... DONE")
