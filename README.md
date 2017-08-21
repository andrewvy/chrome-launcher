# Chrome Launcher

This Elixir library makes launching headless Google Chrome processes with custom options easily.

Currently only supports OSX with plans for Linux/Windows in the future.

---

### Usage:

```elixir
{:ok, pid} = ChromeLauncher.launch([
  remote_debugging_port: 9233
])
```

Available options:

- `remote_debugging_port`: Configures `--remote-debugging-port=PORT` flag for connecting to the chrome process.
- `flags`: Flags to be passed in when starting the headless chrome process. (Overrides defaults set by `:chrome_launcher`)
