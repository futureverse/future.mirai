#' @importFrom mirai daemons status
#' @importFrom future FutureBackend SequentialFutureBackend
#' @export
MiraiMultisessionFutureBackend <- local({
  with_stealth_rng <- import_future("with_stealth_rng")
  
  function(workers = availableCores(), ...) {
    if (is.function(workers)) workers <- workers()
    stop_if_not(is.numeric(workers))
    workers <- structure(as.integer(workers), class = class(workers))
    stop_if_not(length(workers) == 1, is.finite(workers), workers >= 1)
    
    ## Fall back to sequential futures if only a single additional R process
    ## can be spawned off, i.e. then use the current main R process.
    ## Sequential futures best reflect how multicore futures handle globals.
    if (workers == 1L && !inherits(workers, "AsIs")) {
      ## covr: skip=1
      return(SequentialFutureBackend(...))
    }

    ## Inquire about current mirai daemons
    dispatcher <- !is.null(status()[["mirai"]])
    
    ## Do we need to change the number of mirai workers?
    nworkers <- mirai_daemons_nworkers()
    if (is.infinite(workers) && nworkers < +Inf) {
      daemons(n = 0L)
    } else if (!dispatcher || workers != nworkers) {
      daemons(n = 0L)  ## reset is required
      ## Dispatch is required to protect against launching too many workers
      with_stealth_rng({
        daemons(n = workers, dispatcher = TRUE)
      })
    }
  
    core <- MiraiFutureBackend(
      workers = workers,
      ...
    )
    core[["shutdown"]] <- TRUE
    
    core[["futureClasses"]] <- c("MiraiMultisessionFuture", core[["futureClasses"]])
    core <- structure(core, class = c("MiraiMultisessionFutureBackend", "MiraiFutureBackend", "MultiprocessFutureBackend", "FutureBackend", class(core)))
  
    core
  }
})



#' @importFrom future nbrOfWorkers FutureWarning FutureError
#' @importFrom mirai is_error_value status
#' @export
nbrOfWorkers.MiraiMultisessionFutureBackend <- function(evaluator) {
  backend <- evaluator
  as.integer(backend[["workers"]])
}


#' @importFrom future nbrOfFreeWorkers
#' @export
nbrOfFreeWorkers.MiraiMultisessionFutureBackend <- function(evaluator, background = FALSE, ...) {
  backend <- evaluator
  reg <- backend[["reg"]]
  workers <- backend[["workers"]]

  ## (1) Number of free workers per internal registry
  usedWorkers <- length(FutureRegistry(reg, action = "list",
                        earlySignal = FALSE))
  workers <- as.integer(workers) - usedWorkers
  stop_if_not(length(workers) == 1L, !is.na(workers), workers >= 
      0L, is.finite(workers))

  workers
}


#' @importFrom future resolved
#' @export
resolved.MiraiMultisessionFuture <- function(x, .signalEarly = TRUE, ...) {
  resolved <- NextMethod()
  if (resolved) return(TRUE)
  
  ## Collect and relay immediateCondition if they exists
  conditions <- readImmediateConditions(signal = TRUE)
  ## Record conditions as signaled
  signaled <- c(x[[".signaledConditions"]], conditions)
  x[[".signaledConditions"]] <- signaled

  ## Signal conditions early? (happens only iff requested)
  if (.signalEarly) signalEarly(x, ...)

  resolved
}



#' @keywords internal
#' @export
result.MiraiMultisessionFuture <- function(future, ...) {
  result <- NextMethod()

  ## Collect and relay immediateCondition if they exists
  conditions <- readImmediateConditions()
  ## Record conditions as signaled
  signaled <- c(future[[".signaledConditions"]], conditions)
  future[[".signaledConditions"]] <- signaled

  result
}


#' @exportS3Method getFutureBackendConfigs MiraiMultisessionFuture
getFutureBackendConfigs.MiraiMultisessionFuture <- local({
  immediateConditionsPath <- import_future("immediateConditionsPath")
  fileImmediateConditionHandler <- import_future("fileImmediateConditionHandler")
  
  function(future, ..., debug = isTRUE(getOption("future.debug"))) {
    conditionClasses <- future[["conditions"]]
    if (is.null(conditionClasses)) {
      capture <- list()
    } else {
      path <- immediateConditionsPath(rootPath = tempdir())
      capture <- list(
        immediateConditionHandlers = list(
          immediateCondition = function(cond) {
            fileImmediateConditionHandler(cond, path = path)
          }
        )
      )
    }
  
    list(
      capture = capture
    )
  }
})


#' Mirai-based localhost multisession futures
#'
#' _WARNING: This function must never be called.
#'  It may only be used with [future::plan()]_
#'
#' @inheritParams future::Future
#' @inheritParams future::multisession
#'
#' @param \ldots Not used.
#'
#' @return Nothing.
#'
#' @example incl/mirai_multisession.R
#'
#' @importFrom parallelly availableCores
#' @importFrom future future
#' @export
mirai_multisession <- function(..., workers = availableCores(), envir = parent.frame()) {
  stop("INTERNAL ERROR: The future.mirai::mirai_multisession() function must never be called directly")
}
class(mirai_multisession) <- c("mirai_multisession", "mirai_cluster", "mirai", "multiprocess", "future", "function")
attr(mirai_multisession, "init") <- TRUE
attr(mirai_multisession, "cleanup") <- function(...) {
  mirai::daemons(0)
}
attr(mirai_multisession, "factory") <- MiraiMultisessionFutureBackend
