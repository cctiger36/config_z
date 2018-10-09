# ConfigZ

[![Build Status](https://travis-ci.org/cctiger36/config_z.svg?branch=master)](https://travis-ci.org/cctiger36/config_z)

Runtime configuration for Elixir applications.

## Adapter

Recently only supports Kubernetes ConfigMap. (See: [Add ConfigMap data to a Volume](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume))

## Dependency

[FileSystem](https://github.com/falood/file_system) (See: [System Support](https://github.com/falood/file_system#system-support))

## Installation

Add to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [
    {:config_z, "~> 0.1.0"}
  ]
end
```

Add to the supervisor tree of your application:
```elixir
defmodule Your.Application do
  use Application

  def start(_type, _args) do
    children = [
      {ConfigZ, [name: Your.ConfigZ, adapter: :config_map, dir: "/etc/config_map"]}
    ]

    opts = [strategy: :one_for_one, name: Your.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## Usage

Prepares a callback function. For example:
```elixir
def callback(value) do
  Application.put_env(:your_application, :your_config, value)
end
```

Then tells ConfigZ to watch it:
```elixir
ConfigZ.watch(Your.ConfigZ, "YOUR_CONFIG", &callback/1)
```

The callback function will be called immediately, and also every time the config is changed (created, modified or removed).

Also you can pass the config keys and callbacks when starting the supervisor tree:
```elixir
children = [
  {ConfigZ, [name: Your.ConfigZ, adapter: :config_map, dir: "/etc/config_map",
             config_and_callbacks: %{"YOUR_CONFIG" => &callback/1}]}
]
```
