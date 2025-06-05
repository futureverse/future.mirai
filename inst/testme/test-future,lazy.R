#' @tags detritus-files
#' @tags mirai_cluster mirai_multisession

library(future.mirai)

message("*** Futures - lazy ...")

strategies <- c("mirai_cluster", "mirai_multisession")

for (strategy in strategies) {
  mdebugf("- plan('%s') ...", strategy)
  mirai::daemons(0)
  if (strategy == "mirai_cluster") mirai::daemons(parallelly::availableCores())
  plan(strategy)

  a <- 42
  f <- future(2 * a, lazy = TRUE)
  a <- 21
  v <- value(f)
  stopifnot(v == 84)

  a <- 42
  v %<-% { 2 * a } %lazy% TRUE
  a <- 21
  stopifnot(v == 84)

  plan(sequential)
  if (strategy == "mirai_cluster") mirai::daemons(0)

  mdebugf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

message("*** Futures - lazy ... DONE")

