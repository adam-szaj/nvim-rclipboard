local M = {}

-- local function shellescape(str)
--   return vim.fn.shellescape(str)
-- end

local function build_publish_cmd(opts, topic)
	local cmd = { opts.bin, "publish" }
	if topic == "c" then
		table.insert(cmd, "-c")
	elseif topic == "p" then
		table.insert(cmd, "-p")
	elseif topic == "s" then
		table.insert(cmd, "-s")
	end
	table.insert(cmd, "--encoding")
	table.insert(cmd, opts.encoding)
	if opts.uds and #opts.uds > 0 then
		table.insert(cmd, "--uds")
		table.insert(cmd, opts.uds)
	else
		if opts.host then
			table.insert(cmd, "--host")
			table.insert(cmd, opts.host)
		end
		if opts.port then
			table.insert(cmd, "--port")
			table.insert(cmd, tostring(opts.port))
		end
	end
	return table.concat(cmd, " ")
end

local function build_fetch_cmd(opts, topic)
	local cmd = { opts.bin, "fetch" }
	if topic == "c" then
		table.insert(cmd, "-c")
	elseif topic == "p" then
		table.insert(cmd, "-p")
	elseif topic == "s" then
		table.insert(cmd, "-s")
	end
	-- Ask rclipctl to emit in chosen encoding, then decode locally
	table.insert(cmd, "--encoding")
	table.insert(cmd, opts.decode)
	if opts.uds and #opts.uds > 0 then
		table.insert(cmd, "--uds")
		table.insert(cmd, opts.uds)
	else
		if opts.host then
			table.insert(cmd, "--host")
			table.insert(cmd, opts.host)
		end
		if opts.port then
			table.insert(cmd, "--port")
			table.insert(cmd, tostring(opts.port))
		end
	end
	local pipeline
	if opts.decode == "base64" then
		pipeline = " | base64 -d"
	elseif opts.decode == "hex" then
		pipeline = " | xxd -r -p"
	else
		pipeline = ""
	end
	return table.concat(cmd, " ") .. pipeline
end

local function set_clipboard(opts)
	local copy_plus = build_publish_cmd(opts, "c")
	local copy_star = build_publish_cmd(opts, "p")
	local paste_plus = build_fetch_cmd(opts, "c")
	local paste_star = build_fetch_cmd(opts, "p")
	vim.g.clipboard = {
		name = "rclipboard",
		copy = { ["+"] = copy_plus, ["*"] = copy_star },
		paste = { ["+"] = paste_plus, ["*"] = paste_star },
		cache_enabled = 1,
	}
end

local function default_opts()
	return {
		bin = "rclipctl",
		host = nil,
		port = nil,
		uds = nil,
		encoding = "base64", -- for publish
		decode = "base64", -- for paste pipeline
		app = "nvim",
		use_env = true,
	}
end

local function load_env_defaults(opts)
	local conf = os.getenv("RCLIP_CONF") or (vim.fn.expand("~/.config/rclipboard/env"))
	local function getenv_file(path)
		local fd = io.open(path, "r")
		if not fd then
			return nil
		end
		local data = fd:read("*a")
		fd:close()
		local t = {}
		for line in data:gmatch("[^\n]+") do
			local k, v = line:match("^%s*([A-Za-z_][A-Za-z0-9_]*)%s*=%s*(.-)%s*$")
			if k and v and not v:match("^#") then
				v = v:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
				t[k] = v
			end
		end
		return t
	end
	local env = getenv_file(conf)
	if not env then
		return
	end
	if not opts.uds and env["RCLIPBOARD_BIND_UDS"] then
		opts.uds = env["RCLIPBOARD_BIND_UDS"]
	end
	if not opts.host and env["RCLIPBOARD_BIND_ADDR"] then
		opts.host = env["RCLIPBOARD_BIND_ADDR"]
	end
	if not opts.port and env["RCLIPBOARD_BIND_PORT"] then
		opts.port = tonumber(env["RCLIPBOARD_BIND_PORT"])
	end
end

function M.setup(user_opts)
	local opts = vim.tbl_deep_extend("force", default_opts(), user_opts or {})
	if opts.use_env then
		load_env_defaults(opts)
	end
	set_clipboard(opts)

	vim.api.nvim_create_user_command("RclipboardHealth", function()
		local cmd = { "rclipctl", "health" }
		if opts.uds and #opts.uds > 0 then
			table.insert(cmd, "--uds")
			table.insert(cmd, opts.uds)
		else
			local host = opts.host or "127.0.0.1"
			local port = opts.port or 8989
			table.insert(cmd, "--host")
			table.insert(cmd, host)
			table.insert(cmd, "--port")
			table.insert(cmd, tostring(port))
		end
		local out = vim.fn.system(cmd)
		if vim.v.shell_error ~= 0 then
			vim.notify("rclipboard health check failed", vim.log.levels.WARN)
			return
		end
		vim.notify(out, vim.log.levels.INFO)
	end, {})

	vim.api.nvim_create_user_command("RclipboardConfig", function()
		vim.print(opts)
	end, {})
end

return M
