## Record original state
ovars <- ls()
oopts <- options(warn = 1L, mc.cores = 2L, future.debug = TRUE)
oopts$future.delete <- getOption("future.delete")
oplan <- future::plan()

## Use local mirai_multisession futures by default
future::plan(future.mirai::mirai_multisession)

fullTest <- (Sys.getenv("_R_CHECK_FULL_") != "")

all_strategies <- function() {
  strategies <- Sys.getenv("R_FUTURE_TESTS_STRATEGIES")
  strategies <- unlist(strsplit(strategies, split = ","))
  strategies <- gsub(" ", "", strategies)
  strategies <- strategies[nzchar(strategies)]
  strategies <- c(future:::supportedStrategies(), strategies)
  unique(strategies)
}

test_strategy <- function(strategy) {
  strategy %in% all_strategies()
}

attach_locally <- function(x, envir = parent.frame()) {
  for (name in names(x)) {
    assign(name, value = x[[name]], envir = envir)
  }
}

mprint <- future.mirai:::mprint
mprintf <- future.mirai:::mprintf

