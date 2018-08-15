defmodule Commanded.Scheduler.TriggerSchedule do
  @moduledoc false

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t()
        }

  defstruct [
    :schedule_uuid,
    :name
  ]
end
