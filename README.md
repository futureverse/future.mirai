

<div id="badges"><!-- pkgdown markup -->
<a href="https://CRAN.R-project.org/web/checks/check_results_future.mirai.html"><img border="0" src="https://www.r-pkg.org/badges/version/future.mirai" alt="CRAN check status"/></a> <a href="https://github.com/futureverse/future.mirai/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/futureverse/future.mirai/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a> <a href="https://github.com/futureverse/future.mirai/actions?query=workflow%3Arevdepcheck-top"><img border="0" src="https://github.com/futureverse/future.mirai/actions/workflows/revdepcheck-top.yaml/badge.svg?branch=develop" alt="Top reverse-dependency checks status"/></a> <a href="https://github.com/futureverse/future.mirai/actions?query=workflow%3Afuture_tests"><img border="0" src="https://github.com/futureverse/future.mirai/actions/workflows/future_tests.yaml/badge.svg?branch=develop" alt="future.tests checks status"/></a>   <a href="https://app.codecov.io/gh/futureverse/future.mirai"><img border="0" src="https://codecov.io/gh/futureverse/future.mirai/branch/develop/graph/badge.svg" alt="Coverage Status"/></a> 
</div>

# future.mirai: Parallel Future Backend using 'mirai' 

## Introduction

The **[future.mirai]** package is a backend for the **[future]**
framework, also known as the [Futureverse]. The Futureverse makes it
easy to parallelize existing R code - often with only a minor change
of code. Most users interact with it via higher-level packages such
as **[futurize]**, **[future.apply]**, **[furrr]**, and
**[doFuture]**, and you choose _where_ and _how_ the code runs by
setting a future backend with `plan()`. This package adds the
`mirai_multisession` and `mirai_cluster` backends, which run futures
in parallel using the **[mirai]** package.

```r
library(futurize)
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
```

The only thing that differs from using [any other future backend](https://www.futureverse.org/backends.html) is
the `plan()` call. The code does not have to change, it gives
identical results, and it behaves exactly the same.


## The mirai backends

| Backend              | Description                                                      | Alternative in future package
|:---------------------|:-----------------------------------------------------------------|:------------------------------
| `mirai_multisession` | parallel evaluation in separate R processes (on current machine) | `plan(multisession)`
| `mirai_cluster`      | parallel evaluation in mirai-configured workers                  | `plan(cluster)`

With `mirai_multisession`, the parallel workers are launched for you
on the local machine. With `mirai_cluster`, you launch the workers
yourself using `mirai::daemons()`, which means they can also run on
remote machines or on a high-performance compute (HPC) cluster, e.g.

```r
mirai::daemons(2)
plan(future.mirai::mirai_cluster)
```


### Advantages

* Communication between the main R process and the parallel workers
  is orchestrated by the highly-optimized queueing mechanism of
  **mirai**.

* A **mirai** cluster of workers can be configured to communicate
  securely via the Transport Layer Security (TLS) protocol.

* More than 125 parallel workers can be used. The `multisession` and
  `cluster` backends use one R connection per worker, and R has a
  default limit of 125 connections per session. **mirai** does not
  use R connections, so this limit does not apply.


### Limitations

* The `mirai_cluster` backend requires that the **mirai** daemons are
  configured to use a dispatcher, which is the default in
  `mirai::daemons()`.

* Remote workers must be able to establish a TCP connection back to
  the machine that launched them. Some HPC clusters have firewall
  rules that block this, in which case the workers never connect.
  For such systems, consider **[future.batchtools]** instead.


[Futureverse]: https://www.futureverse.org
[future]: https://future.futureverse.org
[future.mirai]: https://future.mirai.futureverse.org
[future.apply]: https://future.apply.futureverse.org
[future.batchtools]: https://future.batchtools.futureverse.org
[furrr]: https://furrr.futureverse.org
[doFuture]: https://doFuture.futureverse.org
[futurize]: https://futurize.futureverse.org
[mirai]: https://mirai.r-lib.org

## Installation

R package future.mirai is available on [CRAN](https://cran.r-project.org/package=future.mirai) and can be installed in R as:

```r
install.packages("future.mirai")
```


### Pre-release version

To install the pre-release version, use:

```r
install.packages("future.mirai", repos = c("https://futureverse-devel.r-universe.dev", "https://cloud.r-project.org"))
```


<!-- pkgdown-drop-below -->

