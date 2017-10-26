defmodule ChromeLauncher do
  @moduledoc """
  Documentation for ChromeLauncher.
  """

  require Logger

  @doc """
  Launches an instance of Chrome.
  """
  @spec launch(list()) :: {:ok, pid()} | {:error, atom()}
  def launch(opts \\ []) do
    merged_opts = Keyword.merge(default_opts(), opts)

    case ChromeLauncher.Finder.find() do
      {:ok, path} ->
        cmd = [String.to_charlist(path) | formatted_flags(merged_opts)]

        exec_opts = [
          stdout: fn(_, pid, data) ->
            Logger.info("[#{pid}] #{inspect(data)}")
          end,
          stderr: fn(_, pid, data) ->
            Logger.error("[#{pid}] #{inspect(data)}")
          end
        ]

        with \
          {:ok, pid, os_pid} <- :exec.run_link(cmd, exec_opts),
          {:ok, _os_pid} <- await_process_on_port(os_pid, merged_opts[:remote_debugging_port])
        do
          {:ok, pid}
        else
          error ->
            error
        end
      {:error, _} = error ->
        error
    end
  end

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


  # Awaits for the chrome process to launch by trying to initiate a TCP
  # connection to the remote debugging port.
  defp await_process_on_port(os_pid, port), do: await_process_on_port(os_pid, port, 10)
  defp await_process_on_port(os_pid, _port, 0) do
    :exec.kill(os_pid, 15)
    {:error, :process_did_not_launch}
  end
  defp await_process_on_port(os_pid, port, retries_left) do
    case :gen_tcp.connect('localhost', port, []) do
      {:error, _} ->
        Process.sleep(30)
        await_process_on_port(os_pid, port, retries_left - 1)
      _ -> {:ok, os_pid}
    end
  end

  defp formatted_flags(opts) do
    tmp_dir = System.tmp_dir()
    user_data_dir = System.tmp_dir()

    internal_flags = [
      "--remote-debugging-port=#{opts[:remote_debugging_port]}",
      "--crash-dumps-dir=#{tmp_dir}",
      "--user-data-dir=#{user_data_dir}"
    ]

    (internal_flags ++ List.wrap(opts[:flags]))
    |> Enum.map(&String.to_charlist/1)
  end
end
