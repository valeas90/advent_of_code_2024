defmodule Nine do
  @moduledoc """
  Day nine
  """

  alias Utils

  @spec part_one :: :ok
  def part_one, do: run(&compact/1)

  @spec part_two :: :ok
  def part_two, do: run(&compact_full_files/1)

  @spec run(function()) :: :ok
  defp run(compact_function) do
    nums = 9 |> Utils.input!() |> Enum.to_list() |> Enum.at(0) |> String.graphemes() |> Enum.map(&String.to_integer/1)
    represented = representation(nums)
    compacted = compact_function.(represented)
    IO.puts("Result #{checksum(compacted)}")
  end

  @spec representation([non_neg_integer()]) :: [[binary()]]
  defp representation(numbers) do
    numbers
    |> Enum.with_index()
    |> Enum.reduce([], fn {number, index}, acc ->
      if rem(index, 2) == 0 do
        identifier = index |> div(2) |> Integer.to_string()
        acc ++ [List.duplicate(identifier, number)]
      else
        acc ++ [List.duplicate(".", number)]
      end
    end)
    |> Enum.reject(&Enum.empty?/1)
  end

  @spec compact([[binary()]]) :: binary()
  defp compact(represented) do
    dots = represented |> List.flatten() |> Enum.count(&(&1 == "."))

    replacers =
      represented
      |> List.flatten()
      |> Enum.reject(&(&1 == "."))
      |> Enum.reverse()
      |> Enum.take(dots)

    {replaced, dots} =
      represented
      |> List.flatten()
      |> Enum.map_reduce(0, fn char, dots_count ->
        if char != "." do
          {char, dots_count}
        else
          {Enum.at(replacers, dots_count), dots_count + 1}
        end
      end)

    replaced
    |> Enum.split(-dots)
    |> elem(0)
  end

  @spec compact_full_files([[binary()]]) :: [binary()]
  defp compact_full_files(represented), do: do_compact(represented, [])

  @spec do_compact([[binary()]], [[binary()]]) :: [binary()]
  defp do_compact(original, blocks_cant_move) do
    reversed_element = original |> Enum.reverse() |> Enum.at(0 + Enum.count(blocks_cant_move))

    cond do
      is_nil(reversed_element) ->
        List.flatten(original)

      "." in reversed_element ->
        do_compact(original, blocks_cant_move ++ [reversed_element])

      true ->
        slots = Enum.count(reversed_element)

        {_, original_index_found} =
          original
          |> Enum.take(Enum.count(original) - Enum.count(blocks_cant_move))
          |> Enum.with_index()
          |> Enum.find({nil, nil}, fn {original_element, _original_index} ->
            "." in original_element and Enum.count(original_element) >= slots
          end)

        if is_nil(original_index_found) do
          do_compact(original, blocks_cant_move ++ [reversed_element])
        else
          {left, [dots_being_replaced | right]} = Enum.split(original, original_index_found)
          {dots_left, maybe_dots_right} = Enum.split(dots_being_replaced, slots)

          original =
            left ++
              [reversed_element] ++
              [maybe_dots_right] ++
              List.replace_at(right, -1 - Enum.count(blocks_cant_move), dots_left)

          original = Enum.reject(original, &Enum.empty?/1)
          do_compact(original, blocks_cant_move)
        end
    end
  end

  @spec checksum([binary()]) :: non_neg_integer()
  defp checksum(compacted) do
    compacted
    |> Enum.with_index()
    |> Enum.map(fn {number, index} -> if number == ".", do: 0, else: String.to_integer(number) * index end)
    |> Enum.sum()
  end
end
