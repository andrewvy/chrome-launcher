defmodule ChromeLauncher do
  @moduledoc """
  Documentation for ChromeLauncher.
  """

  def default_opts() do
    [
      remote_debugging_port: 9222,
      flags: [
        "--headless",
        "--disable-gpu",
        "--disable-translate",
        "--disable-extensions",
        "--disable-background-networking",
        "--safebrowsing-disable-auto-update",
        "--disable-sync",
        "--metrics-recording-only",
        "--disable-default-apps",
        "--mute-audio",
        "--no-first-run"
      ]
    ]
  end

  def launch(opts) do
    merged_opts = Keyword.merge(default_opts(), opts)

    case ChromeLauncher.Finder.find() do
      {:ok, path} ->
        cmd = [String.to_charlist(path) | formatted_flags(merged_opts)]

        exec_opts = [
          stdout: fn(status, pid, data) -> IO.inspect(data) end,
          stderr: fn(status, pid, data) -> IO.inspect(data) end
        ]

        :exec.run_link(cmd, exec_opts)
      {:error, _} = error ->
        error
    end
  end

  def formatted_flags(opts) do
    internal_flags = [
      "--remote-debugging-port=#{opts[:remote_debugging_port]}",
    ]

    (internal_flags ++ List.wrap(opts[:flags]))
    |> Enum.map(&String.to_charlist/1)
  end
end
