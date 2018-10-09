defmodule ConfigZ.Adapter.ConfigMap do
  @moduledoc false

  use GenServer

  @type state :: %{
          watcher_pid: pid,
          dir: String.t(),
          config_and_callbacks: %{String.t() => ConfigZ.callback()}
        }

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: args[:name])

  @impl true
  def init(args) do
    {:ok, pid} = FileSystem.start_link(dirs: [args[:dir]])
    FileSystem.subscribe(pid)
    config_and_callbacks = args[:config_and_callbacks] || %{}

    state = %{
      watcher_pid: pid,
      dir: args[:dir],
      config_and_callbacks: config_and_callbacks
    }

    for {config_name, callback} <- config_and_callbacks,
        do: read_config(args[:dir], config_name, callback)

    {:ok, state}
  end

  @impl true
  def handle_cast({:watch, config_name, callback}, state) do
    state = put_in(state.config_and_callbacks[config_name], callback)
    read_config(state.dir, config_name, callback)
    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:file_event, watcher_pid, {path, _events}},
        %{watcher_pid: watcher_pid} = state
      ) do
    config_name = path_to_config_name(path)
    callback = state.config_and_callbacks[config_name]
    if callback, do: read_config(state.dir, config_name, callback)
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:stop, :normal, state}
  end

  @spec path_to_config_name(String.t()) :: String.t()
  defp path_to_config_name(path), do: path |> String.split("/") |> List.last()

  @spec config_name_to_path(String.t(), String.t()) :: String.t()
  defp config_name_to_path(dir, config_name), do: dir <> "/" <> config_name

  @spec read_config(String.t(), String.t(), ConfigZ.callback()) :: any
  defp read_config(dir, config_name, callback) do
    value =
      case File.read(config_name_to_path(dir, config_name)) do
        {:ok, value} -> value
        {:error, _} -> nil
      end

    callback.(value)
  end
end
