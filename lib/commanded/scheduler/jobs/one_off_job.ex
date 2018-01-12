defmodule Commanded.Scheduler.OneOffJob do
  @moduledoc false

  defstruct [
    :name,
    :module,
    :args,
    :run_at
  ]
end
