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

  test "gets authenticated harvest user's users" do
    use_cassette "users" do
      assert [%Harvex.User{} | _] = Harvex.User.list()
    end
  end

  test "gets authenticated harvest user's projects" do
    use_cassette "projects" do
      assert [%Harvex.Project{} | _] = Harvex.Project.list()
    end
  end

  test "gets a resource list recursively" do
    use_cassette "projects" do
      assert [%Harvex.Project{} | _] = Harvex.Project.list(recurse_pages: true)
    end
  end

  test "gets authenticated harvest user's clients" do
    use_cassette "clients" do
      assert [%Harvex.Client{} | _] = Harvex.Client.list()
    end
  end

  test "gets authenticated harvest user's tasks" do
    use_cassette "tasks" do
      assert [%Harvex.Task{} | _] = Harvex.Task.list()
    end
  end

  test "gets authenticated harvest user's time entries" do
    use_cassette "time_entries" do
      assert [%Harvex.TimeEntry{} | _] = Harvex.TimeEntry.list()
    end
  end

  # test "creates a time entry for authenticated user" do
  #   use_cassette "create_time_entry" do
  #     time_entry = %{
  #       project_id: 23001782,
  #       task_id: 13283058,

  #     }
  #     assert %Harvex.TimeEntry{} = Harvex.TimeEntry.create()
  #   end
  # end
end
