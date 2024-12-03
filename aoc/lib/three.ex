defmodule Three do
  @moduledoc """
  Day three
  """

  alias Utils

  @spec part_one :: :ok
  def part_one do
    result = 3 |> Utils.input!() |> Enum.to_list() |> Enum.map(&multiply(&1)) |> Enum.sum()

    IO.puts("Result #{result}")
  end

  @spec part_two :: :ok
  def part_two do
    lines = 3 |> Utils.input!() |> Enum.to_list()

    [donts, dos, numbers, _] = Enum.reduce(lines, [[], [], [], 0], &create_coords(&1, &2))

    donts = normalize_coords(donts)
    dos = normalize_coords(dos)

    result = numbers |> Enum.map(&maybe_add_with_instructions(&1, donts, dos)) |> Enum.sum()

    IO.puts("Result #{result}")
  end

  @spec multiply(binary()) :: non_neg_integer()
  defp multiply(line) do
    ~r/mul\((?<first>[0-9]{1,3}),(?<second>[0-9]{1,3})\)/
    |> Regex.scan(line)
    |> Enum.map(&multiply_match(&1))
    |> Enum.sum()
  end

  @spec create_coords(binary(), [[tuple()], [tuple()], [tuple()], non_neg_integer()]) :: list()
  defp create_coords(line, [acc_donts, acc_dos, acc_numbers, line_number]) do
    donts =
      ~r/don't\(\)/
      |> Regex.scan(line, return: :index)
      |> Enum.map(&{&1 |> Enum.at(0) |> elem(0), line_number})

    dos =
      ~r/do\(\)/
      |> Regex.scan(line, return: :index)
      |> Enum.map(&{&1 |> Enum.at(0) |> elem(0), line_number})

    number_positions =
      Regex.scan(~r/mul\((?<first>[0-9]{1,3}),(?<second>[0-9]{1,3})\)/, line, return: :index)

    numbers =
      Enum.map(number_positions, fn [{position, _}, {left, left_chars}, {right, right_chars}] ->
        left = line |> String.slice(left, left_chars) |> String.to_integer()
        right = line |> String.slice(right, right_chars) |> String.to_integer()
        {position, left * right, line_number}
      end)

    [acc_donts ++ donts, acc_dos ++ dos, acc_numbers ++ numbers, line_number + 1]
  end

  @spec normalize_coords([tuple]) :: map
  defp normalize_coords(instructions) do
    Enum.reduce(instructions, %{}, fn {position, line_number}, acc ->
      Map.update(acc, line_number, [position], &(&1 ++ [position]))
    end)
  end

  @spec maybe_add_with_instructions(
          {non_neg_integer(), non_neg_integer(), non_neg_integer()},
          map,
          map
        ) :: non_neg_integer()
  defp maybe_add_with_instructions({position, amount, line}, donts, dos) do
    last_dont =
      donts
      |> Map.get(line, [])
      |> Enum.filter(&(&1 < position))
      |> Enum.at(-1)

    last_do = dos |> Map.get(line, []) |> Enum.filter(&(&1 < position)) |> Enum.at(-1)

    cond do
      line == 0 and is_nil(last_dont) ->
        amount

      !is_nil(last_do) and !is_nil(last_dont) ->
        if last_do > last_dont, do: amount, else: 0

      is_nil(last_dont) and !is_nil(last_do) ->
        amount

      !is_nil(last_dont) and is_nil(last_do) ->
        0

      is_nil(last_do) and is_nil(last_dont) ->
        last_dont = donts |> Map.get(line - 1, []) |> Enum.at(-1)
        last_do = dos |> Map.get(line - 1, []) |> Enum.at(-1)
        if last_do > last_dont, do: amount, else: 0
    end
  end

  @spec multiply_match([binary()]) :: non_neg_integer()
  defp multiply_match([_full_match, left, right]),
    do: String.to_integer(left) * String.to_integer(right)
end
