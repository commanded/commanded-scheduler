# Changelog

## v0.2.1

### Bug fixes

- Define `adapter` in Ecto Repo module.

## v0.2.0

### Enhancements

- Support Commanded v0.18.

    Commanded now uses [Jason](https://hex.pm/packages/jason) for JSON serialization of events. Jason has no support for encoding arbitrary structs - explicit implementation of the `Jason.Encoder` protocol is always required.

    You **must** update all your domain event modules and scheduled command modules to include `@derive Jason.Encoder` as shown below:

    ```elixir
    defmodule AnEvent do
      @derive Jason.Encoder
      defstruct [:field]
    end
    ```

    ```elixir
    defmodule ScheduledCommand do
      @derive Jason.Encoder
      defstruct [:field]
    end
    ```

## v0.1.0

- Initial release with support for scheduling one-off commands.
