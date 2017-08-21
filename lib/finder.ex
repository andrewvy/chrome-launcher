defmodule ChromeLauncher.Finder do
  @moduledoc """
  This module is responsible for finding Google Chrome installations through
  common paths.

  Search priority is inspired from https://github.com/GoogleChrome/lighthouse/tree/master/chrome-launcher

  > Darwin:

  1) $CHROME_PATH environment variable
  2) /$HOME/Applications/
  2) /Applications/
  2) /Volumes/

  > Linux:

  1) $CHROME_PATH environment variable
  2) $HOME/.local/share/applications
  3) /usr/share/applications
  4) `which` [google-chrome-stable, google-chrome, chromium-browser, chromium]

  > Windows:

  1) [Program Files, Program Files (x86)] chrome.exe
  """

  def find() do
    case os() do
      {:unix, :darwin} -> darwin()
      {:unix, _} -> linux()
      {:win32, _} -> win32()
    end
  end

  @lsregister String.to_charlist("/System/Library/Frameworks/CoreServices.framework" <>
    "/Versions/A/Frameworks/LaunchServices.framework" <>
    "/Versions/A/Support/lsregister")

  @suffixes ["/Contents/MacOS/Google Chrome Canary", "/Contents/MacOS/Google Chrome"]

  def darwin() do
    cmd = @lsregister ++ ' -dump | grep -i \'Google Chrome\\( Canary\\)\\?.app$\' | awk \'{$1=""; print $0}\''

    default_installation_paths = [
      (System.get_env("CHROME_PATH") || "")
    ]

    installation_paths =
      :os.cmd(cmd)
      |> to_string()
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.flat_map(fn(prefix) ->
        @suffixes |> Enum.map(&(prefix <> &1))
      end)

    existing_installation_paths =
      (default_installation_paths ++ installation_paths)
      |> Enum.filter(&is_executable/1)

    case existing_installation_paths do
      [first | _] -> {:ok, first}
      _ -> {:error, :chrome_not_found}
    end
  end

  def linux() do
    # @todo(vy): Add Linux implementation.
  end

  def win32() do
    # @todo(vy): Add Windows implementation.
  end

  def is_executable(path) do
    case File.stat(path) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp os(), do: :os.type()
end
