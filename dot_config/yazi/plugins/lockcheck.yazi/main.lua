--- @since 25.5.31

-- FileLocksmithCLI prints this to stdout instead of staying silent
local NOT_LOCKED = "No processes found locking"
-- Handle enumeration can wedge for a minute, so never wait forever
local READ_TIMEOUT = 40000
-- A folder scan reports every process whose cwd lives there, yazi and the scanner included
local PROTECTED = { yazi = true, ["yazi.exe"] = true, ["filelocksmithcli.exe"] = true, lsof = true }
local KEYS = "abcdefghijklmnopqrstuvwxyz"
local IS_WINDOWS = ya.target_family() == "windows"

local function notify(content, level)
  ya.notify { title = "Lockcheck", content = content, level = level or "info", timeout = 8 }
end

local selected_or_hovered = ya.sync(function()
  local tab, paths = cx.active, {}
  for _, u in pairs(tab.selected) do
    paths[#paths + 1] = tostring(u)
  end
  if #paths == 0 and tab.current.hovered then
    paths[1] = tostring(tab.current.hovered.url)
  end
  return paths
end)

local function locksmith()
  local exe = (os.getenv("LOCALAPPDATA") or "") .. "\\PowerToys\\FileLocksmithCLI.exe"
  return fs.cha(Url(exe)) and exe or "FileLocksmithCLI.exe"
end

local function scan_command(paths)
  if IS_WINDOWS then
    return Command(locksmith()):arg(paths)
  end
  return Command("lsof"):arg { "-F", "pc", "--" }:arg(paths)
end

local function kill_command(pid)
  if IS_WINDOWS then
    return Command("taskkill"):arg { "/F", "/PID", pid }
  end
  return Command("kill"):arg { "-9", pid }
end

local function capture(cmd)
  local child, err = cmd:stdout(Command.PIPED):stderr(Command.PIPED):spawn()
  if not child then
    return nil, nil, tostring(err)
  end

  local out, errs = {}, {}
  while true do
    local line, event = child:read_line_with { timeout = READ_TIMEOUT }
    if event == 0 then
      out[#out + 1] = line
    elseif event == 1 then
      errs[#errs + 1] = line
    elseif event == 3 then
      child:start_kill()
      return nil, nil, "Timed out waiting for the handle scan"
    else
      break
    end
  end

  child:wait()
  return table.concat(out), (table.concat(errs):gsub("%s+$", ""))
end

-- FileLocksmithCLI: "PID\tUser\tProcess" header, then one tab separated row per process
-- lsof -F pc: one "p<pid>" line followed by one "c<command>" line per process
local function parse(text)
  local rows, seen = {}, {}
  if IS_WINDOWS then
    for pid, name in text:gmatch("(%d+)\t[^\t\r\n]*\t([^\r\n]+)") do
      rows[#rows + 1] = { pid = pid, name = name }
    end
    return rows
  end

  local pid
  for line in text:gmatch("[^\r\n]+") do
    local kind, value = line:sub(1, 1), line:sub(2)
    if kind == "p" then
      pid = value
    elseif kind == "c" and pid and not seen[pid] then
      seen[pid] = true
      rows[#rows + 1] = { pid = pid, name = value }
    end
  end
  return rows
end

local function protected(row) return PROTECTED[row.name:lower()] end

local function render(rows)
  local lines = {}
  for _, r in ipairs(rows) do
    lines[#lines + 1] = ("%s  %s%s"):format(r.pid, r.name, protected(r) and "  (protected)" or "")
  end
  return table.concat(lines, "\n")
end

return {
  entry = function(_, job)
    local paths = selected_or_hovered()
    if #paths == 0 then
      return notify("Nothing selected", "warn")
    end

    local out, errs, err = capture(scan_command(paths))
    if err then
      return notify(err, "error")
    end

    local rows = parse(out)
    if #rows == 0 then
      if errs ~= "" and not out:find(NOT_LOCKED, 1, true) then
        return notify(errs, "error")
      end
      return notify("Not locked")
    end
    if not job.args.kill then
      return notify(render(rows), "warn")
    end

    local victims = {}
    for _, r in ipairs(rows) do
      if not protected(r) and #victims < #KEYS then
        victims[#victims + 1] = r
      end
    end
    if #victims == 0 then
      return notify("Only protected processes hold this:\n" .. render(rows), "warn")
    end

    -- Reuses the original scan, so entries stay listed even if they exit on their own
    while #victims > 0 do
      local cands = {}
      for i, r in ipairs(victims) do
        cands[i] = { on = KEYS:sub(i, i), desc = ("kill %s %s"):format(r.pid, r.name) }
      end

      local pick = ya.which { cands = cands }
      if not pick then
        return
      end

      local victim = table.remove(victims, pick)
      local _, kill_errs, kill_err = capture(kill_command(victim.pid))
      if kill_err or kill_errs ~= "" then
        notify(kill_err or kill_errs, "error")
      else
        notify(("Killed %s %s"):format(victim.pid, victim.name))
      end
    end
  end,
}
