prune_pkg_code <- function(env = topenv(parent.frame())) {
  void <- lapply(names(env), FUN = prune_fcn, envir = env)

  fcns <- list(evalFuture, getFutureData)
  for (fcn in fcns) {
    if (is.function(fcn)) {
      env <- environment(fcn)
      void <- lapply(names(env), FUN = prune_fcn, envir = env)
    }
  }
}

with_assert <- function(expr, ...) { invisible(expr) }

## To be imported from 'future', if available
FutureRegistry <- NULL
prune_fcn <- function(expr, ...) expr
evalFuture <- NULL
getFutureData <- NULL
stop_if_not <- stopifnot
commaq <- NULL

attr(mirai_cluster, "backend") <- MiraiFutureBackend
attr(mirai_multisession, "backend") <- MiraiMultisessionFutureBackend

.onLoad <- function(libname, pkgname) {
  ## Import private functions from 'future'
  FutureRegistry <<- import_future("FutureRegistry")
  prune_fcn <<- import_future("prune_fcn", default = prune_fcn)
  evalFuture <<- import_future("evalFuture", default = NULL)
  getFutureData <<- import_future("getFutureData", default = NULL)
  stop_if_not <<- import_future("stop_if_not", default = stopifnot)
  commaq <<- import_future("commaq", default = NULL)
  
  if (isTRUE(as.logical(Sys.getenv("R_FUTURE_MIRAI_PRUNE_PKG_CODE", "FALSE")))) {
    prune_pkg_code()
  }

  ## Set 'debug' option by environment variable
  value <- Sys.getenv("R_FUTURE_MIRAI_DEBUG", "FALSE")
  value <- isTRUE(suppressWarnings(as.logical(value)))
  options(future.mirai.debug = value)

  ## Set 'queue' option by environment variable
  value <- Sys.getenv("R_FUTURE_MIRAI_QUEUE", NA_character_)
  if (!is.na(value)) {
    options(future.mirai.queue = value)
  }
}

