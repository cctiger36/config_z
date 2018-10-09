defmodule ConfigZTest do
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
    ConfigZ.start_link(name: TestConfigZ, adapter: :config_map, dir: dir)
    {:ok, %{dir: dir}}
  end

  test "The callback should be called right after ConfigZ.watch/3 is called", %{dir: dir} do
    with_mock_test_app do
      File.write(dir <> "/CONFIG_1", "value_1")
      ConfigZ.watch(TestConfigZ, "CONFIG_1", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback("value_1"))
    end
  end

  test "The callback should be called with `nil` if CONFIG is not existing", %{dir: dir} do
    with_mock_test_app do
      ConfigZ.watch(TestConfigZ, "CONFIG_2", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback(nil))
    end
  end

  test "The callback should be called if CONFIG is modified", %{dir: dir} do
    with_mock_test_app do
      File.write(dir <> "/CONFIG_3", "value_3_1")
      ConfigZ.watch(TestConfigZ, "CONFIG_3", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback("value_3_1"))

      File.write(dir <> "/CONFIG_3", "value_3_2")
      wait_until_message_received()
      assert called(TestApp.callback("value_3_2"))
    end
  end

  test "The callback should be called with `nil` if CONFIG is removed", %{dir: dir} do
    with_mock_test_app do
      File.write(dir <> "/CONFIG_4", "value_4")
      ConfigZ.watch(TestConfigZ, "CONFIG_4", &TestApp.callback/1)
      wait_until_message_received()
      assert called(TestApp.callback("value_4"))

      File.rm(dir <> "/CONFIG_4")
      wait_until_message_received()
      assert called(TestApp.callback(nil))
    end
  end
end
