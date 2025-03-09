source("incl/start.R")

plan(mirai_multisession)

g <- function() 42
h <- function() g()

f <- future(h())
v <- value(f)
print(v)
stopifnot(v == h())

plan(sequential)

source("incl/end.R")
