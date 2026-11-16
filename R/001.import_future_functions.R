## Private functions imported from 'future'
readImmediateConditions <- import_future("readImmediateConditions")
signalEarly <- import_future("signalEarly")
prune_fcn <- import_future("prune_fcn")
evalFuture <- import_future("evalFuture")
getFutureData <- import_future("getFutureData")
getFutureBackendConfigs <- import_future("getFutureBackendConfigs")
fileImmediateConditionHandler <- import_future("fileImmediateConditionHandler")
immediateConditionsPath <- import_future("immediateConditionsPath")
with_stealth_rng <- import_future("with_stealth_rng")
sQuoteLabel <- import_future("sQuoteLabel")

## An environment must be imported when the package is loaded, otherwise
## we would get a copy and not share the state with 'future'
.debug <- NULL

## Same for FutureRegistry(), whose state lives in its closure. It must
## be shared with 'future', e.g. so that listFutures() sees our futures
FutureRegistry <- NULL

import_future_functions <- function() {
  .debug <<- import_future(".debug", mode = "environment")
  FutureRegistry <<- import_future("FutureRegistry")

  ## Use future:::waitForWorker(), if available, otherwise our local copy.
  ## This is done when the package is loaded, so that the one in the
  ## installed version of 'future' is used
  waitForWorker <<- import_future("waitForWorker", default = waitForWorker)

  ## The generic is a private function in 'future', so the S3method()
  ## entry in NAMESPACE is not enough to register the method
  registerS3method("getFutureBackendConfigs", "MiraiMultisessionFuture", getFutureBackendConfigs.MiraiMultisessionFuture)
}
