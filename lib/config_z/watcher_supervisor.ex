defmodule ConfigZ.WatcherSupervisor do
  @moduledoc false

  use DynamicSupervisor

  @spec start_link(any) :: Supervisor.on_start()
  def start_link(args), do: DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)

  @impl true
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)

  @spec start_child(keyword) :: DynamicSupervisor.on_start_child()
  def start_child(args) do
    args = Keyword.put(args, :name, watcher_name(args[:name]))
    DynamicSupervisor.start_child(__MODULE__, {adapter_module(args[:adapter]), args})
  end

  @spec watcher_name(atom) :: atom
  def watcher_name(name), do: Module.concat(name, Watcher)

  @spec adapter_module(atom) :: atom
  defp adapter_module(:config_map), do: ConfigZ.Adapter.ConfigMap
  defp adapter_module(_), do: raise("Not supported.")
end
