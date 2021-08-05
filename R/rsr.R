#' @importFrom rvest session html_form html_form_set session_submit html_nodes html_text html_attr session_jump_to
#' @importFrom httr set_cookies write_disk
#' @importFrom purrr keep discard
#' @importFrom stringr str_detect str_to_sentence
#' @noRd
rsr <- function(bureau, year, month, table) {
  r <- session("https://rsr.unhcr.org/report", set_cookies(PHPSESSID = get_sessionid()))
  f <-
    html_form(r)[[1]] |>
    html_form_set("grid_a75b200afdb00bcdb06040d2d98029bd[year][from][]" = year-2017+1,
                  "grid_a75b200afdb00bcdb06040d2d98029bd[month][from][]" = month)
  r <- r |> session_submit(f, submit = 1)
  t <- r |> html_nodes("tr") |> keep(~str_detect(html_text(.), bureau))
  a <- t |> html_nodes("a") |> keep(~str_detect(html_text(.), str_to_sentence(table)))
  f <- fs::file_temp(ext = "xls")
  r |> session_jump_to(html_attr(a, "href"), write_disk(f, overwrite = TRUE))
  f
}

#' Summary reports
#'
#' Departure summary
#'
#' @param bureau UNHCR bureau name as it appears in the RSR application (string)
#' @param year Year (numeric)
#' @param month Month (numeric)
#'
#' @return A tibble
#'
#' @importFrom readxl read_excel
#' @importFrom dplyr select rename slice mutate filter
#' @importFrom tidyr pivot_longer fill
#' @importFrom tidyselect contains
#' @importFrom lubridate make_date rollforward
#'
#' @rdname rsr
#' @export
rsr_departures <- function(bureau, year, month) {
  rsr(bureau, year, month, "departure") |>
    (\(x) suppressMessages(read_excel(x, skip = 5)))() |>
    select(-contains("Total")) |>
    rename(asof = ...1, coa = ...2, coo = ...4) |>
    slice(-1) |>
    pivot_longer(-c(asof, coa, coo), names_to = "cor", values_to = "n") |>
    mutate(n = parse_number(n)) |>
    fill(asof, coa) |>
    filter(asof != "Total", !is.na(n)) |>
    mutate(asof = rollforward(make_date(year, month)))
}

#' Submission summary
#'
#' Submission summary
#'
#' @importFrom readxl read_excel
#' @importFrom dplyr select rename rename_with slice mutate filter
#' @importFrom tidyr pivot_longer fill
#' @importFrom tidyselect last_col
#' @importFrom stringr str_c str_detect
#' @importFrom purrr modify_if
#' @importFrom readr parse_number
#' @importFrom lubridate make_date rollforward
#'
#' @rdname rsr
#' @export
rsr_submissions <- function(bureau, year, month) {
  rsr(bureau, year, month, "submission") |>
    (\(x) suppressMessages(read_excel(x, skip = 5)))() |>
    select(-c(3, 4, last_col(), last_col(1))) |>
    rename(asof = ...1, coa = ...2, coo = ...5) |>
    (\(x) rename_with(x, ~str_c(., as.character(x[1,.]), sep = "-"), -c(asof, coa, coo)))() |>
    slice(-1) |>
    pivot_longer(-c(asof, coa, coo), names_to = c("cor", "unit"), names_pattern = "(.+)-(.+)", values_to = "n") |>
    mutate(cor = modify_if(cor, ~str_detect(., "\\d"), ~NA_character_),
           n = parse_number(n)) |>
    fill(asof, coa, cor) |>
    filter(asof != "Total", !is.na(n)) |>
    mutate(asof = rollforward(make_date(year, month)))
}

#' Indicators summary
#'
#' Indicators summary
#'
#' @importFrom readxl read_excel
#' @importFrom dplyr rename rename_with slice mutate filter
#' @importFrom tidyr pivot_longer fill
#' @importFrom stringr str_c
#' @importFrom lubridate make_date rollforward
#'
#' @rdname rsr
#' @export
rsr_indicators <- function(bureau, year, month) {
  rsr(bureau, year, month, "indicators") |>
    (\(x) suppressMessages(read_excel(x, skip = 5)))() |>
    rename(asof = ...1, coa = ...2, coo = ...3) |>
    (\(x) rename_with(x, ~str_c(., as.character(x[1,.]), sep = "-"), -c(asof, coa, coo)))() |>
    slice(-1) |>
    pivot_longer(-c(asof, coa, coo), names_to = c("ind", "unit"), names_pattern = "(.+)-(.+)", values_to = "n") |>
    mutate(ind = modify_if(ind, ~str_detect(., "\\d"), ~NA_character_),
           n = parse_number(n)) |>
    fill(asof, coa, ind) |>
    filter(asof != "Total") |>
    mutate(asof = rollforward(make_date(year, month)))
}

#' Demographics summary
#'
#' Demographics summary
#'
#' @importFrom readxl read_excel
#' @importFrom dplyr select rename mutate filter if_else
#' @importFrom tidyr pivot_longer fill
#' @importFrom tidyselect contains
#' @importFrom lubridate make_date rollforward
#'
#' @rdname rsr
#' @export
rsr_demographics <- function(bureau, year, month) {
  rsr(bureau, year, month, "demographics") |>
    (\(x) suppressMessages(read_excel(x, skip = 5)))() |>
    select(-contains("Total")) |>
    rename(asof = `Data as of`, coa = COA, coo = COO, cor = COR) |>
    pivot_longer(-c(asof, coa, coo, cor), names_to = c("sex", "age"), names_pattern = "(M|F|Other) ?(.*)", values_to = "n") |>
    mutate(age = if_else(sex == "Other", "Unk", age)) |>
    fill(asof, coa) |>
    filter(asof != "Total", !is.na(n)) |>
    mutate(asof = rollforward(make_date(year, month)))
}
