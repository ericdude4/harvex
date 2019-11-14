defmodule Harvex.Client do
  use Harvex.Resource

  @moduledoc """
  Documentation for Harvex.Client module

  Responsible for Harvest Clients API interactions.
  """
  defstruct [
    :id,
    :name,
    :is_active,
    :address,
    :statement_key,
    :currency,
    :created_at,
    :updated_at
  ]

  def harvest_resource_path(), do: "/clients"
end
