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
        proc_opts = [
          out: IO.stream(:stdio, :line)
        ]

        # @bug(vy): Porcelain won't forward exit by the VM, leaving orphaned process.
        process = Porcelain.spawn(path, formatted_flags(merged_opts), proc_opts)

        {:ok, process}
      {:error, _} = error ->
        error
    end
  end

  def formatted_flags(opts) do
    internal_flags = [
      "--remote-debugging-port=#{opts[:remote_debugging_port]}",
    ]

    internal_flags ++ List.wrap(opts[:flags])
  end
end
