defmodule ExampleDomain.ExampleRouter do
  use Commanded.Commands.Router

  alias ExampleDomain.ExampleAggregate
  alias ExampleDomain.ExampleAggregate.Execute

  identify ExampleAggregate, by: :aggregate_uuid
  dispatch [Execute], to: ExampleAggregate
end
