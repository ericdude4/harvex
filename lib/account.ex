defmodule Harvex.Account do
  defstruct [:id, :name, :product, :google_sign_in_required]

  def list(options \\ []) do
    case HTTPoison.get(
           "https://id.getharvest.com/api/v2/accounts",
           Harvex.get_auth_headers(options, false)
         ) do
      {:ok, resp} ->
        payload = Jason.decode!(resp.body, keys: :atoms)
        Enum.map(payload.accounts, &struct!(__MODULE__, &1))

      {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
        raise(HarvexError, "Unable to connect to Harvest server. Reason #{reason}")
    end
  end
end
