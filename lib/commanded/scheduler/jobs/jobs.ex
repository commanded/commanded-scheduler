defmodule Commanded.Scheduler.Jobs do
  @moduledoc false

  use GenServer

  import Ex2ms

  alias Commanded.Scheduler.{Jobs,JobSupervisor,OneOffJob,RecurringJob}

  defstruct [:schedule_table, :jobs_table]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [name: __MODULE__])
  end

  def schedule_once(name, {_module, _function, _args} = mfa, %NaiveDateTime{} = run_at) do
    GenServer.call(__MODULE__, {:schedule_once, name, mfa, run_at})
  end

  def schedule_recurring(name, {_module, _function, _args} = mfa, schedule) do
    GenServer.call(__MODULE__, {:schedule_recurring, name, mfa, schedule})
  end

  @doc """
  Get all scheduled jobs
  """
  def scheduled_jobs do
    GenServer.call(__MODULE__, :scheduled_jobs)
  end

  def pending_jobs(now) do
    GenServer.call(__MODULE__, {:pending_jobs, now})
  end

  def run_jobs(now) do
    GenServer.call(__MODULE__, {:run_jobs, now})
  end

  def init(_) do
    state = %Jobs{
      schedule_table: :ets.new(:schedule_table, [:set, :private]),
      jobs_table: :ets.new(:jobs_table, [:set, :private]),
    }

    {:ok, state}
  end

  def handle_call({:schedule_once, name, mfa, run_at}, _from, %Jobs{schedule_table: schedule_table} = state) do
    :ets.insert(schedule_table, {name, epoch_seconds(run_at), :pending, %OneOffJob{name: name, mfa: mfa, run_at: run_at}})

    {:reply, :ok, state}
  end

  def handle_call({:schedule_recurring, name, mfa, schedule}, _from, %Jobs{schedule_table: schedule_table} = state) do
    :ets.insert(schedule_table, {name, nil, :pending, %RecurringJob{name: name, mfa: mfa, schedule: schedule}})

    {:reply, :ok, state}
  end

  def handle_call(:scheduled_jobs, _from, %Jobs{schedule_table: schedule_table} = state) do
    reply = schedule_table |> :ets.tab2list() |> Enum.map(fn {_name, _due_at, _status, job} -> job end)

    {:reply, reply, state}
  end

  def handle_call({:pending_jobs, now}, _from, %Jobs{} = state) do
    reply = pending_jobs(now, state)

    {:reply, reply, state}
  end

  def handle_call({:run_jobs, now}, _from, %Jobs{} = state) do
    for job <- pending_jobs(now, state) do
      execute_job(job, state)
    end

    {:reply, :ok, state}
  end

  def handle_info({:DOWN, ref, :process, _object, _reason}, %Jobs{} = state) do
    {:noreply, remove_completed_job(ref, state)}
  end

  defp pending_jobs(now, %Jobs{schedule_table: schedule_table}) do
    due_at_epoch = epoch_seconds(now)

    predicate = fun do
      {_name, due_at, status, job} when due_at <= ^due_at_epoch and status == :pending -> job
    end

    :ets.select(schedule_table, predicate)
  end

  defp execute_job(%OneOffJob{name: name, mfa: mfa}, %Jobs{jobs_table: jobs_table, schedule_table: schedule_table}) do
    with {:ok, pid} <- JobSupervisor.start_job(name, mfa) do
      ref = Process.monitor(pid)

      :ets.update_element(schedule_table, name, {3, :running})
      :ets.insert(jobs_table, {ref, name})
    end
  end

  defp execute_job(%RecurringJob{name: name, mfa: mfa}, %Jobs{}) do
    {:ok, _pid} = JobSupervisor.start_job(name, mfa)
  end

  defp remove_completed_job(ref, %Jobs{jobs_table: jobs_table, schedule_table: schedule_table} = state) do
    case :ets.lookup(jobs_table, ref) do
      [{ref, name}] ->
        :ets.delete(jobs_table, ref)
        :ets.delete(schedule_table, name)
        state

      _ ->
        state
    end
  end

  defp epoch_seconds(due_at), do: NaiveDateTime.diff(due_at, ~N[1970-01-01 00:00:00])
end
