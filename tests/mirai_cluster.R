source("incl/start.R")
library("listenv")

message("*** mirai_multisession() ...")

for (cores in 1:min(2L, availableCores())) {
  ## FIXME:
  if (!fullTest && cores > 1) next

  mprintf("Testing with %d cores ...", cores)
  options(mc.cores = cores - 1L)

  for (globals in c(FALSE, TRUE)) {
    mprintf("*** mirai_multisession(..., globals = %s) without globals",
            globals)

    f <- mirai_multisession({
      42L
    }, globals = globals)
    stopifnot(inherits(f, "MiraiFuture"))

    print(resolved(f))
    y <- value(f)
    print(y)
    stopifnot(y == 42L)

    mprintf("*** mirai_multisession(..., globals = %s) with globals", globals)
    ## A global variable
    a <- 0
    f <- mirai_multisession({
      b <- 3
      c <- 2
      a * b * c
    }, globals = globals)
    print(f)


    ## A mirai_multisession future is evaluated in a separated
    ## process.  Changing the value of a global
    ## variable should not affect the result of the
    ## future.
    a <- 7  ## Make sure globals are frozen
    if (globals) {
      v <- value(f)
      print(v)
      stopifnot(v == 0)
    } else {
      res <- tryCatch({ value(f) }, error = identity)
      print(res)
      stopifnot(inherits(res, "error"))
    }


    mprintf("*** mirai_multisession(..., globals = %s) with globals and blocking", globals) #nolint
    x <- listenv()
    for (ii in 1:3) {
      mprintf(" - Creating mirai_multisession future #%d ...", ii)
      x[[ii]] <- mirai_multisession({ ii }, globals = globals)
    }
    mprintf(" - Resolving %d mirai_multisession futures", length(x))
    if (globals) {
      v <- sapply(x, FUN = value)
      stopifnot(all(v == 1:3))
    } else {
      v <- lapply(x, FUN = function(f) tryCatch(value(f), error = identity))
      stopifnot(all(sapply(v, FUN = inherits, "error")))
    }

    mprintf("*** mirai_multisession(..., globals = %s) and errors", globals)
    f <- mirai_multisession({
      stop("Whoops!")
      1
    }, globals = globals)
    print(f)
    v <- value(f, signal = FALSE)
    print(v)
    stopifnot(inherits(v, "error"))

    res <- tryCatch({
      v <- value(f)
    }, error = identity)
    print(res)
    stopifnot(inherits(res, "error"))

    ## Error is repeated
    res <- tryCatch({
      v <- value(f)
    }, error = identity)
    print(res)
    stopifnot(inherits(res, "error"))

  } # for (globals ...)


  message("*** mirai_multisession(..., workers = 1L) ...")

  a <- 2
  b <- 3
  y_truth <- a * b

  f <- mirai_multisession({ a * b }, workers = 1L)
  rm(list = c("a", "b"))

  v <- value(f)
  print(v)
  stopifnot(v == y_truth)

  message("*** mirai_multisession(..., workers = 1L) ... DONE")

  mprintf("Testing with %d cores ... DONE", cores)
} ## for (cores ...)

message("*** mirai_multisession() ... DONE")

source("incl/end.R")
