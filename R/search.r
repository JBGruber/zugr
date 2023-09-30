#' Search connections
#'
#' @param from,to The departure/arrival station id (obtained via
#'   \code{\link{search_station}}).
#' @param start Character or Datetime. The start time of the search (earlies
#'   depature).
#' @param end Character or Datetime. The end time of the search (latest
#'   arrival).
#' @param parse Logical. Whether to parse the response (otherwise you will get
#'   the nested list returned by the API directly. Currently not all data is
#'   parsed into the returned tibble (just what I tought was important).
#' @return A data frame of connections.
#' @export
#' @examples
#' \dontrun{
#' bahn_search(
#'   "A=1@O=Wiesbaden Hbf@X=8243729@Y=50070788@U=80@L=8000250@B=1@p=1695673683@",
#'   to = "A=1@O=Amsterdam Centraal@X=4899427@Y=52379191@U=80@L=8400058@B=1@p=1695673683@",
#'   start = "2023-10-09T08:00:01",
#'   end = "2023-10-14T18:00:01"
#' )
#'
#' # can be provided as date(time) as well
#' bahn_search(
#'   "A=1@O=Wiesbaden Hbf@X=8243729@Y=50070788@U=80@L=8000250@B=1@p=1695673683@",
#'   to = "A=1@O=Amsterdam Centraal@X=4899427@Y=52379191@U=80@L=8400058@B=1@p=1695673683@",
#'   start = as.Date("2023-10-09"),
#'   end = as.Date("2023-10-10")
#' )
#' }
bahn_search <- function(from,
                        to,
                        start = Sys.time(),
                        end = start + 120,
                        parse = TRUE) {

  if (is.character(start)) start <- lubridate::ymd_hms(start)
  if (is.character(end)) end <- lubridate::ymd_hms(end)


  # TODO: export more parameters
  req_body <- list(
    abfahrtsHalt = from,
    anfrageZeitpunkt = format(start, "%Y-%m-%dT%H:%M:%S"),
    ankunftsHalt = to,
    ankunftSuche = "ABFAHRT",
    klasse = "KLASSE_2",
    produktgattungen = c("ICE","EC_IC", "IR", "REGIONAL", "SBAHN", "BUS", "SCHIFF", "UBAHN", "TRAM", "ANRUFPFLICHTIG"),
    reisende = structure(list(typ = "ERWACHSENER",
                              ermaessigungen = list(structure(list(art = "KEINE_ERMAESSIGUNG", klasse = "KLASSENLOS"),
                                                              class = "data.frame", row.names = 1L)),
                              alter = list(list()), anzahl = 1L), class = "data.frame", row.names = 1L),
    rueckfahrtAnfrageFolgt = FALSE,
    schnelleVerbindungen = TRUE,
    sitzplatzOnly = FALSE,
    bikeCarriage = FALSE,
    reservierungsKontingenteVorhanden = FALSE
  )

  res <- list()
  page <- 1
  cli::cli_progress_bar("Getting results")

  resp <- get_results(req_body)
  res[[page]] <- resp

  while (get_last(resp) < end) {
    cli::cli_progress_update()
    page <- page + 1
    req_body[["pagingReference"]] <- resp$verbindungReference$later
    resp <- get_results(req_body)

    res[[page]] <- resp
  }

  if (parse) {
    return(parse_response(res))
  } else {
    return(res)
  }

}



#' Search Station
#'
#' Search the station id using a query, returns n_res options in a tibble
#'
#' @param q character string, query to search for station.
#' @param n_res number of results to return (integer or character).
#' @return tibble, containing station name and id
#' @export
#'
#' @examples
#' search_station("Frankfurt")
search_station <- function(q, n_res = 10L) {
  resp <- httr2::request("https://www.bahn.de/web/api/reiseloesung/orte") |>
    httr2::req_url_query(
      suchbegriff = q,
      typ = "ALL",
      limit = as.character(n_res)
    ) |>
    httr2::req_headers(
      "user-agent" = "bahnr"
    ) |>
    httr2::req_throttle(5 / 60) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  purrr::map(resp, function(r) {
    tibble::tibble(
      name = purrr::pluck(r, "name"),
      id = purrr::pluck(r, "id")
    )
  }) |>
    dplyr::bind_rows()
}
