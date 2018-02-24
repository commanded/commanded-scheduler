defmodule Commanded.Scheduler.ScheduleBatch do
  @moduledoc """
  Schedule a batch of one-off and recurring commands.
  """

  defmodule Once do
    @moduledoc false

    @type t :: %__MODULE__{
            name: String.t(),
            command: struct(),
            due_at: DateTime.t() | NaiveDateTime.t()
          }

    defstruct [
      :name,
      :command,
      :due_at
    ]
  end

  defmodule Recurring do
    @moduledoc false

    @type t :: %__MODULE__{
            name: String.t(),
            command: struct(),
            schedule: String.t()
          }

    defstruct [
      :name,
      :command,
      :schedule
    ]
  end

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          schedule_once: [Once.t()],
          schedule_recurring: [Recurring.t()]
        }

  defstruct [
    :schedule_uuid,
    schedule_once: [],
    schedule_recurring: []
  ]
end
