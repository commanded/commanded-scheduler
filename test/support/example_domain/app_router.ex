defmodule ExampleDomain.AppRouter do
  @moduledoc false

  use Commanded.Commands.CompositeRouter

  router ExampleDomain.TicketRouter
  router Commanded.Scheduler.Router
end
