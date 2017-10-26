# Chrome Launcher

This Elixir library makes launching headless Google Chrome processes with custom options easily.

Utilizes [erlexec](https://github.com/saleyn/erlexec) to manage processes under the hood.

Only supports OSX + Linux at this time.

---

### Installation:

```elixir
{:chrome_launcher, "~> 0.0.2"}
```

### Usage:

```elixir
{:ok, pid} = ChromeLauncher.launch([
  remote_debugging_port: 9233
])
```

> Or in a supervisor (1.5+)

```elixir
children = [
  {ChromeLauncher, [remote_debugging_port: 9222]}
]

Supervisor.start_link(children, strategy: :one_for_one)
```

> With multiple instances in a supervisor (1.5+)

```elixir
children = [
  Supervisor.child_spec({ChromeLauncher, [remote_debugging_port: 9222]}, id: :chrome_1),
  Supervisor.child_spec({ChromeLauncher, [remote_debugging_port: 9223]}, id: :chrome_2),
]

Supervisor.start_link(children, strategy: :one_for_one)
```

> Pre 1.5

```elixir
import Supervisor.Spec

children = [
  worker(ChromeLauncher, [[remote_debugging_port: 9222]], id: :chrome_1),
  worker(ChromeLauncher, [[remote_debugging_port: 9223]], id: :chrome_2),
]

Supervisor.start_link(children, strategy: :one_for_one)
```

Available options:

- `remote_debugging_port`: Configures `--remote-debugging-port=PORT` flag for connecting to the chrome process.
- `flags`: Flags to be passed in when starting the headless chrome process. (Overrides defaults set by `:chrome_launcher`)
