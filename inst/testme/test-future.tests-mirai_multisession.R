#' @tags detritus-files
#' @tags mirai_multisession
#' @tags future.tests

if (requireNamespace("future.tests")) {
  mirai::daemons(0)  ## Reset any daemons running
  
  future.tests::check("future.mirai::mirai_multisession", timeout = 30.0, exit_value = FALSE)
  
  mirai::daemons(0)  ## Reset any daemons running
  gc()
}
