#' Create a new WARC file
#'
#' @md
#' @param path filesystem path and base name for WARC file
#' @param gzip if `TRUE` then the resultant WARC file will be comprised of
#'        individual gzip streams for each WARC record (the same format the
#'        Creative Commons and Internet Archive WARC files are produced).
#'        Otherwise, an uncompressed WARC file will be created.
#' @note A `.warc` or `.warc.gz` extension will be added to `path` by this function.
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
warc_file <- function(path, gzip=TRUE) {

  path <- path.expand(path)
  path <- gsub("\\.warc[\\.gz]$", "", path)
  path <- sprintf("%s.warc", path)

  list(
    f = path,
    wf = file(path, open="wb", raw=TRUE),
    gzip = gzip
  ) -> wobj

  class(wobj) <- "warc_file"

  wobj

}

#' Close a WARC file
#'
#' @md
#' @param wobj a WARC file object created with [warc_file]()
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
close_warc_file <- function(wobj) {
  close(wobj$wf)
  if (wobj$gzip) {
    compress_warc_file <- J("is.rud.wrc.App")$compressWarcFile
    compress_warc_file(wobj$f, sprintf("%s.gz", wobj$f))
    unlink(wobj$f)
  }
}