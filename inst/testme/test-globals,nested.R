#' @tags globals
#' @tags detritus-files
#' @tags mirai_multisession

library(future.mirai)

plan(mirai_multisession)

g <- function() 42
h <- function() g()

f <- future(h())
v <- value(f)
print(v)
stopifnot(v == h())

plan(sequential)

