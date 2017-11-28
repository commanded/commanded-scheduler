defmodule Commanded.Scheduler.JobSupervisor do
  use Supervisor

  alias Commanded.Scheduler.Job

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_job(name, mfa) do
    Supervisor.start_child(__MODULE__, [name, mfa])
  end

  def init(_arg) do
    job_spec = Supervisor.child_spec(Job, start: {Job, :start_link, []}, restart: :temporary)

    Supervisor.init([
      job_spec,
    ], strategy: :simple_one_for_one)
  end
end
