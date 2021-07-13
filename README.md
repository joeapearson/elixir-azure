[![Hex.pm](https://img.shields.io/hexpm/v/azure.svg)](https://hex.pm/packages/azure)
![CI](https://github.com/joeapearson/elixir-azure/actions/workflows/ci.yml/badge.svg)

# Elixir Azure

Basic Azure support for Elixir.

Includes support for Azure Storage APIs.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `azure` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:azure, "~> 0.3.0"}
  ]
end
```

## Running tests

Tests are run against [Azurite](https://github.com/Azure/Azurite), an Azure storage emulator, using
Docker Compose:

```sh
$ docker compose up -d
$ mix test --include external
```

## Documentation

[https://hexdocs.pm/azure](https://hexdocs.pm/azure)

For usage examples check out the tests.

## Credits

This repo was largely derived from [ex_microsoft_azure_storage](https://github.com/chgeuer/ex_microsoft_azure_storage) originally written by [@chgeuer](https://github.com/chgeuer).  Credit and thanks.
