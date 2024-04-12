<div id="badges"><!-- pkgdown markup -->
 <a href="https://github.com/HenrikBengtsson/future.mirai/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/HenrikBengtsson/future.mirai/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a>  <a href="https://github.com/HenrikBengtsson/future.mirai/actions?query=workflow%3Afuture_tests"><img border="0" src="https://github.com/HenrikBengtsson/future.mirai/actions/workflows/future_tests.yaml/badge.svg?branch=develop" alt="future.tests checks status"/></a>   <a href="https://app.codecov.io/gh/HenrikBengtsson/future.mirai"><img border="0" src="https://codecov.io/gh/HenrikBengtsson/future.mirai/branch/develop/graph/badge.svg" alt="Coverage Status"/></a> 
</div>

# future.mirai: A Future API for Parallel Processing using 'mirai' 

## Introduction

The **[future]** package provides a generic API for using futures in
R.  A future is a simple yet powerful mechanism to evaluate an R
expression and retrieve its value at some point in time.  Futures can
be resolved in many different ways depending on which strategy is
used.  There are various types of synchronous and asynchronous futures
to choose from in the **[future]** package.

This package, **[future.mirai]**, provides a type of futures that
utilizes the **[mirai]** package.

For example,

```r
> library(future.mirai)
> plan(mirai_multisession)
>
> x %<-% { Sys.sleep(5); 3.14 }
> y %<-% { Sys.sleep(5); 2.71 }
> x + y
[1] 5.85
```

This is obviously a toy example to illustrate what futures look like
and how to work with them.  For further examples on how to use
futures, see the vignettes of the **[future]** package as well as
those of **[future.apply]**, **[furrr]**, and **[doFuture]**.


## Using the future.mirai backend

The **future.mirai** package implements a **future** backend wrapper
for **mirai**.


| Backend              | Description                                                      | Alternative in future package
|:---------------------|:-----------------------------------------------------------------|:------------------------------
| `mirai_multisession` | parallel evaluation in separate R processes (on current machine) | `plan(multisession)`
| `mirai_cluster`      | parallel evaluation in mirai-configured workers                  | `plan(cluster)`


### Advantages of mirai futures

The **mirai** package provides a low-level future-like mechanism for
evaluating R expression in separate R processes running on the local
machine or on one or more remote machines.  Centrally to **mirai** is
its highly-optimized queueing mechanism, which is used to orchestrate
communication between the main R process and parallel workers. A
**mirai** cluster of workers can be configured to communicate securly
via the well-established Transport Layer Security (TLS) protocol.

Another advantage with `mirai_*` futures, compared to `multisession`
and `cluster` futures, is that we can use more than 125 parallel
workers.  The current limit of 125 workers for `multisession` and
`cluster` futures stems from how the underlying **parallel** package
using one R connection per parallel worker and R has a limit of 125 R
connections per session.  In R (>= 4.4.0), we can increase this limit
when we launch R, e.g. `R --max-connections=200`. For R (< 4.4.0), R
has to be rebuilt from source after adjusting the source code.  The
**mirai** package does not rely on R connections for parallel workers
and does therefore not suffer from this limit.


## Demos

The **[future]** package provides a demo using futures for calculating
a set of Mandelbrot planes.  The demo does not assume anything about
what type of futures are used.  _The user has full control of how
futures are evaluated_.  For instance, to use `mirai_multisession`
futures, run the demo as:

```r
library(future.mirai)
plan(mirai_multisession)

demo("mandelbrot", package = "future", ask = FALSE)
```

To use `mirai_cluster` futures, use:

```r
library(future.mirai)
mirai::daemons(2)
plan(mirai_cluster)

demo("mandelbrot", package = "future", ask = FALSE)
```


## Installation

R package **future.mirai** is available on
[CRAN](https://cran.r-project.org/package=future.mirai) and can be
installed in R as:

```r
install.packages("future.mirai")
```


### Pre-release version

To install the pre-release version that is available in Git branch
`develop` on GitHub, use:

```r
remotes::install_github("HenrikBengtsson/future.mirai", ref="develop")
```

This will install the package from source.


[mirai]: https://cran.r-project.org/package=mirai
[future]: https://cran.r-project.org/package=future
[future.mirai]: https://github.com/HenrikBengtsson/future.mirai
[future.apply]: https://cran.r-project.org/package=future.apply
[furrr]: https://cran.r-project.org/package=furrr
[doFuture]: https://cran.r-project.org/package=doFuture

<!-- pkgdown-drop-below -->
