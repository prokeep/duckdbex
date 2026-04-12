defmodule Duckdbex.Nif.ConfigTest do
  use ExUnit.Case, async: false

  test "create_config/0" do
    assert {:ok, config} = Duckdbex.create_config()
    assert is_reference(config)
  end

  test "get_config_options/0 returns DuckDB config options" do
    options = Duckdbex.get_config_options()

    assert is_list(options)
    assert length(options) > 0
    assert Enum.any?(options, &(&1.name == "search_path"))
    assert Enum.any?(options, &(&1.name == "threads"))
  end

  test "open with nil config" do
    assert {:ok, _db} = Duckdbex.open(":memory:", nil)
  end

  test "invalid config type" do
    assert_raise(ArgumentError, fn ->
      Duckdbex.open(":memory:", invalid: "config")
    end)
  end

  test "set_config_option returns error for unknown option" do
    {:ok, config} = Duckdbex.create_config()
    assert {:error, _reason} = Duckdbex.set_config_option(config, "definitely_unknown_option", 1)
  end

  test "open with supported config option" do
    {:ok, config} = Duckdbex.create_config()
    assert :ok = Duckdbex.set_config_option(config, "threads", 1)
    assert {:ok, _db} = Duckdbex.open(":memory:", config)
  end

  test "unsupported config option returns DuckDB error" do
    {:ok, config} = Duckdbex.create_config()
    assert {:error, reason} = Duckdbex.set_config_option(config, "search_path", "main")
    assert reason =~ "Could not set option"
  end
end
