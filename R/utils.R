now <- function(x = Sys.time(), format = "[%H:%M:%OS3] ") {
  ## format(x, format = format) ## slower
  format(as.POSIXlt(x, tz = ""), format = format)
}

mdebug <- function(..., prefix = now(), debug = getOption("future.mirai.debug", FALSE)) {
  if (!debug) return()
  message(prefix, ...)
}

mdebugf <- function(..., appendLF = TRUE,
                    prefix = now(), debug = getOption("future.mirai.debug", FALSE)) {
  if (!debug) return()
  message(prefix, sprintf(...), appendLF = appendLF)
}

#' @importFrom utils capture.output str
mstr <- function(..., prefix = now(), debug = getOption("future.mirai.debug", FALSE)) {
  if (!debug) return()
  stdout <- capture.output(str(...))
  stdout <- paste(prefix, stdout, sep = "", collapse = "\n")
  message(stdout)
}

#' @importFrom utils capture.output str
mprint <- function(..., prefix = now(), debug = getOption("future.mirai.debug", FALSE)) {
  if (!debug) return()
  stdout <- capture.output(print(...))
  stdout <- paste(prefix, stdout, sep = "", collapse = "\n")
  message(stdout)
}
