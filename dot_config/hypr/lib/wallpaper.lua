local M = {}

math.randomseed(os.time())

local function list_wallpapers(dir)
  local files = {}
  local p = io.popen('find "' .. dir .. '" -type f')
  if p then
    for line in p:lines() do
      if line:match("%.mp4$") or line:match("%.webm$") or line:match("%.mkv$") or line:match("%.json$") then
        table.insert(files, line)
      end
    end
    p:close()
  end
  return files
end

local function wallpaperengine_id(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content:match('"id"%s*:%s*"([^"]+)"')
end

-- Shared draw pool: wallpapers are dealt without replacement and the pool
-- refills once empty, so every wallpaper shows up before repeats.
local pool = {}
local function pick(dir)
  if #pool == 0 then
    pool = list_wallpapers(dir)
  end
  if #pool == 0 then
    return nil
  end
  return table.remove(pool, math.random(#pool))
end

local function mpvpaper_cmd(name, wp)
  return 'mpvpaper -o "no-audio loop hwdec=auto panscan=1.0" "' .. name .. '" "' .. wp .. '"'
end

local function engine_screen(name, id)
  return "--scaling fill --screen-root " .. name .. " --bg " .. id
end

local function monitor_cmd(dir, name)
  local wp = pick(dir)
  if not wp then
    return nil
  end
  if wp:match("%.json$") then
    local id = wallpaperengine_id(wp)
    if not id then
      return nil
    end
    return "linux-wallpaperengine --silent " .. engine_screen(name, id)
  end
  return mpvpaper_cmd(name, wp)
end

-- Monitors that already have a wallpaper launched for them.
local claimed = {}
local watching = false

local function apply_monitor(dir, name)
  if claimed[name] then
    return
  end
  local cmd = monitor_cmd(dir, name)
  if cmd then
    claimed[name] = true
    hl.exec_cmd(cmd)
  end
end

-- At hyprland.start monitors may not be registered yet, so apply also
-- subscribes to monitor.added and covers each screen as it appears
-- (handles boot order and hotplug alike).
function M.apply(dir)
  if not watching then
    watching = true
    hl.on("monitor.added", function(mon)
      if mon and mon.name then
        apply_monitor(dir, mon.name)
      else
        M.apply(dir)
      end
    end)
    hl.on("monitor.removed", function(mon)
      if mon and mon.name then
        claimed[mon.name] = nil
      end
    end)
  end
  for _, mon in ipairs(hl.get_monitors()) do
    apply_monitor(dir, mon.name)
  end
end

-- Kill everything and deal a fresh wallpaper to every monitor. Engine
-- monitors share a single invocation; videos get one mpvpaper each.
function M.shuffle(dir)
  local cmds = {}
  local we_screens = {}
  for _, mon in ipairs(hl.get_monitors()) do
    local wp = pick(dir)
    if wp then
      claimed[mon.name] = true
      if wp:match("%.json$") then
        local id = wallpaperengine_id(wp)
        if id then
          table.insert(we_screens, engine_screen(mon.name, id))
        end
      else
        table.insert(cmds, mpvpaper_cmd(mon.name, wp))
      end
    end
  end
  if #we_screens > 0 then
    table.insert(cmds, "linux-wallpaperengine --silent " .. table.concat(we_screens, " "))
  end
  if #cmds == 0 then
    return
  end
  hl.exec_cmd("sh -c 'pkill mpvpaper; pkill linux-wallpape; sleep 0.3; " .. table.concat(cmds, " & ") .. " &'")
end

return M
