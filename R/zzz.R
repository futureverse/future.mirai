## To be cached by .onLoad()
FutureRegistry <- NULL

.onLoad <- function(libname, pkgname) {
  ## Import private functions from 'future'
  FutureRegistry <<- import_future("FutureRegistry")

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

