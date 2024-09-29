defmodule FcmDigitalTask do
  @moduledoc """
  Documentation for `FcmDigitalTask`.
  """

  alias FcmDigitalTask.Itinerary
  alias FcmDigitalTask.Parser

  def process, do: File.read!("./test/fixtures/input.txt") |> _process()

  def process(path), do: File.read!(path) |> _process()

  defp _process(data) do
    with {:ok, based, segments} <- Parser.parse(data),
         itinerary <- Itinerary.build_itinerary(based, segments) do
      Itinerary.to_string(itinerary)
    else
      {:error, error} -> IO.puts("Error processing input file: #{error}")
    end
  end
end
