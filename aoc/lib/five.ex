defmodule Five do
  @moduledoc """
  Day five
  """

  alias Utils

  @spec part_one :: :ok
  def part_one do
    {instructions, updates} = 5 |> Utils.input!() |> Enum.to_list() |> Enum.reduce({[], []}, &parse_lines(&1, &2))

    order = create_ordering(instructions)
    updates = clean_updates(updates)

    result = sum_updates(order, updates)

    IO.puts("Result #{result}")
  end

  @spec part_two :: :ok
  def part_two do
    {instructions, updates} = 5 |> Utils.input!() |> Enum.to_list() |> Enum.reduce({[], []}, &parse_lines(&1, &2))

    order = create_ordering(instructions)
    updates = clean_updates(updates)

    result = fix_and_sum_wrong_updates(order, updates)

    IO.puts("Result #{result}")
  end

  @spec parse_lines(binary(), {[binary()], [binary()]}) :: {[binary()], [binary()]}
  defp parse_lines(line, {ordering, updates}) do
    ordering = if "|" in String.graphemes(line) and line != "", do: ordering ++ [line], else: ordering
    updates = if "|" not in String.graphemes(line) and line != "", do: updates ++ [line], else: updates

    {ordering, updates}
  end

  @spec create_ordering([binary()]) :: map
  defp create_ordering(order) do
    Enum.reduce(order, %{}, fn line, acc ->
      [left, right] = String.split(line, "|")
      left = String.to_integer(left)
      right = String.to_integer(right)
      Map.update(acc, left, [right], fn value -> value ++ [right] end)
    end)
  end

  defp clean_updates(updates) do
    Enum.map(updates, fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer(String.trim(&1)))
    end)
  end

  @spec sum_updates(map, [[non_neg_integer()]]) :: non_neg_integer()
  defp sum_updates(order, updates) do
    Enum.reduce(updates, 0, fn numbers, acc ->
      if valid_update?(numbers, order), do: acc + middle(numbers), else: acc
    end)
  end

  @spec fix_and_sum_wrong_updates(map, [binary()]) :: non_neg_integer()
  defp fix_and_sum_wrong_updates(order, updates) do
    Enum.reduce(updates, 0, fn numbers, acc ->
      if valid_update?(numbers, order) do
        acc
      else
        fixed_update = fix_update(numbers, order, true, 0)
        acc + middle(fixed_update)
      end
    end)
  end

  @spec valid_update?([non_neg_integer()], map) :: boolean()
  defp valid_update?(numbers, order) do
    numbers
    |> Enum.with_index()
    |> Enum.all?(fn {number, index} ->
      sublist = Enum.slice(numbers, index + 1, 50)
      good_order?(number, sublist, order)
    end)
  end

  @spec fix_update([non_neg_integer()], map, boolean(), non_neg_integer()) :: [non_neg_integer()]
  def fix_update(numbers, _order, false, _pointer), do: numbers

  def fix_update(numbers, order, _needs_fixing?, pointer) do
    current_number = Enum.at(numbers, pointer)
    sublist = Enum.slice(numbers, pointer + 1, 50)

    {subnumber, subindex} =
      Enum.find(Enum.with_index(sublist), {nil, nil}, fn {subnumber, _subindex} ->
        current_number in Map.get(order, subnumber, [])
      end)

    cond do
      is_nil(subnumber) and valid_update?(numbers, order) ->
        fix_update(numbers, order, false, pointer)

      is_nil(subnumber) and not valid_update?(numbers, order) ->
        fix_update(numbers, order, true, pointer + 1)

      true ->
        new_numbers =
          Enum.slice(numbers, 0, pointer) ++ [subnumber] ++ [current_number] ++ List.delete_at(sublist, subindex)

        fix_update(new_numbers, order, true, 0)
    end
  end

  @spec good_order?(non_neg_integer(), [non_neg_integer()], map) :: boolean()
  defp good_order?(number, sublist, order) do
    inconsistencies_found =
      Enum.map(sublist, fn check_number ->
        number in Map.get(order, check_number, [])
      end)

    inconsistencies_found |> Enum.filter(& &1) |> Enum.count() == 0
  end

  @spec middle([non_neg_integer()]) :: non_neg_integer()
  defp middle(numbers), do: Enum.at(numbers, numbers |> Enum.count() |> Integer.floor_div(2))
end
