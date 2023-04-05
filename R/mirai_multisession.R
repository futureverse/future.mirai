#' Mirai-based localhost multisession futures
#'
#' @inheritParams MiraiFuture
#' @inheritParams future::multisession
#'
#' @return An object of class [MiraiFuture].
#'
#' @example incl/mirai_multisession.R
#'
#' @seealso [mirai::mirai()]
#'
#' @importFrom parallelly availableCores
#' @importFrom mirai mirai
#' @export
mirai_multisession <- function(expr,
                               substitute = TRUE,
                               envir = parent.frame(),
                               ...,
                               workers = availableCores()) {
  if (substitute) expr <- substitute(expr)

  future <- MiraiFuture(
              expr = expr, substitute = FALSE,
              envir = envir,
              workers = workers,
              ...
            )
  if(!isTRUE(future[["lazy"]])) future <- run(future)
  invisible(future)
}
class(mirai_multisession) <- c("mirai_multisession", "mirai", "multiprocess", "future", "function")
attr(mirai_multisession, "init") <- TRUE
attr(mirai_multisession, "tweakable") <- "workers"


#' @importFrom future tweak
#' @export
tweak.mirai_multisession <- function(strategy, ..., penvir = parent.frame()) {
  attr(strategy, "init") <- TRUE
  NextMethod("tweak")
}

#' @importFrom future FutureError
#' @importFrom mirai daemons
mirai_daemons_nworkers <- function() {
  res <- daemons()
  workers <- res[["daemons"]]
  if (is.matrix(workers)) return(nrow(workers))
  if (length(workers) == 1L && workers == 0L) return(Inf)
  stop(FutureError(sprintf("Unknown value of mirai::daemons()$daemons: %s", paste(workers, collapse = ", "))))
}


#' @importFrom future nbrOfWorkers FutureError
#' @importFrom mirai daemons
#' @export
nbrOfWorkers.mirai <- function(evaluator) {
  res <- daemons()
  workers <- res[["daemons"]]
  if (!is.numeric(workers)) {
    stop(FutureError(sprintf("Unknown type of mirai::daemons()$daemons: %s", typeof(workers))))
  }

  if (is.matrix(workers)) {
    n_online <- sum(workers[, "status_online", drop = TRUE])
    return(n_online)
  }

  if (length(workers) == 1L && workers == 0L) return(Inf)
  
  stop(FutureError(sprintf("Unknown value of mirai::daemons()$daemons: %s", paste(workers, collapse = ", "))))
}

#' @importFrom future nbrOfFreeWorkers FutureError
#' @importFrom mirai daemons
#' @export
nbrOfFreeWorkers.mirai <- function(evaluator, background = FALSE, ...) {
  res <- daemons()
  workers <- res[["daemons"]]
  if (!is.numeric(workers)) {
    stop(FutureError(sprintf("Unknown type of mirai::daemons()$daemons: %s", typeof(workers))))
  }

  if (is.matrix(workers)) {
    n_online <- sum(workers[, "status_online", drop = TRUE])
    n_busy <- sum(workers[, "status_busy", drop = TRUE])
    return(n_online - n_busy)
  }

  if (length(workers) == 1L && workers == 0L) return(Inf)
  
  stop(FutureError(sprintf("Unknown value of mirai::daemons()$daemons: %s", paste(workers, collapse = ", "))))
}
