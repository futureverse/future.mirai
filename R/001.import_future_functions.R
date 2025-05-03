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
cancel <- NULL


## Import private functions from 'future'
import_future_functions <- function() {
  stop_if_not <<- import_future("stop_if_not", default = stopifnot)
  commaq <<- import_future("commaq", default = NULL)
  readImmediateConditions <<- import_future("readImmediateConditions")
  signalEarly <<- import_future("signalEarly")
  FutureRegistry <<- import_future("FutureRegistry")
  
  ## future (>= 1.40.0)
  prune_fcn <<- import_future("prune_fcn", default = prune_fcn)
  evalFuture <<- import_future("evalFuture", default = NULL)
  getFutureData <<- import_future("getFutureData", default = NULL)
  getFutureBackendConfigs <<- import_future("getFutureBackendConfigs")

  ## Until future (>= 1.49.0) is on CRAN
  cancel <<- import_future("cancel", default = NULL)
  if (is.null(cancel)) {
    interrupt <- import_future("interrupt")
    cancel <<- function(x, interrupt = TRUE, ...) {
      if (!interrupt) return(x)
      interrupt(x, ...)
    }
  }
}
