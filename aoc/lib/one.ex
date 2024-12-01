defmodule One do
  @moduledoc """
  Day one
  """

  alias Utils

  @spec part_one :: :ok
  def part_one do
    input = 1 |> Utils.input!() |> Enum.to_list()

    {lefts, rights} =
      Enum.reduce(input, {[], []}, fn line, {lefts, rights} ->
        [left | [right]] = String.split(line, "   ")
        {lefts ++ [String.to_integer(left)], rights ++ [String.to_integer(right)]}
      end)

    pairs = Enum.zip(Enum.sort(lefts), Enum.sort(rights))

    result =
      Enum.reduce(pairs, 0, fn {left, right}, acc -> acc + max(right, left) - min(right, left) end)

    IO.puts("Result #{result}")
  end

  @spec part_two :: :ok
  def part_two do
    input = 1 |> Utils.input!() |> Enum.to_list()

    {lefts, rights} =
      Enum.reduce(input, {[], []}, fn line, {lefts, rights} ->
        [left | [right]] = String.split(line, "   ")
        {lefts ++ [String.to_integer(left)], rights ++ [String.to_integer(right)]}
      end)

    repeats =
      Enum.reduce(rights, %{}, fn number, acc ->
        Map.update(acc, number, 1, fn _ -> acc[number] + 1 end)
      end)

    result =
      Enum.reduce(lefts, 0, fn number, acc ->
        factor = if is_nil(repeats[number]), do: 0, else: repeats[number]
        acc + factor * number
      end)

    IO.puts("Result #{result}")
  end
end
