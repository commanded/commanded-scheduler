defmodule Commanded.Scheduler.ExampleCommand do
  @moduledoc false

  @derive Jason.Encoder
  defstruct [
    :aggregate_uuid,
    :data
  ]
end
