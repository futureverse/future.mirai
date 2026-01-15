# future.mirai: A Future API for Parallel Processing using 'mirai'

The future.mirai package implements the Future API using the mirai
package.

## See also

Useful links:

- <https://future.mirai.futureverse.org>

- <https://github.com/futureverse/future.mirai>

- Report bugs at <https://github.com/futureverse/future.mirai/issues>

## Author

**Maintainer**: Henrik Bengtsson <henrikb@braju.com>
([ORCID](https://orcid.org/0000-0002-7579-5165)) \[copyright holder\]

Other contributors:

- Charlie Gao <charlie.gao@shikokuchuo.net>
  ([ORCID](https://orcid.org/0000-0002-0750-061X)) (For 'mirai'-related
  patches and implementing feature requests in 'mirai') \[contributor\]

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
#> [1] 3.141871

## Switch back to sequential processing, which also
## shuts down the automatically launched mirai workers 
plan(sequential)
```
