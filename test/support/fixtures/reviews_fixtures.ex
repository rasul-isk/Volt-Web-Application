defmodule Volt.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Volt.Reviews` context.
  """

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        body: "some body",
        rating: 42
      })
      |> Volt.Reviews.create_review()

    review
  end
end
