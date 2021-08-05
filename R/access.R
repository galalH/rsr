#' Interactive login to the RSR application
#'
#' Interactive login to the RSR application
#'
#' @importFrom purrr discard
#' @export
rsr_login <- function() {
  cookiejar <- fs::path(fs::dir_create(rappdirs::app_dir("rsr", "unhcr")$cache()), "cookies.rds")
  b <- chromote::ChromoteSession$new()
  b$Page$navigate("https://rsr.unhcr.org/connect/azure")
  b$view()
  readline("Hit [RETURN] to continue when you've logged in.")
  cookies <- b$Network$getAllCookies()
  b$close()
  cookies$cookies |> discard(~.$domain == "rsr.unhcr.org") |> saveRDS(cookiejar)
}

#' @importFrom purrr keep pluck
#' @noRd
get_sessionid <- function() {
  cookiejar <- fs::path(rappdirs::app_dir("rsr", "unhcr")$cache(), "cookies.rds")
  b <- chromote::ChromoteSession$new()
  b$Network$setCookies(cookies = readRDS(cookiejar))
  b$Page$navigate("https://rsr.unhcr.org/connect/azure")
  cookies <- b$Network$getAllCookies()
  b$close()
  cookies$cookies |> keep(~.$name == "PHPSESSID") |> pluck(1, "value")
}
