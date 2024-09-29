defmodule FcmDigitalTask.Parser.SegmentParser do
  @moduledoc """
  Module responsible for parsing segments from input string
  """

  import NimbleParsec

  date =
    integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)

  time =
    integer(2)
    |> ignore(string(":"))
    |> integer(2)

  date_time =
    date
    |> ignore(string(" "))
    |> concat(time)

  iata = ascii_string([?A..?Z], 3)

  travel_seg =
    iata
    |> ignore(string(" "))
    |> concat(date_time)
    |> ignore(string(" -> "))
    |> concat(iata)
    |> ignore(string(" "))
    |> concat(time)

  flight =
    string("Flight ")
    |> replace("flight")
    |> concat(travel_seg)

  train =
    string("Train ")
    |> replace("train")
    |> concat(travel_seg)

  hotel =
    string("Hotel ")
    |> replace("hotel")
    |> concat(iata)
    |> ignore(string(" "))
    |> concat(date)
    |> ignore(string(" -> "))
    |> concat(date)

  defparsec(:segment, choice([flight, train, hotel]))
end
