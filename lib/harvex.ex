defmodule Harvex do
  @moduledoc """
  Documentation for Harvex.
  """

  @doc """
  return list of authorization headers
  """
  def get_auth_headers(auth_opts, requires_account_id_header \\ true) do
    auth_headers =
      case Keyword.get(auth_opts, :auth_method) do
        :oauth_2 ->
          oauth_2_headers(auth_opts)

        :personal_access_token ->
          personal_auth_headers(auth_opts)

        nil ->
          personal_auth_headers(auth_opts)

        _ ->
          raise(HarvexError, "invalid :auth_method in options")
      end

    account_id_headers =
      if requires_account_id_header do
        account_id =
          case Keyword.get(auth_opts, :account_id) do
            nil ->
              case Application.fetch_env(:harvex, :account_id) do
                :error ->
                  raise(HarvexError, "no :account_id in options or config")

                {:ok, account_id} ->
                  account_id
              end

            account_id ->
              account_id
          end

        [{"Harvest-Account-Id", account_id}]
      else
        []
      end

    auth_headers ++ account_id_headers ++ get_user_agent_headers(auth_opts)
  end

  # return request headers based on an Oauth2 authentication scheme
  defp oauth_2_headers(auth_opts) do
    access_token =
      case Keyword.get(auth_opts, :access_token) do
        nil ->
          raise(HarvexError, "no :access_token in options.")

        access_token ->
          case access_token do
            %{"access_token" => access_token} ->
              access_token

            %{access_token: access_token} ->
              access_token
          end
      end

    [{"Authorization", "Bearer #{access_token}"}]
  end

  @doc """
  Exchanges an OAuth code for an access token.

  returns struct
  """
  def authorize(code) do
    case HTTPoison.post(
           "https://id.getharvest.com/api/v2/oauth2/token",
           Jason.encode!(%{
             code: code,
             client_id: System.get_env("HARVEST_CLIENT_ID"),
             client_secret: System.get_env("HARVEST_CLIENT_SECRET"),
             grant_type: "authorization_code"
           }),
           [
             {"Content-Type", "application/json"},
             {"User-Agent", "Clockk (eric@clockk.com)"}
           ]
         ) do
      {:ok, response} ->
        Jason.decode!(response.body, keys: :atoms)
    end
  end

  # return request headers based on a Harvest personal access token
  defp personal_auth_headers(auth_opts) do
    personal_access_token =
      case Keyword.get(auth_opts, :personal_access_token) do
        nil ->
          case Application.fetch_env(:harvex, :personal_access_token) do
            :error ->
              raise(HarvexError, "no :personal_access_token in :auth_options or config")

            {:ok, personal_access_token} ->
              personal_access_token
          end

        personal_access_token ->
          personal_access_token
      end

    [
      {"Authorization", "Bearer #{personal_access_token}"}
    ]
  end

  # return user agent headers based on :user_agent in harvex config or the one provided in config
  defp get_user_agent_headers(auth_opts) do
    case Keyword.get(auth_opts, :user_agent) do
      nil ->
        case Application.fetch_env(:harvex, :user_agent) do
          :error ->
            []

          {:ok, user_agent} ->
            [{"User-Agent", user_agent}]
        end

      user_agent ->
        [{"User-Agent", user_agent}]
    end
  end
end
