defmodule Two do
  @moduledoc """
  Day two
  """

  alias Utils

  @spec part_one :: :ok
  def part_one do
    input = 2 |> Utils.input!() |> Enum.to_list() |> Enum.map(&parse_line(&1))

    result =
      input
      |> Enum.map(&check_line(&1, :not_started))
      |> Enum.filter(& &1)
      |> Enum.count()

    IO.puts("Result #{result}")
  end

  @spec part_two :: :ok
  def part_two do
    input = 2 |> Utils.input!() |> Enum.to_list() |> Enum.map(&parse_line(&1))

    result =
      input
      |> Enum.map(&check_with_tolerance(&1))
      |> Enum.filter(& &1)
      |> Enum.count()

    IO.puts("Result #{result}")
  end

  @spec check_line([non_neg_integer()], atom()) :: boolean()
  defp check_line([_last], _), do: true

  defp check_line([first | [second | _more] = rest], previous_trend) do
    trend =
      case first - second do
        diff when diff >= 4 or diff <= -4 or diff == 0 -> nil
        diff when diff >= 1 -> :decreasing
        diff when diff <= -1 -> :increasing
      end

    if is_nil(trend) or previous_trend not in [:not_started, trend] do
      false
    else
      check_line(rest, trend)
    end
  end

  @spec check_with_tolerance([non_neg_integer()]) :: boolean()
  defp check_with_tolerance(numbers) do
    indexes = 0..(Enum.count(numbers) - 1)
    variants = Enum.map(indexes, &List.delete_at(numbers, &1))

    variants
    |> Enum.map(&check_line(&1, :not_started))
    |> Enum.any?(&(&1 == true))
  end

  @spec parse_line(binary) :: boolean()
  defp parse_line(line), do: line |> String.split() |> Enum.map(&String.to_integer/1)
end
