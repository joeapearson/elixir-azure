# Azure

Basic Azure support for Elixir.

Includes support for Azure Storage APIs.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `azure` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:azure, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/azure](https://hexdocs.pm/azure).

## Running tests

Tests are run against [Azurite](https://github.com/Azure/Azurite), an Azure storage emulator, using
Docker Compose:

```sh
$ docker compose up -d
$ mix test --include external
```

## Credits

This repo was largely derived from [ex_microsoft_azure_storage](https://github.com/chgeuer/ex_microsoft_azure_storage) originally written by [@chgeuer](https://github.com/chgeuer).  Credit and thanks.
