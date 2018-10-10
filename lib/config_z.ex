defmodule ConfigZ do
  @moduledoc """
  Runtime configuration for Elixir applications.
  """

  alias __MODULE__.WatcherSupervisor

  use Application

  @type callback :: (String.t() -> any)

  @impl true
  def start(_type, _args) do
    children = [
      {WatcherSupervisor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @spec init(keyword) :: no_return
  def init(args), do: WatcherSupervisor.start_child(args)

  @spec watch(atom, String.t(), callback) :: no_return
  def watch(name, config_name, callback) do
    GenServer.cast(WatcherSupervisor.watcher_name(name), {:watch, config_name, callback})
  end
end
