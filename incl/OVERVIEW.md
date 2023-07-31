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
those of **[future.apply]** and **[doFuture]**.


## Using the future.mirai backend

The **future.mirai** package implements a **future** backend wrapper
for **mirai**.


| Backend              | Description                                                      | Alternative in future package
|:---------------------|:-----------------------------------------------------------------|:------------------------------
| `mirai_multisession` | parallel evaluation in a separate R process (on current machine) | `plan(multisession)`


### Each mirai future uses a fresh R session

When using `mirai` futures, each future is resolved in a fresh
background R session which ends as soon as the value of the future has
been collected.  In contrast, `multisession` futures are resolved in
background R worker sessions that serve multiple futures over their
life spans.  The advantage with using a new R process for each future
is that it is that the R environment is guaranteed not to be
contaminated by previous futures, e.g. memory allocations, finalizers,
modified options, and loaded and attached packages.  The disadvantage,
is an added overhead of launching a new R process.


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


[mirai]: https://cran.r-project.org/package=mirai
[future]: https://cran.r-project.org/package=future
[future.mirai]: https://github.com/HenrikBengtsson/future.mirai
[future.apply]: https://cran.r-project.org/package=future.apply
[doFuture]: https://cran.r-project.org/package=doFuture
