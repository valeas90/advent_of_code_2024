defmodule Eight do
  @moduledoc """
  Day eight
  """

  alias Utils

  @size 50

  @spec run(function()) :: :ok
  def run(finder_function) do
    lines = 8 |> Utils.input!() |> Enum.to_list()
    antennas = get_antennas(lines)
    initial_antinodes = empty_grid()

    antinodes_grid =
      for antenna_identifier <- Map.keys(antennas), reduce: initial_antinodes do
        facc ->
          antenna_coords = Map.get(antennas, antenna_identifier)
          pairs = get_pairs(antenna_coords)

          for pair <- pairs, reduce: facc do
            acc ->
              pair
              |> finder_function.([])
              |> Enum.reject(fn {x, y} -> x >= @size or x < 0 or y >= @size or y < 0 end)
              |> update_antinodes_grid(acc)
          end
      end

    IO.puts("Result #{count_antinodes(antinodes_grid)}")
  end

  @spec part_one :: :ok
  def part_one, do: run(&find_antinodes/2)

  @spec part_two :: :ok
  def part_two, do: run(&maybe_find_antinodes_part_two/2)

  @spec get_pairs(list()) :: list()
  def get_pairs(antenna_coords) do
    pairs =
      for {first, findex} <- Enum.with_index(antenna_coords), reduce: [] do
        acc ->
          for {second, sindex} <- Enum.with_index(antenna_coords), reduce: acc do
            acc -> if findex == sindex, do: acc, else: acc ++ [[first, second]]
          end
      end

    pairs |> Enum.map(&List.keysort(&1, 0)) |> Enum.into(MapSet.new()) |> Enum.into([])
  end

  @spec find_antinodes([tuple()], any()) :: [tuple()]
  defp find_antinodes(pair, _acc \\ []) do
    [{fx, fy}, {sx, sy}] = List.keysort(pair, 0)
    distance_x = abs(fx - sx)
    distance_y = abs(fy - sy)

    if (fx > sx and fy > sy) or (fx < sx and fy < sy) do
      [{sx + distance_x, sy + distance_y}, {fx - distance_x, fy - distance_y}]
    else
      [{fx - distance_x, fy + distance_y}, {sx + distance_x, sy - distance_y}]
    end
  end

  @spec maybe_find_antinodes_part_two([tuple()], [tuple()]) :: [tuple()]
  defp maybe_find_antinodes_part_two([{x, y}, {xx, yy}] = pair, acc) do
    cond do
      Enum.any?([x, xx, y, yy], &(&1 < 0 or &1 >= @size)) -> []
      pair in acc -> []
      true -> find_antinodes_part_two(pair, acc)
    end
  end

  @spec find_antinodes_part_two([tuple()], list()) :: [tuple()]
  defp find_antinodes_part_two(pair, acc) do
    antinodes = find_antinodes(pair)
    acc = acc ++ [pair] ++ [antinodes]
    {left, right} = (pair ++ antinodes) |> List.keysort(0) |> Enum.split(2)
    result = acc ++ maybe_find_antinodes_part_two(left, acc) ++ maybe_find_antinodes_part_two(right, acc)
    result |> List.flatten() |> List.keysort(0) |> Enum.into(MapSet.new()) |> Enum.into([])
  end

  @spec update_antinodes_grid([tuple()], map) :: map
  defp update_antinodes_grid(antinodes, grid) do
    Enum.reduce(antinodes, grid, fn antinode, acc -> Map.put(acc, antinode, "#") end)
  end

  @spec count_antinodes(map) :: non_neg_integer()
  defp count_antinodes(grid), do: grid |> Map.values() |> Enum.filter(&(&1 == "#")) |> Enum.count()

  @spec get_antennas([binary()]) :: map
  defp get_antennas(lines) do
    for {line, yaxis} <- Enum.with_index(lines), reduce: %{} do
      antennas ->
        characters = line |> String.graphemes() |> Enum.with_index()

        for {character, xaxis} <- characters, reduce: antennas do
          antennas ->
            if character == "." do
              antennas
            else
              Map.update(antennas, character, [{xaxis, yaxis}], &(&1 ++ [{xaxis, yaxis}]))
            end
        end
    end
  end

  @spec empty_grid :: map
  defp empty_grid do
    for x <- 0..(@size - 1), y <- 0..(@size - 1), reduce: %{} do
      acc -> Map.put(acc, {x, y}, ".")
    end
  end
end
