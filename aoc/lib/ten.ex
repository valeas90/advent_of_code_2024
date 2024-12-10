defmodule Ten do
  @moduledoc """
  Day ten
  """

  alias Utils

  @spec part_one :: :ok
  def part_one do
    grid = get_grid()
    inits = get_inits(grid)
    results = inits |> Enum.map(&check_trailhead(&1, grid)) |> Enum.sum()

    IO.puts("Results #{results}")
  end

  def part_two do
    grid = get_grid()
    inits = get_inits(grid)
    results = inits |> Enum.map(&check_trailhead_part_two(&1, grid)) |> Enum.sum()

    IO.puts("Results #{results}")
  end

  @spec get_grid :: map
  def get_grid do
    10
    |> Utils.input!()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, yaxis}, acc ->
      numbers = line |> String.graphemes() |> Enum.with_index()
      Enum.reduce(numbers, acc, fn {number, xaxis}, acc ->
        Map.put(acc, {xaxis, yaxis}, (if number != ".", do: String.to_integer(number), else: nil))
      end)
    end)
  end

  @spec get_inits(map) :: [{non_neg_integer(), non_neg_integer()}]
  def get_inits(grid), do: grid |> Enum.filter(fn {_key, value} -> value == 0 end) |> Enum.map(fn {key, _} -> key end)

  @spec check_trailhead({non_neg_integer(), non_neg_integer()}, map) :: non_neg_integer()
  def check_trailhead(coords, grid) do
    coords
    |> check_vectors([0], [coords], grid)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.into(MapSet.new())
    |> Enum.count()
  end

  def check_trailhead_part_two(coords, grid) do
    coords
    |> check_vectors_part_two([0], [coords], grid)
    |> List.flatten()
    |> Enum.count(& &1)
  end

  @spec check_trail_score(tuple(), tuple(), [non_neg_integer()], [tuple()], map) :: nil | tuple()
  def check_trail_score({x, y}, {mx, my}, trail, visited, grid) do
    new_position = {x + mx, y + my}
    value = Map.get(grid, new_position)
    updated_trail = trail ++ [value]
    cond do
      is_nil(value) -> nil
      new_position in visited -> nil
      updated_trail == good_trail() -> new_position
      Enum.at(updated_trail, -1) - Enum.at(updated_trail, -2) != 1 -> nil
      true -> check_vectors(new_position, trail ++ [value], visited ++ [new_position], grid)
    end
  end

  def check_trail_rating({x, y}, {mx, my}, trail, visited, grid) do
    new_position = {x + mx, y + my}
    value = Map.get(grid, new_position)
    updated_trail = trail ++ [value]
    cond do
      is_nil(value) -> false
      new_position in visited -> false
      updated_trail == good_trail() -> true
      Enum.at(updated_trail, -1) - Enum.at(updated_trail, -2) != 1 -> false
      true -> check_vectors(new_position, trail ++ [value], visited ++ [new_position], grid)
    end
  end

  @spec check_vectors({non_neg_integer(), non_neg_integer()}, [non_neg_integer()], [tuple()], map) :: [nil | tuple()]
  def check_vectors({x, y}, trail, visited, grid) do
    for vector <- vectors(), do: check_trail_score({x, y}, vector, trail, visited, grid)
  end

  def check_vectors_part_two({x, y}, trail, visited, grid) do
    for vector <- vectors(), do: check_trail_rating({x, y}, vector, trail, visited, grid)
  end

  def vectors, do: [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]

  def good_trail, do: (for x <- 0..9, do: x)
end
