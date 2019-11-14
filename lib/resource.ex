defmodule Harvex.Resource do
  defmacro __using__(_) do
    quote do
      def get(append_url \\ "", options \\ [method: :personal]) do
        url = "https://api.harvestapp.com/v2#{harvest_resource_path()}/#{append_url}"

        case HTTPoison.get(
               url,
               Harvex.get_auth_headers(options)
             ) do
          {:ok, resp} ->
            case resp.status_code do
              200 ->
                payload = Jason.decode!(resp.body, keys: :atoms)

                if append_url == "" do
                  # this means it is a list of resources. The resources will be
                  # contained within a property of the response with the same
                  # name as the pluralized resource being retrieved.
                  "/" <> key = harvest_resource_path()

                  payload[String.to_atom(key)]
                  |> Enum.map(&struct!(__MODULE__, &1))
                else
                  # this means it is a single resource. The resource will exist at
                  # the top level of the response body
                  struct!(__MODULE__, payload)
                end

              401 ->
                error = Jason.decode!(resp.body, keys: :atoms)
                raise(HarvexError, error.error_description)
            end
        end
      end

      def list(options \\ [method: :personal]), do: get("", options)
    end
  end
end
