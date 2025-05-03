#' @tags plan
#' @tags detritus-files
#' @tags mirai_multisession

message("*** plan() ...")

message("*** future::plan(future.mirai::mirai_multisession)")
oplan <- future::plan(future.mirai::mirai_multisession)
print(future::plan())
future::plan(oplan)
print(future::plan())


library(future.mirai)

for (type in c("mirai_multisession")) {
  mdebugf("*** plan('%s') ...", type)

  plan(type)
  stopifnot(inherits(plan("next"), "mirai_multisession"))

  a <- 0
  f <- future({
    b <- 3
    c <- 2
    a * b * c
  })
  a <- 7  ## Make sure globals are frozen
  v <- value(f)
  print(v)
  stopifnot(v == 0)

  plan(sequential)

  mdebugf("*** plan('%s') ... DONE", type)
} # for (type ...)


message("*** Assert that default backend can be overridden ...")

mpid <- Sys.getpid()
print(mpid)

plan(mirai_multisession)

pid %<-% { Sys.getpid() }
print(pid)
if (nbrOfWorkers() == 1L) {
  stopifnot(pid == mpid)
} else {
  stopifnot(pid != mpid)
}

plan(sequential)


message("*** plan() ... DONE")
