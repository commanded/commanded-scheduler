defmodule Commanded.Scheduler.ScheduleRecurring do
  @moduledoc """
  Schedule a recurring command using a cron job schedule definition.

  ## Cron format

  Schedule supports the following cron job formats:

    - `* * * * *` - Runs every minute.
    - `*/15 * * * *` - Runs every 15 minutes.
    - `0 18-6/2 * *` - Runs at 18:00, 20:00, 22:00, 0:00, 2:00, 4:00, 6:00.
    - `@daily` - Runs each day at midnight.
  """

  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    cancellation_token: String.t | nil,
    command: struct(),
    schedule: String.t,
  }
  defstruct [
    :schedule_uuid,
    :cancellation_token,
    :command,
    :schedule,
  ]
end
