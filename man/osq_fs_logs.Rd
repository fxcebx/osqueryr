% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/logs.R
\name{osq_fs_logs}
\alias{osq_fs_logs}
\title{List all the logs on our local system}
\usage{
osq_fs_logs(pattern = NULL, full.names = TRUE,
  log_dir = "/var/log/osquery")
}
\arguments{
\item{pattern, full.names}{passed on to \code{\link[=list.files]{list.files()}}}

\item{log_dir}{Defaults to \code{/var/log/osquery/}. Change this if you modified the location}
}
\description{
List all the logs on our local system
}
