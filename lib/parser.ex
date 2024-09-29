defmodule FcmDigitalTask.Parser do
  @moduledoc """
  Module responsible for parsing input string
  """

  alias FcmDigitalTask.Parser.SegmentParser
  alias FcmDigitalTask.Trips.Segment

  require Logger

  @doc """
  Parse the given string into list of segments
  """
  @spec parse(String.t()) :: {:ok, String.t(), list(Segment.t())} | {:error, String.t()}
  def parse(input) do
    lines = String.split(input, "\n")

    with {:ok, based, lines} <- parse_based(lines),
         {:ok, segments} <- parse_segments(lines) do
      segments = segments |> parse_date_times() |> build_segments()
      {:ok, based, segments}
    else
      error -> error
    end
  end

  defp parse_based([first_line | rest]), do: parse_based(first_line, rest)

  def parse_based("BASED: " <> based, rest), do: {:ok, based, rest}

  def parse_based(_, _rest), do: {:error, "Could not parse based value"}

  defp parse_segments(lines) do
    segments = for("SEGMENT: " <> segment_data <- lines, do: SegmentParser.segment(segment_data))

    if Enum.all?(segments, fn
         {:ok, _, _, _, _, _} ->
           true

         {:error, _, line, _, _, _} ->
           Logger.error("Could not parse segment: #{line}")
           false
       end) do
      {:ok, segments}
    else
      {:error, "Could not parse all segments"}
    end
  end

  defp parse_date_times(segments) do
    Enum.map(segments, fn
      {:ok, [type, iata1, y, mo, d, h1, mi1, iata2, h2, mi2], _, _, _, _} ->
        start_time = datetime(y, mo, d, h1, mi1)
        dest_time = datetime(y, mo, d, h2, mi2)
        {:ok, type, iata1, start_time, iata2, dest_time}

      {:ok, [type, iata1, y1, m1, d1, y2, m2, d2], _, _, _, _} ->
        start_time = datetime(y1, m1, d1, 0, 0)
        dest_time = datetime(y2, m2, d2, 0, 0)
        {:ok, type, iata1, start_time, iata1, dest_time}

      other ->
        other
    end)
  end

  defp datetime(y, mo, d, h, mi),
    do: %DateTime{
      year: y,
      month: mo,
      day: d,
      zone_abbr: "UTC",
      hour: h,
      minute: mi,
      second: 0,
      microsecond: {0, 0},
      utc_offset: 0,
      std_offset: 0,
      time_zone: "Etc/UTC"
    }

  defp build_segments(segments) do
    for {:ok, type, iata1, start_time, iata2, dest_time} <- segments,
        do: Segment.new(type, iata1, start_time, iata2, dest_time)
  end
end
