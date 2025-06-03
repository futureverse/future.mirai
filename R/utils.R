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

commaq <- function(x, sep = ", ") paste(sQuote(x), collapse = sep)
