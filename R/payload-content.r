#' Helper function to convert WARC raw headers+payload into something useful
#'
#' This works much the same way as the `content()` function in the `httr` package and
#' conforms to its API for the `as`, `type`, `encoding` and `...` fields.
#'
#' Unlike its `httr` counterpart, `payload_content()` can handle gzip'd payload
#' contents (`httr` has it easy since `curl` decodes the gzip content automagically
#' for it). It does make a best-guess for expanded content size, so is not 100%
#' guaranteed to work for all gzip'd payload content.
#'
#' @md
#' @param url,ctype,headers,payload `raw` content from the `target_uri`,
#'        `http_protocol_content_type`, `http_raw_headers` &
#'        `payload` fields of a WARC data frame.
#' @param as desired type of output: `raw`, `text` or
#'   `parsed`. `content` attempts to automatically figure out
#'   which one is most appropriate, based on the content-type.
#' @param type MIME type (aka internet media type) used to override
#'   the content type returned by the server. See
#'   \url{http://en.wikipedia.org/wiki/Internet_media_type} for a list of
#'   common types.
#' @param encoding For text, overrides the charset or the Latin1 (ISO-8859-1)
#'   default, if you know that the server is returning the incorrect encoding
#'   as the charset in the content-type. Use for text and parsed outputs.
#' @param ... Other parameters parsed on to the parsing functions, if `as = "parsed"`.
#' @export
payload_content <- function(url, ctype=NULL, headers, payload, as = NULL, type = NULL,
                            encoding = NULL, ...) {

  x <- list(
    url = url,
    headers = parse_single_header(stringi::stri_split_lines(rawToChar(headers))[[1]]),
    content = payload
  )

  class(x) <- "response"

  stopifnot(is_response(x))

  type <- type %||% ctype %||% x$headers[["Content-Type"]] %||%
    mime::guess_type(x$url, empty = "application/octet-stream")

  as <- as %||% parseability(type)
  as <- match.arg(as, c("raw", "text", "parsed"))

  if (is_compressed(x$content)) {
    rc <- rawConnection(x$content)
    gzrc <- gzcon(rc)
    raw <- readBin(gzrc, what="raw", n=length(x$content)*10)
    close(gzrc)
  } else {
    raw <- x$content
  }

  switch(as,
         raw = raw,
         text = parse_text(raw, type, encoding),
         parsed = parse_auto(raw, type, encoding, ...)
  )
}

#' Test if a raw vector gzip compressed
#'
#' @param x raw vector
#' @export
is_compressed <- function(x) {
  all(x[1:3] == as.raw(c(0x1f, 0x8b, 0x08)))
}

parse_single_header <- function(lines) {

  status <- parse_http_status(lines[[1]])

  header_lines <- lines[lines != ""][-1]
  pos <- regexec("^([^:]*):\\s*(.*)$", header_lines)
  pieces <- regmatches(header_lines, pos)

  n <- vapply(pieces, length, integer(1))
  if (any(n != 3)) {
    bad <- header_lines[n != 3]
    pieces <- pieces[n == 3]

    warning("Failed to parse headers:\n", paste0(bad, "\n"), call. = FALSE)
  }

  names <- vapply(pieces, "[[", 2, FUN.VALUE = character(1))
  values <- lapply(pieces, "[[", 3)
  headers <- httr::insensitive(stats::setNames(values, names))

  list(status = status$status, version = status$version, headers = headers)

}

parse_http_status <- function(x) {

  status <- as.list(strsplit(x, "\\s+")[[1]])
  names(status) <- c("version", "status", "message")[seq_along(status)]
  status$status <- as.integer(status$status)

  status

}
