defmodule Azure.Storage.BlobTest do
  @moduledoc false

  use ExUnit.Case, async: true

  @moduletag :external

  alias Azure.Storage.{Blob, Container}

  import Azure.Factory

  setup do
    storage_context = build(:storage_context)
    container_context = storage_context |> Container.new("my-container")

    {:ok, _response} = Container.ensure_container(container_context)

    %{storage_context: storage_context, container_context: container_context}
  end

  describe "put_blob" do
    test "puts a blob", %{container_context: container_context} do
      blob_name = "my_blob"
      blob_data = "my_blob_data"
      blob = container_context |> Blob.new(blob_name)

      assert {:ok, %{status: 201}} =
               blob
               |> Blob.put_blob(blob_data)

      assert {:ok, %{body: ^blob_data}} = blob |> Blob.get_blob()
    end
  end

  describe "put_blob_by_url" do
    test "puts a blob from a URL", %{container_context: container_context} do
      url =
        "https://raw.githubusercontent.com/joeapearson/elixir-azure/main/test/storage/blob_from_url.txt"

      blob_name = "my_blob_from_url"
      blob = container_context |> Blob.new(blob_name)

      assert {:ok, %{status: 201}} = blob |> Blob.put_blob_from_url(url)

      # Storage emulator returns an empty blob but if switch to a true storage account then this
      # works.
      assert {:ok, %{status: 200}} = blob |> Blob.get_blob()
    end
  end
end
