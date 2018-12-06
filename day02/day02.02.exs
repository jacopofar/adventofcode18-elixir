defmodule CommonChars do
    @moduledoc """
    Day 2, exercise 2.
    Find two strings which differ only for one character,
    return the common part.

    E.g. aabde, aabce give aabe
    """
    defp commonChars(s1, s2) do
        # zip characters in same position
        List.zip([s1, s2])
        # get only matching ones
        |> Enum.filter(&(elem(&1,0) == elem(&1,1)))
        # back from zip tuple to the character
        |> Enum.map(&(elem(&1,0)))
    end

    def findVerySimilar(filename) do
        all_boxes = File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&String.to_charlist/1)
        |> Enum.to_list
        for i <- all_boxes, j <- all_boxes
        do
            common = commonChars(i, j)
            if Enum.count(common) == Enum.count(i) - 1 do
                common
            end
        end
    end
end

# take the first one which is not nil
common = CommonChars.findVerySimilar("day02.01.txt")
|> Enum.reject(&is_nil/1)
|> Enum.take(1)

IO.puts "secret string: #{common}"