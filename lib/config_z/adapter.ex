defmodule ConfigZ.Adapter do
  @moduledoc false

  @type state :: %{
          required(:callbacks) => %{String.t() => ConfigZ.callback()},
          optional(atom) => any
        }

  @callback init_state(keyword) :: state
  @callback read_config(String.t(), state) :: any

  defmacro __using__(_) do
    quote do
      use GenServer

      @spec start_link(keyword) :: GenServer.on_start()
      def start_link(args), do: GenServer.start_link(__MODULE__, args, name: args[:name])

      @impl true
      def init(args) do
        state = init_state(args)

        for {config_name, callback} <- state.callbacks,
            do: load_config(config_name, callback, state)

        {:ok, state}
      end

      @impl true
      def handle_call({:read, config_name}, _from, state) do
        value = read_config(config_name, state)
        {:reply, value, state}
      end

      @impl true
      def handle_cast({:watch, config_name, callback}, state) do
        state = put_in(state.callbacks[config_name], callback)
        load_config(config_name, callback, state)
        {:noreply, state}
      end

      @spec load_config(String.t(), ConfigZ.callback(), state) :: any
      def load_config(config_name, callback, state) do
        value = read_config(config_name, state)
        callback.(value)
      end
    end
  end
end
