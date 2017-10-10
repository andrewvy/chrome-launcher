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
  2) `which` [google-chrome-stable, google-chrome, chromium-browser, chromium]

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

  def darwin() do
    lsregister = String.to_charlist("/System/Library/Frameworks/CoreServices.framework" <>
      "/Versions/A/Frameworks/LaunchServices.framework" <>
      "/Versions/A/Support/lsregister")

    suffixes = ["/Contents/MacOS/Google Chrome Canary", "/Contents/MacOS/Google Chrome"]

    cmd = lsregister ++ ' -dump | grep -i \'Google Chrome\\( Canary\\)\\?.app$\' | awk \'{$1=""; print $0}\''

    default_installation_paths = [
      resolve_chrome_path()
    ]

    installation_paths =
      :os.cmd(cmd)
      |> to_string()
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.flat_map(fn(prefix) ->
        suffixes |> Enum.map(&(prefix <> &1))
      end)

    sort(default_installation_paths ++ installation_paths)
  end

  def linux() do
    default_installation_paths = [
      resolve_chrome_path()
    ]

    executables =  [
      "google-chrome-stable",
      "google-chrome",
      "chromium-browser",
      "chromium",
    ]

    installation_paths = Enum.reduce(executables, [], fn(executable, paths) ->
      case System.cmd("which", [executable]) do
        {path, 0} -> List.insert_at(paths, -1, String.trim(path))
        _ -> paths
      end
    end)

    sort(default_installation_paths ++ installation_paths)
  end

  def win32() do
    # @todo(vy): Add Windows implementation.
  end

  def executable?(path) do
    case File.stat(path) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp os(), do: :os.type()

  defp resolve_chrome_path() do
    System.get_env("CHROME_PATH") || ""
  end

  defp sort(paths) do
    paths
    |> Enum.filter(&executable?/1)
    |> case do
      [first | _] -> {:ok, first}
      _ -> {:error, :chrome_not_found}
    end
  end
end
