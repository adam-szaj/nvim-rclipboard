package = "nvim-rclipboard"
version = "0.1.0-1"
source = {
	url = "git+file://.",
}
description = {
	summary = "Simple Neovim clipboard provider for rclipboard",
	detailed = [[
A lightweight Neovim plugin that wires Neovim's clipboard to rclipboard via rclipctl,
supporting TCP or Unix Domain Sockets and reading the same env file as the systemd setup.
  ]],
	license = "MIT",
	homepage = "https://example.local/nvim-rclipboard",
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	modules = {
		["rclipboard"] = "lua/rclipboard/init.lua",
	},
}
