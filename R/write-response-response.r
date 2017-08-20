.write_response_response <- function(wobj, res) {

  hdr_ct <- length(res$all_headers)

  h <- res$all_headers[[hdr_ct]]

  status_line <- sprintf("%s %s %s\r\n", h$version, h$status,
                         http_statuses[as.character(h$status)])

  hdrs <- sprintf("%s: %s\r\n", names(h$headers), unname(as.vector(h$headers)))
  hdrs <- paste0(hdrs, sep="", collapse="")
  hdrs <- sprintf("%s%s\r\n", status_line, hdrs)
  hdrs <- charToRaw(hdrs)

  URL <- res$request$url[1]

  dom <- urltools::domain(URL)
  ip <- curl::nslookup(dom)[1]

  content_type <- h$headers$`content-type`[1]

  raw_content <- httr::content(res, as="raw")
  clen <- sum(lengths(list(hdrs, raw_content)))

  c(
    "WARC/1.0",
    "WARC-Type: response",
    sprintf("WARC-Date: %s", strftime(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz="GMT")),
    sprintf("WARC-Record-ID: <urn:uuid:%s>", uuid::UUIDgenerate()),
    sprintf("Content-Length: %s", clen),
    sprintf("Content-Type: application/http; msgtype=response"),
    sprintf("WARC-Identified-Payload-Type: %s", content_type),
    sprintf("WARC-IP-Address: %s", ip),
    sprintf("WARC-Target-URI: %s", URL)
  ) -> warc_fields

  wraw <- charToRaw(paste0(warc_fields, sep="", collapse="\r\n"))

  tmp <- c(wraw, charToRaw("\r\n\r\n"), hdrs, raw_content, charToRaw("\r\n\r\n"))

  writeBin(tmp, wobj$wf, useBytes = FALSE)

}
