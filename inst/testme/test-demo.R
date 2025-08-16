#' @tags detritus-files
#' @tags mirai_multisession

library(future)

options(future.demo.mandelbrot.nrow = 2L)
options(future.demo.mandelbrot.resolution = 50L)
options(future.demo.mandelbrot.delay = FALSE)

message("*** Demos ...")

message("*** Mandelbrot demo of the 'future' package ...")

plan(future.mirai::mirai_multisession, workers = 2)
demo("mandelbrot", package = "future", ask = FALSE)
plan(sequential)

message("*** Demos ... DONE")

