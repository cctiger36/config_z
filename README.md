[![Actions Status](https://github.com/cctiger36/config_z/workflows/test/badge.svg)](https://github.com/cctiger36/config_z/actions)
[![Coverage Status](https://coveralls.io/repos/github/cctiger36/config_z/badge.svg?branch=master)](https://coveralls.io/github/cctiger36/config_z?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/config_z.svg)](https://hex.pm/packages/config_z)

# ConfigZ

Runtime configuration for Elixir applications.

## Adapter

Recently only supports Kubernetes ConfigMap. (See: [Add ConfigMap data to a Volume](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume))

## Dependency

[FileSystem](https://github.com/falood/file_system) (See: [System Support](https://github.com/falood/file_system#system-support))

## Installation

Add to your list of dependencies in `mix.exs`:

```elixir
# mix.exs
def deps do
  [
    {:config_z, "~> 0.3"}
  ]
end
```

Ensure `:config_z` is started before your application by adding it to `:extra_applications`.

```elixir
# mix.exs
def application do
  [
    extra_applications: [:config_z, :logger]
  ]
end
```

## Usage

Prepares callback functions. For example:

```elixir
def callback(value) do
  Application.put_env(:your_application, :your_config, value)
end
```

Initializes ConfigZ:

```elixir
:ok =
  ConfigZ.init(
    name: Your.ConfigZ,
    adapter: :config_map,
    dir: "/etc/config_map",
    callbacks: %{
      "YOUR_CONFIG" => &callback/1
    }
  )
```

It's best to do this before your supervisor tree is started. The callback function will be called immediately, and also every time the config is changed (created, modified or removed).

Also you can add config keys and callbacks later:

```elixir
:ok = ConfigZ.watch(Your.ConfigZ, "ANOTHER_CONFIG", &another_callback/1)
```
