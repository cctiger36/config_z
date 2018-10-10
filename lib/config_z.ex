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

  @doc """
  Initialize the watcher.

  ## Arguments

  * `:adapter`: Only supports `:config_map`.
  * `:callbacks`: The map of config keys and callbacks.
  * For `:config_map` adapter:
    * `:dir`: The path of the directory that mounted config map volume.
  """
  @spec init(keyword) :: no_return
  def init(args), do: WatcherSupervisor.start_child(args)

  @doc """
  Read the config value.
  """
  @spec read(atom, String.t()) :: any
  def read(name, config_name) do
    GenServer.call(WatcherSupervisor.watcher_name(name), {:read, config_name})
  end

  @doc """
  Watch the config, the callback function will be called whenever it is changed.
  """
  @spec watch(atom, String.t(), callback) :: no_return
  def watch(name, config_name, callback) do
    GenServer.cast(WatcherSupervisor.watcher_name(name), {:watch, config_name, callback})
  end
end
