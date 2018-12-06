defmodule DetectSeenPartialSums do
    @moduledoc """
    Dsay 1, exercise 2. Iterate over a file with numbers, and perform the partial sum.
    When a partial sum appears for a second time, show it.
    IMPORTANT: the file is iterated over and over while preserving the partial sum,
     as if it was infinitely concatenaded with itself.
    """
    def detect(filename) do
        # cycle over the file, we want to read it again and again
        Stream.cycle(File.stream!(filename))
        |> Stream.map(&String.trim/1) |> Stream.map(&Integer.parse/1)
        |> Stream.transform(%{:current_total => 0, :seen_total => MapSet.new([0])}, fn (candidate_line, acc) ->
            case candidate_line do
                {number, _} ->
                    if MapSet.member?(acc[:seen_total], acc[:current_total] + number) do
                        IO.puts "found frequency: #{acc[:current_total] + number}"
                        :timer.sleep(10000)
                        {:halt, acc}
                    else
                        {[candidate_line], %{:current_total => acc[:current_total] + number, :seen_total => MapSet.put(acc[:seen_total], acc[:current_total] + number)}}
                    end
                    _ ->
                        IO.puts "end of the file"
                        {:halt, acc}
            end
        end)
        |> Stream.run
    end
end

DetectSeenPartialSums.detect("day01.02.txt")
#DetectSeenPartialSums.detect("numba.txt")