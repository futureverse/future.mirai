# Version 0.2.2

## Miscellaneous

 * Internal updates for **mirai** (>= 1.1.0), e.g. `mirai::daemons()`
   argument `resilience` is being removed.
 

# Version 0.2.1

## Bug Fix
 
 * `nbrOfWorkers()` and `nbrOfFreeWorkers()` did not handle mirai
   dispatcher errors. Because those are integers, these functions
   would return the error integer value instead of giving a
   `FutureError`.
  

# Version 0.2.0

 * First public release.


# Version 0.1.1

## Miscellaneous

 * Align code with **mirai** 0.9.1.
 

# Version 0.1.0

## Significant Changes

 * A working, proof-of-concept implementation.
