defmodule Commanded.Scheduler.Jobs do
  @moduledoc false

  use GenServer

  alias Commanded.Scheduler.{Jobs,OneOffJob,RecurringJob}

  defstruct [:jobs_table]

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

  def init(_) do
    state = %Jobs{
      jobs_table: :ets.new(:jobs_table, [:set, :private]),
    }

    {:ok, state}
  end

  def handle_call({:schedule_once, name, mfa, run_at}, _from, %Jobs{jobs_table: jobs_table} = state) do
    :ets.insert(jobs_table, {name, %OneOffJob{name: name, mfa: mfa, run_at: run_at}})

    {:reply, :ok, state}
  end

  def handle_call({:schedule_recurring, name, mfa, schedule}, _from, %Jobs{jobs_table: jobs_table} = state) do
    :ets.insert(jobs_table, {name, %RecurringJob{name: name, mfa: mfa, schedule: schedule}})

    {:reply, :ok, state}
  end

  def handle_call(:scheduled_jobs, _from, %Jobs{jobs_table: jobs_table} = state) do
    reply = jobs_table |> :ets.tab2list() |> Enum.map(fn {_name, job} -> job end)

    {:reply, reply, state}
  end
end
