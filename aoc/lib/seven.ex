defmodule Seven do
  @moduledoc """
  Day seven

  Very interesting read to understand how permutations are calculated
  https://medium.com/@c3doornb/using-different-number-bases-to-display-unique-permutations-caaf8c57a6f3
  """

  alias Utils

  @ops_part_one 2
  @ops_part_two 3

  @spec part_one :: :ok
  def part_one, do: run(@ops_part_one)

  @spec part_two :: :ok
  def part_two, do: run(@ops_part_two)

  @spec run(non_neg_integer()) :: :ok
  def run(amount_of_different_operations) do
    lines = 7 |> Utils.input!() |> Enum.to_list() |> Enum.map(&parse_line/1)

    result =
      for {end_number, numbers} <- lines, reduce: 0 do
        acc ->
          permutations = get_permutations(numbers, amount_of_different_operations)
          if valid_line?(end_number, numbers, permutations), do: acc + end_number, else: acc
      end

    IO.puts("Result #{result}")
  end

  @spec parse_line(binary()) :: {non_neg_integer(), [non_neg_integer()]}
  defp parse_line(line) do
    [left, right] = line |> String.split(":") |> Enum.map(&String.trim/1)
    numbers = right |> String.split(" ") |> Enum.map(&String.to_integer/1)
    {String.to_integer(left), numbers}
  end

  @spec get_permutations([non_neg_integer()], non_neg_integer()) :: [binary()]
  defp get_permutations(numbers, ops) do
    max_permutations = ops |> :math.pow(Enum.count(numbers) - 1) |> round() |> then(&(&1 - 1))
    padding = max_permutations |> transform_base(ops) |> String.length()

    for permutation <- 0..max_permutations do
      permutation
      |> Integer.digits(ops)
      |> Enum.map_join(&Integer.to_string/1)
      |> String.pad_leading(padding, "0")
      |> String.replace("0", "+")
      |> String.replace("1", "*")
      |> String.replace("2", "|")
      |> String.graphemes()
      |> Enum.into([])
    end
  end

  @spec transform_base(non_neg_integer(), non_neg_integer()) :: binary()
  defp transform_base(number, ops), do: number |> Integer.digits(ops) |> Enum.map_join(&Integer.to_string/1)

  @spec valid_line?(non_neg_integer(), [non_neg_integer()], [[binary()]]) :: boolean()
  defp valid_line?(result, numbers, permutations) do
    found? = Enum.find(permutations, nil, &operate_and_check(result, numbers, &1))
    !is_nil(found?)
  end

  @spec operate_and_check(non_neg_integer(), [non_neg_integer()], [binary()]) :: boolean()
  def operate_and_check(end_number, numbers, operations) do
    {[initial_number], more_numbers} = Enum.split(numbers, 1)
    result = operate(initial_number, more_numbers, operations)
    result == end_number
  end

  @spec operate(non_neg_integer(), [non_neg_integer()], [binary()]) :: non_neg_integer()
  defp operate(current_number, [], []), do: current_number

  defp operate(current_number, [number | more_numbers], [current_operation | more_operations]) do
    result = math_operation(current_operation, current_number, number)
    operate(result, more_numbers, more_operations)
  end

  @spec math_operation(binary(), non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  defp math_operation("+", a, b), do: Kernel.+(a, b)
  defp math_operation("*", a, b), do: Kernel.*(a, b)

  defp math_operation("|", a, b) do
    concat = Integer.to_string(a) <> Integer.to_string(b)
    String.to_integer(concat)
  end
end
