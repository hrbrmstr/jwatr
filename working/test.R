library(curl)
library(urltools)
library(stringi)
library(uuid)
library(httr)

cf <- curl_fetch_memory("https://rud.is/b", handle = new_handle(followlocation=TRUE))

warc_record_from_url <- function(URL) {

  dom <- domain(URL)
  ip <- nslookup(dom)

  res <- curl::curl_fetch_memory(URL, handle = new_handle(followlocation=TRUE))

  hdrs <- stri_split_fixed(rawToChar(res$headers), "\r\n\r\n")[[1]]
  hdrs <- charToRaw(sprintf("%s\r\n\r\n", hdrs[[length(hdrs)-1]]))

  hdr <- curl::parse_headers_list(hdrs)

  clen <- sum(lengths(list(hdrs, res$content)))

  c(
    "WARC/1.0",
    "WARC-Type: response",
    sprintf("WARC-Date: %s", strftime(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz="GMT")),
    sprintf("WARC-Record-ID: <urn:uuid:%s>", uuid::UUIDgenerate()),
    sprintf("Content-Length: %s", clen),
    sprintf("Content-Type: application/http; msgtype=response"),
    sprintf("WARC-Identified-Payload-Type: %s", hdr$`content-type`[1]),
    sprintf("WARC-IP-Address: %s", ip[1]),
    sprintf("WARC-Target-URI: %s", URL)
  ) -> warc_fields

  wraw <- charToRaw(paste0(warc_fields, sep="", collapse="\r\n"))

  c(wraw, charToRaw("\r\n\r\n"), hdrs, res$content, charToRaw("\r\n\r\n"))

}

rm(wgz)
rm(xdf)

unlink("~/Desktop/a.warc")
unlink("~/Desktop/a.warc.gz")

w <- file("~/Desktop/a.warc", open = "wb")
writeBin(warc_record_from_url("https://rud.is/b"), w, useBytes = FALSE);
writeBin(warc_record_from_url("https://www.r-project.org/"), w, useBytes = FALSE);
writeBin(warc_record_from_url("https://stackoverflow.com/questions/tagged/r"), w, useBytes = FALSE);
close(w)

glimpse(xdf <- read_warc("~/Desktop/a.warc.gz", include_payload = TRUE))
