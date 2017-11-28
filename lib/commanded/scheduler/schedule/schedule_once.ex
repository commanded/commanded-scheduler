defmodule Commanded.Scheduler.ScheduleOnce do
  @moduledoc """
  Schedule a one-off command due at the given date/time (in UTC).
  """

  @type t :: %__MODULE__{
    schedule_uuid: String.t,
    cancellation_token: String.t | nil,
    command: struct(),
    due_at: NaiveDateTime.t,
  }
  defstruct [
    :schedule_uuid,
    :cancellation_token,
    :command,
    :due_at,
  ]
end
