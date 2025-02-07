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

and

```r
library(future.mirai)
mirai::daemons(2)
plan(mirai_cluster)

demo("mandelbrot", package = "future", ask = FALSE)
```


[mirai]: https://cran.r-project.org/package=mirai
[future]: https://cran.r-project.org/package=future
[future.mirai]: https://github.com/futureverse/future.mirai
[future.apply]: https://cran.r-project.org/package=future.apply
[furrr]: https://cran.r-project.org/package=furrr
[doFuture]: https://cran.r-project.org/package=doFuture
