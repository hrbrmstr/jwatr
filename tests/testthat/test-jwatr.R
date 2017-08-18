library(jwatjars)
library(jwatr)
library(rJava)

context("basic functionality")
test_that("we can do something", {

  wf <- jwatr::read_warc(system.file("extdata/sample.warc.gz", package="jwatr"),
                         warc_types = "response", TRUE)

  expect_equal(nrow(wf), 299)

})
