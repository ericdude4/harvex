defmodule Harvex.Company do
  @moduledoc """
  Documentation for Harvex.Company module.

  Responsible for Harvest Company API interactions. See authorization requirements in Harvex.Resource Shared Authorization Options
  """
  defstruct [
    :base_uri,
    :full_domain,
    :name,
    :is_active,
    :week_start_day,
    :wants_timestamp_timers,
    :time_format,
    :plan_type,
    :clock,
    :decimal_symbol,
    :thousands_separator,
    :color_scheme,
    :weekly_capacity,
    :expense_feature,
    :invoice_feature,
    :estimate_feature,
    :approval_feature
  ]

  @doc """
  Retrieves the company for the currently authenticated user. Returns %Harvex.Company{}
  """
  def retrieve(options \\ []) do
    case HTTPoison.get(
           "https://api.harvestapp.com/v2/company",
           Harvex.get_auth_headers(options)
         ) do
      {:ok, resp} ->
        payload = Jason.decode!(resp.body, keys: :atoms)

        struct!(__MODULE__, payload)

      {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
        raise(HarvexError, "Unable to connect to Harvest server. Reason #{reason}")
    end
  end

  @doc """
  Update customer for currently authenticated user account. Parameters are not validated, but passed along in the request body. Please see Harvest API documentation for the appropriate body parameters for your resource.

  Will return `%Harvex.Company{}` on success, `{:error, 404}` if resource not found, or throw `HarvexError` for implementation errors.

  ## Params
  * `changes` - Map of resource properties to change on the resource. This will be different for each resource based on the specification in Harvest API
  """
  def update(changes, options \\ []) do
    url = "https://api.harvestapp.com/v2/company"

    headers =
      Harvex.get_auth_headers(options)
      |> (fn headers ->
            case Keyword.get(options, :additional_headers) do
              nil ->
                headers

              additional_headers ->
                headers ++ additional_headers
            end
          end).()
      |> (&(&1 ++ [{"Content-Type", "application/json"}])).()

    body =
      case Jason.encode(changes) do
        {:ok, body} ->
          body

        {:error, %Jason.EncodeError{message: message}} ->
          raise(
            HarvexError,
            "Invalid :changes. Was not able to encode to JSON. #{message}"
          )
      end

    case HTTPoison.patch(url, body, headers) do
      {:ok, resp} ->
        case resp.status_code do
          200 ->
            payload =
              Jason.decode!(resp.body, keys: :atoms)

            struct!(__MODULE__, payload)

          404 ->
            {:error, 404}

          status_code when status_code > 399 ->
            error = Jason.decode!(resp.body, keys: :atoms)
            raise(HarvexError, error.message)
        end

      {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
        raise(HarvexError, "Unable to connect to Harvest server. Reason #{reason}")
    end
  end
end
