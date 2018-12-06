defmodule Count23AndMultiply do
    @moduledoc """
    Day 2, exercise 1.
    Iterate over a list of strings, for each one detect whether it has a letter
    appearing exactly 2 or exactly 3 times. Multiply the numbers of strings
    having these characteristics.
    If a string have both the cases it is counted twice.
    """
    defp str2freq(s) do
        Enum.reduce(s, Map.new, fn c,acc -> Map.update(acc, c, 1, &(&1+1)) end)
    end

    defp hasCount?(freq, count) do
        Enum.any?(Map.values(freq), &(&1 == count))
    end

    def detect(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.transform(%{:total2 => 0, :total3 => 0},
            fn (line, acc) ->
                fs = str2freq(String.to_charlist(line))
                has2 = if hasCount?(fs, 2), do: 1, else: 0
                has3 = if hasCount?(fs, 3), do: 1, else: 0
                # IO.inspect acc
                res = %{:total2 => acc[:total2] + has2,
                :total3 => acc[:total3] + has3}
                {[res[:total2] * res[:total3]],
                  res
                    }
        end)
        # there must be a simpler way to get the last accumulator
        |> Enum.to_list
        |> Enum.reverse
        |> Enum.at(0)
    end
end

IO.puts "Result: #{Count23AndMultiply.detect("day02.01.txt")}"
