## This requires mirai (>= 0.13.2)
if (packageVersion("mirai") >= "0.13.2") {
library(future.mirai)

mirai::daemons(1, dispatcher = FALSE)
plan(mirai_cluster)

g <- function() 42
h <- function() g()

f <- future(h())
v <- value(f)
print(v)
stopifnot(v == h())

plan(sequential)
mirai::daemons(0)  ## Reset any daemons running
gc()

}
