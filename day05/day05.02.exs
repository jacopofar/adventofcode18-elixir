defmodule PolymerReaction do
    @moduledoc """
    Day 5, exercise 1.
    Like ex.1, but this time we want to find which letter, when removed with
    both cases, minimizes the final length of the polymer.
    """
    @doc """
    Tells whether two characters are reacting or not
    """
    def opposite?(a,b) do
        (String.upcase(a) == b and a != b)
        or
        (String.downcase(a) == b and a != b)
    end
    @doc """
    Given a string performs a single reaction step
    """
    def singleReaction(s) do
        s
        |> String.graphemes
        |> Enum.reduce(%{prev: "", newchain: ""}, fn (cur, %{prev: p, newchain: n}) ->
             cond do
                opposite?(cur, p) ->
                    %{prev: "", newchain: n}
                true ->
                    %{prev: cur, newchain: n <> p}
             end
            end)
            # I found weird the way this anonymous function has to be passed here
            # turns out it's due to ambiguity when not using () invoking a
            # function with arity 1
            # see comments from José Valim:
            # https://stackoverflow.com/questions/18011784/why-are-there-two-kinds-of-functions-in-elixir/18023790#18023790
        |> (fn(%{prev: p, newchain: n}) -> n <> p end).()
    end

    @doc """
    Applies singleReaction until the string cannot be reduced anymore
    """
    def reactUntilYouCan(s) do
        cond do
            s == singleReaction(s) -> s
            true -> reactUntilYouCan(singleReaction(s))
        end
    end
    @doc """
    Distinct lowercased chars in a string
    """
    def distinctChars(s) do
        s |> String.downcase |> to_charlist |> Enum.uniq
    end

    def eliminateChar(s, c) do
        s
        |> String.replace(String.downcase(to_string([c])), "")
        |> String.replace(String.upcase(to_string([c])), "")
    end

    def measureWithout(s, c) do
        IO.puts "measuring without #{to_string([c])}"
        result = eliminateChar(s, c)
        |> reactUntilYouCan
        |> String.length
        IO.puts "length: #{result}"
        result
    end
end


question = String.trim(File.read!("day05.txt"))
distinct_chars = PolymerReaction.distinctChars(question)
IO.puts "found these distinct characters #{distinct_chars}"
distinct_chars
|> Enum.map(&(PolymerReaction.measureWithout(question, &1)))
|> Enum.min
|> IO.puts