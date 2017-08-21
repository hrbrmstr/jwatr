# stolen from httr

is_response <- function (x) { inherits(x, "response") }

"%||%" <- function(a, b) {
  if (length(a) > 0) a else b
}

is_path <- function(x) inherits(x, "path")

timestamp <- function(x = Sys.time()) {
  format(x, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

is_installed <- function(pkg) {
  system.file(package = pkg) != ""
}

need_package <- function(pkg) {
  if (is_installed(pkg)) return(invisible())

  stop("Please install ", pkg, " package", call. = FALSE)
}

check_encoding <- function(x) {
  if ((tolower(x) %in% tolower(iconvlist())))
    return(x)

  message("Invalid encoding ", x, ": defaulting to UTF-8.")
  "UTF-8"
}

guess_encoding <- function(encoding = NULL, type = NULL) {
  if (!is.null(encoding))
    return(check_encoding(encoding))

  charset <- if (!is.null(type)) httr::parse_media(type)$params$charset

  if (is.null(charset)) {
    message("No encoding supplied: defaulting to UTF-8.")
    return("UTF-8")
  }

  check_encoding(charset)
}

parse_text <- function(content, type = NULL, encoding = NULL) {
  encoding <- guess_encoding(encoding, type)
  iconv(readBin(content, character()), from = encoding, to = "UTF-8")
}

parse_query <- function(query) {
  params <- vapply(strsplit(query, "&")[[1]], str_split_fixed, "=", 2,
    FUN.VALUE = character(2))

  values <- as.list(curl::curl_unescape(params[2, ]))
  names(values) <- curl::curl_unescape(params[1, ])
  values
}

parse_auto <- function(content, type = NULL, encoding = NULL, ...) {
  if (length(content) == 0) {
    return(NULL)
  }

  if (is.null(type)) {
    stop("Unknown mime type: can't parse automatically. Use the `type` ",
      "argument to specify manually.", call. = FALSE)
  }

  mt <- httr::parse_media(type)
  parser <- parsers[[mt$complete]]
  if (is.null(parser)) {
    stop("No automatic parser available for ", mt$complete, ".",
      call. = FALSE)
  }

  parser(x = content, type = type, encoding = encoding, ...)
}

parseability <- function(type) {
  if (is.null(type) || type == "") return("raw")
  mt <- httr::parse_media(type)

  if (exists(mt$complete, parsers)) {
    "parsed"
  } else if (mt$type == "text") {
    "text"
  } else {
    "raw"
  }
}

parsers <- new.env(parent = emptyenv())

# Binary formats ---------------------------------------------------------------

# http://www.ietf.org/rfc/rfc4627.txt - section 3. (encoding)
parsers$`application/json` <- function(x, type = NULL, encoding = NULL,
                                       simplifyVector = FALSE, ...) {
  jsonlite::fromJSON(parse_text(x, encoding = "UTF-8"),
    simplifyVector = simplifyVector, ...)
}
parsers$`application/x-www-form-urlencoded` <- function(x, encoding = NULL,
                                                        type = NULL, ...) {
  parse_query(parse_text(x, encoding = "UTF-8"))
}

# Text formats -----------------------------------------------------------------
parsers$`image/jpeg` <- function(x, type = NULL, encoding = NULL, ...) {
  need_package("jpeg")
  jpeg::readJPEG(x)
}

parsers$`image/png` <- function(x, type = NULL, encoding = NULL, ...) {
  need_package("png")
  png::readPNG(x)
}

parsers$`text/plain` <- function(x, type = NULL, encoding = NULL, ...) {
  encoding <- guess_encoding(encoding, type)
  parse_text(x, type = type, encoding = encoding)
}

parsers$`text/html` <- function(x, type = NULL, encoding = NULL, ...) {
  need_package("xml2")

  encoding <- guess_encoding(encoding, type)
  xml2::read_html(x, encoding = encoding, ...)
}

parsers$`application/xml` <- function(x, type = NULL, encoding = NULL, ...) {
  need_package("xml2")

  encoding <- guess_encoding(encoding, type)
  xml2::read_xml(x, encoding = encoding, ...)
}

parsers$`text/xml` <- function(x, type = NULL, encoding = NULL, ...) {
  need_package("xml2")

  encoding <- guess_encoding(encoding, type)
  xml2::read_xml(x, encoding = encoding, ...)
}

parsers$`text/csv` <- function(x, type = NULL, encoding = NULL, ...) {
  need_package("readr")

  encoding <- guess_encoding(encoding, type)
  readr::read_csv(x, locale = readr::locale(encoding = encoding), ...)
}

parsers$`text/tab-separated-values` <- function(x, type = NULL, encoding = NULL, ...) {
  need_package("readr")

  encoding <- guess_encoding(encoding, type)
  readr::read_tsv(x, locale = readr::locale(encoding = encoding), ...)
}