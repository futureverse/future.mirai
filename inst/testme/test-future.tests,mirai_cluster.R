#' @tags detritus-files
#' @tags mirai_cluster
#' @tags future.tests

if (requireNamespace("future.tests")) {
  ## FIXME: The following is disabled on MS Windows, because it will
  ## result in a 'R CMD check' NOTE on "detritus in the temp directory" [1].
  ## This happens whenever we use mirai::daemons(..., dispatcher = TRUE).
  ## [1] https://github.com/shikokuchuo/mirai/discussions/105
  dispatcher <- (.Platform[["OS.type"]] != "windows")
  if (isTRUE(dispatcher)) {
    mirai::daemons(0)  ## Reset any daemons running
    mirai::daemons(parallelly::availableCores())
    future.tests::check("future.mirai::mirai_cluster", timeout = 10.0, exit_value = FALSE)
    mirai::daemons(0)  ## Reset any daemons running
  }
  gc()
}
