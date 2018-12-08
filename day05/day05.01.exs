defmodule PolymerReaction do
    @moduledoc """
    Day 5, exercise 1.
    Eliminate adiacent characters which are the same except for the case.
    Only latin alphabet, no worries for that, but has to be done iteratively
    since eliminating two characters can make other two come close and be in turn
    eliminated.
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
end


question = String.trim(File.read!("day05.txt"))
IO.puts "Before reaction, length is #{String.length(question)}"
IO.puts "After reaction, length is #{String.length(PolymerReaction.reactUntilYouCan(question))}"