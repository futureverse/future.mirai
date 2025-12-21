#' @tags internals

message("Internal import functions ...")

import_from <- future.mirai:::import_from
import_future <- future.mirai:::import_future
with_assert <- future.mirai:::with_assert
.onLoad <- future.mirai:::.onLoad

void <- import_future("future")
stopifnot(is.function(void))
void <- import_future("non-existing", default = NA)
stopifnot(is.na(void))
void <- tryCatch(import_future("non-existing"), error = identity)
stopifnot(inherits(void, "error"))

with_assert(TRUE)

options(future.mirai.debug = NULL)
options(future.mirai.queue = NULL)
Sys.setenv(R_FUTURE_MIRAI_DEBUG = "FALSE")
Sys.setenv(R_FUTURE_MIRAI_QUEUE = "FALSE")
.onLoad("future.mirai", "future.mirai")
