#' A future backend based based on the 'mirai' framework
#'
#' Set up the future parameters.
#'
#' @inheritParams future::FutureBackend
#'
#' @param \ldots Additional arguments passed to `Future()`.
#'
#' @return An object of class `MiraiFutureBackend`.
#'
#' @aliases MiraiMultisessionFutureBackend
#' @importFrom utils capture.output
#' @importFrom mirai status
#' @importFrom future FutureBackend SequentialFutureBackend
#' @export
MiraiFutureBackend <- local({
  with_stealth_rng <- import_future("with_stealth_rng")
  
  function(...) {
    status <- status()
  
    if (status[["connections"]] == 0L) {
      stop(FutureError(sprintf("Mirai futures require that at least one mirai daemon is available. mirai::status() reports:\n%s", paste(capture.output(print(status)), collapse = "\n"))))
    }
  
    ## Assert that a mirai dispatcher is in place, which is
    ## required to protect against launching too many workers
    dispatcher <- !is.null(status[["mirai"]])
    if (!dispatcher) {
      stop(sprintf("Mirai futures require that the mirai daemons are configured to use a dispatcher (dispatcher = TRUE). If not, there is a risk of launching an unlimited number of mirai processes. This requirement might be relaxed in future versions of the %s package. mirai::status() reports:\n%s", sQuote(.packageName), paste(capture.output(print(status)), collapse = "\n")))
    }
  
    core <- FutureBackend(
      reg = "workers-mirai",
      dispatcher = dispatcher,
      shutdown = FALSE,
      ...,
      timeout = getOption("future.wait.timeout", 30 * 24 * 60 * 60),
      delta = getOption("future.wait.interval", 0.2),
      alpha = getOption("future.wait.alpha", 1.01)
    )
    core[["futureClasses"]] <- c("MiraiFuture", "MultiprocessFuture", core[["futureClasses"]])
    core <- structure(core, class = c("MiraiFutureBackend", "MultiprocessFutureBackend", "FutureBackend", class(core)))
    core
  }
})


#' @importFrom mirai mirai
#' @importFrom future launchFuture
#' @export
launchFuture.MiraiFutureBackend <- local({
  evalFuture <- import_future("evalFuture")
  getFutureData <- import_future("getFutureData")
  
  function(backend, future, ...) {
    debug <- isTRUE(getOption("future.mirai.debug"))
    if (debug) {
      mdebugf_push("launchFuture() for %s ...", class(backend)[1])
      on.exit(mdebug_pop())
    }

    stop_if_not(nbrOfWorkers(backend) > 0L)
    
    ## Wait for a free worker
    waitForWorker(backend, debug = debug)
    
    globals <- future[["globals"]]
    if (length(globals) > 0) {
      ## Sanity check
      not_allowed <- intersect(names(globals), names(formals(mirai)))
      if (length(not_allowed) > 0) {
        stop(FutureError(sprintf("Detected global variables that clash with argument names of mirai::mirai(): %s", paste(sQuote(not_allowed), collapse = ", "))))
      }
    }

    ## Record 'backend' in future for now
    future[["backend"]] <- backend

    ## Is there 'workers' field?
    workers <- backend[["workers"]]
    if (!is.null(workers)) future[["workers"]] <- workers

    data <- getFutureData(future)

    future[["state"]] <- "submitted"
    mirai <- mirai(future:::evalFuture(data), data = data)
    future[["mirai"]] <- mirai
    future[["state"]] <- "running"

    ## Allocate future to worker
    reg <- backend[["reg"]]
    FutureRegistry(reg, action = "add", future = future, earlySignal = FALSE)

    stopifnot(inherits(future[["mirai"]], "mirai"))

    invisible(future)
  }
})


#' @importFrom future cancel stopWorkers
#' @export
stopWorkers.MiraiFutureBackend <- function(backend, ...) {
  debug <- isTRUE(getOption("future.mirai.debug"))
  if (debug) {
    mdebugf_push("stopWorkers() for %s ...", class(backend)[1])
    on.exit(mdebug_pop())
  }
    
  reg <- backend[["reg"]]
  futures <- FutureRegistry(reg, action = "list", earlySignal = FALSE)
  if (debug) mdebugf("Number of active futures: %d", length(futures))
  
  if (length(futures) > 0L) {
    ## Enable interrupts temporarily, if disabled
    if (!isTRUE(backend[["interrupts"]])) {
      backend[["interrupts"]] <- TRUE
      on.exit(backend[["interrupts"]] <- FALSE)
    }
  
    ## Cancel and interrupt all futures, which terminates the workers
    if (debug) mdebugf_push("Cancel and interrupt futures ...")
    futures <- lapply(futures, FUN = cancel, interrupt = TRUE)
    if (debug) mdebugf_pop()
  
    ## Erase registry
    futures <- FutureRegistry(reg, action = "reset")
  }

  ## Stop workers?
  if (backend[["shutdown"]]) {
    if (debug) {
      mdebug("Mirai daemons:")
      mprint(mirai::status())
    }
    mirai::daemons(n = 0L)
    if (debug) mdebug("Mirai daemons shut down")
  }

  backend
}


#' @importFrom future nbrOfWorkers FutureWarning FutureError
#' @importFrom mirai is_error_value status
#' @export
nbrOfWorkers.MiraiFutureBackend <- function(evaluator) {
  backend <- evaluator
  
  res <- status()
  workers <- res[["daemons"]]
  if (is_error_value(workers)) {
    reason <- capture.output(print(workers))
    stop(FutureError(sprintf("Cannot infer number of mirai workers. mirai::status() failed to communicate with dispatcher: %s", reason)))
  }
  
  if (is.character(workers)) {
    workers <- res[["connections"]]
    stop_if_not(is.numeric(workers))
  } else if (!is.numeric(workers)) {
    stop(FutureError(sprintf("Cannot infer number of mirai workers. Unknown type of mirai::daemons()$daemons: %s", typeof(workers))))
  }

  if (is.matrix(workers)) {
    n_online <- sum(workers[, "online", drop = TRUE])
    if (n_online != nrow(workers)) {
      warning(FutureWarning(sprintf("The number of mirai workers that are online does not match the total number of mirai workers: %d != %d", n_online, nrow(workers))))
    }
    return(nrow(workers))
  }

  if (length(workers) != 1L) {
    stop(FutureError(sprintf("Cannot infer number of mirai workers. Length of mirai::daemons()$daemons is not one: %d", length(workers))))
  }

  mirai <- res[["mirai"]]
  if (is.null(mirai)) return(0L)

  workers
}

#' @importFrom future nbrOfFreeWorkers FutureError
#' @importFrom mirai is_error_value status
#' @export
nbrOfFreeWorkers.MiraiFutureBackend <- function(evaluator, background = FALSE, ...) {
  backend <- evaluator

  res <- status()
  workers <- res[["daemons"]]
  if (is_error_value(workers)) {
    reason <- capture.output(print(workers))
    stop(FutureError(sprintf("Cannot infer number of free mirai workers. mirai::status() failed to communicate with dispatcher: %s", reason)))
  }
  
  if (is.character(workers)) {
     workers <- res[["connections"]]
     stop_if_not(is.numeric(workers))
  } else if (!is.numeric(workers)) {
    stop(FutureError(sprintf("Unknown type of mirai::daemons()$daemons: %s", typeof(workers))))
  }

  if (is.matrix(workers)) {
    n_online <- sum(workers[, "online", drop = TRUE])
    n_assigned <- sum(workers[, "assigned", drop = TRUE])
    n_complete <- sum(workers[, "complete", drop = TRUE])
    n_busy <- n_assigned - n_complete
    return(n_online - n_busy)
  }

  if (length(workers) != 1L) {
    stop(FutureError(sprintf("Cannot infer number of free mirai workers. Length of mirai::daemons()$daemons is not one: %d", length(workers))))
  }

  mirai <- res[["mirai"]]
  if (is.null(mirai)) {
    stop(FutureError("Cannot infer number of free mirai workers. mirai::status() reports zero daemons. Did you call mirai::daemons(0) by mistake?"))
  }
  
  used <- mirai[["awaiting"]] + mirai[["executing"]]
  workers <- workers - used
  stop_if_not(is.numeric(workers), is.finite(workers), workers >= 0)
  
  workers
}


#' Check on the status of a future task.
#' @return boolean indicating the task is finished (TRUE) or not (FALSE)
#' @importFrom mirai unresolved
#' @importFrom future resolved run
#' @keywords internal
#' @export
resolved.MiraiFuture <- function(x, ...) {
  debug <- isTRUE(getOption("future.mirai.debug"))
  if (debug) {
    mdebugf_push("resolved() for %s ...", class(x)[1])
    on.exit(mdebug_pop())
  }
  
  resolved <- NextMethod()
  if(resolved) {
    if (debug) mdebug("already resolved")
    return(TRUE)
  }
  
  if(x[["state"]] %in% c("finished", "interrupted")) {
    if (debug) mdebugf("already resolved (state == %s)", sQuote(x[["state"]]))
    stopifnot(inherits(x[["mirai"]], "mirai"))
    return(TRUE)
  } else if(x[["state"]] == "created") { # Not yet submitted to queue (iff lazy)
    if (debug) mdebug("just created; launching")
    x <- run(x)
    stopifnot(inherits(x[["mirai"]], "mirai"))
    return(FALSE)
  }

  if (debug) mdebug_push("mirai::unresolved() ...")
  mirai <- x[["mirai"]]
  stopifnot(inherits(mirai, "mirai"))
  res <- unresolved(mirai)
  if (debug) {
    mstr(res)
    mdebug_pop()
  }
  
  !res
}


#' @importFrom future result FutureInterruptError
#' @export
result.MiraiFuture <- function(future, ...) {
  debug <- isTRUE(getOption("future.mirai.debug"))
  if (debug) {
    mdebugf_push("result() for %s ...", class(future)[1])
    mdebugf("Future state: %s", sQuote(future[["state"]]))
    on.exit(mdebug_pop())
  }


  state <- future[["state"]]
  if (state == "finished") {
    return(future[["result"]])
  } else if (state == "interrupted") {
    stop(future[["result"]])
  }

  backend <- future[["backend"]]
  reg <- backend[["reg"]]

  if (debug) t0 <- proc.time()
  result <- mirai_collect_future(future)
  if (debug) {
    dt <- proc.time() - t0
    dt <- dt[dt > 0]
    dt_str <- paste(sprintf("%s=%gs", names(dt), dt), collapse = ", ")
    mdebugf("collected mirai in %s", dt_str)
    mdebugf("mirai result class: %s", class(result)[1])
  }

  if (inherits(result, "errorValue")) {
    if (debug) mdebugf("mirai error value: %s", result)
    
    label <- sQuoteLabel(future)

    if (result %in% c(19L, 20L)) {
      stop_if_not(state %in% c("canceled", "interrupted", "running"))
      
      if (result == 19L) {
        ## "If a daemon crashes or terminates unexpectedly during evaluation,
        ##  an 'errorValue' 19 (Connection reset) is returned."
        ## Source: help("collect_mirai", package = "mirai")
        event <- sprintf("was terminated while %s", state)
      } else if (result == 20L) {
        ## "Stops a 'mirai' if still in progress, causing it to resolve
        ##  immediately to an 'errorValue' 20 (Operation canceled)."
        ## Source: help("stop_mirai", package = "mirai")
        event <- if (state %in% "running") {
          event <- sprintf("failed for unknown reason while %s", state)
        } else {
          event <- sprintf("was %s", state)
        }
      }

      future[["state"]] <- "interrupted"
      msg <- sprintf("Future (%s) of class %s %s, while running on localhost (error code %d)", label, class(future)[1], event, result)
      if (debug) mdebug(msg)
      result <- FutureInterruptError(msg, future = future)
      future[["result"]] <- result
      FutureRegistry(reg, action = "remove", future = future)
      stop(result)
    }
    
    FutureRegistry(reg, action = "remove", future = future)
    msg <- sprintf("Failed to retrieve results from %s (%s). The mirai framework reports on error value %s", class(future)[1], label, result)
    stop(FutureError(msg))
  }

  future[["result"]] <- result
  future[["state"]] <- "finished"

  FutureRegistry(reg, action = "remove", future = future)
  
  result
}



#' @importFrom future FutureError
#' @importFrom mirai daemons
mirai_daemons_nworkers <- function() {
  workers <- get_mirai_daemons()
  if (is.data.frame(workers)) return(nrow(workers))
  
  if (length(workers) != 1L) {
    msg <- sprintf("Length of mirai::status()$daemons is not one: %d", length(workers))
    stop(FutureError(msg))
  }
  
  if (workers == 0L) return(Inf)
  workers
}


#' @importFrom utils packageVersion
mirai_version <- local({
  version <- NULL
  function() {
    if (is.null(version)) version <<- packageVersion("mirai")
    version
  }
})

#' @importFrom mirai call_mirai
mirai_collect_future <- function(future) {
  mirai <- future[["mirai"]]
  stopifnot(inherits(mirai, "mirai"))
  call_mirai(mirai)$data
}


#' @importFrom future interruptFuture
#' @importFrom mirai stop_mirai
#' @export
interruptFuture.MiraiFutureBackend <- function(backend, future, ...) {
  mirai <- future[["mirai"]]
  stopifnot(inherits(mirai, "mirai"))
  stop_mirai(mirai)
  future[["state"]] <- "interrupted"
  future
}


#' @importFrom future tweak
#' @export
tweak.mirai_cluster <- function(strategy, ..., penvir = parent.frame()) {
  attr(strategy, "init") <- TRUE
  backend <- attr(strategy, "backend", exact = TRUE)
  if (!is.null(backend)) {
    stopWorkers(backend)
    attr(strategy, "backend") <- NULL
  }
  NextMethod("tweak")
}


#' Mirai-based cluster futures
#'
#' _WARNING: This function must never be called.
#'  It may only be used with [future::plan()]_
#'
#' @inheritParams future::Future
#'
#' @param \ldots Not used.
#'
#' @return Nothing.
#'
#' @example incl/mirai_cluster.R
#'
#' @importFrom future future
#' @export
mirai_cluster <- function(..., envir = parent.frame()) {
  stop("INTERNAL ERROR: The future.mirai::mirai_cluster() function must never be called directly")
}
class(mirai_cluster) <- c("mirai_cluster", "mirai", "multiprocess", "future", "function")
attr(mirai_cluster, "init") <- TRUE
attr(mirai_cluster, "factory") <- MiraiFutureBackend
