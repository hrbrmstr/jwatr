#' Write a `warcinfo` record to a WARC File
#'
#' @md
#' @param wobj a WARC file object created with [warc_file]()
#' @param warc_date A supplied `POSIXct` timestamp to use to timestamp the WARC file.
#'        Current time will be used if none supplied.
#' @param warc_record_id A unique identifier for the WARC record. If not provided one
#'        will be generated with `UUIDgenerate`.
#' @param warc_info A named `list` with fields to store for the `warcinfo` record.
#' @return The passed-in `wobj` (thus, allowing for pipe chaining)
#' @export
warc_write_warcinfo <- function(
  wobj,
  warc_date = Sys.time(),
  warc_record_id = NULL,
  warc_info = list(
    software = sprintf("jwatr %s", packageVersion("jwatr")),
    format = "WARC File Format 1.0"
  )) {

  if (is.null(warc_record_id)) warc_record_id <- sprintf("<urn:uuid:%s>", uuid::UUIDgenerate())

  hdrs <- sprintf("%s: %s\r\n", names(warc_info), unname(as.vector(warc_info)))
  hdrs <- paste0(hdrs, sep="", collapse="")
  hdrs <- sprintf("%s\r\n", hdrs)
  hdrs <- charToRaw(hdrs)

  clen <- length(hdrs)

  c(
    "WARC/1.0",
    "WARC-Type: warcinfo",
    sprintf("WARC-Date: %s", strftime(warc_date, "%Y-%m-%dT%H:%M:%SZ", tz="GMT")),
    sprintf("WARC-Record-ID: %s", warc_record_id),
    sprintf("Content-Length: %s", clen),
    sprintf("Content-Type: application/warc-fields"),
    sprintf("WARC-Filename: %s", basename(wobj$f))
  ) -> warc_fields

  wraw <- charToRaw(paste0(warc_fields, sep="", collapse="\r\n"))

  tmp <- c(wraw, charToRaw("\r\n\r\n"), hdrs, charToRaw("\r\n\r\n"))

  writeBin(tmp, wobj$wf, useBytes = FALSE)

  class(wobj) <- "warc_file"

  invisible(wobj)

}