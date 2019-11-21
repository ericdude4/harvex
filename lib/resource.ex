defmodule Harvex.Resource do
  @moduledoc """
  All Harvest requests require authorization headers. These can be set by deafult in your config file:

  ## Example Config
      config :harvex,
        personal_access_token:
          "2137291.pt.hp837WAz5X82h7Pm4T9Hubqcc30PSApWJmS8f_8XNfzq458gB1lQELSCdo8y04wthis_is_an_example_2123",
        account_id: "123456789",
        user_agent: "Harvex (eric@clockk.com)"

  The authorization headers can be customized for each request using the following options:

  ## Shared Authorization Options
  * `:auth_method` - Required. `:oauth_2` or `:personal_access_token` are the only valid options. Defaults to `:personal_access_token`
  * `:access_token` - Required. Either a Harvest issued OAuth2 access token or Harvest issued personal access token. Defaults to the `:personal_access_token` provided in config file if one was set.
  * `:account_id` - Required. An access token can have access to resources from multiple Harvest accounts. Specify which one with this option. All requests except for `Harvex.Account.list/2` require this field. Defaults to `:account_id` provided in config file if one was set.
  * `:user_agent` - Optional. Tells Harvest API who is communicating with their API.
  """
  defmacro __using__(_) do
    quote do
      @doc """
      Retrieve Harvest resource by id.

      ## Options
      * `:id` - The id of the resource you are trying to retrieve. Defaults to empty, giving same behaviour as list/1
      * `:get_parameters` - Map of query parameters that you want to include in the query.
      * `:additional_headers` - List of headers formatted as `[{"Header-Name", "Header-Value"}]`
      """
      def get(options \\ []) do
        resource_id = Keyword.get(options, :id)

        url =
          "https://api.harvestapp.com/v2#{harvest_resource_path()}"
          |> (fn url ->
                if is_nil(resource_id) do
                  url
                else
                  url <> "/#{resource_id}"
                end
              end).()
          |> (fn url ->
                case Keyword.get(options, :get_parameters) do
                  nil ->
                    url

                  get_parameters ->
                    url <> "?" <> URI.encode_query(get_parameters)
                end
              end).()

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

        case HTTPoison.get(url, headers) do
          {:ok, resp} ->
            case resp.status_code do
              200 ->
                payload = Jason.decode!(resp.body, keys: :atoms)

                case Keyword.get(options, :id) do
                  nil ->
                    # this means it is a list of resources. The resources will be
                    # contained within a property of the response with the same
                    # name as the pluralized resource being retrieved.
                    "/" <> key = harvest_resource_path()

                    payload[String.to_atom(key)]
                    |> Enum.map(&struct!(__MODULE__, &1))

                  _resource_id ->
                    # this means it is a single resource. The resource will exist at
                    # the top level of the response body
                    struct!(__MODULE__, payload)
                end

              401 ->
                error = Jason.decode!(resp.body, keys: :atoms)
                raise(HarvexError, error.error_description)
            end

          {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
            raise(HarvexError, "Unable to connect to Harvest server. Reason #{reason}")
        end
      end

      defp get_recursive(
             options \\ [],
             collector \\ [],
             page \\ 1,
             per_page \\ 100
           ) do
        get_parameters =
          case Keyword.get(options, :get_parameters) do
            nil ->
              %{page: page, per_page: per_page}

            get_parameters ->
              Map.merge(get_parameters, %{page: page, per_page: per_page})
          end

        resources = get(options ++ [get_parameters: get_parameters])

        if Enum.count(resources) == per_page do
          get_recursive(options, resources ++ collector, page + 1, per_page)
        else
          # all pages exhausted for resource. return collection
          resources ++ collector
        end
      end

      @doc """
      Retrieve list of this Harvest resource. Shares all options with get/1

      ## Options
      * `:page` - The page number to use in pagination. Default 1
      * `:per_page` - The number of records to return per page. Can range between 1 and 100. Default 100
      * `:recurse_pages` - Recursively follow each next page and return all records.
      """
      def list(options \\ []) do
        page = Keyword.get(options, :page, 1)
        per_page = Keyword.get(options, :per_page, 100)

        if Keyword.get(options, :recurse_pages) do
          get_recursive(options, [], page, per_page)
        else
          get(options ++ [get_parameters: %{page: page, per_page: per_page}])
        end
      end

      @doc """
      Create new harvest resource. Parameters are not validated, but passed along in the request body. Please see Harvest API documentation for the appropriate body parameters for your resource.

      ## Params
      * `properties` - Map of resource properties to create the resource with. This will be different for each resource based on the specification in Harvest API
      """
      def create(properties, options \\ []) do
        url = "https://api.harvestapp.com/v2#{harvest_resource_path()}"

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
          case Jason.encode(properties) do
            {:ok, body} ->
              body

            {:error, %Jason.EncodeError{message: message}} ->
              raise(
                HarvexError,
                "Invalid :properties. Was not able to encode to JSON. #{message}"
              )
          end

        case HTTPoison.post(url, body, headers) do
          {:ok, resp} ->
            case resp.status_code do
              201 ->
                payload = Jason.decode!(resp.body, keys: :atoms)

                struct!(__MODULE__, payload)

              status_code when status_code > 399 ->
                error = Jason.decode!(resp.body, keys: :atoms)
                raise(HarvexError, error.message)
            end

          {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
            raise(HarvexError, "Unable to connect to Harvest server. Reason #{reason}")
        end
      end
    end
  end
end
