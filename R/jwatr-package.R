#' Tools to Query and Create Web Archive Files Using the Java Web Archive Toolkit
#'
#' The Java Web Archive Toolkit ('JWAT') <https://sbforge.org/display/JWAT/Overview>
#' is a library of Java objects and methods which enables reading, writing and validating web
#' archive files. Intial support is provided to read 'gzip' compressed 'WARC' files. Future
#' plans include support for reading and writing all formats supported by 'JWAT'.
#'
#' @md
#' @name jwatr
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import rJava jwatjars tools
#' @importFrom curl nslookup curl_fetch_memory parse_headers_list new_handle
#' @importFrom httr GET
#' @importFrom urltools domain suffix_extract
#' @importFrom tibble data_frame
#' @importFrom stringi stri_split_fixed
NULL
