# Manually launch mirai workers
mirai::daemons(parallelly::availableCores())

plan(mirai_cluster)

# A function that returns a future
# (note that N is a global variable)
f <- function() future({
  4 * sum((runif(N) ^ 2 + runif(N) ^ 2) < 1) / N
}, seed = TRUE)

# Run a simple sampling approximation of pi in parallel using  M * N points:
N <- 1e6  # samples per worker
M <- 10   # iterations
pi_est <- Reduce(sum, Map(value, replicate(M, f()))) / M
print(pi_est)

## Switch back to sequential processing
plan(sequential)

## Shut down manually launched mirai workers
invisible(mirai::daemons(0))
