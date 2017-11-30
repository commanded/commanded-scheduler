defmodule Commanded.Scheduler.OneOffJob do
  defstruct [
    :name,
    :module,
    :args,
    :run_at,
  ]
end
