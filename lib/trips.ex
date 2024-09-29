defmodule FcmDigitalTask.Trips do
  @moduledoc """
  Module responsible for building trip functionality
  """

  alias FcmDigitalTask.Trips.Segment

  defmodule Segment do
    @moduledoc """
    Module keeping information about trip segments
    """

    defstruct [:type, :start, :start_time, :dest, :dest_time]

    @type t :: %__MODULE__{
            type: String.t(),
            start: String.t(),
            start_time: DateTime.t(),
            dest: String.t(),
            dest_time: DateTime.t()
          }

    def new(type, start, start_time, dest, dest_time) do
      %__MODULE__{
        type: type,
        start: start,
        start_time: start_time,
        dest: dest,
        dest_time: dest_time
      }
    end
  end

  defmodule Trip do
    @moduledoc """
    Struct definition of single trip
    """
    defstruct destinations: [], segments: []

    @type t :: %__MODULE__{
            destinations: list(String.t()),
            segments: list(Segment.t())
          }
  end

  @spec build_trips(list(Segment.t()), String.t()) :: list(Trip.t())
  def build_trips(segments, based), do: build_trips(segments, based, [])

  defp build_trips([%{start: start} = segment | segments], based, trips) when start == based do
    # Grouping with the assumption that trip starts always from based value
    # when segment matches based value -> create new trip
    trip = %Trip{segments: [segment]}

    build_trips(segments, based, [trip | trips])
  end

  defp build_trips([segment | segments], based, [trip | trips]) do
    trip = %{trip | segments: [segment | trip.segments]}

    build_trips(segments, based, [trip | trips])
  end

  defp build_trips([], _based, trips),
    do:
      trips
      |> Enum.map(&%{&1 | segments: Enum.reverse(&1.segments)})
      |> Enum.reverse()

  @spec fill_trips_destinations(list(Trip.t()), String.t()) :: list(Trip.t())
  def fill_trips_destinations(trips, based) do
    Enum.map(trips, &%{&1 | destinations: fill_destinations(&1.segments, based)})
  end

  defp fill_destinations(segments, based), do: fill_destinations(segments, based, [])

  defp fill_destinations(
         [
           %{type: type, dest: dest, dest_time: dest_time}
           | [%{type: type2, start_time: start_time, dest: dest2} | _] = segments
         ],
         based,
         destinations
       )
       when type in ["train", "flight"] and type2 != "hotel" and dest != based and dest2 != based do
    if DateTime.diff(start_time, dest_time, :hour) < 24 do
      fill_destinations(segments, based, destinations)
    else
      fill_destinations(segments, based, [dest | destinations])
    end
  end

  defp fill_destinations([%{type: type, dest: dest} | segments], based, destinations)
       when type in ["train", "flight"] and dest != based do
    fill_destinations(segments, based, [dest | destinations])
  end

  defp fill_destinations([_ | segments], based, destinations),
    do: fill_destinations(segments, based, destinations)

  defp fill_destinations([], _based, destinations), do: destinations |> Enum.reverse()

  @spec trip_to_string(Trip.t()) :: String.t()
  def trip_to_string(%Trip{segments: segments, destinations: destinations}) do
    "TRIP to #{Enum.join(destinations, ", ")}\n" <> segments_to_string(segments)
  end

  defp segments_to_string(segments), do: segments_to_string(segments, "")

  defp segments_to_string([segment | segments], result) do
    result = result <> segment_to_string(segment) <> "\n"

    segments_to_string(segments, result)
  end

  defp segments_to_string([], result), do: result

  defp segment_to_string(%{
         type: type,
         start: start,
         start_time: start_time,
         dest: dest,
         dest_time: dest_time
       })
       when type in ["flight", "train"] do
    type_str = if type == "flight", do: "Flight", else: "Train"

    "#{type_str} from #{start} to #{dest} at #{Calendar.strftime(start_time, "%Y-%m-%d %H:%M")} to #{Calendar.strftime(dest_time, "%H:%M")}"
  end

  defp segment_to_string(%{
         type: "hotel",
         start: start,
         start_time: start_time,
         dest_time: dest_time
       }),
       do:
         "Hotel at #{start} on #{Calendar.strftime(start_time, "%Y-%m-%d")} to #{Calendar.strftime(dest_time, "%Y-%m-%d")}"
end
