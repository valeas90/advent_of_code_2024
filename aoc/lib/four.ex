defmodule Four do
  @moduledoc """
  Day four
  """

  alias Utils

  @word "XMAS"
  @grid_size 140

  @spec part_one :: :ok
  def part_one do
    coords = 4 |> Utils.input!() |> Enum.with_index() |> Enum.reduce(%{}, &create_coords(&1, &2))
    IO.puts("Result #{count_words(coords)}")
  end

  @spec part_two :: :ok
  def part_two do
    coords = 4 |> Utils.input!() |> Enum.with_index() |> Enum.reduce(%{}, &create_coords(&1, &2))
    IO.puts("Result #{count_crosses(coords)}")
  end

  @spec create_coords(tuple(), map) :: map
  defp create_coords({line, number}, coords) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(coords, fn {letter, index}, acc -> Map.put(acc, {number, index}, letter) end)
  end

  @spec count_words(map) :: non_neg_integer()
  defp count_words(coords) do
    Enum.reduce(0..(@grid_size - 1), 0, fn x_axis, acc ->
      0..(@grid_size - 1)
      |> Enum.map(&count_words({x_axis, &1}, coords))
      |> Enum.sum()
      |> Kernel.then(&(&1 + acc))
    end)
  end

  @spec count_words(tuple, map) :: non_neg_integer()
  defp count_words({x, y}, coords) do
    get_vectors_part_one()
    |> Enum.map(fn vectors -> check_word(vectors, {x, y}, coords) end)
    |> Enum.sum()
  end

  @spec count_crosses(map) :: non_neg_integer()
  defp count_crosses(coords) do
    Enum.reduce(0..(@grid_size - 1), 0, fn x_axis, acc ->
      0..(@grid_size - 1)
      |> Enum.map(&count_crosses({x_axis, &1}, coords))
      |> Enum.sum()
      |> Kernel.then(&(&1 + acc))
    end)
  end

  @spec count_crosses(tuple, map) :: non_neg_integer()
  defp count_crosses({x, y}, coords) do
    [left, right] = get_vectors_part_two()
    left = Enum.map_join(left, fn {x_axis, y_axis} -> Map.get(coords, {x + x_axis, y + y_axis}, nil) end)
    right = Enum.map_join(right, fn {x_axis, y_axis} -> Map.get(coords, {x + x_axis, y + y_axis}, nil) end)

    if left in ["MAS", "SAM"] and right in ["MAS", "SAM"], do: 1, else: 0
  end

  @spec check_word([tuple], {non_neg_integer(), non_neg_integer()}, map) :: non_neg_integer()
  defp check_word(vectors, {x, y}, coords) do
    vectors
    |> Enum.map_join(fn {x_axis, y_axis} -> Map.get(coords, {x + x_axis, y + y_axis}, nil) end)
    |> Kernel.then(fn word -> word == @word end)
    |> Kernel.then(fn match? -> if match?, do: 1, else: 0 end)
  end

  @spec get_vectors_part_one :: [list()]
  defp get_vectors_part_one do
    # XMAS is a 4 letter word
    # If we are in {4,4}, we need to check
    #  {4,4}, {4,5}, {4,6}, {4,7} for the horizontal rightwards
    #  {4,4}, {4,3}, {4,2}, {4,1} for the horizontal backward
    #  {4,4}, {3,4}, {2,4}, {1,4} for the vertical upward
    #  {4,4}, {5,4}, {6,4}, {7,4} for the vertical downward
    #  {4,4}, {3,3}, {2,2}, {1,1} for the diagonal left-top
    #  {4,4}, {3,5}, {2,6}, {1,7} for the diagonal right-top
    #  {4,4}, {5,3}, {6,2}, {7,1} for the diagonal left-bottom
    #  {4,4}, {5,5}, {6,6}, {7,7} for the diagonal right-bottom
    [
      [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
      [{0, 0}, {0, -1}, {0, -2}, {0, -3}],
      [{0, 0}, {-1, 0}, {-2, 0}, {-3, 0}],
      [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
      [{0, 0}, {-1, -1}, {-2, -2}, {-3, -3}],
      [{0, 0}, {-1, 1}, {-2, 2}, {-3, 3}],
      [{0, 0}, {1, -1}, {2, -2}, {3, -3}],
      [{0, 0}, {1, 1}, {2, 2}, {3, 3}]
    ]
  end

  @spec get_vectors_part_two :: [list()]
  defp get_vectors_part_two do
    # In the center of the cross we have a letter `A`
    # If we are in {4,4}
    # We check {3,3} and {5,5} and see if any of the two combinations is `MAS` or `SAM`
    # We check {5,3} and {3,5} and see if any of the two combinations is `MAS` or `SAM`
    # If BOTH are true, we match
    [
      [{-1, -1}, {0, 0}, {1, 1}],
      [{1, -1}, {0, 0}, {-1, 1}]
    ]
  end
end
