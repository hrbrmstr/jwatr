
`jwatr` : Tools to Query and Create Web Archive Files Using the Java Web Archive Toolkit

The Java Web Archive Toolkit ('JWAT') <https://sbforge.org/display/JWAT/Overview> is a library of Java objects and methods which enables reading, writing and validating web archive files. Intial support is provided to read 'gzip' compressed 'WARC' files. Future plans include support for reading and writing all formats supported by 'JWAT'.

WIP!!! Reading & writing need some optimization and edge case checking. There's also a chance I'll change the name to `warc` but some folks are using that package now and I dinna want to cause pain there yet.

The following functions are implemented:

*Reading*

-   `read_warc`: Read a WARC file (compressed or uncompressed)

*Writing*

-   `warc_file`: Create a new WARC file
-   `warc_write_response`: Write simple `httr::GET` requests or full `httr` `response` objects to a WARC file
-   `close_warc_file`: Close a WARC file

NOTE: To read in typical (~800MB-1GB gzip'd WARC files) you should consider doing the following (in order) in your scripts:

``` r
options(java.parameters = "-Xmx2g")

library(rJava)
library(jwatjars)
library(jwatr)
```

That idiom generally provides enough heap space, but you may need to adjust the heap size if you've got larger payloads.

Alternatively, you can set the same option in your R startup scripts, but that will likely come back to bite you when moving workloads around.

### Installation

``` r
devtools::install_github("hrbrmstr/jwatr")
```

### Reading WARC Files

``` r
library(rJava)
library(jwatr)
library(magick)
library(tidyverse)

# current verison
packageVersion("jwatr")
```

    ## [1] '0.2.0'

``` r
# small, uncompressed WARC file
glimpse(read_warc(system.file("extdata/bbc.warc", package="jwatr")))
```

    ## Observations: 1
    ## Variables: 13
    ## $ target_uri                 <chr> "http://news.bbc.co.uk/2/hi/africa/3414345.stm"
    ## $ ip_address                 <chr> "212.58.244.61"
    ## $ warc_content_type          <chr> "application/http; msgtype=response"
    ## $ warc_type                  <chr> "response"
    ## $ content_length             <dbl> 43428
    ## $ payload_type               <chr> NA
    ## $ profile                    <chr> NA
    ## $ date                       <dttm> 2014-08-02
    ## $ http_status_code           <dbl> 200
    ## $ http_protocol_content_type <chr> "text/html"
    ## $ http_version               <chr> "HTTP/1.1"
    ## $ http_raw_headers           <list> <48, 54, 54, 50, 2f, 31, 2e, 31, 20, 32, 30, 30, 20, 4f, 4b, 0a, 53, 65, 72, 76...
    ## $ warc_record_id             <chr> "<urn:uuid:ffbfb0c0-6456-42b0-af03-3867be6fc09f>"

``` r
# larger example
xdf <- read_warc(system.file("extdata/sample.warc.gz", package="jwatr"),
                 warc_types = "response", TRUE)

glimpse(xdf)
```

    ## Observations: 299
    ## Variables: 14
    ## $ target_uri                 <chr> "dns:www.archive.org", "http://www.archive.org/robots.txt", "http://www.archive....
    ## $ ip_address                 <chr> "68.87.76.178", "207.241.229.39", "207.241.229.39", "207.241.229.39", "207.241.2...
    ## $ warc_content_type          <chr> "text/dns", "application/http; msgtype=response", "application/http; msgtype=res...
    ## $ warc_type                  <chr> "response", "response", "response", "response", "response", "response", "respons...
    ## $ content_length             <dbl> 56, 782, 680, 29000, 1963, 1424, 564, 50832, 14473, 66, 260, 16969, 59, 3135, 13...
    ## $ payload_type               <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ profile                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ date                       <dttm> 2008-04-30, 2008-04-30, 2008-04-30, 2008-04-30, 2008-04-30, 2008-04-30, 2008-04...
    ## $ http_status_code           <dbl> NA, 200, 200, 200, 200, 200, 200, 200, 200, NA, 200, 200, NA, 200, 200, 200, 200...
    ## $ http_protocol_content_type <chr> NA, "text/plain; charset=UTF-8", "text/html; charset=UTF-8", "text/html; charset...
    ## $ http_version               <chr> NA, "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTT...
    ## $ http_raw_headers           <list> [<>, <48, 54, 54, 50, 2f, 31, 2e, 31, 20, 32, 30, 30, 20, 4f, 4b, 0d, 0a, 44, 6...
    ## $ warc_record_id             <chr> "<urn:uuid:ff728363-2d5f-4f5f-b832-9552de1a6037>", "<urn:uuid:e7c9eff8-f5bc-4aeb...
    ## $ payload                    <list> [<32, 30, 30, 38, 30, 34, 33, 30, 32, 30, 34, 38, 32, 35, 0a, 77, 77, 77, 2e, 6...

``` r
imgs <- filter(xdf, grepl("(png|gif|jpeg)$", http_protocol_content_type))

imgs
```

    ## # A tibble: 55 x 14
    ##                                                target_uri     ip_address                  warc_content_type warc_type
    ##                                                     <chr>          <chr>                              <chr>     <chr>
    ##  1                http://www.archive.org/images/logoc.jpg 207.241.229.39 application/http; msgtype=response  response
    ##  2    http://www.archive.org/images/go-button-gateway.gif 207.241.229.39 application/http; msgtype=response  response
    ##  3                 http://www.archive.org/images/star.png 207.241.229.39 application/http; msgtype=response  response
    ##  4              http://www.archive.org/images/hewlett.jpg 207.241.229.39 application/http; msgtype=response  response
    ##  5    http://www.archive.org/images/alexalogo-archive.gif 207.241.229.39 application/http; msgtype=response  response
    ##  6        http://www.archive.org/images/djvu-download.gif 207.241.229.39 application/http; msgtype=response  response
    ##  7 http://www.archive.org/images/alexa_websearch_logo.gif 207.241.229.39 application/http; msgtype=response  response
    ##  8          http://www.archive.org/images/ta2004_icon.jpg 207.241.229.39 application/http; msgtype=response  response
    ##  9           http://www.archive.org/images/lizardtech.gif 207.241.229.39 application/http; msgtype=response  response
    ## 10         http://www.archive.org/images/LOCLogoSmall.jpg 207.241.229.39 application/http; msgtype=response  response
    ## # ... with 45 more rows, and 10 more variables: content_length <dbl>, payload_type <chr>, profile <chr>, date <dttm>,
    ## #   http_status_code <dbl>, http_protocol_content_type <chr>, http_version <chr>, http_raw_headers <list>,
    ## #   warc_record_id <chr>, payload <list>

``` r
image_read(imgs$payload[[1]])
```

    ##   format width height colorspace filesize
    ## 1   JPEG    70     56       sRGB     1662

![](imgs/img1.jpeg)

### Writing WARC Files

``` r
library(jwatr)
library(httr)
library(magick)
library(tidyverse)

tf <- tempfile("test")
wf <- warc_file(tf)

warc_write_response(wf, "https://rud.is/b/")

# store a simple httr::GET request
warc_write_response(wf, GET("https://rud.is/b/"))

warc_write_response(wf, "https://www.rstudio.com/")
warc_write_response(wf, "https://www.r-project.org/")

# all valid content types work, like this PDF
warc_write_response(wf, "http://che.org.il/wp-content/uploads/2016/12/pdf-sample.pdf")

# complex API calls can be made and the results stored in the WARC file as well
# this API call returns a JSON object
POST(
 url = "https://data.police.uk/api/crimes-street/all-crime",
 query = list( lat = "52.629729", lng = "-1.131592", date = "2017-01")
) -> uk_res

warc_write_response(wf, uk_res)
warc_write_response(wf, "https://journal.r-project.org/RLogo.png")

close_warc_file(wf)

xdf <- read_warc(sprintf("%s.warc.gz", tf), include_payload = TRUE)

glimpse(xdf)
```

    ## Observations: 7
    ## Variables: 14
    ## $ target_uri                 <chr> "https://rud.is/b/", "https://rud.is/b/", "https://www.rstudio.com/", "https://w...
    ## $ ip_address                 <chr> "2604:a880:800:10::6bc:2001", "2604:a880:800:10::6bc:2001", "104.196.200.5", "13...
    ## $ warc_content_type          <chr> "application/http; msgtype=response", "application/http; msgtype=response", "app...
    ## $ warc_type                  <chr> "response", "response", "response", "response", "response", "response", "response"
    ## $ content_length             <dbl> 38764, 38764, 334, 7244, 8207, 511564, 166003
    ## $ payload_type               <chr> "text/html; charset=UTF-8", "text/html; charset=UTF-8", "text/html", "text/html"...
    ## $ profile                    <chr> NA, NA, NA, NA, NA, NA, NA
    ## $ date                       <dttm> 2017-08-21, 2017-08-21, 2017-08-21, 2017-08-21, 2017-08-21, 2017-08-21, 2017-08-21
    ## $ http_status_code           <dbl> 200, 200, 403, 200, 200, 200, 200
    ## $ http_protocol_content_type <chr> "text/html; charset=UTF-8", "text/html; charset=UTF-8", "text/html", "text/html"...
    ## $ http_version               <chr> "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1"
    ## $ http_raw_headers           <list> [<48, 54, 54, 50, 2f, 31, 2e, 31, 20, 32, 30, 30, 20, 4f, 4b, 0d, 0a, 53, 65, 7...
    ## $ warc_record_id             <chr> "<urn:uuid:6719c595-b979-45e3-be56-0cbb9f7dba6d>", "<urn:uuid:b14f9fda-28ae-44ea...
    ## $ payload                    <list> [<3c, 21, 64, 6f, 63, 74, 79, 70, 65, 20, 68, 74, 6d, 6c, 3e, 0d, 0a, 0d, 0a, 3...

``` r
# decode the WARC stored JSON response from the UK Crimes API
glimpse(jsonlite::fromJSON(rawToChar(xdf[6,]$payload[[1]]), flatten=TRUE))
```

    ## Observations: 1,318
    ## Variables: 13
    ## $ category                <chr> "anti-social-behaviour", "anti-social-behaviour", "anti-social-behaviour", "anti-so...
    ## $ location_type           <chr> "Force", "Force", "Force", "Force", "Force", "Force", "Force", "Force", "Force", "F...
    ## $ context                 <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",...
    ## $ persistent_id           <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",...
    ## $ id                      <int> 54163555, 54167687, 54167689, 54168393, 54168392, 54168391, 54168386, 54168381, 541...
    ## $ location_subtype        <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",...
    ## $ month                   <chr> "2017-01", "2017-01", "2017-01", "2017-01", "2017-01", "2017-01", "2017-01", "2017-...
    ## $ location.latitude       <chr> "52.616961", "52.629963", "52.641646", "52.635184", "52.627880", "52.636250", "52.6...
    ## $ location.longitude      <chr> "-1.120719", "-1.122291", "-1.131486", "-1.135455", "-1.144730", "-1.133691", "-1.1...
    ## $ location.street.id      <int> 882391, 883268, 884340, 883410, 883453, 883415, 882352, 883332, 882350, 883148, 883...
    ## $ location.street.name    <chr> "On or near Hartopp Road", "On or near Prebend Street", "On or near Yarmouth Street...
    ## $ outcome_status.category <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
    ## $ outcome_status.date     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...

``` r
select(xdf, content_length, http_protocol_content_type)
```

    ## # A tibble: 7 x 2
    ##   content_length http_protocol_content_type
    ##            <dbl>                      <chr>
    ## 1          38764   text/html; charset=UTF-8
    ## 2          38764   text/html; charset=UTF-8
    ## 3            334                  text/html
    ## 4           7244                  text/html
    ## 5           8207            application/pdf
    ## 6         511564           application/json
    ## 7         166003                  image/png

``` r
image_read(xdf$payload[[5]])
```

    ##   format width height colorspace filesize
    ## 1    PDF   595    842       sRGB    27600

![](imgs/img2.png)

### Test Results

``` r
library(jwatr)
library(testthat)

date()
```

    ## [1] "Mon Aug 21 04:48:20 2017"

``` r
test_dir("tests/")
```

    ## testthat results ========================================================================================================
    ## OK: 1 SKIPPED: 0 FAILED: 0
    ## 
    ## DONE ===================================================================================================================

### Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
