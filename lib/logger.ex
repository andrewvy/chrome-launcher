defmodule ChromeLauncher.Logger do
  @moduledoc """
  This module is responsible for parsing logging out of chrome
  instances and output logging at the correct levels.
  """

  require Logger

  def log(binary) do
    log_level = determine_log_level(binary)

    Logger.bare_log(log_level, binary)
  end

  def determine_log_level(binary) do
    cond do
      :binary.match(binary, ":INFO:") != :nomatch -> :info
      :binary.match(binary, ":WARNING:") != :nomatch -> :warn
      true -> :error
    end
  end
end
