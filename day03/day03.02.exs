defmodule FindOverlappingSquares do
    @moduledoc """
    Day 3, exercise 2.
    Get a list of rectangles on a grid, defined like this

    #3 @ 53,233: 21x25

    this is a 21x25 rectangle which starts at 53,233 and has size 21x25

    Find a rectangle not overlapping with any of the others
    """
    @doc """
    Convert a rectangle string to the list of left, top, width, height
    Return a tuple
    """
    def str2box(s) do
        Regex.split(~r"[^0-9]+", s)
        |> Enum.slice(2, 4)
        |> Enum.reduce({}, &(Tuple.append(&2, elem(Integer.parse(&1), 0))))
    end

    def box2squares(box) do
        {al, at, aw, ah} = box
        for x <- al + 1..al + aw, y <- at + 1..at + ah do
            {x, y}
        end
    end

    def not_overlap?(s1, s2) do
        MapSet.disjoint?(
            MapSet.new(box2squares(str2box(s1))),
            MapSet.new(box2squares(str2box(s2)))
        )
    end

    def processFile(filename) do
        all_boxes = File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Enum.to_list
        # super slow, nicer to use a map and count the overlaps
        Enum.find(all_boxes, fn candidate ->
                Enum.all?(all_boxes, fn other ->
                    (other == candidate) or not_overlap?(candidate, other)
                end)
            end)
    end
end

IO.inspect FindOverlappingSquares.processFile("day03.txt")
|> IO.puts