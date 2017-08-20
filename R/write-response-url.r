.write_response_url <- function(wobj, URL) {

  dom <- urltools::domain(URL)
  ip <- curl::nslookup(dom)[1]

  res <- curl::curl_fetch_memory(URL, handle = curl::new_handle(followlocation=TRUE))

  hdrs <- stri_split_fixed(rawToChar(res$headers), "\r\n\r\n")[[1]]
  hdrs <- charToRaw(sprintf("%s\r\n\r\n", hdrs[[length(hdrs)-1]]))

  hdr <- curl::parse_headers_list(hdrs)
  content_type <- hdr$`content-type`[1]

  clen <- sum(lengths(list(hdrs, res$content)))

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

  tmp <- c(wraw, charToRaw("\r\n\r\n"), hdrs, res$content, charToRaw("\r\n\r\n"))

  writeBin(tmp, wobj$wf, useBytes = FALSE)

}
