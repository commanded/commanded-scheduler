defmodule Commanded.Scheduler.RecurringJob do
  @moduledoc false

  defstruct [
    :name,
    :module,
    :args,
    :schedule
  ]
end
