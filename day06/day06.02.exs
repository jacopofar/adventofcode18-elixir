defmodule SomethingVoronoi do
    @moduledoc """
    Day 6, exercise 2.
    Given a few cells in a grid, find the cells with a sum of the
    manhattan distances lower than 10000. Find the size of this region.
    """
    def dist({x1, y1},{x2, y2}) do
        abs(x1 - x2) + abs(y1 - y2)
    end

    @doc """
    Return the total distance from all the centers
    """
    def distances_sum({x, y}, centers) do

        Enum.sum(centers |> Enum.map(fn ({center_x, center_y}) ->
            dist({x, y}, {center_x, center_y}) end))

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
    A map where key is the coordinate and value is the sum of the distances
    """
    def calculate_populated_region(centers) do
       grid_cells(centers)
       |> Enum.map(fn ({x, y}) ->
         {{x, y}, distances_sum({x, y}, centers)} end )
       |> Enum.into(%{})
    end


    def region_color(rid) do
        case rid do
            x when x < 10000 -> "black"
            _ -> colors = [
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
        regions = calculate_populated_region(centers)
        """
        <?xml version="1.0" encoding="UTF-8" ?>
        <svg xmlns="http://www.w3.org/2000/svg" version="1.1">
        """
        <> (regions
            |> Enum.sort
            |> Enum.map(fn({{x, y}, r})->
                "<rect x=\"#{2 * x}\" y=\"#{2 * y}\" width=\"2\" height=\"2\" fill=\"#{region_color(r)}\" data-idx=\"#{r}\" />"
            end)
            |> Enum.join("\n"))
        <> (centers
        |> Enum.map(fn({x, y})->
            "<circle cx=\"#{x * 2}\" cy=\"#{y * 2}\" r=\"3\" fill=\"red\" />"
            end)
            |> Enum.join("\n"))
         <> "</svg>"
    end
end


svgdata = SomethingVoronoi.regions_to_svg(SomethingVoronoi.coords_from_file!("day06.txt"))
File.write!("day06.02.svg", svgdata)
IO.puts "SVG map generated!"

big_hole_size = SomethingVoronoi.coords_from_file!("day06.txt")
    |> SomethingVoronoi.calculate_populated_region
    |> Enum.filter(fn ({{_, _}, r}) -> r < 10000 end)
    |> Enum.count

IO.puts "the size of the area with a sum < 1000 is #{big_hole_size}"