defmodule Utils do
  @moduledoc """
  Some utility functions
  """

  @inputs_path "/home/jhon/projects/advent_of_code_2024/aoc/inputs/"

  @spec lines(binary) :: Enum.t()
  def lines(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  @spec input!(non_neg_integer) :: Enum.t()
  def input!(day) when is_integer(day) do
    check_input(day)
    lines(@inputs_path <> "day_#{day}.txt")
  end

  defp check_input(day) when day < 1 and day > 25 do
    raise ArgumentError, message: "Allowed values are between 1 and 25 included"
  end

  defp check_input(_day), do: :ok
end
