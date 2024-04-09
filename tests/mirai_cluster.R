if (requireNamespace("future.tests")) {
  mirai::daemons(0)  ## Reset any daemons running

  ## FIXME: The following is disable on MS Windows, because it will
  ## result in a 'R CMD check' NOTE on "detritus in the temp directory".
  ## This happens whenever we use  mirai::daemons(..., dispatcher = TRUE) [1],
  ## which is what mirai_cluster() uses.
  ## [1] https://github.com/shikokuchuo/mirai/discussions/105
  if (.Platform[["OS.type"]] != "windows") {
    future.tests::check("future.mirai::mirai_cluster", timeout = 30.0, exit_value = FALSE)
  }
  
  mirai::daemons(0)  ## Reset any daemons running
  gc()
}
