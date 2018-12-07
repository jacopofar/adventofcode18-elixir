defmodule FindSleepyGuard do
    @moduledoc """
    Day 4, exercise 1.
    Get a list of guards and events (sleep and awake)

    [1518-09-16 00:04] Guard #3323 begins shift
    [1518-10-07 00:34] falls asleep
    [1518-08-26 00:47] wakes up

    A guard may have no events, or multiple sleep and awake

    Calculate which guard sleeps the most, and in which minute.
    """
    defp guardId(s) do
        {minute, _} = Regex.split(~r" |#", s) |>  Enum.at(4) |> Integer.parse
        minute
    end

    defp minute(s) do
        {minute, _} = Integer.parse(Enum.at(Regex.split(~r"]|:", s), 1))
        minute
    end
    @doc """
    update the state according to the line.

    A sort of FSM but along with the guard state we have the time of the sleep
    and the partial sum of all sleep times seen until now
    """
    def processLine(event, {guard_id, sleep_minute, sleep_map}) do
        cond do
         event =~ "begins shift" ->
            this_guard = guardId(event)
            # initialize the 60 minutes list to 0 if not present
            new_sleep_map = Map.put(sleep_map, this_guard, Map.get(
                sleep_map, this_guard, List.duplicate(0, 60)))
            {this_guard, nil, new_sleep_map}
        event =~ "wakes up" and (guard_id == nil or sleep_minute == nil)->
            # nothing, this event is spurious
            {guard_id, sleep_minute, sleep_map}
        event =~ "wakes up" and not (guard_id == nil or sleep_minute == nil)->
            awake_minute = minute(event)
            new_guard_sleep = Enum.with_index(sleep_map[guard_id])
            |> Enum.map(fn ({count, index}) ->
                count +
                    if index < awake_minute and index >= sleep_minute do
                        1
                    else
                        0
                    end
                end)

            {guard_id, nil, Map.put(sleep_map, guard_id, new_guard_sleep)}
        event =~ "falls asleep" and (guard_id == nil or sleep_minute != nil)->
            # nothing, this event is spurious
            {guard_id, sleep_minute, sleep_map}
        event =~ "falls asleep" and not(guard_id == nil or sleep_minute != nil) ->
            {guard_id, minute(event), sleep_map}
        end
    end

    def processFile(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Enum.to_list
        |> Enum.sort
        |> Stream.transform({nil, nil, %{}}, fn (line, state) ->
            {guard_id, sleep_minute, sleep_map} = processLine(line, state)
            {[sleep_map], {guard_id, sleep_minute, sleep_map}}
        end)
    end

    def mostSleepyGuard(sleep_map) do
        Enum.max_by(sleep_map, fn {_, v} ->
            Enum.sum v
        end)
    end
end

{sleepy_guard_id, sleepy_guard_sleep_frequency} = FindSleepyGuard.processFile("day04.txt")
    |> Enum.to_list
    |> List.last
    |> FindSleepyGuard.mostSleepyGuard
{_, sleepiest_minute} = sleepy_guard_sleep_frequency
    |> Enum.with_index
    |> Enum.max_by(fn {v, _} -> v end)

IO.puts "The most sleepy guard is #{sleepy_guard_id} and sleeps most at #{sleepiest_minute}, so solution is #{sleepy_guard_id * sleepiest_minute}"
