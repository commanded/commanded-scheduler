defmodule Commanded.Scheduler.CancelSchedule do
  @moduledoc """
  Cancel a one-off or recurring scheduled command.
  """

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t()
        }
  defstruct [
    :schedule_uuid,
    :name
  ]
end
