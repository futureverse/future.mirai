if (requireNamespace("future.tests")) {
  mirai::daemons(0)
  future.tests::check("future.mirai::mirai_multisession", timeout = 30.0, exit_value = FALSE)
  mirai::daemons(0)
}
