is_url <- function(path) {
  if (!inherits(path, "character")) return(FALSE)
  return(grepl("^(http)s?://", path))
}
