if (requireNamespace("future.tests")) {
  mirai::daemons(0)  ## Reset any daemons running

  ## FIXME: The following is disabled on MS Windows, because it will
  ## result in a 'R CMD check' NOTE on "detritus in the temp directory" [1].
  ## This happens whenever we use mirai::daemons(..., dispatcher = TRUE).
  ## [1] https://github.com/shikokuchuo/mirai/discussions/105
  dispatcher <- (.Platform[["OS.type"]] != "windows")
  
  mirai::daemons(2, dispatcher = dispatcher)
  future.tests::check("future.mirai::mirai_cluster", timeout = 10.0, exit_value = FALSE)
  
  mirai::daemons(0)  ## Reset any daemons running
  gc()
}
