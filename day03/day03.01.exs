defmodule FindOverlappingSquares do
    @moduledoc """
    Day 3, exercise 1.
    Get a list of rectangles on a grid, defined like this

    #3 @ 53,233: 21x25

    this is a 21x25 rectangle which starts at 53,233 and has size 21x25

    The goal is to count how many 1x1 squares are overlapping
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

    @doc """
    Given two box tuples from str2box return the list of overlapping coordinates

    It's not used because later I realized it was superflous. Still, I enjoyed
    writing it and so here it is :)
    """
    def boxes2overlaps(a, b) do
        {al, at, aw, ah} = a
        {bl, bt, bw, bh} = b
        # how far from the left starts the overlapping area?
        start_x = max(al, bl)
        # end when does it end?
        end_x = min(al + aw, bl + bw)
        # same for Y
        start_y = max(at, bt)
        end_y = min(at + ah, bt + bh)
        IO.inspect {start_x, end_x, start_y, end_y}
        if start_x >= end_x or start_y >= end_y do
            # no overlapping
            []
        else
            # all the squares inside the overlapping area
            # add + 1
            for x <- start_x + 1..end_x, y <- start_y + 1..end_y do
                {x, y}
            end
        end
    end

    def box2squares(box) do
        {al, at, aw, ah} = box
        for x <- al + 1..al + aw, y <- at + 1..at + ah do
            {x, y}
        end
    end

    def processFile(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&str2box/1)
        |> Stream.transform({MapSet.new(), MapSet.new()}, fn
            (box, {covered, multi_covered}) ->
                this_patch = MapSet.new(box2squares(box))

                common_squares = MapSet.intersection(covered, this_patch)
                new_covered = MapSet.union(covered, this_patch)
                new_multi_covered = MapSet.union(multi_covered, common_squares)

                #IO.inspect {box, common_squares}
                #IO.puts "---"
                {[new_multi_covered], {
                    MapSet.union(covered, MapSet.new(new_covered)),
                    new_multi_covered
                    }}
        end
        )
        |> Enum.to_list
    end
end
#s1 = "#1 @ 1,3: 4x4"
#b1 = FindOverlappingSquares.str2box(s1)
#b2 = FindOverlappingSquares.str2box(s2)
# IO.inspect FindOverlappingSquares.box2squares(b1)
# IO.puts "Result: #{FindOverlappingSquares.str2box("#3 @ 53,233: 21x25")}"
# IO.inspect FindOverlappingSquares.str2box("#3 @ 53,233: 21x25")
IO.inspect FindOverlappingSquares.processFile("day03.txt")
|> Enum.reverse
|> Enum.at(0)
|> MapSet.size