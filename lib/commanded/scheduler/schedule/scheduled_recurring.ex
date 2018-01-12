defmodule Commanded.Scheduler.ScheduledRecurring do
  @moduledoc false

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t(),
          schedule: String.t()
        }
  @derive [Poison.Encoder]
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type,
    :schedule
  ]
end
