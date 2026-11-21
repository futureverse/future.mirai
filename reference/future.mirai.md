# future.mirai: Parallel Future Backend using 'mirai'

The future.mirai package implements the Future API using the mirai
package. The Future API is defined by the future package.

## Details

To use mirai futures, attach future, and select the type of future you
wish to use, e.g. `plan(future.mirai::mirai_multisession)`.

## Example

    library(futurize)                       # also attaches 'future'
    plan(future.mirai::mirai_multisession)  # parallelize on the current machine

    # A slow function
    slow_fcn <- function(x) {
      Sys.sleep(1.0)
      x^2
    }

    # Example data
    xs <- 1:10

    # Sequential and parallel base R apply
    ys <- lapply(xs, slow_fcn)
    ys <- lapply(xs, slow_fcn) |> futurize()

    # Sequential and parallel purrr map
    library(purrr)
    ys <- xs |> map(slow_fcn)
    ys <- xs |> map(slow_fcn) |> futurize()

    # Sequential and parallel foreach calls
    library(foreach)
    ys <- foreach(x = xs) %do% slow_fcn(x)
    ys <- foreach(x = xs) %do% slow_fcn(x) |> futurize()

## See also

Useful links:

- <https://future.mirai.futureverse.org>

- <https://github.com/futureverse/future.mirai>

- Report bugs at <https://github.com/futureverse/future.mirai/issues>

## Author

**Maintainer**: Henrik Bengtsson <henrikb@braju.com>
([ORCID](https://orcid.org/0000-0002-7579-5165)) \[copyright holder\]

Authors:

- Henrik Bengtsson <henrikb@braju.com>
  ([ORCID](https://orcid.org/0000-0002-7579-5165)) \[copyright holder\]

Other contributors:

- Charlie Gao <charlie.gao@shikokuchuo.net>
  ([ORCID](https://orcid.org/0000-0002-0750-061X)) (note: For
  'mirai'-related patches and implementing feature requests in 'mirai')
  \[contributor\]
