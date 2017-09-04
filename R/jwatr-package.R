#' Tools to Query and Create Web Archive Files Using the Java Web Archive Toolkit
#'
#' The Java Web Archive Toolkit ('JWAT') <https://sbforge.org/display/JWAT/Overview>
#' is a library of Java objects and methods which enables reading, writing and validating web
#' archive files.
#'
#' @md
#' @name jwatr
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import rJava jwatjars tools
#' @importFrom tools file_ext
#' @importFrom stats setNames
#' @importFrom curl nslookup curl_fetch_memory parse_headers_list new_handle
#' @importFrom httr GET insensitive parse_media
#' @importFrom urltools domain suffix_extract
#' @importFrom tibble data_frame as_data_frame
#' @importFrom stringi stri_split_fixed stri_split_lines
#' @importFrom scales comma
NULL
