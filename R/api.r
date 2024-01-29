#' Make a request tot the fahrplan endpoint
#' @noRd
get_results <- function(req_body, throttle = 5) {
  # TODO: remove progress bar for req_throttle
  suppressMessages({
    httr2::request("https://www.bahn.de/web/api/angebote/fahrplan") |>
      httr2::req_headers(
        "user-agent" = "bahnr"
      ) |>
      httr2::req_body_json(req_body) |>
      httr2::req_throttle(throttle / 60) |>
      httr2::req_perform() |>
      httr2::resp_body_json()
  })
}
