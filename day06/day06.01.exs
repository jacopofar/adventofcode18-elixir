defmodule SomethingVoronoi do
    @moduledoc """
    Day 6, exercise 1.
    Given a few cells in a grid, find the finite sets of cells which are stricly
    the most close to each of them, using manhattan distance.

    Ignore infinite regions, return the size of the biggest one
    """
    def dist({x1, y1},{x2, y2}) do
        abs(x1 - x2) + abs(y1 - y2)
    end

    @doc """
    Return the index of the closest center, nil if more than one (region edge)
    """
    def closest({x, y}, centers) do
        centers
        |> Enum.with_index
        |> Enum.group_by(
             fn ({{center_x, center_y}, _}) ->
                dist({x, y}, {center_x, center_y}) end,
             fn ({_, idx}) -> idx end)
        |> Enum.min
        # strictly ONE region
        |> case do
             {_, [idx]} -> idx
             _ -> nil
           end
    end

    @doc """
    Helper to get the {X, Y} tuple from the string X, Y in the file
    """
    def coord_to_tuple(s) do
        s
        |> String.split(", ")
        |> Enum.map(&(elem(Integer.parse(&1), 0)))
        |> List.to_tuple
    end

    @doc """
    List of coordinates read from the file, as tuples {X, Y}
    """
    def coords_from_file!(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&coord_to_tuple/1)
        |> Enum.into([])
    end

    @doc """
    Get the bounding box
    The limits of the map are just enough to contain all the centers
    """
    def map_bounding(centers) do
        {
            centers |> Enum.map(fn ({x, _}) -> x end) |> Enum.min,
            centers |> Enum.map(fn ({x, _}) -> x end) |> Enum.max,
            centers |> Enum.map(fn ({_, y}) -> y end) |> Enum.min,
            centers |> Enum.map(fn ({_, y}) -> y end) |> Enum.max
        }
    end
    @doc """
    Enumerate the map cells
    Coordinates are in "reading order"
    """
    def grid_cells(centers) do
        {min_x, max_x, min_y, max_y} = map_bounding(centers)
        for x <- min_x..max_x, y <- min_y..max_y do
            {x, y}
        end
    end
    @doc """
    Calculate the complete grid given the centers.
    A map where key is the coordinate and value is the region (or nil)
    """
    def calculate_regions(centers) do
       grid_cells(centers)
       |> Enum.map(fn ({x, y}) ->
         {{x, y}, closest({x, y}, centers)} end )
       |> Enum.into(%{})
    end

    @doc """
    Calculate the ids of infinite regions.
    Those are the ones that reach the border.
    """
    def get_infinite_regions(centers, regions) do
        {min_x, max_x, min_y, max_y}= map_bounding(centers)

        regions
        # keep only non-nil cells on the border
        |> Enum.filter(fn({{_, _}, r}) -> r != nil end)
        |> Enum.filter(fn({{x, y}, _}) -> x == min_x or x == max_x or y == min_y or y == max_y end)
        # from them, get all the unique regions
        |> Enum.map(fn({{_, _}, r}) -> r end)
        |> Enum.uniq
    end

    def ranked_regions_sizes(centers) do
        regions = calculate_regions(centers)
        infinite_regions = get_infinite_regions(centers, regions)
        regions
        # filter out infinite and nil cells
        |> Enum.filter(fn ({{_, _}, r}) -> r != nil and !Enum.member?(infinite_regions, r) end)
        # map each region to the list of its cells
        |> Enum.group_by(fn ({{_, _}, r}) -> r end)
        # keep only the cell count, not their coordinates
        |> Enum.map(fn ({r, cells}) -> {r, Enum.count(cells)} end)
        |> Enum.sort_by(fn ({_, count}) -> count end)
    end

    def region_color(rid) do
        case rid do
            nil -> "black"
            _ -> colors = [
                    "red",
                    "lime",
                    "blue",
                    "yellow",
                    "cyan",
                    "magenta",
                    "silver",
                    "gray",
                    "gold",
                    "maroon",
                    "olive",
                    "green",
                    "purple",
                    "teal",
                    "navy",
                    "olive",
                    "indigo"
            ]
            Enum.at(colors, rem(rid, Enum.count(colors)))
        end
    end

    def regions_to_svg(centers) do
        regions = calculate_regions(centers)
        infinite_regions = get_infinite_regions(centers, regions)

        """
        <?xml version="1.0" encoding="UTF-8" ?>
        <svg xmlns="http://www.w3.org/2000/svg" version="1.1">
        """
        <> (regions
            |> Enum.sort
            |> Enum.filter(fn ({{_, _}, r}) -> r != nil and !Enum.member?(infinite_regions, r) end)
            |> Enum.map(fn({{x, y}, r})->
                "<rect x=\"#{2 * x}\" y=\"#{2 * y}\" width=\"2\" height=\"2\" fill=\"#{region_color(r)}\" data-idx=\"#{r}\" />"
            end)
            |> Enum.join("\n"))
        <> (centers
        |> Enum.map(fn({x, y})->
            "<circle cx=\"#{x * 2}\" cy=\"#{y * 2}\" r=\"3\" fill=\"black\" />"
            end)
            |> Enum.join("\n"))
         <> "</svg>"
    end
end


svgdata = SomethingVoronoi.regions_to_svg(SomethingVoronoi.coords_from_file!("day06.txt"))
File.write!("day06.01.svg", svgdata)
IO.puts "SVG map generated!"

ranked_regions = SomethingVoronoi.coords_from_file!("day06.txt")
    |> SomethingVoronoi.ranked_regions_sizes

IO.inspect ranked_regions

{rid, size} = List.last(ranked_regions)
IO.puts "Biggest non-infinite region has index #{rid} and size #{size}"