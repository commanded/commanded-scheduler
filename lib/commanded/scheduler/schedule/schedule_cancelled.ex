defmodule Commanded.Scheduler.ScheduleCancelled do
  @moduledoc false

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t()
        }
  @derive Jason.Encoder
  defstruct [
    :schedule_uuid,
    :name
  ]
end
