defmodule FcmDigitalTask.TripsTest do
  use ExUnit.Case

  alias FcmDigitalTask.Trips
  alias FcmDigitalTask.Trips.Segment

  describe "build_trips/2" do
    test "it creates trips with grouped segments" do
      segments1 = [
        %Segment{
          type: "flight",
          start: "SVQ",
          start_time: ~U[2023-01-05 20:40:00Z],
          dest: "BCN",
          dest_time: ~U[2023-01-05 22:10:00Z]
        },
        %Segment{
          type: "hotel",
          start: "BCN",
          start_time: ~U[2023-01-05 00:00:00Z],
          dest: "BCN",
          dest_time: ~U[2023-01-10 00:00:00Z]
        },
        %Segment{
          type: "flight",
          start: "BCN",
          start_time: ~U[2023-01-10 10:30:00Z],
          dest: "SVQ",
          dest_time: ~U[2023-01-10 11:50:00Z]
        }
      ]

      segments2 = [
        %FcmDigitalTask.Trips.Segment{
          type: "flight",
          start: "SVQ",
          start_time: ~U[2023-03-02 06:40:00Z],
          dest: "BCN",
          dest_time: ~U[2023-03-02 09:10:00Z]
        },
        %FcmDigitalTask.Trips.Segment{
          type: "flight",
          start: "NYC",
          start_time: ~U[2023-03-06 08:00:00Z],
          dest: "BOS",
          dest_time: ~U[2023-03-06 09:25:00Z]
        }
      ]

      assert Trips.build_trips(segments1 ++ segments2, "SVQ") == [
               %Trips.Trip{
                 destinations: [],
                 segments: segments1
               },
               %Trips.Trip{
                 destinations: [],
                 segments: segments2
               }
             ]
    end
  end

  describe "fill_trips_destinations/2" do
    test "it fills trips with destination strings" do
      trip =
        %Trips.Trip{
          destinations: [],
          segments: [
            %Segment{
              type: "flight",
              start: "SVQ",
              start_time: ~U[2023-01-05 20:40:00Z],
              dest: "BCN",
              dest_time: ~U[2023-01-05 22:10:00Z]
            },
            %Segment{
              type: "hotel",
              start: "BCN",
              start_time: ~U[2023-01-05 00:00:00Z],
              dest: "BCN",
              dest_time: ~U[2023-01-10 00:00:00Z]
            },
            %Segment{
              type: "flight",
              start: "BCN",
              start_time: ~U[2023-01-10 10:30:00Z],
              dest: "SVQ",
              dest_time: ~U[2023-01-10 11:50:00Z]
            }
          ]
        }

      assert [%{destinations: ["BCN"]}] = Trips.fill_trips_destinations([trip], "SVQ")
    end
  end
end
