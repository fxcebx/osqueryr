#' @include osqueryr-driver.R
NULL

OsqueryConnection <- function(host = NULL, keyfile = NULL, session = NULL, osquery_remote_path = NULL) {
  # TODO: Add arguments
  new(
    "OsqueryConnection",
    host = host,
    keyfile = keyfile,
    session = session,
    osquery_remote_path = osquery_remote_path
  )
}

#' @rdname DBI
#' @export
setClass(
  "OsqueryConnection",
  contains = "DBIConnection",
  slots = list(
    host = "ANY",
    keyfile = "ANY",
    osquery_remote_path = "ANY",
    session = "ANY"
  )
)

#' @rdname DBI
#' @inheritParams methods::show
#' @export
setMethod(
  "show", "OsqueryConnection",
  function(object) {
    cat("<OsqueryConnection>\n")
    if (!is.null(object@session)) {
      print(object@session)
    }
  })

#' @rdname DBI
#' @inheritParams DBI::dbIsValid
#' @export
setMethod(
  "dbIsValid", "OsqueryConnection",
  function(dbObj, ...) {
    if (is.null(dbObj@host)) return(TRUE)
    s <- ssh_info(dbObj@session)
    return(TRUE)
  })

#' @rdname DBI
#' @inheritParams DBI::dbDisconnect
#' @export
setMethod(
  "dbDisconnect", "OsqueryConnection",
  function(conn, ...) {
    if (is.null(conn@host)) return(TRUE)
    if (!dbIsValid(conn)) {
      warning("Connection already closed.", call. = FALSE)
    } else {
      ssh_disconnect(conn@session)
    }

    # TODO: Free resources
    TRUE
  })

#' @rdname DBI
#' @inheritParams DBI::dbSendQuery
#' @export
setMethod(
  "dbSendQuery", c("OsqueryConnection", "character"),
  function(conn, statement, ...) {
    # message("dbSendQuery")
    OsqueryResult(connection = conn, statement = statement)
  })

#' @rdname DBI
#' @inheritParams DBI::dbSendStatement
#' @export
setMethod(
  "dbSendStatement", c("OsqueryConnection", "character"),
  function(conn, statement, ...) {
    OsqueryResult(connection = conn, statement = statement)
  })

#' @rdname DBI
#' @inheritParams DBI::dbDataType
#' @export
setMethod(
  "dbDataType", "OsqueryConnection",
  function(dbObj, obj, ...) {
    if (is.integer(obj)) "INTEGER"
    else if (is.numeric(obj)) "DOUBLE"
    else "TEXT"
    # tryCatch(
    #   getMethod("dbDataType", "DBIObject", asNamespace("DBI"))(dbObj, obj, ...),
    #   error = function(e) testthat::skip("Not yet implemented: dbDataType(Connection)"))
  })

#' @rdname DBI
#' @inheritParams DBI::dbQuoteString
#' @export
setMethod(
  "dbQuoteString", c("OsqueryConnection", "character"),
  function(conn, x, ...) {
    # Optional
    getMethod("dbQuoteString", c("DBIConnection", "character"), asNamespace("DBI"))(conn, x, ...)
  })

#' @rdname DBI
#' @inheritParams DBI::dbQuoteIdentifier
#' @export
setMethod(
  "dbQuoteIdentifier", c("OsqueryConnection", "character"),
  function(conn, x, ...) {
    # Optional
    getMethod("dbQuoteIdentifier", c("DBIConnection", "character"), asNamespace("DBI"))(conn, x, ...)
  })

# @rdname DBI
# @inheritParams DBI::dbWriteTable
# @param overwrite Allow overwriting the destination table. Cannot be
#   `TRUE` if `append` is also `TRUE`.
# @param append Allow appending to the destination table. Cannot be
#   `TRUE` if `overwrite` is also `TRUE`.
# @export
# setMethod(
#   "dbWriteTable", c("OsqueryConnection", "character", "data.frame"),
#   function(conn, name, value, overwrite = FALSE, append = FALSE, ...) {
#     testthat::skip("Not yet implemented: dbWriteTable(Connection, character, data.frame)")
#   })

#' @rdname DBI
#' @inheritParams DBI::dbReadTable
#' @export
setMethod(
  "dbReadTable", c("OsqueryConnection", "character"),
  function(conn, name, ...) {
    if (dbExistsTable(conn, name)) {
      dbGetQuery(conn, sprintf("SELECT * FROM %s", name))
    } else {
      NULL
    }
  })

#' @rdname DBI
#' @inheritParams DBI::dbListTables
#' @export
setMethod(
  "dbListTables", "OsqueryConnection",
  function(conn, ...) {
    # message("dbListTables")
    if (is.null(conn@session)) {
      ret <- call_osquery(".tables")
    } else {
      ret <- ssh_osquery(conn@session, conn@osquery_remote_path, ".tables")
    }
    out <- strsplit(ret$stdout, "\n")[[1]]
    out <- gsub("^[[:space:]]*=>[[:space:]]*", "", out)
    out
  })

#' @rdname DBI
#' @inheritParams DBI::dbExistsTable
#' @export
setMethod(
  "dbExistsTable", c("OsqueryConnection", "character"),
  function(conn, name, ...) {
    if (is.null(conn@session)) {
      ret <- call_osquery(".tables")
    } else {
      ret <- ssh_osquery(conn@session, conn@osquery_remote_path, ".tables")
    }
    out <- strsplit(ret$stdout, "\n")[[1]]
    out <- gsub("^[[:space:]]*=>[[:space:]]*", "", out)
    (name %in% out)
  })

#' @rdname DBI
#' @inheritParams DBI::dbListFields
#' @export
setMethod(
  "dbListFields", c("OsqueryConnection", "character"),
  function(conn, name, ...) {
    names(dbGetQuery(conn, paste('SELECT * FROM', name, 'LIMIT 1')))
  })

# @rdname DBI
# @inheritParams DBI::dbRemoveTable
# @export
# setMethod(
#   "dbRemoveTable", c("OsqueryConnection", "character"),
#   function(conn, name, ...) {
#     testthat::skip("Not yet implemented: dbRemoveTable(Connection, character)")
#   })

# @rdname DBI
# @inheritParams DBI::dbBegin
# @export
# setMethod(
#   "dbBegin", "OsqueryConnection",
#   function(conn, ...) {
#     testthat::skip("Not yet implemented: dbBegin(Connection)")
#   })

# @rdname DBI
# @inheritParams DBI::dbCommit
# @export
# setMethod(
#   "dbCommit", "OsqueryConnection",
#   function(conn, ...) {
#     testthat::skip("Not yet implemented: dbCommit(Connection)")
#   })

# @rdname DBI
# @inheritParams DBI::dbRollback
# @export
# setMethod(
#   "dbRollback", "OsqueryConnection",
#   function(conn, ...) {
#     testthat::skip("Not yet implemented: dbRollback(Connection)")
#   })
