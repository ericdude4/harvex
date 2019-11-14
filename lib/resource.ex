defmodule Harvex.Resource do
  # def form_request(options, method, url) do
  #   %HTTPoison.Request{method: method, url: url, headers: Harvex.get_auth_headers(options)}
  # end
  defmacro __using__(_) do
    quote do
      def get(append_url \\ "", options) do
        url = "https://api.harvestapp.com/v2#{harvest_resource_path()}/#{append_url}"

        case HTTPoison.get(
               url,
               Harvex.get_auth_headers(options)
             ) do
          {:ok, resp} ->
            case resp.status_code do
              200 ->
                payload = Jason.decode!(resp.body, keys: :atoms)

                struct!(__MODULE__, payload)

              401 ->
                error = Jason.decode!(resp.body, keys: :atoms)
                raise(HarvexError, error.error_description)
            end
        end
      end
    end
  end
end
