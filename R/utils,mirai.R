#' @importFrom mirai daemons
#' @importFrom utils capture.output
get_mirai_daemons <- function() {
  res <- daemons()$daemons
  
  if (inherits(res, "errorValue")) {
    reason <- capture.output(print(res))
    msg <- sprintf("mirai::daemons() failed to communicate with dispatcher: %s", reason)
    stop(FutureError(msg))
  }

  if (is.matrix(res)) {
    res <- as.data.frame(res)
  }
  
  res
}

#' @importFrom parallelly makeClusterPSOCK
#' @importFrom parallel parLapply stopCluster
launch_mirai_servers <- function(hostnames, ..., timeout = 60) {
  online <- NULL  ## To please R CMD check
  
  stopifnot(is.character(hostnames), !anyNA(hostnames))
  stopifnot(is.numeric(timeout), !is.na(timeout), is.finite(timeout), timeout > 0.0)

  ## Assert that mirai daemons have been configured
  dd <- get_mirai_daemons()
  stopifnot(is.data.frame(dd))

  ## Consider only non-connected daemons
  dd <- subset(dd, online == 0L)

  ## Nothing to do?
  if (nrow(dd) == 0L) return(NULL)

  ## Launch only a subset?
  if (nrow(dd) > length(hostnames)) {
    dd <- dd[seq_along(hostnames), ]
  } else if (nrow(dd) < length(hostnames)) {
    hostnames <- hostnames[seq_len(nrow(dd))]
  }

  uris <- rownames(dd)
  stopifnot(is.character(uris), !anyNA(uris), anyDuplicated(uris) == 0L)

  ## FIXME: This assumes servers are launched on localhost, or that
  ## reverse tunnelling is used when setting up the PSOCK cluster
  ## /HB 2023-05-02
  client_ip <- "127.0.0.1"
  uris <- sub("//:", sprintf("//%s:", client_ip), uris)

  ## Launching parallel PSOCK workers
  cl <- makeClusterPSOCK(hostnames, ...)

  ## Use them to launch mirai servers to connect back to daemons
  void <- parLapply(cl, uris, function(uri) {
    code <- sprintf('mirai::server("%s")', uri)
    bin <- file.path(R.home("bin"), "Rscript")
    system2(bin, args = c("-e", shQuote(code)), wait = FALSE)
  }, chunk.size = 1L)


  ## Wait for mirai servers to connect back
  t0 <- Sys.time()
  ready <- FALSE
  while (!ready) {
    dd2 <- get_mirai_daemons()
    stopifnot(is.data.frame(dd))
    dd2 <- dd2[rownames(dd), , drop = FALSE]
    dd2 <- subset(dd2, online == 0L)
    ready <- (nrow(dd2) == 0)
    Sys.sleep(1.0)
    dt <- Sys.time() - t0
    if (dt > timeout) {
      stopCluster(cl)
      cl <- NULL
      stop(sprintf("%d out of %d mirai servers did not connect back within %g seconds",
                   nrow(dd2), nrow(dd), timeout))
    }
  }

  cl
} ## launch_mirai_servers()
