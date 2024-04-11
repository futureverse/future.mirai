#' Mirai-based cluster futures
#'
#' @inheritParams MiraiFuture
#' @inheritParams future::cluster
#'
#' @return An object of class [MiraiFuture].
#'
#' @example incl/mirai_cluster.R
#'
#' @export
mirai_cluster <- function(expr,
                               substitute = TRUE,
                               envir = parent.frame(),
                               ...) {
  if (substitute) expr <- substitute(expr)

  future <- MiraiFuture(
              expr = expr, substitute = FALSE,
              envir = envir,
              workers = NULL,
              ...
            )
  if(!isTRUE(future[["lazy"]])) future <- run(future)
  invisible(future)
}
class(mirai_cluster) <- c("mirai_cluster", "mirai", "multiprocess", "future", "function")
attr(mirai_cluster, "init") <- TRUE


#' @importFrom future tweak
#' @export
tweak.mirai_cluster <- function(strategy, ..., penvir = parent.frame()) {
  attr(strategy, "init") <- TRUE
  NextMethod("tweak")
}
