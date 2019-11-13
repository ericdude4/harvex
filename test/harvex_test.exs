defmodule HarvexTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Harvex

  setup_all do
    HTTPoison.start()
  end

  test "gets authenticated harvest user's accounts" do
    use_cassette "accounts" do
      assert [%Harvex.Account{} | _] = Harvex.Account.list()
    end
  end

  test "gets authenticated harvest user" do
    use_cassette "get_me" do
      assert %Harvex.User{} = Harvex.User.get_me()
    end
  end
end
