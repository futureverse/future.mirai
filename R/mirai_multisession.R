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
