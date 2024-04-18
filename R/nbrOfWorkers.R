#' @importFrom future nbrOfWorkers FutureWarning FutureError
#' @importFrom mirai status
#' @export
nbrOfWorkers.mirai <- function(evaluator) {
  res <- status()
  workers <- res[["daemons"]]
  if (is.character(workers)) {
    workers <- res[["connections"]]
    stopifnot(is.numeric(workers))
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
#' @importFrom mirai status
#' @export
nbrOfFreeWorkers.mirai <- function(evaluator, background = FALSE, ...) {
  res <- status()
  workers <- res[["daemons"]]
  if (is.character(workers)) {
     workers <- res[["connections"]]
     stopifnot(is.numeric(workers))
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

  if (workers == 0L) return(Inf)
  workers
}
