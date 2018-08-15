# Usage

## Schedule a one-off command

Schedule a uniquely identified one-off job using the given command to dispatch at the specified date/time.

### Example

```elixir
Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, ~N[2020-01-01 12:00:00])
```

Name the scheduled job:

```elixir
Commanded.Scheduler.schedule_once(reservation_id, %TimeoutReservation{..}, due_at, name: "timeout")
```

## Schedule multiple one-off commands in a single batch

This guarantees that all, or none, of the commands are scheduled.

### Example

```elixir
alias Commanded.Scheduler
alias Commanded.Scheduler.Batch

batch =
  reservation_id
  |> Batch.new()
  |> Batch.schedule_once(%TimeoutReservation{..}, timeout_due_at, name: "timeout")
  |> Batch.schedule_once(%ReleaseSeat{..}, release_due_at, name: "release")

Scheduler.schedule_batch(batch)  
```

## Dispatch a scheduled command

You can dispatch a scheduled command by defining a composite Commanded router for your application and including the `Commanded.Scheduler.Router`:

```elixir
defmodule AppRouter do
  use Commanded.Commands.CompositeRouter

  router ExampleDomain.TicketRouter
  router Commanded.Scheduler.Router
end
```

Then you can dispatch a `Commanded.Scheduler.ScheduleOnce` or `Commanded.Scheduler.ScheduleBatch` command, including the command to be executed later:

```elixir
alias Commanded.Scheduler.ScheduleOnce

timeout_reservation = %TimeoutReservation{
  ticket_uuid: ticket_uuid
}

schedule_once = %ScheduleOnce{
  schedule_uuid: ticket_uuid,
  command: timeout_reservation,
  due_at: expires_at,
}

AppRouter.dispatch(schedule_once)
```

This approach allows you to dispatch a command from within a process manager:

```elixir
defmodule TicketProcessManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "TicketProcessManager",
    router: AppRouter

  alias Commanded.Scheduler.ScheduleOnce

  defstruct [:ticket_uuid]

  def interested?(%TicketReserved{ticket_uuid: ticket_uuid}),
    do: {:start, ticket_uuid}

  def handle(
    %TicketProcessManager{},
    %TicketReserved{ticket_uuid: ticket_uuid, expires_at: expires_at})
  do
    %ScheduleOnce{
      schedule_uuid: ticket_uuid,
      command: %TimeoutReservation{ticket_uuid: ticket_uuid},
      due_at: expires_at
    }
  end
end
```
