# nvim-rclipboard

Simple Neovim plugin to integrate rclipboard as Neovim’s clipboard provider using `rclipctl`.

Features
- Uses rclipboard over TCP or Unix Domain Socket (UDS).
- Publishes yanks as base64 (with padding) by default; decodes on paste.
- Reads the same env file as the systemd user units (`~/.config/rclipboard/env`).
- Commands: `:RclipboardHealth`, `:RclipboardConfig`.

Install
- LuaRocks (local):
  cd nvim-rclipboard && luarocks make --local nvim-rclipboard-0.1.0-1.rockspec
  # Add to your runtimepath if needed (e.g., via packpath) or use lazy.nvim/packer to call setup.
- lazy.nvim:
  {
    'your/repo/nvim-rclipboard',
    config = function()
      require('rclipboard').setup()
    end,
  }
- packer.nvim:
  use { 'your/repo/nvim-rclipboard', config = function()
    require('rclipboard').setup()
  end }

Config
- Minimal (auto-read env file at `~/.config/rclipboard/env`):
  require('rclipboard').setup()
- Force UDS path:
  require('rclipboard').setup({ uds = vim.env.XDG_RUNTIME_DIR .. '/rclipboard.sock' })
- Custom host/port:
  require('rclipboard').setup({ host = '127.0.0.1', port = 8989 })
- Change encodings:
  require('rclipboard').setup({ encoding = 'base64', decode = 'base64' })

Notes
- `rclipctl` must be on PATH.
- For UDS, ensure the socket exists and is readable (see the main README for systemd socket activation).
- The plugin sets `vim.g.clipboard` using external commands; this works across most setups without additional Lua dependencies.
