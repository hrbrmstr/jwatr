#' Read a WARC file
#'
#' The API for this functiuon is likely to change since this is a WIP. Optimizations
#' will be occurring at the Java-level as well (this was a lazy PoC implementation).
#'
#' @section Reading Large WARC files:
#'
#' Typical WARC files from sources like Common Crawl <http://commoncrawl.org/the-data/>
#' are between 100 MB and ~1 GB in size (compressed). Since the goal of `read_warc()` is
#' to bring a WARC file into an R data frame, said data frames can become quite large
#' (proportional to the size of the WARC file). You may need to do the following at the
#' top of scripts or at the start of an R session to ensure the JVM has enough room
#' to accommodate the vectors used in the data frame creation:
#'
#'     options(java.parameters = "-Xmx2g")
#'
#' The `2g` value may need to be higher in specific use cases.
#'
#' Functions will eventually be provided to "stream process" WARC files vs read them
#' all into memory.
#'
#' @md
#' @note Presently only works with gzip'd WARC files (but they are most common)
#' @param path path to WARF file
#' @param warc_types if not `NULL` and one or more of `warcinfo`, `request`, `response`,
#'        `resource`, `metadata`, `revisit`, `conversion` then returned WARC records
#'        will be filtered to only include the specified record types.
#' @param include_payload if `TRUE` then the payload for each WARC record will
#'        be included.
#' @export
#' @examples
#' read_warc(system.file("extdata/sample.warc.gz", package="jwatr"),
#'           warc_types = "response", include_payload = FALSE)
read_warc <- function(path, warc_types = NULL, include_payload = FALSE) {

  if (!is.null(warc_types)) {

    warc_types <- match.arg(
      warc_types,
      several.ok = TRUE,
      choices = c("warcinfo", "request", "response", "resource",
                  "metadata", "revisit", "conversion")
    )

  }

  path <- path.expand(path)

  warc_obj <- new(J("is.rud.wrc.App"))
  warc_obj$process(path)

  suppressWarnings(
    data_frame(
      warc_record_id = warc_obj$warcRecordIdStr,
      warc_content_type = warc_obj$contentTypeStr,
      warc_type = warc_obj$warcTypeStr,
      ip_address = warc_obj$warcIpAddress,
      content_length = warc_obj$contentLengthStr,
      payload_type = warc_obj$warcIdentifiedPayloadTypeStr,
      profile = warc_obj$warcProfileStr,
      target_uri = warc_obj$warcTargetUriStr,
      date = as.POSIXct(warc_obj$warcDateStr),
      http_status_code = as.numeric(warc_obj$httpStatusCode),
      http_protocol_content_type = warc_obj$httpProtocolContentType,
      http_version = warc_obj$httpVersion,
      http_raw_headers = lapply(warc_obj$httpRawHeaders, .jevalArray)
    )
  ) -> xdf

  if (include_payload) xdf$payload <- lapply(warc_obj$warc_payload, .jevalArray)

  if (!is.null(warc_types)) xdf <- dplyr::filter(xdf, warc_type %in% warc_types)

  xdf

}
