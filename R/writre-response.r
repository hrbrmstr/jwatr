#' Write simple `httr::GET` requests or full `httr` `response` objects to a WARC file
#'
#' If a plain, single, character URL is provided, a `curl` request will be made
#' and the contents of the result will be added to the WARC file.
#'
#' If an `httr` `response` object is provided, it will be transformed and the
#' contents of the result will be added to the WARC file.
#'
#' @md
#' @param wobj a WARC file object created with [warc_file]()
#' @param x Either a single, valid URL to retrieve the contents of or an `httr` `response` object
#' @export
#' @examples \dontrun{
#' tf <- tempfile("test")
#' wf <- warc_file(tf)
#' warc_write_response(wf, "https://rud.is/b/")
#' warc_write_response(wf, GET("https://rud.is/b/"))
#' warc_write_response(wf, "https://www.rstudio.com/")
#' warc_write_response(wf, "https://www.r-project.org/")
#' warc_write_response(wf, "http://che.org.il/wp-content/uploads/2016/12/pdf-sample.pdf")
#'
#' POST(
#'   url = "https://data.police.uk/api/crimes-street/all-crime",
#'   query = list( lat = "52.629729", lng = "-1.131592", date = "2017-01")
#' ) -> uk_res
#'
#' warc_write_response(wf, uk_res)
#' warc_write_response(wf, "https://journal.r-project.org/RLogo.png")
#'
#' close_warc_file(wf)
#' unlink(tf)
#' }
warc_write_response <- function(wobj, x) {

  if (is_url(x)) {
    .write_response_url(wobj, x)
  } else if (inherits(x, "response")) {
    .write_response_response(wobj, x)
  } else {
    message("Input must be a valid, curl_fetch-able URL or an httr::response object.")
  }

  invisible(wobj)

}
