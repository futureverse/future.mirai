# Mirai-based localhost multisession futures

*WARNING: This function must never be called. It may only be used with
[`future::plan()`](https://future.futureverse.org/reference/plan.html)*

## Usage

``` r
mirai_multisession(..., workers = availableCores(), envir = parent.frame())
```

## Arguments

- workers:

  The number of parallel processes to use. If a function, it is called
  without arguments *when the future is created* and its value is used
  to configure the workers. If `workers == 1`, then all processing using
  done in the current/main R session and we therefore fall back to using
  a sequential future. To override this fallback, use `workers = I(1)`.

- envir:

  The [environment](https://rdrr.io/r/base/environment.html) from where
  global objects should be identified.

- ...:

  Not used.

## Value

Nothing.

## Examples

``` r
library(future)
plan(future.mirai::mirai_multisession)

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
#> [1] 3.142363

## Switch back to sequential processing, which also
## shuts down the automatically launched mirai workers 
plan(sequential)
```
