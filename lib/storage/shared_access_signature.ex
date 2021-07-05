defmodule Azure.Storage.SharedAccessSignature do
  @moduledoc """
  SharedAccessSignature
  """

  alias Azure.Storage
  import Azure.Storage.Utilities, only: [add_to: 3, set_to_string: 2]

  # https://docs.microsoft.com/en-us/rest/api/storageservices/delegating-access-with-a-shared-access-signature
  # https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1
  # https://github.com/chgeuer/private_gists/blob/76db1345142d25d3359af6ce4ba7b9eef1aeb769/azure/AccountSAS/AccountSas.cs

  defstruct [
    :service_version,
    :target_scope,
    :services,
    :resource_type,
    :permissions,
    :start_time,
    :expiry_time,
    :canonicalized_resource,
    :resource,
    :ip_range,
    :protocol
  ]

  def new, do: %__MODULE__{}

  def for_storage_account(v = %__MODULE__{target_scope: nil}),
    do: v |> Map.put(:target_scope, :account)

  def for_blob_service(v = %__MODULE__{target_scope: nil}), do: v |> Map.put(:target_scope, :blob)

  def for_table_service(v = %__MODULE__{target_scope: nil}),
    do: v |> Map.put(:target_scope, :table)

  def for_queue_service(v = %__MODULE__{target_scope: nil}),
    do: v |> Map.put(:target_scope, :queue)

  # https://docs.microsoft.com/en-us/rest/api/storageservices/constructing-an-account-sas#specifying-account-sas-parameters
  @services_map %{blob: "b", queue: "q", table: "t", file: "f"}
  def add_service_blob(v = %__MODULE__{target_scope: :account}), do: v |> add_to(:services, :blob)

  def add_service_queue(v = %__MODULE__{target_scope: :account}),
    do: v |> add_to(:services, :queue)

  def add_service_table(v = %__MODULE__{target_scope: :account}),
    do: v |> add_to(:services, :table)

  def add_service_file(v = %__MODULE__{target_scope: :account}), do: v |> add_to(:services, :file)

  @resource_types_map %{service: "s", object: "o", container: "c"}
  def add_resource_type_service(v = %__MODULE__{target_scope: :account}),
    do: v |> add_to(:resource_type, :service)

  def add_resource_type_container(v = %__MODULE__{target_scope: :account}),
    do: v |> add_to(:resource_type, :container)

  def add_resource_type_object(v = %__MODULE__{target_scope: :account}),
    do: v |> add_to(:resource_type, :object)

  @resource_map %{
    # https://docs.microsoft.com/en-us/rest/api/storageservices/constructing-a-service-sas#specifying-the-signed-resource-blob-service-only
    container: "c",
    blob: "b",
    # https://docs.microsoft.com/en-us/rest/api/storageservices/constructing-a-service-sas#specifying-the-signed-resource-file-service-only
    share: "s",
    file: "f"
  }

  def add_resource_blob_container(v = %__MODULE__{}), do: v |> add_to(:resource, :container)

  def add_resource_blob_blob(v = %__MODULE__{}), do: v |> add_to(:resource, :blob)

  @permissions_map %{
    read: "r",
    write: "w",
    delete: "d",
    list: "l",
    add: "a",
    create: "c",
    update: "u",
    process: "p"
  }
  def add_permission_read(v = %__MODULE__{}), do: add_to(v, :permissions, :read)
  def add_permission_write(v = %__MODULE__{}), do: add_to(v, :permissions, :write)
  def add_permission_delete(v = %__MODULE__{}), do: add_to(v, :permissions, :delete)
  def add_permission_list(v = %__MODULE__{}), do: add_to(v, :permissions, :list)
  def add_permission_add(v = %__MODULE__{}), do: add_to(v, :permissions, :add)
  def add_permission_create(v = %__MODULE__{}), do: add_to(v, :permissions, :create)
  def add_permission_update(v = %__MODULE__{}), do: add_to(v, :permissions, :update)
  def add_permission_process(v = %__MODULE__{}), do: add_to(v, :permissions, :process)

  def add_canonicalized_resource(v = %__MODULE__{}, resource_name) do
    %{v | canonicalized_resource: resource_name}
  end

  def as_time(t), do: t |> Timex.format!("{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}Z")

  def service_version(v = %__MODULE__{}, service_version),
    do: %{v | service_version: service_version}

  def start_time(v = %__MODULE__{}, start_time), do: %{v | start_time: start_time}
  def expiry_time(v = %__MODULE__{}, expiry_time), do: %{v | expiry_time: expiry_time}
  def resource(v = %__MODULE__{}, resource), do: %{v | resource: resource}
  def ip_range(v = %__MODULE__{}, ip_range), do: %{v | ip_range: ip_range}
  def protocol(v = %__MODULE__{}, protocol), do: %{v | protocol: protocol}

  def encode({:service_version, value}), do: {"sv", value}
  def encode({:start_time, value}), do: {"st", value |> as_time()}

  def encode({:expiry_time, value}), do: {"se", value |> as_time()}
  def encode({:canonicalized_resource, value}), do: {"cr", value}
  def encode({:resource, value}), do: {"sr", value |> set_to_string(@resource_map)}
  def encode({:ip_range, value}), do: {"sip", value}
  def encode({:protocol, value}), do: {"spr", value}
  def encode({:services, value}), do: {"ss", value |> set_to_string(@services_map)}
  def encode({:resource_type, value}), do: {"srt", value |> set_to_string(@resource_types_map)}
  def encode({:permissions, value}), do: {"sp", value |> set_to_string(@permissions_map)}
  def encode(_), do: {nil, nil}

  # https://docs.microsoft.com/en-us/rest/api/storageservices/create-service-sas#version-2018-11-09-and-later
  # StringToSign = signedPermissions + "\n" +
  #              signedStart + "\n" +
  #              signedExpiry + "\n" +
  #              canonicalizedResource + "\n" +
  #              signedIdentifier + "\n" +
  #              signedIP + "\n" +
  #              signedProtocol + "\n" +
  #              signedVersion + "\n" +
  #              signedResource + "\n"
  #              signedSnapshotTime + "\n" +
  #              rscc + "\n" +
  #              rscd + "\n" +
  #              rsce + "\n" +
  #              rscl + "\n" +
  #              rsct
  defp string_to_sign(values, _account_name, :blob) do
    [
      # permissions
      values |> Map.get("sp", ""),
      # start date
      values |> Map.get("st", ""),
      # expiry date
      values |> Map.get("se", ""),
      # canonicalized resource
      values |> Map.get("cr", ""),
      # identifier
      "",
      # IP address
      values |> Map.get("sip", ""),
      # Protocol
      values |> Map.get("spr", ""),
      # Version
      values |> Map.get("sv", ""),
      # resource
      values |> Map.get("sr"),
      # snapshottime
      "",
      # rscc
      "",
      # rscd
      "",
      # rsce
      "",
      # rscl
      "",
      # rsct
      ""
    ]
    |> Enum.join("\n")
  end

  defp string_to_sign(values, account_name, _) do
    [
      account_name,
      values |> Map.get("sp", ""),
      values |> Map.get("ss", ""),
      values |> Map.get("srt", ""),
      values |> Map.get("st", ""),
      values |> Map.get("se", ""),
      values |> Map.get("sip", ""),
      values |> Map.get("spr", ""),
      values |> Map.get("sv", ""),
      ""
    ]
    |> Enum.join("\n")
  end

  def sign(
        sas = %__MODULE__{target_scope: target_scope},
        %Storage{account_name: account_name, account_key: account_key}
      )
      when is_atom(target_scope) and target_scope != nil do
    # https://docs.microsoft.com/en-us/rest/api/storageservices/service-sas-examples
    values =
      sas
      |> Map.from_struct()
      |> Enum.filter(fn {_, val} -> val != nil end)
      |> Enum.map(&__MODULE__.encode/1)
      |> Enum.filter(fn {_, val} -> val != nil end)
      |> Map.new()

    string_to_sign = string_to_sign(values, account_name, target_scope)

    signature =
      Storage.Crypto.hmac(:sha256, account_key |> Base.decode64!(), string_to_sign)
      |> Base.encode64()

    values
    |> Map.put("sig", signature)
    |> Map.drop(["cr"])
    |> URI.encode_query()
  end
end
