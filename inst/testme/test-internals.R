#' @tags internals

message("Internal import functions ...")

import_from <- future.mirai:::import_from
import_future <- future.mirai:::import_future
import_future_functions <- future.mirai:::import_future_functions

void <- import_future("future")
stopifnot(is.function(void))
void <- import_future("non-existing", default = NA)
stopifnot(is.na(void))
void <- tryCatch(import_future("non-existing"), error = identity)
stopifnot(inherits(void, "error"))



