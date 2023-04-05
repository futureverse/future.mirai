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
mirai_multisession <- local({
  .workers <- NULL
  .nworkers <- 0L
  
  function(expr,
           substitute = TRUE,
           envir = parent.frame(),
           ...,
           workers = availableCores())
  {
    if (substitute) expr <- substitute(expr)

    future <- MiraiFuture(
                expr = expr, substitute = FALSE,
                envir = envir, 
                ...
              )
    if(!isTRUE(future[["lazy"]])) future <- run(future)
    invisible(future)
  }
})
class(mirai_multisession) <- c("mirai_multisession", "mirai", "multiprocess", "future", "function")
attr(mirai_multisession, "init") <- TRUE
attr(mirai_multisession, "tweakable") <- "workers"



#' @importFrom future nbrOfWorkers
#' @export
nbrOfWorkers.mirai <- function(evaluator) {
  ## FIXME: Find a way to query Mirai for the number of active workers
  Inf
}

#' @importFrom future nbrOfFreeWorkers
#' @export
nbrOfFreeWorkers.mirai <- function(evaluator, background = FALSE, ...) {
  ## FIXME: Find a way to query Mirai for the number of free workers
  Inf
}

#' @importFrom future nbrOfWorkers
#' @export
nbrOfWorkers.mirai_multisession <- function(evaluator) {
  expr <- formals(evaluator)$workers
  workers <- eval(expr, enclos = baseenv())
  if (is.function(workers)) {
    workers <- workers()
  }
  if (inherits(workers, "MiraiWorkerConfiguration")) {
    ## FIXME: Find a way to query Mirai for the number of active workers
    workers <- Inf
  } else if (is.numeric(workers)) {
  } else {
      stopf("Unsupported type of 'workers' for evaluator of class %s: %s", 
          paste(sQuote(class(evaluator)), collapse = ", "), 
          class(workers)[1])
  }
  stopifnot(length(workers) == 1L, !is.na(workers), workers >= 1L)
  workers
}