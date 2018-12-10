defmodule YoDAG do
    @moduledoc """
    Day 7, exercise 1.
    Given a DAG where each node is an English uppercase letter, give a task sequence
    compatible with it and selecting the lowest (lexicographically) letter
    when multiple tasks are possible.
    """
    @doc """
    Parse a DAG dependency description and give it as a tuple of decimal values
    e.g. "Step M must be finished before step Z can begin."
    becomes {77, 90} (77 is the Unicode decimal for M, 90 is Z)
    """
    def parseDependency(s) do
        p = Regex.split(~r" ", s)
        first = to_charlist(Enum.at(p, 1))
        then = to_charlist(Enum.at(p, 7))
        {first, then}
    end

    @doc """
    Enumerate all the existing tasks from the DAG, without duplicates and
    sorted in ascending order
    """
    def allTasks(dag_edges) do
    dag_edges
        |> Enum.flat_map(fn ({first, then}) -> [first, then] end)
        |> Enum.uniq
        |> Enum.sort
    end

    def dag_from_file!(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&parseDependency/1)
        |> Enum.into([])
    end

    @doc """
    Checks if all the dependencies are satisfied for a task
    """
    def can_run?(dag, task, done_set) do
        !(dag
        |> Enum.any?(fn({first, then}) ->
            then == task and !MapSet.member?(done_set, first) end))
    end

    @doc """
    Get the next task to execute, if any
    """
    def next_task(done_set, dag_list, existing) do
        existing
        # ignore tasks already executed
        |> Enum.filter(fn (e) -> !MapSet.member?(done_set, e) end)
        # ignore tasks not ready to be executed
        |> Enum.filter(fn (e) -> can_run?(dag_list, e, done_set) end)
        |> Enum.at(0)
    end

    def complete_plan(done_set, dag_list, existing) do
        cond do
            Enum.count(done_set) == Enum.count(existing) -> ""
            true ->
                next_step = next_task(done_set, dag_list, existing)
                (to_string([next_step])
                <> complete_plan(MapSet.put(done_set, next_step),
                                 dag_list,
                                 existing))
        end
    end
end

dag = YoDAG.dag_from_file!("day07.txt")
all_tasks = YoDAG.allTasks(dag)

IO.inspect YoDAG.complete_plan(MapSet.new(), dag, all_tasks)
