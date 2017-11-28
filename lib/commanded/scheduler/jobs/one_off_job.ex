defmodule Commanded.Scheduler.OneOffJob do
  defstruct [:name, :mfa, :run_at]
end
