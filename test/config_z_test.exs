defmodule ConfigZTest do
  use ExUnit.Case, async: false

  test "init/1" do
    assert {:error, "adapter is missing"} == ConfigZ.init(name: TestConfigZ)

    assert {:error, "name is missing"} ==
             ConfigZ.init(adapter: :config_map, dir: "/tmp/config_z_test")

    assert {:error, "dir is missing"} == ConfigZ.init(name: TestConfigZ, adapter: :config_map)
    assert {:error, "dummy is not supported"} = ConfigZ.init(name: TestConfigZ, adapter: :dummy)
    assert :ok == ConfigZ.init(name: TestConfigZ, adapter: :config_map, dir: "/tmp/config_z_test")
  end
end
