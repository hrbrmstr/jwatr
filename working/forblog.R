# [Fist segment of July 2017 WET archive](https://commoncrawl.s3.amazonaws.com/crawl-data/CC-MAIN-2017-30/segments/1500549423183.57/wet/CC-MAIN-20170720121902-20170720141902-00000.warc.wet.gz)
library(jwatr)
library(urltools)
library(tidytext)
library(tidyverse)

# system.time(wet <- read_warc("~/Data/CC-MAIN-20170720121902-20170720141902-00000.warc.wet.gz",
#                             include_payload = TRUE))

##    user  system elapsed
##  47.644   3.511  43.025

wet <- read_rds("~/Data/wet.rds")

wet

glimpse(wet)

bind_cols(
  wet,
  pull(wet, target_uri) %>%
    domain() %>%
    suffix_extract()
) -> wet

filter(wet, !is.na(domain), !is.na(suffix)) %>%
  mutate(dsfx = sprintf("%s.%s", domain, suffix)) %>%
  count(dsfx, sort=TRUE)

mutate(wet, dsfx = sprintf("%s.%s", domain, suffix)) %>%
  filter(dsfx == "wordpress.com") %>%
  mutate(payload = map_chr(payload, rawToChar)) %>%
  filter(nchar(payload) > 0) -> wp_sites

glimpse(wp_sites)

select(wp_sites, payload, target_uri) %>%
  unnest_tokens(word, payload) %>%
  anti_join(stop_words, "word") %>%
  filter(!grepl("(^\\_.*$|[[:digit:]]|[[:punct:]])", word)) %>%
  count(target_uri, word) %>%
  group_by(word) %>%
  summarise(number_of_sites_using_word = n(), total_word_references = sum(n)) %>%
  arrange(desc(number_of_sites_using_word), desc(total_word_references)) %>%
  filter(number_of_sites_using_word > 50 & number_of_sites_using_word < 100)
