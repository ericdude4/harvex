defmodule Harvex.TimeEntry do
  use Harvex.Resource

  @moduledoc """
  Documentation for Harvex.TimeEntry module

  Responsible for Harvest TimeEntrys API interactions.
  """
  defstruct [
    :id,
    :spent_date,
    :user,
    :user_assignment,
    :client,
    :project,
    :task,
    :task_assignment,
    :external_reference,
    :invoice,
    :hours,
    :rounded_hours,
    :notes,
    :is_locked,
    :locked_reason,
    :is_closed,
    :is_billed,
    :timer_started_at,
    :started_time,
    :ended_time,
    :is_running,
    :billable,
    :budgeted,
    :billable_rate,
    :cost_rate,
    :created_at,
    :updated_at
  ]

  def harvest_resource_path(), do: "/time_entries"
end
