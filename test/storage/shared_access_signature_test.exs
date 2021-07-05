defmodule Azure.Storage.SharedAccessSignatureTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Azure.Factory

  alias Azure.Storage.SharedAccessSignature, as: SAS

  describe "encode" do
    test "encodes values" do
      value = build(:value)
      now = DateTime.utc_now()

      assert {"sv", value} == SAS.encode({:service_version, value})
      assert {"st", SAS.as_time(now)} == SAS.encode({:start_time, now})
      assert {"se", SAS.as_time(now)} == SAS.encode({:expiry_time, now})
      assert {"cr", value} == SAS.encode({:canonicalized_resource, value})

      assert {"sr", "b"} == SAS.encode({:resource, [:blob]})
      assert {"sr", "c"} == SAS.encode({:resource, [:container]})
      assert {"sr", "s"} == SAS.encode({:resource, [:share]})
      assert {"sr", "f"} == SAS.encode({:resource, [:file]})

      assert {"sip", value} == SAS.encode({:ip_range, value})
      assert {"spr", value} == SAS.encode({:protocol, value})

      assert {"ss", "b"} == SAS.encode({:services, [:blob]})
      assert {"ss", "q"} == SAS.encode({:services, [:queue]})
      assert {"ss", "t"} == SAS.encode({:services, [:table]})
      assert {"ss", "f"} == SAS.encode({:services, [:file]})

      assert {"srt", "s"} == SAS.encode({:resource_type, [:service]})
      assert {"srt", "o"} == SAS.encode({:resource_type, [:object]})
      assert {"srt", "c"} == SAS.encode({:resource_type, [:container]})

      assert {"sp", "r"} == SAS.encode({:permissions, [:read]})
      assert {"sp", "w"} == SAS.encode({:permissions, [:write]})
      assert {"sp", "d"} == SAS.encode({:permissions, [:delete]})
      assert {"sp", "l"} == SAS.encode({:permissions, [:list]})
      assert {"sp", "a"} == SAS.encode({:permissions, [:add]})
      assert {"sp", "c"} == SAS.encode({:permissions, [:create]})
      assert {"sp", "u"} == SAS.encode({:permissions, [:update]})
      assert {"sp", "p"} == SAS.encode({:permissions, [:process]})

      assert {nil, nil} == SAS.encode({:not, "a value"})
    end
  end
end
