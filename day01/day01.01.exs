defmodule Day01 do
    IO.puts "Copy-paste the input for day one, multiple line with a + or - and a number"
    def ask(total) do
        new_line = Integer.parse(IO.gets "")
        case new_line do
            {number, _} ->
                ask(total + number)
                _ ->
                    IO.puts total
        end
    end
end

Day01.ask(0)