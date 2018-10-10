defmodule ConfigZ.Adapter.ConfigMapTest do
  alias ConfigZ.Adapter.ConfigMap

  import Mock

  use ExUnit.Case, async: false

  defmacrop with_mock_test_app(block) do
    quote do
      defmodule TestApp do
        def callback(value), do: value
      end

      with_mock TestApp, callback: fn value -> value end do
        unquote(block)
      end
    end
  end

  defp wait_until_message_received, do: Process.sleep(1000)

  setup_all do
    dir = "/tmp/config_z_test"
    File.rm_rf(dir)
    File.mkdir(dir)
    :ok = ConfigZ.init(name: TestConfigZ, adapter: :config_map, dir: dir)
    {:ok, %{dir: dir}}
  end

  test "init_state/1" do
    dir = "/tmp/init_state_test"
    callbacks = [%{"CONFIG_1" => fn _value -> :noop end}]
    state = ConfigMap.init_state(dir: dir, callbacks: callbacks)
    assert state.dir == dir
    assert state.callbacks == callbacks
    assert is_pid(state.watcher_pid)
  end

  test "read_config/2", %{dir: dir} do
    File.write(dir <> "/CONFIG_2", "value_2")
    assert ConfigMap.read_config("CONFIG_2", %{dir: dir}) == "value_2"
  end

  test "The callback should be called right after ConfigZ.watch/3 is called", %{dir: dir} do
    with_mock_test_app do
      File.write(dir <> "/CONFIG_3", "value_3")
      :ok = ConfigZ.watch(TestConfigZ, "CONFIG_3", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback("value_3"))
    end
  end

  test "The callback should be called with `nil` if CONFIG is not existing", %{dir: dir} do
    with_mock_test_app do
      :ok = ConfigZ.watch(TestConfigZ, "CONFIG_4", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback(nil))
    end
  end

  test "The callback should be called if CONFIG is modified", %{dir: dir} do
    with_mock_test_app do
      File.write(dir <> "/CONFIG_5", "value_5_1")
      :ok = ConfigZ.watch(TestConfigZ, "CONFIG_5", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback("value_5_1"))

      File.write(dir <> "/CONFIG_5", "value_5_2")
      wait_until_message_received()
      assert called(TestApp.callback("value_5_2"))
    end
  end

  test "The callback should be called with `nil` if CONFIG is removed", %{dir: dir} do
    with_mock_test_app do
      File.write(dir <> "/CONFIG_6", "value_6")
      :ok = ConfigZ.watch(TestConfigZ, "CONFIG_6", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback("value_6"))

      File.rm(dir <> "/CONFIG_6")
      wait_until_message_received()
      assert called(TestApp.callback(nil))
    end
  end
end
