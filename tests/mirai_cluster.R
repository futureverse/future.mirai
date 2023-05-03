if (requireNamespace("future.tests")) {
  future.tests::check("future.mirai::mirai_cluster", timeout = 10.0, exit_value = FALSE)
}
