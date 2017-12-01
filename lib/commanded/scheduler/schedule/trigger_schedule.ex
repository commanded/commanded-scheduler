defmodule Commanded.Scheduler.TriggerSchedule do
  @moduledoc """
  Trigger a schedule that has elapsed.
  """

  @type t :: %__MODULE__{
    schedule_uuid: String.t,
  }

  defstruct [
    :schedule_uuid,
  ]
end
