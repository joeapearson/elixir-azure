defmodule Azure.Storage.BlobTest do
  @moduledoc false

  use ExUnit.Case, async: true

  @moduletag :external

  alias Azure.Storage.{Blob, BlobProperties, Container}

  import Azure.Factory

  defp header(headers, key) do
    case List.keyfind(headers, key, 0) do
      nil -> nil
      {^key, value} -> value
    end
  end

  setup do
    storage_context = build(:storage_context)
    container_context = storage_context |> Container.new("blob-test")

    {:ok, _response} = Container.ensure_container(container_context)

    %{storage_context: storage_context, container_context: container_context}
  end

  describe "blob properties" do
    setup %{container_context: container_context} do
      blob_name = "my_blob"
      blob_data = "my_blob_data"
      blob = container_context |> Blob.new(blob_name)

      blob |> Blob.delete_blob()
      {:ok, %{status: 201}} = blob |> Blob.put_blob(blob_data)

      %{blob: blob}
    end

    test "gets blob properties", %{blob: blob} do
      assert {:ok, %{status: 200, properties: %BlobProperties{}}} =
               blob |> Blob.get_blob_properties()
    end

    test "set blob properties", %{blob: blob} do
      content_type = "x-my-new-content-type"

      {:ok, %{status: 200, properties: blob_properties}} =
               blob |> Blob.get_blob_properties()

      refute blob_properties.content_type == content_type

      blob_properties = blob_properties |> Map.put(:content_type, content_type)

      assert {:ok, %{ status: 200}} = blob |> Blob.set_blob_properties(blob_properties)

      assert {:ok, %{ status: 200, properties: blob_properties }} = blob |> Blob.get_blob_properties()

      assert blob_properties.content_type == content_type
    end
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
    test "puts a blob from a URL", %{
      container_context: container_context,
      storage_context: storage_context
    } do
      blob_name = "blob_from_url.txt"

      url =
        "https://raw.githubusercontent.com/joeapearson/elixir-azure/main/test/storage/#{blob_name}"

      %{headers: source_headers} = Tesla.head!(url)
      source_content_type = header(source_headers, "content-type")

      expected_contents =
        if storage_context.is_development_factory do
          # Storage emulator doesn't yet support put blob from URL API and always returns an empty
          # blob
          ""
        else
          File.read!(Path.expand(blob_name, __DIR__))
        end

      blob = container_context |> Blob.new(blob_name)

      assert {:ok, %{status: 201}} = blob |> Blob.put_blob_from_url(url)

      assert {:ok, %{status: 200, body: destination_body, headers: destination_headers}} =
               blob |> Blob.get_blob()

      assert destination_body == expected_contents

      destination_content_type = header(destination_headers, "content-type")

      assert is_binary(source_content_type)

      assert source_content_type == destination_content_type
    end
  end
end
