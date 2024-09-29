defmodule FcmDigitalTask.Itinerary do
  @moduledoc """
  Module responsible for keeping information about trip itinerary
  """

  defstruct [:based, segments: [], trips: []]

  alias FcmDigitalTask.Trips
  alias FcmDigitalTask.Trips.Segment
  alias FcmDigitalTask.Trips.Trip

  @type t :: %__MODULE__{
          based: String.t(),
          trips: list(Trip.t())
        }

  @spec build_itinerary(String.t(), list(Segment.t())) :: t()
  def build_itinerary(based, segments) do
    trips =
      segments
      |> sort_by_destination_time()
      |> Trips.build_trips(based)
      |> Trips.fill_trips_destinations(based)

    %__MODULE__{based: based, trips: trips}
  end

  @spec sort_by_destination_time(list(Segment.t())) :: list(Segment.t())
  defp sort_by_destination_time(segments),
    do: Enum.sort_by(segments, & &1.dest_time, {:asc, DateTime})

  @spec to_string(t()) :: String.t()
  def to_string(%{trips: trips}), do: Enum.map_join(trips, "\n", &Trips.trip_to_string/1)
end
