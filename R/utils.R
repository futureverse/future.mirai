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

mprintf <- function(...) message(now(), sprintf(...), appendLF = FALSE)

stop_if_not <- function(...) {
  res <- list(...)
  for (ii in 1L:length(res)) {
    res_ii <- .subset2(res, ii)
    if (length(res_ii) != 1L || is.na(res_ii) || !res_ii) {
        mc <- match.call()
        call <- deparse(mc[[ii + 1]], width.cutoff = 60L)
        if (length(call) > 1L) call <- paste(call[1L], "....")
        stopf("%s is not TRUE", sQuote(call), call. = FALSE, domain = NA)
    }
  }
  
  NULL
}
