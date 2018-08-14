defmodule ExampleDomain.ExampleRouter do
  use Commanded.Commands.Router

  alias ExampleDomain.ExampleAggregate
  alias ExampleDomain.ExampleAggregate.{Error, Execute, Raise}

  identify(ExampleAggregate, by: :aggregate_uuid)
  dispatch([Error, Execute, Raise], to: ExampleAggregate)
end
