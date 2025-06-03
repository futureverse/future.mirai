## To be imported from 'future', if available
stop_if_not <- stopifnot
commaq <- NULL
readImmediateConditions <- NULL
signalEarly <- NULL
prune_fcn <- function(expr, ...) expr
FutureRegistry <- NULL
evalFuture <- NULL
getFutureData <- NULL
getFutureBackendConfigs <- NULL
sQuoteLabel <- NULL
.debug <- NULL

## Import private functions from 'future'
import_future_functions <- function() {
  stop_if_not <<- import_future("stop_if_not", default = stopifnot)
  commaq <<- import_future("commaq", default = NULL)
  readImmediateConditions <<- import_future("readImmediateConditions")
  signalEarly <<- import_future("signalEarly")
  FutureRegistry <<- import_future("FutureRegistry")
  
  ## future (>= 1.40.0)
  prune_fcn <<- import_future("prune_fcn")
  evalFuture <<- import_future("evalFuture")
  getFutureData <<- import_future("getFutureData")
  getFutureBackendConfigs <<- import_future("getFutureBackendConfigs")
  registerS3method("getFutureBackendConfigs", "MiraiMultisessionFuture", getFutureBackendConfigs.MiraiMultisessionFuture)

  ## future (>= 1.49.0)
  sQuoteLabel <<- import_future("sQuoteLabel")

  .debug <<- import_future(".debug", mode = "environment", default = new.env(parent = emptyenv()))
}
