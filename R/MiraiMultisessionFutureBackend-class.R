#' Mirai-based localhost multisession futures
#'
#' @inheritParams future::Future
#' @inheritParams future::multisession
#'
#' @param \ldots Additional arguments passed to `Future()`.
#'
#' @return An object of class MiraiFuture.
#'
#' @example incl/mirai_multisession.R
#'
#' @importFrom parallelly availableCores
#' @importFrom future Future
#' @export
mirai_multisession <- function(..., workers = availableCores(), envir = parent.frame()) {
  stop("INTERNAL ERROR: The future.mirai::mirai_multisession() function implements the FutureBackend and should never be called directly")
}
class(mirai_multisession) <- c("mirai_multisession", "mirai_cluster", "mirai", "multiprocess", "future", "function")
attr(mirai_multisession, "init") <- TRUE
attr(mirai_multisession, "cleanup") <- function(...) {
  mirai::daemons(0)
}
attr(mirai_multisession, "tweakable") <- "workers"



#' @importFrom future tweak
#' @export
tweak.mirai_multisession <- function(strategy, ..., penvir = parent.frame()) {
  attr(strategy, "init") <- TRUE
  NextMethod("tweak")
}


#' @importFrom mirai daemons status
#' @importFrom future FutureBackend SequentialFutureBackend
#' @export
MiraiMultisessionFutureBackend <- function(workers = availableCores(), ...) {
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
  
  core[["futureClasses"]] <- c("MiraiMultisessionFuture", core[["futureClasses"]])
  core <- structure(core, class = c("MiraiMultisessionFutureBackend", "MiraiFutureBackend", "MultiprocessFutureBackend", "FutureBackend", class(core)))

  core
}
