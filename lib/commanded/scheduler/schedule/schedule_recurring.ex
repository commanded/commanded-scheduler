defmodule Commanded.Scheduler.ScheduleRecurring do
  @moduledoc false

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          schedule: String.t()
        }
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :schedule
  ]
end
