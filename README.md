
`jwatr` : Tools to Query and Create Web Archive Files Using the Java Web Archive Toolkit

The Java Web Archive Toolkit ('JWAT') <https://sbforge.org/display/JWAT/Overview> is a library of Java objects and methods which enables reading, writing and validating web archive files. Intial support is provided to read 'gzip' compressed 'WARC' files. Future plans include support for reading and writing all formats supported by 'JWAT'.

WIP!!! Reading & writing need some optimization and edge case checking. There's also a chance I'll change the name to `warc` but some folks are using that package now and I dinna want to cause pain there yet.

The following functions are implemented:

*Reading*

-   `read_warc`: Read a WARC file

*Writing*

-   `warc_file`: Create a new WARC file
-   `warc_write_response`: Add the response to a HTTP GET request to a WARC file
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

    ## [1] '0.1.0'

``` r
xdf <- read_warc(system.file("extdata/sample.warc.gz", package="jwatr"),
                 warc_types = "response", TRUE)

glimpse(xdf)
```

    ## Observations: 299
    ## Variables: 14
    ## $ warc_record_id             <chr> "<urn:uuid:ff728363-2d5f-4f5f-b832-9552de1a6037>", "<urn:uuid:e7c9eff8-f5bc-4aeb...
    ## $ warc_content_type          <chr> "text/dns", "application/http; msgtype=response", "application/http; msgtype=res...
    ## $ warc_type                  <chr> "response", "response", "response", "response", "response", "response", "respons...
    ## $ ip_address                 <chr> "68.87.76.178", "207.241.229.39", "207.241.229.39", "207.241.229.39", "207.241.2...
    ## $ content_length             <dbl> 56, 782, 680, 29000, 1963, 1424, 564, 50832, 14473, 66, 260, 16969, 59, 3135, 13...
    ## $ payload_type               <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ profile                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ target_uri                 <chr> "dns:www.archive.org", "http://www.archive.org/robots.txt", "http://www.archive....
    ## $ date                       <dttm> 2008-04-30, 2008-04-30, 2008-04-30, 2008-04-30, 2008-04-30, 2008-04-30, 2008-04...
    ## $ http_status_code           <dbl> NA, 200, 200, 200, 200, 200, 200, 200, 200, NA, 200, 200, NA, 200, 200, 200, 200...
    ## $ http_protocol_content_type <chr> NA, "text/plain; charset=UTF-8", "text/html; charset=UTF-8", "text/html; charset...
    ## $ http_version               <chr> NA, "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTT...
    ## $ http_raw_headers           <list> [<>, <48, 54, 54, 50, 2f, 31, 2e, 31, 20, 32, 30, 30, 20, 4f, 4b, 0d, 0a, 44, 6...
    ## $ payload                    <list> [<32, 30, 30, 38, 30, 34, 33, 30, 32, 30, 34, 38, 32, 35, 0a, 77, 77, 77, 2e, 6...

``` r
imgs <- filter(xdf, grepl("(png|gif|jpeg)$", http_protocol_content_type))

imgs
```

    ## # A tibble: 55 x 14
    ##                                     warc_record_id                  warc_content_type warc_type     ip_address
    ##                                              <chr>                              <chr>     <chr>          <chr>
    ##  1 <urn:uuid:248b06a8-1dd8-4f34-a7e3-7e0df27268e1> application/http; msgtype=response  response 207.241.229.39
    ##  2 <urn:uuid:7f4eb3e1-8887-488e-b22d-8667925d3e15> application/http; msgtype=response  response 207.241.229.39
    ##  3 <urn:uuid:7dc2f6b9-0f82-4e3c-9436-97a2f46874d9> application/http; msgtype=response  response 207.241.229.39
    ##  4 <urn:uuid:0a556a1b-a3b3-4ec0-82e5-7b54ed5293cb> application/http; msgtype=response  response 207.241.229.39
    ##  5 <urn:uuid:06c4c82e-1659-4265-9571-7483ba7bc802> application/http; msgtype=response  response 207.241.229.39
    ##  6 <urn:uuid:677c328e-214b-4c5f-8058-a386ba7e2997> application/http; msgtype=response  response 207.241.229.39
    ##  7 <urn:uuid:6ca0a72f-70c7-4af7-84c1-de56ec666419> application/http; msgtype=response  response 207.241.229.39
    ##  8 <urn:uuid:8e9b9946-259a-4440-a396-174081d59fe5> application/http; msgtype=response  response 207.241.229.39
    ##  9 <urn:uuid:847c6746-9c99-4de0-b29f-c1b7d3185685> application/http; msgtype=response  response 207.241.229.39
    ## 10 <urn:uuid:31efe1d8-f7d1-4b1e-9a1d-48d57270ec61> application/http; msgtype=response  response 207.241.229.39
    ## # ... with 45 more rows, and 10 more variables: content_length <dbl>, payload_type <chr>, profile <chr>,
    ## #   target_uri <chr>, date <dttm>, http_status_code <dbl>, http_protocol_content_type <chr>, http_version <chr>,
    ## #   http_raw_headers <list>, payload <list>

``` r
image_read(imgs$payload[[1]])
```

    ##   format width height colorspace filesize
    ## 1   JPEG    70     56       sRGB     1662

![](imgs/img1.jpeg)

### Writing WARC Files

``` r
library(jwatr)
library(magick)
library(htmltools)
library(tidyverse)

wf <- warc_file("~/Desktop/test")
warc_write_response(wf, "https://rud.is/b/")
warc_write_response(wf, "https://www.rstudio.com/")
warc_write_response(wf, "https://www.r-project.org/")
warc_write_response(wf, "https://journal.r-project.org/archive/2016-2/RJ-2016-2.pdf")
warc_write_response(wf, "https://journal.r-project.org/RLogo.png")
close_warc_file(wf)

xdf <- read_warc("~/Desktop/test.warc.gz", include_payload = TRUE)

glimpse(xdf)
```

    ## Observations: 5
    ## Variables: 14
    ## $ warc_record_id             <chr> "<urn:uuid:5d6c2067-a55f-41b2-83c6-2ef50e9f279a>", "<urn:uuid:9ccac3c0-e9a9-4248...
    ## $ warc_content_type          <chr> "application/http; msgtype=response", "application/http; msgtype=response", "app...
    ## $ warc_type                  <chr> "response", "response", "response", "response", "response"
    ## $ ip_address                 <chr> "2604:a880:800:10::6bc:2001", "104.196.200.5", "137.208.57.37", "137.208.57.37",...
    ## $ content_length             <dbl> 38764, 334, 7244, 31811093, 166003
    ## $ payload_type               <chr> "text/html; charset=UTF-8", "text/html", "text/html", "application/pdf", "image/...
    ## $ profile                    <chr> NA, NA, NA, NA, NA
    ## $ target_uri                 <chr> "https://rud.is/b/", "https://www.rstudio.com/", "https://www.r-project.org/", "...
    ## $ date                       <dttm> 2017-08-20, 2017-08-20, 2017-08-20, 2017-08-20, 2017-08-20
    ## $ http_status_code           <dbl> 200, 403, 200, 200, 200
    ## $ http_protocol_content_type <chr> "text/html; charset=UTF-8", "text/html", "text/html", "application/pdf", "image/...
    ## $ http_version               <chr> "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1"
    ## $ http_raw_headers           <list> [<48, 54, 54, 50, 2f, 31, 2e, 31, 20, 32, 30, 30, 20, 4f, 4b, 0d, 0a, 53, 65, 7...
    ## $ payload                    <list> [<3c, 21, 64, 6f, 63, 74, 79, 70, 65, 20, 68, 74, 6d, 6c, 3e, 0d, 0a, 0d, 0a, 3...

``` r
select(xdf, content_length, http_protocol_content_type)
```

    ## # A tibble: 5 x 2
    ##   content_length http_protocol_content_type
    ##            <dbl>                      <chr>
    ## 1          38764   text/html; charset=UTF-8
    ## 2            334                  text/html
    ## 3           7244                  text/html
    ## 4       31811093            application/pdf
    ## 5         166003                  image/png

``` r
image_read(xdf$payload[[5]])
```

    ##   format width height colorspace filesize
    ## 1    PNG  1810   1400       sRGB   165769

![](imgs/img2.png)

### Test Results

``` r
library(jwatr)
library(testthat)

date()
```

    ## [1] "Sat Aug 19 21:30:57 2017"

``` r
test_dir("tests/")
```

    ## testthat results ========================================================================================================
    ## OK: 1 SKIPPED: 0 FAILED: 0
    ## 
    ## DONE ===================================================================================================================
