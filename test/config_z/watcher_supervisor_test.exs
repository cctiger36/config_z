defmodule ConfigZ.WatcherSupervisorTest do
  alias ConfigZ.WatcherSupervisor

  use ExUnit.Case, async: false

  test "start_child/1" do
    :ok =
      WatcherSupervisor.start_child(
        name: TestApp.ConfigZ,
        adapter: :config_map,
        dir: "/tmp/config_z_test",
        callbacks: %{"CONFIG_1" => fn _value -> :noop end}
      )

    refute is_nil(GenServer.whereis(TestApp.ConfigZ.Watcher))
  end
end
