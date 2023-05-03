#' Mirai-based localhost multisession futures
#'
#' @inheritParams MiraiFuture
#' @inheritParams future::multisession
#'
#' @return An object of class [MiraiFuture].
#'
#' @example incl/mirai_multisession.R
#'
#' @importFrom parallelly availableCores
#' @export
mirai_multisession <- function(expr,
                               substitute = TRUE,
                               envir = parent.frame(),
                               ...,
                               workers = availableCores()) {
  if (substitute) expr <- substitute(expr)

  if (is.function(workers)) workers <- workers()
  if (!is.numeric(workers)) {
    stop(sprintf("Argument 'workers' is not numeric: %s", mode(workers)))
  } else if (length(workers) != 1L) {
    stop(sprintf("Argument 'workers' does not have length one: %d", length(workers)))
  } else if (!is.finite(workers)) {
    stop(sprintf("Argument 'workers' is not finite: %g", workers))
  } else if (workers <= 0) {
    stop(sprintf("Argument 'workers' is non-positive: %g", workers))
  }
  workers <- as.integer(workers)
  
  future <- MiraiFuture(
              expr = expr, substitute = FALSE,
              envir = envir,
              workers = workers,
              ...
            )
  if(!isTRUE(future[["lazy"]])) future <- run(future)
  invisible(future)
}
class(mirai_multisession) <- c("mirai_multisession", "mirai_cluster", "mirai", "multiprocess", "future", "function")
attr(mirai_multisession, "init") <- TRUE
attr(mirai_multisession, "tweakable") <- "workers"


#' @importFrom future tweak
#' @export
tweak.mirai_multisession <- function(strategy, ..., penvir = parent.frame()) {
  attr(strategy, "init") <- TRUE
  NextMethod("tweak")
}
