# future.mirai: Parallel Future Backend using ‘mirai’

## Introduction

The **[future.mirai](https://future.mirai.futureverse.org)** package is
a backend for the **[future](https://future.futureverse.org)**
framework, also known as the [Futureverse](https://www.futureverse.org).
The Futureverse makes it easy to parallelize existing R code - often
with only a minor change of code. Most users interact with it via
higher-level packages such as
**[futurize](https://futurize.futureverse.org)**,
**[future.apply](https://future.apply.futureverse.org)**,
**[furrr](https://furrr.futureverse.org)**, and
**[doFuture](https://doFuture.futureverse.org)**, and you choose *where*
and *how* the code runs by setting a future backend with
[`plan()`](https://future.futureverse.org/reference/plan.html). This
package adds the `mirai_multisession` and `mirai_cluster` backends,
which run futures in parallel using the
**[mirai](https://mirai.r-lib.org)** package.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`futurize`](https://futurize.futureverse.org)`)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.mirai``::`[`mirai_multisession`](https://future.mirai.futureverse.org/reference/mirai_multisession.md)`)``  ``# parallelize on the current machine`\
\
`# A slow function`\
`slow_fcn`` ``<-`` ``function``(``x``)`` ``{`\
`  `[`Sys.sleep`](https://rdrr.io/r/base/Sys.sleep.html)`(``1.0``)`\
`  ``x``^``2`\
`}`\
\
`# Example data`\
`xs`` ``<-`` ``1``:``10`\
\
`# Sequential and parallel base R apply`\
`ys`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xs``, ``slow_fcn``)`\
`ys`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xs``, ``slow_fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.html)`(``)`\
\
`# Sequential and parallel purrr map`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`\
`ys`` ``<-`` ``xs`` ``|>`` `[`map`](https://purrr.tidyverse.org/reference/map.html)`(``slow_fcn``)`\
`ys`` ``<-`` ``xs`` ``|>`` `[`map`](https://purrr.tidyverse.org/reference/map.html)`(``slow_fcn``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.html)`(``)`\
\
`# Sequential and parallel foreach calls`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`foreach`](https://github.com/RevolutionAnalytics/foreach)`)`\
`ys`` ``<-`` `[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html)`(``x ``=`` ``xs``)`` `[`%do%`](https://rdrr.io/pkg/foreach/man/foreach.html)` ``slow_fcn``(``x``)`\
`ys`` ``<-`` `[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html)`(``x ``=`` ``xs``)`` `[`%do%`](https://rdrr.io/pkg/foreach/man/foreach.html)` ``slow_fcn``(``x``)`` ``|>`` `[`futurize`](https://futurize.futureverse.org/reference/futurize.html)`(``)`

The only thing that differs from using [any other future
backend](https://www.futureverse.org/backends.html) is the
[`plan()`](https://future.futureverse.org/reference/plan.html) call. The
code does not have to change, it gives identical results, and it behaves
exactly the same.

## The mirai backends

| Backend | Description | Alternative in future package |
|:---|:---|:---|
| `mirai_multisession` | parallel evaluation in separate R processes (on current machine) | `plan(multisession)` |
| `mirai_cluster` | parallel evaluation in mirai-configured workers | `plan(cluster)` |

With `mirai_multisession`, the parallel workers are launched for you on
the local machine. With `mirai_cluster`, you launch the workers yourself
using
[`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html),
which means they can also run on remote machines or on a
high-performance compute (HPC) cluster, e.g.

\
`mirai``::`[`daemons`](https://mirai.r-lib.org/reference/daemons.html)`(``2``)`\
[`plan`](https://future.futureverse.org/reference/plan.html)`(``future.mirai``::`[`mirai_cluster`](https://future.mirai.futureverse.org/reference/mirai_cluster.md)`)`

### Advantages

- Communication between the main R process and the parallel workers is
  orchestrated by the highly-optimized queueing mechanism of **mirai**.

- A **mirai** cluster of workers can be configured to communicate
  securely via the Transport Layer Security (TLS) protocol.

- More than 125 parallel workers can be used. The `multisession` and
  `cluster` backends use one R connection per worker, and R has a
  default limit of 125 connections per session. **mirai** does not use R
  connections, so this limit does not apply.

### Limitations

- The `mirai_cluster` backend requires that the **mirai** daemons are
  configured to use a dispatcher, which is the default in
  [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html).

- Remote workers must be able to establish a TCP connection back to the
  machine that launched them. Some HPC clusters have firewall rules that
  block this, in which case the workers never connect. For such systems,
  consider
  **[future.batchtools](https://future.batchtools.futureverse.org)**
  instead.

## Installation

R package future.mirai is available on
[CRAN](https://cran.r-project.org/package=future.mirai) and can be
installed in R as:

\
[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"future.mirai"``)`

### Pre-release version

To install the pre-release version, use:

\
[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"future.mirai"``, repos ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"https://futureverse-devel.r-universe.dev"``, ``"https://cloud.r-project.org"``)``)`
