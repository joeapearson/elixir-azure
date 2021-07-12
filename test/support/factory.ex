defmodule Azure.Factory do
  @moduledoc """
  Provides test data factories.
  """

  use ExMachina

  def connection_string_factory(attrs) do
    [
      [
        "DefaultEndpointsProtocol",
        Map.get(attrs, :default_endpoints_protocol, sequence("default_endpoints_protocol"))
      ],
      ["AccountName", Map.get(attrs, :account_name, sequence("account_name"))],
      ["AccountKey", Map.get(attrs, :account_key, sequence("account_key"))],
      ["EndpointSuffix", Map.get(attrs, :endpoint_suffix, sequence("endpoint_suffix"))]
    ]
    |> Enum.map(fn kv -> Enum.join(kv, "=") end)
    |> Enum.join(";")
  end

  def storage_context_factory do
    Azure.Storage.development_factory()
  end

  def value_factory(_attrs) do
    sequence("value")
  end
end
