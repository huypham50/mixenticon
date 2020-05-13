defmodule Mixenticon do
  @moduledoc """
  Documentation for `Mixenticon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Mixenticon.hello()
      :world

  """
  def hello do
    :world
  end

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  def draw_image(%Mixenticon.Image{pixel_map: pixel_map, color: color}) do
    image = :egd.create(280, 280)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def build_pixel_map(%Mixenticon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        horizontal = rem(index, 5) * 50 + 15
        vertical = div(index, 5) * 50 + 15

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Mixenticon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Mixenticon.Image{grid: grid} = image) do
    filtered_grid = Enum.filter(grid, fn {code, _index} -> rem(code, 2) === 0 end)

    %Mixenticon.Image{image | grid: filtered_grid}
  end

  def build_grid(%Mixenticon.Image{hex: hex} = image) do
    chunks =
      hex
      |> Enum.chunk_every(3)
      |> List.pop_at(-1)

    {_, unpopped} = chunks

    grid =
      unpopped
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Mixenticon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def pick_color(%Mixenticon.Image{hex: [r, g, b | _tail]} = image) do
    %Mixenticon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Mixenticon.Image{hex: hex}
  end
end
