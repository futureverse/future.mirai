#' future.mirai: Parallel Future Backend using 'mirai'
#'
#' The \pkg{future.mirai} package implements the Future API
#' using the \pkg{mirai} package.
#' The Future API is defined by the \pkg{future} package.
#'
#' To use mirai futures, attach \pkg{future}, and
#' select the type of future you wish to use, e.g.
#' `plan(future.mirai::mirai_multisession)`.
#'
#' @section Example:
#' ```r
#' library(futurize)                       # also attaches 'future'
#' plan(future.mirai::mirai_multisession)  # parallelize on the current machine
#'
#' # A slow function
#' slow_fcn <- function(x) {
#'   Sys.sleep(1.0)
#'   x^2
#' }
#'
#' # Example data
#' xs <- 1:10
#'
#' # Sequential and parallel base R apply
#' ys <- lapply(xs, slow_fcn)
#' ys <- lapply(xs, slow_fcn) |> futurize()
#'
#' # Sequential and parallel purrr map
#' library(purrr)
#' ys <- xs |> map(slow_fcn)
#' ys <- xs |> map(slow_fcn) |> futurize()
#'
#' # Sequential and parallel foreach calls
#' library(foreach)
#' ys <- foreach(x = xs) %do% slow_fcn(x)
#' ys <- foreach(x = xs) %do% slow_fcn(x) |> futurize()
#' ```
#'
#' @aliases future.mirai-package
#' @name future.mirai
"_PACKAGE"


