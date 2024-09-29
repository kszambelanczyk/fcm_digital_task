defmodule FcmDigitalTask.ParserTest do
  use ExUnit.Case

  alias FcmDigitalTask.Parser

  import ExUnit.CaptureLog

  describe "parse/1" do
    @correct_input """
    BASED: SVQ

    SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17
    SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45
    SEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:25
    """

    @incorrect_input1 """
    BASED: SVQ

    SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17
    SEGMENT: Flidght BCN 2023-03-02 15:00 -> NYC 22:45
    SEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:25
    """

    @incorrect_input2 """
    BASED:SVQ

    SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17
    SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45
    SEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:25
    """

    test "it parser input string into the list of segments" do
      result = Parser.parse(@correct_input)

      assert {:ok, "SVQ",
              [
                %{type: "hotel", start: "MAD", dest: "MAD"},
                %{type: "flight", start: "BCN", dest: "NYC"},
                %{type: "flight", start: "NYC", dest: "BOS"}
              ]} =
               result
    end

    test "it return error for incorrect segment input data" do
      fun = fn ->
        result = Parser.parse(@incorrect_input1)

        assert {:error, "Could not parse all segments"} =
                 result
      end

      assert capture_log(fun) =~
               "Could not parse segment: Flidght BCN 2023-03-02 15:00 -> NYC 22:45"
    end

    test "it return error for incorrect based input data" do
      assert {:error, "Could not parse based value"} = Parser.parse(@incorrect_input2)
    end
  end
end
