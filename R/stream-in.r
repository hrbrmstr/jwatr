#' Stream in records from a WARC file
#'
#' This is a pure R function that streams in WARC records and calls a callback function
#' with the WARC headers and payload for each record, optionally filtering by a subset
#' of WARC record types.
#'
#' The signature of the callback function should be:
#'
#'     function(headers, payload, ...) { }
#'
#' @md
#' @param path path to WARC file
#' @param handler callback function to call for each record
#' @param ... optional arguments to `handler`
#' @param warc_types if provided, only WARC record types matching the ones specified will
#'        be streamed in and passed to `f()`. Valid options are: `warcinfo`, `request`,
#'        `response`, `resource`, `metadata`, `revisit`, `conversion` then returned WARC
#'        records.
#' @return the number of records processed (invisibly)
#' @export
#' @examples
#' myfun <- function(headers, payload, ...) {
#'   print(as.numeric(headers$`content-length`) == length(payload))
#' }
#'
#' warc_stream_in(
#'   system.file("extdata/sample.warc.gz", package="jwatr"),
#'   myfun
#' )
warc_stream_in <- function(path, handler, ..., warc_types=NULL) {

  if (!is.null(warc_types)) {

    warc_types <- match.arg(
      warc_types,
      several.ok = TRUE,
      choices = c("warcinfo", "request", "response", "resource",
                  "metadata", "revisit", "conversion")
    )

  }

  path <- path.expand(path)
  if (!file.exists(path)) stop(sprintf("'%s' does not exist.", path), call. = FALSE)

  if (tools::file_ext(path) == "gz") {
    wf <- gzfile(path, "rb")
  } else if (tools::file_ext(path) == "warc") {
    wf <- file(path, "rb")
  } else {
    stop("'path' must be a compressed or uncompressed WARC file.", call.=FALSE)
  }

  rec_count <- 0

  repeat {

    rec <- c()
    l <- suppressWarnings(readLines(wf, 1L, warn=FALSE))

    if (length(l) == 0) break

    while(l != "") {
      rec <- c(rec, l)
      l <- suppressWarnings(readLines(wf, 1L, warn=FALSE))
    }

    whdrs <- stri_split_fixed(rec[-1], pattern = ": ", n = 2, simplify = TRUE)
    whdrs <- as.list(setNames(whdrs[,2], tolower(whdrs[,1])))

    payload <- readBin(wf, what = "raw", n = whdrs$`content-length`)

    if (!is.null(warc_types)) {
      if (whdrs$`warc-type` %in% warc_types) {
        rec_count <- rec_count + 1
        handler(headers=whdrs, payload=payload, ...)
      }
    } else {
      rec_count <- rec_count + 1
      handler(headers=whdrs, payload=payload, ...)
    }

    tmp <- suppressWarnings(readLines(wf, 2L, warn=FALSE))

  }

  close(wf)

  invisible(rec_count)

}