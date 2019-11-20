defmodule Harvex.Task do
  use Harvex.Resource

  @moduledoc """
  Documentation for Harvex.Task module

  Responsible for Harvest Tasks API interactions.
  """
  defstruct [
    :id,
    :name,
    :billable_by_default,
    :default_hourly_rate,
    :is_default,
    :is_active,
    :created_at,
    :updated_at
  ]

  def harvest_resource_path(), do: "/tasks"
end
