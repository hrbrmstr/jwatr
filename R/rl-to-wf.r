#' Turns a list of `httr` `response` objects into a WARC file
#'
#' You may not want to change your existing workflows to use the `httr` `GET`
#' and `POST` helpers. It it not uncommon to `lapply` or `purrr::map` a series
#' of `httr` verb cals into a list of `response` objects. Those that have been
#' bitten by the intermittent HTTP errors that cause scraping loops to fail
#' will also likely be using `purrr::safely` to wrap `httr` verb calls to ensure
#' the loop succeeds in capturing some information.
#'
#' This function makes it easy to turn a list of these `response` objects (wrapped
#' or plain) into a WARC file. Sure, you can save an R `list` to an R data file,
#' but that won't be usable by folks outside the R ecosystem. Plus, there are scads of
#' tools that can work with WARC files, including those in large-scale data
#' processing environments.
#'
#' List elements that are not plain or "safe" `response` objects will be gracefully
#' skipped over.
#'
#' @md
#' @param httr_response_list a list of `httr` `response` objects _or_ a list of
#'        `safely`-wrapped `httr` `reponse` objects (i.e. `httr::GET` was wrapped
#'        with `purrr::safely`).
#' @param path path (dir + base file name) to the created WARC file
#' @param gzip should the WARC file be gzip'd?
#' @param warc_date A supplied `POSIXct` timestamp to use to timestamp the WARC file.
#'        Current time will be used if none supplied.
#' @param warc_record_id A unique identifier for the WARC record. If not provided one
#'        will be generated with `UUIDgenerate`.
#' @param warc_info a named `list` of fields to go into the payload of the `warcinfo`
#'        record that will be at the top of the WARC file
#' @export
#' @examples \dontrun{
#' urls <- c("https://rud.is/", "https://rud.is/b/")
#'
#' res_list <- lapply(urls, httr::GET)
#'
#' tf <- tempfile()
#' response_list_to_warc_file(res_list, tf)
#' ulink(tf)
#' }
response_list_to_warc_file <- function(
  httr_response_list, path, gzip = TRUE,
  warc_date = Sys.time(), warc_record_id = NULL,
  warc_info = list(
    software = sprintf("jwatr %s", packageVersion("jwatr")),
    format = "WARC File Format 1.0")) {

  path <- path.expand(path)

  if (!dir.exists(dirname(path))) stop("Path not found", call.=FALSE)

  if (inherits(httr_response_list, "list") &&
      (length(httr_response_list) > 0) &&
      ((inherits(httr_response_list[[1]], "response")) ||
       (length(setdiff(names(httr_response_list[[1]]), c("result", "error"))) == 0))) {

    wobj <- warc_file(path, gzip)
    wobj <- warc_write_warcinfo(wobj, warc_date, warc_record_id, warc_info)

    for (idx in 1:length(httr_response_list)) {
      r <- httr_response_list[[idx]]
      if (inherits(r, "response")) {
        warc_write_response(wobj, r)
      } else if ((length(setdiff(names(r), c("result", "error"))) == 0)) {
        if ((!is.null(r$result)) && inherits(r$result, "response")) {
          wobj <- warc_write_response(wobj, r$result)
        } else {
          message(sprintf("Skipping element %s...", scales::comma(idx)))
        }
      } else {
        message(sprintf("Skipping element %s...", scales::comma(idx)))
      }
    }

    close_warc_file(wobj)

  } else {
    stop("Input must contain 'httr' 'response's  or 'safe' versions of them.", call.=FALSE)
  }

}