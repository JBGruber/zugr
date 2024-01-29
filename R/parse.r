#' Parse response from calls to the fahrplan endpoint
#' @noRd
parse_response <- function(x) {
  # shut up notes
  start <- NULL
  end <- NULL
  duration <- NULL
  # TODO: better way to parse this?
  out <- purrr::map(x, function(r) {
    purrr::map(purrr::pluck(r, "verbindungen"), function(v) {
      n_abschnitt <- length(purrr::pluck(v, "verbindungsAbschnitte"))
      tibble::tibble(
        id = purrr::pluck(v, "tripId"),
        duration = purrr::pluck(v, "verbindungsDauerInSeconds"),
        price = purrr::pluck(v, "angebotsPreis", "betrag"),
        changes = purrr::pluck(v, "umstiegsAnzahl"),
        start = purrr::pluck(v, "verbindungsAbschnitte", 1, "abfahrtsZeitpunkt"),
        end = purrr::pluck(v, "verbindungsAbschnitte", n_abschnitt, "ankunftsZeitpunkt")
      )
    }) |>
      dplyr::bind_rows()
  }) |>
    dplyr::bind_rows()

  if (nrow(out) > 0) {
    out <- out |>
      dplyr::mutate(
      start = lubridate::force_tz(lubridate::ymd_hms(start), "Europe/Berlin"),
      end = lubridate::force_tz(lubridate::ymd_hms(end), "Europe/Berlin"),
      duration = lubridate::as.duration(duration)
    )
  }

  return(out)

}

get_last <- function(x) {
  v <- utils::tail(purrr::pluck(x, "verbindungen"), 1)
  a <- utils::tail(purrr::pluck(v, 1, "verbindungsAbschnitte"), 1)
  lubridate::ymd_hms(purrr::pluck(a, 1, "ankunftsZeitpunkt")) |>
    lubridate::force_tz("Europe/Berlin")
}
