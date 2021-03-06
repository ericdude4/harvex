defmodule Harvex.User do
  use Harvex.Resource

  @moduledoc """
  Documentation for Harvex.User module.

  Responsible for Harvest Users API interactions.
  """
  defstruct [
    :id,
    :first_name,
    :last_name,
    :email,
    :has_access_to_all_future_projects,
    :calendar_integration_enabled,
    :calendar_integration_source,
    :telephone,
    :timezone,
    :is_contractor,
    :is_admin,
    :is_project_manager,
    :can_see_rates,
    :can_create_projects,
    :can_create_invoices,
    :is_active,
    :weekly_capacity,
    :default_hourly_rate,
    :cost_rate,
    :roles,
    :avatar_url,
    :created_at,
    :updated_at
  ]

  def harvest_resource_path(), do: "/users"

  @doc """
  Retreives the currently authenticated user.

  ## Examples

      iex> Harvex.User.get_me()
      {:ok, %Harvex.User{}}
  """
  def get_me(options \\ []) do
    get(options ++ [id: "me"])
  end
end
