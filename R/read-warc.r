#' Read a WARC file
#'
#' @param path path to WARF file
#' @export
read_warc <- function(path) {

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
      http_raw_headers = lapply(warc_obj$httpRawHeaders, .jevalArray),
      payload = lapply(warc_obj$warc_payload, .jevalArray)
    )
  )

}
