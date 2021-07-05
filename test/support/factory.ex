defmodule Azure.Factory do
  @moduledoc """
  Provides test data factories.
  """

  use ExMachina

  def value_factory(_attrs) do
    sequence("value")
  end

  def storage_context_factory do
    Azure.Storage.development_factory()
  end
end
