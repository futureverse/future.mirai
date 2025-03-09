#' Mirai-based cluster futures
#'
#' @inheritParams future::Future
#'
#' @param \ldots Additional arguments passed to `Future()`.
#'
#' @return An object of class MiraiFuture.
#'
#' @example incl/mirai_cluster.R
#'
#' @details
#' _WARNING_: When using this future plan, mirai workers are _not_ shutdown when
#' switching away from this future plan. This is because it the backend requires
#' them to be launched manually before, and it therefore needs to be manually
#' shutdown as well.
#'
#' @importFrom future Future
#' @export
mirai_cluster <- function(..., envir = parent.frame()) {
  f <- Future(..., envir = envir)
  class(f) <- c("MiraiFuture", "MultiprocessFuture", "Future")
  f
}
class(mirai_cluster) <- c("mirai_cluster", "mirai", "multiprocess", "future", "function")
attr(mirai_cluster, "init") <- TRUE


#' @importFrom future tweak
#' @export
tweak.mirai_cluster <- function(strategy, ..., penvir = parent.frame()) {
  attr(strategy, "init") <- TRUE
  NextMethod("tweak")
}




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
#' @importFrom mirai status
#' @importFrom future FutureBackend SequentialFutureBackend
#' @export
MiraiFutureBackend <- function(...) {
  ## Assert that a mirai dispatcher is in place, which is
  ## required to protect against launching too many workers
  dispatcher <- !is.null(status()[["mirai"]])
  if (!dispatcher) {
    stop(sprintf("Mirai futures require that the mirai daemons are configured to use a dispatcher (dispatcher = TRUE). If not, there is a risk of launching an unlimited number of mirai processes. This requirement might be relaxed in future versions of the %s package", sQuote(.packageName)))
  }

  core <- FutureBackend(
    dispatcher = dispatcher,
    ...
  )
  core[["futureClasses"]] <- c("MiraiFuture", "MultiprocessFuture", core[["futureClasses"]])
  core <- structure(core, class = c("MiraiFutureBackend", "MultiprocessFutureBackend", "FutureBackend", class(core)))
  core
}


#' @importFrom mirai mirai
#' @importFrom future launchFuture
#' @export
launchFuture.MiraiFutureBackend <- local({
  evalFuture <- import_future("evalFuture")
  getFutureData <- import_future("getFutureData")
  
  function(backend, future, ...) {
    debug <- isTRUE(getOption("future.mirai.debug"))
    if (debug) {
      mdebugf("launchFuture() for %s ...", class(backend)[1], debug = debug)
      on.exit(mdebugf("launchFuture() for %s ... done", class(backend)[1], debug = debug))
    }

    ## Block?
    while (nbrOfFreeWorkers() == 0) {
      Sys.sleep(0.1)
    }
    
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

    future[["state"]] <- "submitted"
  
    data <- getFutureData(future)
    mirai <- mirai(future:::evalFuture(data), data = data)
    
    future[["mirai"]] <- mirai
  
    future[["state"]] <- "running"
  
    invisible(future)
  }
})


#' @importFrom future nbrOfWorkers FutureWarning FutureError
#' @importFrom mirai is_error_value status
#' @export
nbrOfWorkers.MiraiFutureBackend <- function(evaluator) {
  backend <- evaluator
  
  res <- status()
  workers <- res[["daemons"]]
  if (is_error_value(workers)) {
    reason <- capture.output(print(workers))
    stop(FutureError(sprintf("mirai::status() failed to communicate with dispatcher: %s", reason)))
  }
  
  if (is.character(workers)) {
    workers <- res[["connections"]]
    stop_if_not(is.numeric(workers))
  } else if (!is.numeric(workers)) {
    stop(FutureError(sprintf("Unknown type of mirai::daemons()$daemons: %s", typeof(workers))))
  }

  if (is.matrix(workers)) {
    n_online <- sum(workers[, "online", drop = TRUE])
    if (n_online != nrow(workers)) {
      warning(FutureWarning(sprintf("The number of mirai workers that are online does not match the total number of mirai workers: %d != %d", n_online, nrow(workers))))
    }
    return(nrow(workers))
  }

  if (length(workers) != 1L) {
    stop(FutureError(sprintf("Length of mirai::daemons()$daemons is not one: %d", length(workers))))
  }

  if (workers == 0L) return(Inf)
  
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
    stop(FutureError(sprintf("mirai::status() failed to communicate with dispatcher: %s", reason)))
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
    stop(FutureError(sprintf("Length of mirai::daemons()$daemons is not one: %d", length(workers))))
  }

  mirai <- res[["mirai"]]
  stop_if_not(!is.null(mirai))
  used <- mirai[["awaiting"]] + mirai[["executing"]]
  workers <- workers - used
  stop_if_not(is.numeric(workers), is.finite(workers), workers >= 0)
  
  workers
}


#' Check on the status of a future task.
#' @return boolean indicating the task is finished (TRUE) or not (FALSE)
#' @importFrom mirai unresolved
#' @importFrom future resolved
#' @keywords internal
#' @export
resolved.MiraiFuture <- function(x, ...) {
  debug <- isTRUE(getOption("future.mirai.debug"))
  if (debug) {
    mdebugf("resolved() for %s ...", class(x)[1], debug = debug)
    on.exit(mdebugf("resolved() for %s ... done", class(x)[1], debug = debug))
  }
  
  resolved <- NextMethod()
  if(resolved) {
    if (debug) mdebug("- already resolved", debug = debug)
    return(TRUE)
  }
  
  if(x[["state"]] == "finished") {
    if (debug) mdebug("- already resolved (state == finished)", debug = debug)
    return(TRUE)
  } else if(x[["state"]] == "created") { # Not yet submitted to queue (iff lazy)
    if (debug) mdebug("- just created; launching")
    x <- run(x)
    return(FALSE)
  }

  if (debug) mdebug("mirai::unresolved() ...", debug = debug)
  mirai <- x[["mirai"]]
  res <- unresolved(mirai)
  if (debug) {
    mstr(res, debug = debug)
    mdebug("mirai::unresolved() ... done", debug = debug)
  }
  
  !res
}



#' @importFrom mirai mirai
#' @importFrom future run getExpression
#' @export
run.MiraiFuture <- function(future, ...) {
  if(isTRUE(future[["state"]] != "created")) return(invisible(future))
  
  debug <- isTRUE(getOption("future.mirai.debug"))
  if (debug) {
    mdebugf("run() for %s ...", class(future)[1], debug = debug)
    on.exit(mdebugf("run() for %s ... done", class(future)[1], debug = debug))
  }

  future[["state"]] <- "submitted"

  globals <- future[["globals"]]

  if (length(globals) > 0) {
    ## Sanity check
    not_allowed <- intersect(names(globals), names(formals(mirai::mirai)))
    if (length(not_allowed) > 0) {
      stop(FutureError(sprintf("Detected global variables that clash with argument names of mirai::mirai(): %s", paste(sQuote(not_allowed), collapse = ", "))))
    }
  }

  if (is.function(evalFuture)) {
    data <- getFutureData(future)
    mirai <- mirai(future:::evalFuture(data), data = data)
  } else {
    expr <- getExpression(future)
    args = list(.expr = expr)
    if (length(globals) > 0) args <- c(args, globals)
    mirai <- do.call(mirai, args = args)
  }
  future[["mirai"]] <- mirai

  future[["state"]] <- "running"

  invisible(future)
}


#' @importFrom future result
#' @export
result.MiraiFuture <- function(future, ...) {
  if(isTRUE(future[["state"]] == "finished")) {
    return(future[["result"]])
  }

  debug <- isTRUE(getOption("future.mirai.debug"))
  if (debug) {
    mdebugf("result() for %s ...", class(future)[1], debug = debug)
    on.exit(mdebugf("result() for %s ... done", class(future)[1], debug = debug))
  }

  if (debug) t0 <- proc.time()
  result <- mirai_collect_future(future)
  if (debug) {
    dt <- proc.time() - t0
    dt <- dt[dt > 0]
    dt_str <- paste(sprintf("%s=%gs", names(dt), dt), collapse = ", ")
    mdebugf(" - collected mirai in %s", dt_str)
  }

  if (inherits(result, "errorValue")) {
    label <- future[["label"]]
    if (is.null(label)) label <- "<none>"
    msg <- sprintf("Failed to retrieve results from %s (%s). The mirai framework reports on error value %s", class(future)[1], label, result)
    stop(FutureError(msg))
  }

  future[["result"]] <- result
  future[["state"]] <- "finished"

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

#' @importFrom mirai call_mirai_
mirai_collect_future <- function(future) {
  mirai <- future[["mirai"]]
  call_mirai_(mirai)$data
}
