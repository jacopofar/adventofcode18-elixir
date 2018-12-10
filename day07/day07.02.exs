defmodule YoDAG do
    @moduledoc """
    Day 7, exercise 2.
    Same as exercise 1, but now there are 5 workers and task can run in parallel
    The duration of a task is A=61, B=62, ... Z=86
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
    Get the next tasks to execute, [] if none.
    now_running is a set of tasks that are to be ignored but not yet done
    """
    def next_tasks(done_set, dag_list, existing, how_many, now_running) do
        existing
        # ignore tasks already executed
        |> Enum.filter(fn (e) -> !MapSet.member?(done_set, e) end)
        # do not return task already running
        |> Enum.filter(fn (e) -> !MapSet.member?(now_running, e) end)
        # ignore tasks not ready to be executed
        |> Enum.filter(fn (e) -> can_run?(dag_list, e, done_set) end)
        |> Enum.take(how_many)
    end

    @doc """
    Get the task duration
    """
    def duration(task) do
        Enum.at(task, 0) - 4
    end

    def total_time(done_set, dag_list, existing) do
        total_time(done_set, dag_list, existing, %{}, 0)
    end

    defp total_time(done_set, dag_list, existing, running_tasks, elapsed) do
        IO.inspect {"second: #{elapsed}", "done:", done_set, "running:", running_tasks}
        updated_workers = running_tasks
            |> Enum.map(&({elem(&1, 0), elem(&1, 1) - 1}))


        still_running_workers = updated_workers
            |> Enum.filter(fn({_, time}) -> time != 0 end)
            |> Map.new

        finished_now = updated_workers
            |> Enum.filter(fn({_, time}) -> time == 0 end)
            |> Enum.map(fn({task, _}) -> task end)

        new_done_set = MapSet.union(done_set, MapSet.new(finished_now))

        cond do
            Enum.count(done_set) == Enum.count(existing) ->
                elapsed - 1
            true ->
                additional_workers = next_tasks(
                    new_done_set,
                    dag_list,
                    existing, 5 - Enum.count(still_running_workers),
                    MapSet.new(Map.keys(still_running_workers)))
                        |> Enum.map(&({&1, duration(&1)}))
                new_workers = Map.merge(
                    still_running_workers,
                    Map.new(additional_workers))
                total_time(new_done_set, dag_list, existing, new_workers, elapsed + 1)
        end
    end
end

dag = YoDAG.dag_from_file!("day07.txt")
all_tasks = YoDAG.allTasks(dag)

IO.puts "Total time in seconds: #{YoDAG.total_time(MapSet.new(), dag, all_tasks)}"
