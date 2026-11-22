local M = {}

-- Loads trusted modules from <directory>/<name>/init.lua; each exports setup().
function M.setup(directory)
  local quoted = "'" .. directory:gsub("'", "'\"'\"'") .. "'"
  local command = "if [ -d " .. quoted .. " ]; then find -L " .. quoted
    .. " -mindepth 2 -maxdepth 2 -type f -name init.lua -print0; fi; printf '\\0%s' \"$?\""
  local pipe = assert(io.popen(command, "r"))
  local output = assert(pipe:read("*a"))
  pipe:close()
  -- Hyprland reaps child processes, so read the exit status from stdout.
  local listing, status = output:match("^(.*)%z(%d+)$")
  assert(status == "0", "Failed to scan autoload directory: " .. directory)

  local paths = {}
  for path in listing:gmatch("[^%z]+") do
    table.insert(paths, path)
  end
  table.sort(paths)

  for _, path in ipairs(paths) do
    local module = assert(loadfile(path))()
    assert(type(module) == "table" and type(module.setup) == "function", path .. " must return a module with setup()")
    module.setup()
  end
end

return M
