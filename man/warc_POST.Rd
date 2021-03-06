% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/warc-wrappers.r
\name{warc_POST}
\alias{warc_POST}
\title{WARC-ify an httr::GET request}
\usage{
warc_POST(wobj, url = NULL, config = list(), ..., body = NULL,
  encode = c("multipart", "form", "json", "raw"), handle = NULL)
}
\arguments{
\item{wobj}{WARC file object}

\item{url}{the url of the page to retrieve}

\item{config}{Additional configuration settings such as http
authentication (\code{\link{authenticate}}), additional headers
(\code{\link{add_headers}}), cookies (\code{\link{set_cookies}}) etc.
See \code{\link{config}} for full details and list of helpers.}

\item{...}{Further named parameters, such as \code{query}, \code{path}, etc,
passed on to \code{\link{modify_url}}. Unnamed parameters will be combined
with \code{\link{config}}.}

\item{body}{One of the following:
\itemize{
\item \code{FALSE}: No body. This is typically not used with \code{POST},
\code{PUT}, or \code{PATCH}, but can be useful if you need to send a
bodyless request (like \code{GET}) with \code{VERB()}.
\item \code{NULL}: An empty body
\item \code{""}: A length 0 body
\item \code{upload_file("path/")}: The contents of a file.  The mime
type will be guessed from the extension, or can be supplied explicitly
as the second argument to \code{upload_file()}
\item A character or raw vector: sent as is in body. Use
\code{\link{content_type}} to tell the server what sort of data
you are sending.
\item A named list: See details for encode.
}}

\item{encode}{If the body is a named list, how should it be encoded? Can be
one of form (application/x-www-form-urlencoded), multipart,
(multipart/form-data), or json (application/json).

For "multipart", list elements can be strings or objects created by
\code{\link{upload_file}}. For "form", elements are coerced to strings
and escaped, use \code{I()} to prevent double-escaping. For "json",
parameters are automatically "unboxed" (i.e. length 1 vectors are
converted to scalars). To preserve a length 1 vector as a vector,
wrap in \code{I()}. For "raw", either a character or raw vector. You'll
need to make sure to set the \code{\link{content_type}()} yourself.}

\item{handle}{The handle to use with this request. If not
supplied, will be retrieved and reused from the \code{\link{handle_pool}}
based on the scheme, hostname and port of the url. By default \pkg{httr}
requests to the same scheme/host/port combo. This substantially reduces
connection time, and ensures that cookies are maintained over multiple
requests to the same host. See \code{\link{handle_pool}} for more
details.}
}
\description{
Automagically writes out the result of an \code{httr::POST} request to an open
WARC file connection enabling seamless recording/caching of the response
for later re-use.
}
\examples{
\dontrun{
tf <- tempfile("test")
wf <- warc_file(tf)

warc_GET(wf, "https://data.police.uk/api/crimes-street/all-crime",
         query = list(lat=52.629729, lng=-1.131592, date="2017-01"))

warc_POST(
  wf,
  url = "https://data.police.uk/api/crimes-street/all-crime",
  query = list( lat = "52.629729", lng = "-1.131592", date = "2017-01")
) -> uk_res

close_warc_file(wf)
unlink(tf)
}
}
