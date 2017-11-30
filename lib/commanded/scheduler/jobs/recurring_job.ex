defmodule Commanded.Scheduler.RecurringJob do
  defstruct [
    :name,
    :module,
    :args,
    :schedule,
  ]
end
