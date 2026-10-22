# Version (development version)

## Significant Changes

 * Significantly lowered the per-worker and the total memory use, but
   reducing the amount of data transferred to parallel workers. This
   should increase the performance in cases where large objects per
   parallelized over.

## Bug Fixes

 * Waiting for an available worker with a timeout greater than 60
   seconds could take much longer than that.

 * `nbrOfFreeWorkers()` would produce an error when the number of
   queued and executing tasks exceeded the number of available workers.

 * `waitForWorker()` evaluated `nbrOfWorkers()` against the current
   global plan rather than the current backend.

 * `result()` on a `mirai_multisession` future dropped immediate
   conditions, despite already being signaled.

 * `resolved()` on a `mirai_multisession` future did not signal
   conditions early when the future was resolved.

 * A `mirai_multisession` future exported extra, non-needed data to
   each mirai worker, resulting in extra memory use and slowdowns.

 * If mirai daemons were configured without a dispatcher,
   `MiraiFutureBackend()` signaled a plain error instead of a
   `FutureError`.


# Version 1.0.0 [2026-06-22]

## Significant Changes

 * Changed the package license to permissive Apache License (>= 2).

## Documentation

 * Add 'Launch mirai workers via HPC job scheduler' section to
   `help("mirai_cluster", package = "future.mirai")`.


# Version 0.10.1 [2025-07-10]

## Bug Fix

 * If a mirai future that was terminated abruptly (e.g. via
   `tools::pskill()` or by the operating system), then it was not
   detected as such. Instead it resulted in an unexpected error that
   could not be recovered from. Now it is detected and a
   `FutureInterruptError` is signaled, which can then be handled and
   the future may be `reset()`.

 * `result()` on an interrupted mirai future would only throw
   FutureInterruptError the first time. Succeeding calls would result
   in other errors.
 
 * `resolved()` on a mirai future already known to be interrupted
   would re-query the mirai object, instead of returning TRUE
   immediately.
 

# Version 0.10.0 [2025-06-05]

## New Features

 * Now 'mirai' futures can be canceled using `cancel()`, which also
   interrupts them by default, which in turn frees up compute
   resources sooner. Map-reduce APIs such as **future.apply**,
   **doFuture**, and **furrr** can take advantage of this by
   canceling all non-resolved futures whenever they detect an error
   in one of the futures. Also, canceled futures can be `reset()` 
   and thereafter relaunched, possibly on another future backend.

 * Now 'mirai_multisession' futures relay `immediateCondition`s
   in near real-time, e.g. `progression` conditions signaled by the
   **progressr** package.


# Version 0.2.2 [2024-07-03]

## Miscellaneous

 * Internal updates for **mirai** (>= 1.1.0), e.g. `mirai::daemons()`
   argument `resilience` is being removed.
 

# Version 0.2.1 [2024-05-15]

## Bug Fix
 
 * `nbrOfWorkers()` and `nbrOfFreeWorkers()` did not handle mirai
   dispatcher errors. Because those are integers, these functions
   would return the error integer value instead of giving a
   `FutureError`.
  

# Version 0.2.0 [2024-04-18]

 * First public release.


# Version 0.1.1

## Miscellaneous

 * Align code with **mirai** 0.9.1.
 

# Version 0.1.0

## Significant Changes

 * A working, proof-of-concept implementation.
