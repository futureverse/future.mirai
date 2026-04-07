# Mirai-based cluster futures

*WARNING: This function must never be called. It may only be used with
[`future::plan()`](https://future.futureverse.org/reference/plan.html)*

## Usage

``` r
mirai_cluster(..., envir = parent.frame())
```

## Arguments

- envir:

  The [environment](https://rdrr.io/r/base/environment.html) from where
  global objects should be identified.

- ...:

  Not used.

## Value

Nothing.

## Launch mirai workers via HPC job scheduler

If you have access to a high-performance-compute (HPC) environment with
a job scheduler, you can use **future.mirai** and **mirai** to run
parallel workers distributed on the computer cluster. How to set these
workers up is explained in
[`mirai::cluster_config()`](https://mirai.r-lib.org/reference/cluster_config.html),
which should work for our most common job schedulers, e.g. Slurm,
Sun/Son of/Oracle/Univa/Altair Grid Engine (SGE), OpenLava, Load Sharing
Facility (LSF), and TORQUE/PBS.

*Note: Not all compute clusters support running **mirai** workers this
way. This is because **mirai** workers need to establish a TCP
connection back to the machine that launched the workers, but some
systems have security policies disallowing such connections from being
established. This is often configured in the firewall and can only be
controlled by the admins. If your system has such rules, you will find
that the mirai jobs are launched and running on the scheduler, but we
will wait forever for the mirai workers to connect back, i.e.
`mirai::info()[["connections"]]` is always zero in the below example.*

Briefly, to launch a cluster of mirai workers on an HPC cluster, we need
to:

1.  configure
    [`mirai::cluster_config()`](https://mirai.r-lib.org/reference/cluster_config.html)
    for the job scheduler,

2.  use configuration to launch workers using
    [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html).

The first step is specific to each job scheduler and this is where you
control things such as how much memory each worker gets, for how long
they may run, which environment modules to load, and which environment
modules to load, if any. The second step is the same regardless of job
scheduler. Here is an example for how to run parallel mirai workers on a
Slurm scheduler and then use these in futureverse.

    # Here we give each worker 200 MiB of RAM and a maximum of one hour
    # to run. Unless we specify '--cpus-per-task=N', each mirai worker
    # is allotted one CPU core, which prevents nested parallelization.
    # R is provided via environment module 'r' on this cluster.
    config <- mirai::cluster_config(command = "sbatch", options = "
      #SBATCH --job-name=mirai
      #SBATCH --time=01:00:00
      #SBATCH --mem=200M
      module load r
    ")

    # -------------------------------------------------------------------
    # Launch eight mirai workers, via equally many jobs, wait for all of
    # them to become available, and use them in futureverse
    # -------------------------------------------------------------------
    workers <- 8
    mirai::daemons(n = workers, url = mirai::host_url(), remote = config)
    while(mirai::info()[["connections"]] < workers) Sys.sleep(1.0)
    plan(future.mirai::mirai_cluster)

    # Verify that futures are resolved on a compute node
    f <- future({
      data.frame(
         hostname = Sys.info()[["nodename"]],
               os = Sys.info()[["sysname"]],
        osVersion = utils::osVersion,
            cores = unname(parallelly::availableCores()),
          modules = Sys.getenv("LOADEDMODULES")
      )
    })
    info <- value(f)
    print(info)
    #>   hostname    os                osVersion cores  modules
    #> 1      n12 Linux Linux Ubuntu 24.04.3 LTS     1  r/4.5.2

    # Shut down parallel workers
    plan(sequential)
    mirai::daemons(0)

If you are on SGE, you can use the following configuration:

    config <- mirai::cluster_config(command = "qsub", options = "
      #$ -N mirai
      #$ -j y
      #$ -cwd
      #$ -l h_rt=01:00:00
      #$ -l mem_free=200M
      module load r
    ")

Everything else is the same.

*Comment*:
[`mirai::cluster_config()`](https://mirai.r-lib.org/reference/cluster_config.html)
configures the jobs to run vanilla POSIX shells, i.e. `/bin/sh`. This
might be too strict for some users. If your setup requires your jobs to
be run using Bash (`/bin/sh`), you can tweak the configuration `config`
object manually to do so;

    config$command <- "/bin/bash"
    config$args <- sub("/bin/sh", config$command, config$args)

## Examples

``` r
library(future)

# Manually launch mirai workers
mirai::daemons(parallelly::availableCores())

plan(future.mirai::mirai_cluster)

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
#> [1] 3.140932

## Switch back to sequential processing
plan(sequential)

## Shut down manually launched mirai workers
invisible(mirai::daemons(0))
```
