#' A Mirai-based future task queue implementation
#'
#' Set up the future parameters.
#'
#' @inheritParams future::`Future-class`
#'
#' @return An object of class `MiraiFuture`.
#'
#' @keywords internal
#' @importFrom future getGlobalsAndPackages Future
#' @export
MiraiFuture <- function(expr = NULL,
                        substitute = TRUE,
                        envir = parent.frame(),
                        globals = TRUE,
                        packages = NULL,
                        lazy = FALSE,
                        ...)
{
  if(isTRUE(substitute)) expr <- substitute(expr)

  ## Record globals
  if(!isTRUE(attr(globals, "already-done", exact = TRUE))) {
    gp <- getGlobalsAndPackages(expr, envir = envir, persistent = FALSE, globals = globals)
    globals <- gp[["globals"]]
    packages <- c(packages, gp[["packages"]])
    expr <- gp[["expr"]]
    gp <- NULL
  }

  future <- Future(expr = expr,
                   substitute = substitute,
                   envir = envir,
                   globals = globals,
                   packages = packages,
                   lazy = lazy,
                   ...)
  
  structure(future, class = c("MiraiFuture", class(future)))
}


#' Check on the status of a future task.
#' @return boolean indicating the task is finished (TRUE) or not (FALSE)
#' @importFrom mirai unresolved
#' @importFrom future resolved
#' @keywords internal
#' @export
resolved.MiraiFuture <- function(x, ...) {
  debug <- getOption("future.mirai.debug", FALSE)
  if (debug) {
    mdebugf("resolved() for %s ...", class(x)[1], debug = debug)
    on.exit(mdebugf("resolved() for %s ... done", class(x)[1], debug = debug))
  }
  
  resolved <- NextMethod()
  if(resolved) {
    mdebug("- already resolved", debug = debug)
    return(TRUE)
  }
  
  if(x[["state"]] == "finished") {
    mdebug("- already resolved (state == finished)", debug = debug)
    return(TRUE)
  } else if(x[["state"]] == "created") { # Not yet submitted to queue (iff lazy)
    mdebug("- just created; launching")
    x <- run(x)
    return(FALSE)
  }

  mirai <- x[["mirai"]]
  mdebug("mirai::unresolved() ...", debug = debug)
  res <- unresolved(mirai)
  mstr(res, debug = debug)
  mdebug("mirai::unresolved() ... done", debug = debug)
  
  !res
}



#' @importFrom mirai mirai
#' @importFrom future run getExpression
#' @export
run.MiraiFuture <- function(future, ...) {
  if(isTRUE(future[["state"]] != "created")) return(invisible(future))
  
  debug <- getOption("future.mirai.debug", FALSE)
  if (debug) {
    mdebugf("run() for %s ...", class(future)[1], debug = debug)
    on.exit(mdebugf("run() for %s ... done", class(future)[1], debug = debug))
  }

  future[["state"]] <- "submitted"

  globals <- future[["globals"]]
  fexpr <- getExpression(future)

  fexpr <- bquote({
    local({
      genv <- globalenv()
      for (name in names(globals)) {
        assign(name, value = globals[[name]], envir = genv)
      }
    })
    .(fexpr)
  })

  expr <- bquote(mirai(.(fexpr), .args = list(globals)))
  
  mirai <- eval(expr)
  future[["mirai"]] <- mirai

  future[["state"]] <- "running"

  invisible(future)
}


#' @importFrom future result
#' @export
result.MiraiFuture <- function(future, ...) {
  if(isTRUE(future[["state"]] == "finished")) {
    return(future[["result"]])
  }

  debug <- getOption("future.mirai.debug", FALSE)
  if (debug) {
    mdebugf("result() for %s ...", class(future)[1], debug = debug)
    on.exit(mdebugf("result() for %s ... done", class(future)[1], debug = debug))
  }

  mirai <- future[["mirai"]]
  while (unresolved(mirai)) {
    Sys.sleep(0.1)
  }
  
  result <- mirai$data
  future[["result"]] <- result
  future[["state"]] <- "finished"

  result
}
