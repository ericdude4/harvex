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

  test "creates a time entry for authenticated user" do
    use_cassette "create_time_entry" do
      # these id values come from the cassettes
      time_entry =
        %{
          user_id: 3_031_110,
          project_id: 23_001_782,
          task_id: 13_283_054,
          spent_date: "2019-11-21",
          hours: 0.25
        }
        |> Harvex.TimeEntry.create()

      assert %Harvex.TimeEntry{} = time_entry
    end
  end

  test "updates authenticated harvest user's task" do
    use_cassette "update_task" do
      assert %Harvex.Task{} =
               Harvex.Task.update(13_283_058, %{name: "harvex is the best harvest api wrapper"})
    end
  end

  test "deletes authenticated harvest user's task" do
    use_cassette "delete_task" do
      assert :ok = Harvex.Task.delete(13_283_057)
    end
  end

  test "retrieves authenticated harvest user's company" do
    use_cassette "retrieve_company" do
    assert %Harvex.Company{} = Harvex.Company.retrieve()
    end
  end

  test "updates authenticated harvest user's company" do
    use_cassette "update_company" do
      assert %Harvex.Company{} = Harvex.Company.update(%{wants_timestamp_timers: true})
    end
  end

  test "gets authenticated harvest user's invoices" do
    use_cassette "invoices" do
      assert [%Harvex.Invoice{} | _] = Harvex.Invoice.list()
    end
  end
end
