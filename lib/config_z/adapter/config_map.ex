defmodule ConfigZ.Adapter.ConfigMap do
  @moduledoc false

  use ConfigZ.Adapter

  @type state :: %{
          callbacks: %{String.t() => ConfigZ.callback()},
          dir: String.t(),
          watcher_pid: pid
        }

  @impl true
  def required_args, do: [:dir]

  @impl true
  def init_state(args) do
    {:ok, pid} = FileSystem.start_link(dirs: [args[:dir]])
    FileSystem.subscribe(pid)

    %{
      callbacks: args[:callbacks] || %{},
      dir: args[:dir],
      watcher_pid: pid
    }
  end

  @impl true
  def read_config(config_name, state) do
    case File.read(config_name_to_path(state[:dir], config_name)) do
      {:ok, value} -> value
      _ -> nil
    end
  end

  @impl true
  def handle_info(
        {:file_event, watcher_pid, {path, _events}},
        %{watcher_pid: watcher_pid} = state
      ) do
    config_name = path_to_config_name(path)
    callback = state.callbacks[config_name]
    if callback, do: load_config(config_name, callback, state)
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:stop, :normal, state}
  end

  @spec path_to_config_name(String.t()) :: String.t()
  defp path_to_config_name(path), do: path |> String.split("/") |> List.last()

  @spec config_name_to_path(String.t(), String.t()) :: String.t()
  defp config_name_to_path(dir, config_name), do: dir <> "/" <> config_name
end
