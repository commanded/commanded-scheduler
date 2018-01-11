defmodule Commanded.SchedulerTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Assertions.EventAssertions

  alias Commanded.Scheduler
  alias Commanded.Scheduler.ExampleCommand
  alias Timex.Duration

  defmodule Executed do
    defstruct [:data]
  end

  defmodule ExampleAggregate do
    defstruct [:executed_at]

    def execute(%ExampleAggregate{}, %ExampleCommand{data: data}) do
      %Executed{data: data}
    end

    def apply(%ExampleAggregate{} = agg, _event), do: agg
  end

  defmodule ExampleRouter do
    use Commanded.Commands.Router

    identify(ExampleAggregate, by: :aggregate_uuid)
    dispatch([ExampleCommand], to: ExampleAggregate)
  end

  setup do
    original_router = Application.get_env(:commanded_scheduler, :router)

    Application.put_env(:commanded_scheduler, :router, ExampleRouter)

    on_exit(fn ->
      Application.put_env(:commanded_scheduler, :router, original_router)
    end)
  end

  describe "schedule once" do
    test "should schedule job" do
      aggregate_uuid = UUID.uuid4()
      command = %ExampleCommand{aggregate_uuid: aggregate_uuid, data: "once"}
      run_at = NaiveDateTime.utc_now()

      Scheduler.schedule_once("once", command, run_at)

      Scheduler.Jobs.run_jobs(run_at)

      assert_receive_event(Executed, fn executed ->
        assert executed.data == "once"
      end)
    end
  end

  describe "schedule recurring" do
    @tag :pending
    test "should schedule job" do
      aggregate_uuid = UUID.uuid4()
      command = %ExampleCommand{aggregate_uuid: aggregate_uuid, data: "once"}

      Scheduler.schedule_recurring("recurring", command, "@daily")

      now = NaiveDateTime.utc_now()
      tomorrow = Timex.add(now, Duration.from_days(1))
      Scheduler.Jobs.run_jobs(tomorrow)

      assert_receive_event(Executed, fn executed ->
        assert executed.data == "recurring"
      end)
    end
  end
end
