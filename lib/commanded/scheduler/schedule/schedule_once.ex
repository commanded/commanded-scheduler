defmodule Commanded.Scheduler.ScheduleOnce do
  @moduledoc """
  Schedule a one-off command due at the given date/time (in UTC).
  """

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          due_at: DateTime.t() | NaiveDateTime.t()
        }
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :due_at
  ]
end
