library(future.mirai)
plan(mirai_multisession, workers = I(1))

g <- function() 42
h <- function() g()

f <- future(h())
v <- value(f)
print(v)
stopifnot(v == h())

plan(sequential)
mirai::daemons(0)
