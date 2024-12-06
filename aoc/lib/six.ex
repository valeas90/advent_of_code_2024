defmodule Six do
  @moduledoc """
  Day six
  """

  alias Utils

  @size 130
  @first_move {0, -1}
  @move_limit 10_000

  @spec part_one :: :ok
  def part_one do
    grid = get_grid()
    guard = find_guard(grid)
    initial_visited_grid = get_initial_visited_grid(guard)
    result = next_step(guard, grid, @first_move, initial_visited_grid)
    IO.puts("Result #{result}")
  end

  @spec part_two :: :ok
  def part_two do
    grid = get_grid()
    guard = find_guard(grid)
    blockable_positions = get_blockable_positions(grid)

    loopable_positions =
      for blocked_position <- blockable_positions, reduce: 0 do
        acc ->
          blocked_grid = update_grid(grid, blocked_position)
          if trapped_guard?(guard, blocked_grid, @first_move), do: acc + 1, else: acc
      end

    IO.puts("Result #{loopable_positions}")
  end

  @spec get_grid :: map
  def get_grid do
    6
    |> Utils.input!()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, yaxis}, acc ->
      characters = line |> String.graphemes() |> Enum.with_index()
      Enum.reduce(characters, acc, fn {character, xaxis}, acc -> Map.put(acc, {xaxis, yaxis}, character) end)
    end)
  end

  @spec find_guard(map) :: {non_neg_integer(), non_neg_integer()}
  def find_guard(grid) do
    guard =
      for x <- 0..(@size - 1), y <- 0..(@size - 1), reduce: [] do
        acc -> if Map.get(grid, {x, y}) == "^", do: acc ++ [{x, y}], else: acc
      end

    Enum.at(guard, 0)
  end

  @spec next_step({non_neg_integer(), non_neg_integer()}, map, {non_neg_integer(), non_neg_integer()}, map) :: map
  defp next_step(here, grid, move_vector, visited) do
    next = {elem(here, 0) + elem(move_vector, 0), elem(here, 1) + elem(move_vector, 1)}

    case Map.get(grid, next) do
      nil ->
        visited_updated = Map.put(visited, here, 1)
        count_visited(visited_updated)

      "#" ->
        new_vector = change_vector(move_vector)
        next_step(here, grid, new_vector, visited)

      _ ->
        visited_updated = Map.put(visited, here, 1)
        next_step(next, grid, move_vector, visited_updated)
    end
  end

  @spec trapped_guard?({non_neg_integer(), non_neg_integer()}, map, tuple()) :: boolean()
  def trapped_guard?(initial_position, grid, move_vector) do
    next_step_with_limit(initial_position, grid, move_vector, @move_limit) == :trapped
  end

  @spec next_step_with_limit(tuple(), map, tuple(), non_neg_integer()) :: atom()
  defp next_step_with_limit(_here, _grid, _move_vector, 0), do: :trapped

  defp next_step_with_limit(here, grid, move_vector, remaining) do
    next = {elem(here, 0) + elem(move_vector, 0), elem(here, 1) + elem(move_vector, 1)}

    case Map.get(grid, next) do
      nil ->
        :out_of_bounds

      "#" ->
        new_vector = change_vector(move_vector)
        next_step_with_limit(here, grid, new_vector, remaining - 1)

      _ ->
        next_step_with_limit(next, grid, move_vector, remaining - 1)
    end
  end

  @spec change_vector({non_neg_integer(), non_neg_integer()}) :: {non_neg_integer(), non_neg_integer()}
  defp change_vector(vector) do
    case vector do
      {0, -1} -> {1, 0}
      {1, 0} -> {0, 1}
      {0, 1} -> {-1, 0}
      {-1, 0} -> {0, -1}
    end
  end

  @spec get_initial_visited_grid({non_neg_integer(), non_neg_integer()}) :: map
  defp get_initial_visited_grid(guard) do
    empty_grid =
      for x <- 0..(@size - 1), y <- 0..(@size - 1), reduce: %{} do
        acc -> Map.put(acc, {x, y}, 0)
      end

    Map.update(empty_grid, guard, 0, fn _ -> 1 end)
  end

  @spec update_grid(map, {non_neg_integer(), non_neg_integer()}) :: map
  defp update_grid(grid, blocked_position) do
    Map.put(grid, blocked_position, "#")
  end

  @spec get_blockable_positions(map) :: [{non_neg_integer(), non_neg_integer()}]
  defp get_blockable_positions(grid) do
    for x <- 0..(@size - 1), y <- 0..(@size - 1), reduce: [] do
      acc -> if Map.get(grid, {x, y}) == ".", do: acc ++ [{x, y}], else: acc
    end
  end

  @spec count_visited(map) :: non_neg_integer()
  defp count_visited(grid) do
    for x <- 0..(@size - 1), y <- 0..(@size - 1), reduce: 0 do
      acc -> acc + Map.get(grid, {x, y})
    end
  end

  @spec print(map) :: :ok
  def print(grid) do
    # for debugging purposes, show grid
    printable =
      for yaxis <- 0..(@size - 1) do
        for xaxis <- 0..(@size - 1) do
          Map.get(grid, {xaxis, yaxis})
        end
      end

    for line <- printable, do: IO.puts(line)
  end
end
