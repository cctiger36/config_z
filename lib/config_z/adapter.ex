defmodule ConfigZ.Adapter do
  @moduledoc false

  @type state :: %{
          required(:callbacks) => %{String.t() => ConfigZ.callback()},
          required(:values) => %{String.t() => any},
          optional(atom) => any
        }

  @callback required_args :: [atom]
  @callback init_state(keyword) :: map
  @callback read_config(String.t(), state) :: any

  defmacro __using__(_) do
    quote do
      use GenServer

      @behaviour ConfigZ.Adapter

      @type state :: ConfigZ.Adapter.state()

      @spec start_link(keyword) :: GenServer.on_start()
      def start_link(args), do: GenServer.start_link(__MODULE__, args, name: args[:name])

      @impl true
      def init(args) do
        state =
          args
          |> init_state()
          |> Map.merge(%{
            callbacks: args[:callbacks] || %{},
            values: %{}
          })

        state =
          Enum.reduce(state.callbacks, state, fn {config_name, _}, state ->
            load_config(state, config_name)
          end)

        {:ok, state}
      end

      @impl true
      def handle_call({:read, config_name}, _from, state) do
        value = read_config(config_name, state)
        {:reply, value, state}
      end

      @impl true
      def handle_cast({:watch, config_name, callback}, state) do
        state =
          state
          |> put_in([:callbacks, config_name], callback)
          |> load_config(config_name)

        {:noreply, state}
      end

      @spec load_config(state, String.t()) :: state
      def load_config(state, config_name) do
        if state.callbacks[config_name] do
          value = read_config(config_name, state)

          if Map.has_key?(state.values, config_name) and state.values[config_name] === value do
            state
          else
            state.callbacks[config_name].(value)
            put_in(state.values[config_name], value)
          end
        else
          state
        end
      end
    end
  end
end
