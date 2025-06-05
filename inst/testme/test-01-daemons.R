#' @tags daemons
#' @tags detritus-files

mirai::daemons(2)
print(mirai::status())

## Give daemons a chance to shutdown
Sys.sleep(10)

options(future.mirai.detritus.file.count = 2L)
