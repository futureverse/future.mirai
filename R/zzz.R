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


.onLoad <- function(libname, pkgname) {
  import_future_functions()

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
