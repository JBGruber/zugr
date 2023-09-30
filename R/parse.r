#' Parse response from calls to the fahrplan endpoint
#' @noRd
parse_response <- function(x) {
  # shut up notes
  start <- NULL
  end <- NULL
  duration <- NULL
  x <- unlist(x, recursive = FALSE)
  purrr::map(x[["verbindungen"]], function(v) {
    n_abschnitt <- length(v[["verbindungsAbschnitte"]])
    tibble::tibble(
      id = v[["tripId"]],
      duration = v[["verbindungsDauerInSeconds"]],
      price = v[["angebotsPreis"]][["betrag"]],
      changes = v[["umstiegsAnzahl"]],
      start = v[["verbindungsAbschnitte"]][[1]][["ankunftsZeitpunkt"]],
      end = v[["verbindungsAbschnitte"]][[n_abschnitt]][["ankunftsZeitpunkt"]]
    )
  }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      start = lubridate::force_tz(lubridate::ymd_hms(start), "Europe/Berlin"),
      end = lubridate::force_tz(lubridate::ymd_hms(end), "Europe/Berlin"),
      duration = lubridate::as.duration(duration)
    )
}

get_last <- function(x) {
  v <- utils::tail(x[["verbindungen"]], 1)
  a <- utils::tail(v[[1]][["verbindungsAbschnitte"]], 1)
  lubridate::ymd_hms(a[[1]][["ankunftsZeitpunkt"]]) |>
    lubridate::force_tz("Europe/Berlin")
}
