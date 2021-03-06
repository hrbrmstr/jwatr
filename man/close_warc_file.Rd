% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/warc-file.r
\name{close_warc_file}
\alias{close_warc_file}
\title{Close a WARC file}
\usage{
close_warc_file(wobj)
}
\arguments{
\item{wobj}{a WARC file object created with \url{warc_file}}
}
\description{
Close a WARC file
}
\examples{
\dontrun{
tf <- tempfile("test")
wf <- warc_file(tf)
warc_write_response(wf, "https://rud.is/b/")
warc_write_response(wf, GET("https://rud.is/b/"))
warc_write_response(wf, "https://www.rstudio.com/")
warc_write_response(wf, "https://www.r-project.org/")
warc_write_response(wf, "http://che.org.il/wp-content/uploads/2016/12/pdf-sample.pdf")

POST(
  url = "https://data.police.uk/api/crimes-street/all-crime",
  query = list( lat = "52.629729", lng = "-1.131592", date = "2017-01")
) -> uk_res

warc_write_response(wf, uk_res)
warc_write_response(wf, "https://journal.r-project.org/RLogo.png")

close_warc_file(wf)
unlink(tf)
}
}
