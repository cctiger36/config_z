defmodule ConfigZ do
  @moduledoc """
  Runtime configuration for Elixir applications.
  """

  use Supervisor

  @type callback :: (String.t() -> any)

  @spec start_link(keyword) :: Supervisor.on_start()
  def start_link(args) do
    supervisor_name = Module.concat(args[:name], Supervisor)
    Supervisor.start_link(__MODULE__, args, name: supervisor_name)
  end

  @impl true
  def init(args) do
    args = Keyword.put(args, :name, watcher_name(args[:name]))

    children = [
      {adapter_module(args[:adapter]), args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec watch(atom, String.t(), callback) :: no_return
  def watch(name, config_name, callback) do
    GenServer.cast(watcher_name(name), {:watch, config_name, callback})
  end

  @spec watcher_name(atom) :: atom
  defp watcher_name(name), do: Module.concat(name, Watcher)

  @spec adapter_module(atom) :: atom
  defp adapter_module(:config_map), do: ConfigZ.Adapter.ConfigMap
  defp adapter_module(_), do: raise("Not supported.")
end
