% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/search.r
\name{bahn_search}
\alias{bahn_search}
\title{Search connections}
\usage{
bahn_search(
  from,
  to,
  start = Sys.time(),
  end = start + 120,
  throttle = 5,
  parse = TRUE
)
}
\arguments{
\item{from, to}{The departure/arrival station id (obtained via
\code{\link{search_station}}).}

\item{start}{Character or Datetime. The start time of the search (earlies
depature).}

\item{end}{Character or Datetime. The end time of the search (latest
arrival).}

\item{throttle}{how many request per minute to perform.}

\item{parse}{Logical. Whether to parse the response (otherwise you will get
the nested list returned by the API directly. Currently not all data is
parsed into the returned tibble (just what I tought was important).}
}
\value{
A data frame of connections.
}
\description{
Search connections
}
\examples{
\dontrun{
bahn_search(
  "A=1@O=Wiesbaden Hbf@X=8243729@Y=50070788@U=80@L=8000250@B=1@p=1695673683@",
  to = "A=1@O=Amsterdam Centraal@X=4899427@Y=52379191@U=80@L=8400058@B=1@p=1695673683@",
  start = "2023-10-09T08:00:01",
  end = "2023-10-14T18:00:01"
)

# can be provided as date(time) as well
bahn_search(
  "A=1@O=Wiesbaden Hbf@X=8243729@Y=50070788@U=80@L=8000250@B=1@p=1695673683@",
  to = "A=1@O=Amsterdam Centraal@X=4899427@Y=52379191@U=80@L=8400058@B=1@p=1695673683@",
  start = as.Date("2023-10-09"),
  end = as.Date("2023-10-10")
)
}
}
