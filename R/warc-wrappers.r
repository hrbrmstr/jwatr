#' WARC-ify an httr::GET request
#'
#' Automagically writes out the result of an `httr::GET` request to an open
#' WARC file connection enabling seamless recording/caching of the response
#' for later re-use.
#'
#' @md
#' @param wobj WARC file object
#' @param url the url of the page to retrieve
#' @param ... Further named parameters, such as `query`, `path`, etc,
#'   passed on to \code{\link{modify_url}}. Unnamed parameters will be combined
#'   with \code{\link{config}}.
#' @param config Additional configuration settings such as http
#'   authentication (\code{\link{authenticate}}), additional headers
#'   (\code{\link{add_headers}}), cookies (\code{\link{set_cookies}}) etc.
#'   See \code{\link{config}} for full details and list of helpers.
#' @param handle The handle to use with this request. If not
#'   supplied, will be retrieved and reused from the \code{\link{handle_pool}}
#'   based on the scheme, hostname and port of the url. By default \pkg{httr}
#    automatically reuses the same http connection (aka handle) for mulitple
#'   requests to the same scheme/host/port combo. This substantially reduces
#'   connection time, and ensures that cookies are maintained over multiple
#'   requests to the same host. See \code{\link{handle_pool}} for more
#'   details.
#' @export
#' @examples \dontrun{
#' tf <- tempfile("test")
#' wf <- warc_file(tf)
#'
#' warc_GET(wf, "https://data.police.uk/api/crimes-street/all-crime",
#'          query = list(lat=52.629729, lng=-1.131592, date="2017-01"))
#'
#' warc_POST(
#'   wf,
#'   url = "https://data.police.uk/api/crimes-street/all-crime",
#'   query = list( lat = "52.629729", lng = "-1.131592", date = "2017-01")
#' ) -> uk_res
#'
#' close_warc_file(wf)
#' unlink(tf)
#' }
warc_GET <- function(wobj, url = NULL, config = list(), ..., handle = NULL) {
  res <- httr::GET(url = url, config = config, handle = handle, ...)
  warc_write_response(wobj, res)
  invisible(res)
}

#' WARC-ify an httr::GET request
#'
#' Automagically writes out the result of an `httr::POST` request to an open
#' WARC file connection enabling seamless recording/caching of the response
#' for later re-use.
#'
#' @md
#' @inheritParams warc_GET
#' @param body One of the following:
#'   \itemize{
#'     \item \code{FALSE}: No body. This is typically not used with \code{POST},
#'       \code{PUT}, or \code{PATCH}, but can be useful if you need to send a
#'       bodyless request (like \code{GET}) with \code{VERB()}.
#'     \item \code{NULL}: An empty body
#'     \item \code{""}: A length 0 body
#'     \item \code{upload_file("path/")}: The contents of a file.  The mime
#'       type will be guessed from the extension, or can be supplied explicitly
#'       as the second argument to \code{upload_file()}
#'     \item A character or raw vector: sent as is in body. Use
#'       \code{\link{content_type}} to tell the server what sort of data
#'       you are sending.
#'     \item A named list: See details for encode.
#'   }
#' @param encode If the body is a named list, how should it be encoded? Can be
#'   one of form (application/x-www-form-urlencoded), multipart,
#'   (multipart/form-data), or json (application/json).
#'
#'   For "multipart", list elements can be strings or objects created by
#'   \code{\link{upload_file}}. For "form", elements are coerced to strings
#'   and escaped, use \code{I()} to prevent double-escaping. For "json",
#'   parameters are automatically "unboxed" (i.e. length 1 vectors are
#'   converted to scalars). To preserve a length 1 vector as a vector,
#'   wrap in \code{I()}. For "raw", either a character or raw vector. You'll
#'   need to make sure to set the \code{\link{content_type}()} yourself.
#' @export
#' @examples \dontrun{
#' tf <- tempfile("test")
#' wf <- warc_file(tf)
#'
#' warc_GET(wf, "https://data.police.uk/api/crimes-street/all-crime",
#'          query = list(lat=52.629729, lng=-1.131592, date="2017-01"))
#'
#' warc_POST(
#'   wf,
#'   url = "https://data.police.uk/api/crimes-street/all-crime",
#'   query = list( lat = "52.629729", lng = "-1.131592", date = "2017-01")
#' ) -> uk_res
#'
#' close_warc_file(wf)
#' unlink(tf)
#' }
warc_POST <- function(wobj, url = NULL, config = list(), ..., body = NULL,
                      encode = c("multipart", "form", "json", "raw"), handle = NULL) {
  res <- httr::POST(url = url, config = list(), body = body,
                    encode = encode, handle = handle, ...)
  warc_write_response(wobj, res)
  invisible(res)
}