#' Mirai-based cluster futures
#'
#' @inheritParams MiraiFuture
#' @inheritParams future::cluster
#'
#' @param workers Specifies **mirai** workers to use as parallel workers.
#' If a numeric scalar, then this number of local **mirai** daemons will
#' be launched.
#' If a character vector, then this it specifies the hostnames of where
#' the **mirai** daemons will be launched.
#' If `NULL`, then any **mirai** daemons previously created by
#' [mirai::daemons()] will be used as parallel workers.
#'
#' @return An object of class [MiraiFuture].
#'
#' @example incl/mirai_cluster.R
#'
#' @importFrom parallelly availableWorkers
#' @export
mirai_cluster <- function(expr,
                               substitute = TRUE,
                               envir = parent.frame(),
                               ...,
                               workers = availableWorkers()) {
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
class(mirai_cluster) <- c("mirai_cluster", "mirai", "multiprocess", "future", "function")
attr(mirai_cluster, "init") <- TRUE
attr(mirai_cluster, "tweakable") <- "workers"


#' @importFrom future tweak
#' @export
tweak.mirai_cluster <- function(strategy, ..., penvir = parent.frame()) {
  attr(strategy, "init") <- TRUE
  NextMethod("tweak")
}
