defmodule ConfigZ.WatcherSupervisor do
  @moduledoc false

  use DynamicSupervisor

  @spec start_link(any) :: Supervisor.on_start()
  def start_link(args), do: DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)

  @impl true
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)

  @spec start_child(keyword) :: :ok | {:error, String.t()}
  def start_child(args) do
    case validate_adapter_args(args) do
      :ok ->
        args = Keyword.put(args, :name, watcher_name(args[:name]))
        DynamicSupervisor.start_child(__MODULE__, {adapter_module(args[:adapter]), args})
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec watcher_name(atom) :: atom
  def watcher_name(name), do: Module.concat(name, Watcher)

  @spec adapter_module(atom) :: atom
  defp adapter_module(:config_map), do: ConfigZ.Adapter.ConfigMap

  @spec validate_adapter_args(keyword) :: :ok | {:error, String.t()}
  defp validate_adapter_args(args) do
    required_args = apply(adapter_module(args[:adapter]), :required_args, [])

    case required_args -- Keyword.keys(args) do
      [] -> :ok
      missing_args -> {:error, "#{Enum.join(missing_args, ", ")} is missing"}
    end
  end
end
