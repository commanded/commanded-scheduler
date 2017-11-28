defmodule Commanded.Scheduler.RecurringJob do
  defstruct [
    :name,
    :mfa,
    :schedule,
  ]
end
