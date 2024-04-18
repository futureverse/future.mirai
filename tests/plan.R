source("incl/start,load-only.R")

message("*** plan() ...")

message("*** future::plan(future.mirai::mirai_multisession)")
oplan <- future::plan(future.mirai::mirai_multisession)
print(future::plan())
future::plan(oplan)
print(future::plan())


library("future.mirai")
plan(mirai_multisession)

for (type in c("mirai_multisession")) {
  mprintf("*** plan('%s') ...", type)

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

  mprintf("*** plan('%s') ... DONE", type)
} # for (type ...)


message("*** Assert that default backend can be overridden ...")

mpid <- Sys.getpid()
print(mpid)

plan(mirai_multisession)
pid %<-% { Sys.getpid() }
print(pid)
stopifnot(pid != mpid)


message("*** plan() ... DONE")

source("incl/end.R")
