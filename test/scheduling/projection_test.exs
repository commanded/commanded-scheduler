defmodule Commanded.Scheduling.ProjectionTest do
  use Commanded.Scheduler.RuntimeCase

  import Commanded.Scheduler.Factory

  alias Commanded.Helpers.Wait
  alias Commanded.Scheduler.Projection.Schedule
  alias Commanded.Scheduler.Repo

  describe "schedule once" do
    setup [:schedule_once]

    test "should persist scheduled job", context do
      {:ok, schedule} = get_schedule(context)

      assert schedule.name == "timeout_reservation"
      assert schedule.command == %{
        "ticket_uuid" => context.ticket_uuid,
      }
      assert schedule.command_type == "Elixir.ExampleDomain.TicketBooking.Commands.TimeoutReservation"
      assert schedule.due_at == context.due_at
    end
  end

  describe "schedule once, cancelled" do
    setup [:schedule_once, :cancel_schedule]

    test "should delete persisted job schedule", %{schedule_uuid: schedule_uuid} do
      Wait.until(fn ->
        assert Repo.get_by(Schedule, schedule_uuid: schedule_uuid) == nil
      end)
    end
  end

  describe "schedule once, triggered" do
    setup [:reserve_ticket, :schedule_once, :trigger_schedule]

    test "should delete persisted job schedule", %{schedule_uuid: schedule_uuid} do
      Wait.until(fn ->
        assert Repo.get_by(Schedule, schedule_uuid: schedule_uuid) == nil
      end)
    end
  end

  defp get_schedule(%{schedule_uuid: schedule_uuid, schedule_name: name}) do
    Wait.until(fn ->
      case Repo.get_by(Schedule, schedule_uuid: schedule_uuid, name: name) do
        nil -> flunk("Schedule #{inspect schedule_uuid} does not exist")
        schedule -> {:ok, schedule}
      end
    end)
  end
end
