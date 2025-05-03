#' @tags detritus-files
#' @tags mirai_cluster mirai_multisession

library(future.mirai)

message("*** Futures - labels ...")

strategies <- c("mirai_cluster", "mirai_multisession")

for (strategy in strategies) {
  mdebugf("- plan('%s') ...", strategy)
  mirai::daemons(0)
  if (strategy == "mirai_cluster") mirai::daemons(parallelly::availableCores())
  plan(strategy)

  for (label in list(NULL, sprintf("strategy_%s", strategy))) {
    f <- future(42, label = label)
    print(f)
    stopifnot(identical(f$label, label))
    v <- value(f)
    stopifnot(v == 42)

    v %<-% { 42 } %label% label
    f <- futureOf(v)
    print(f)
    stopifnot(identical(f$label, label))
    stopifnot(v == 42)

  } ## for (label ...)

  plan(sequential)
  if (strategy == "mirai_cluster") mirai::daemons(0)

  mdebugf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

message("*** Futures - labels ... DONE")

