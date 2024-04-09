plan(mirai_multisession)

# A function that returns a future, note that N uses lexical scoping...
f <- \() future({4 * sum((runif(N) ^ 2 + runif(N) ^ 2) < 1) / N}, seed = TRUE)

# Run a simple sampling approximation of pi in parallel using  M * N points:
N <- 1e6  # samples per worker
M <- 10   # iterations
pi_est <- Reduce(sum, Map(value, replicate(M, f()))) / M
print(pi_est)

plan(sequential)
invisible(mirai::daemons(0)) ## Shut down mirai workers
