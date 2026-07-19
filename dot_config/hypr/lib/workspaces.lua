local M = {}

-- At startup, monitors configured with position = "auto" briefly report the
-- sentinel position x=-1 y=-1 before Hyprland computes the layout. Sorting by
-- position.x while unsettled puts a -1 monitor "left" of the real x=0 monitor,
-- so the workspace bindings come out mirrored. We treat any negative or
-- duplicate x as "not ready" and retry until positions settle.
local RETRY_MS = 200
local MAX_RETRIES = 25

local function positions_settled(monitors)
  local seen = {}
  for _, mon in ipairs(monitors) do
    local x = mon.position.x
    if x == nil or x < 0 or mon.position.y < 0 then
      return false
    end
    if seen[x] then
      return false
    end
    seen[x] = true
  end
  return true
end

local function apply(monitors)
  table.sort(monitors, function(a, b)
    return a.position.x < b.position.x
  end)

  local leftmost = monitors[1]
  local rightmost = monitors[#monitors]

  local function bind(ws, mon)
    hl.workspace_rule({
      workspace = tostring(ws),
      monitor = mon.name,
      default = (ws == 1 or ws == 6),
    })

    if hl.get_workspace(ws) then
      hl.dispatch(hl.dsp.workspace.move({
        workspace = ws,
        monitor = mon.name,
      }))
    end
  end

  for ws = 1, 5 do
    bind(ws, leftmost)
  end
  bind(10, leftmost)
  for ws = 6, 9 do
    bind(ws, rightmost)
  end
end

local function bind_workspaces(attempt)
  attempt = attempt or 0

  local monitors = hl.get_monitors()
  if monitors == nil or #monitors == 0 then
    return
  end

  if not positions_settled(monitors) then
    if attempt < MAX_RETRIES then
      hl.timer(function()
        bind_workspaces(attempt + 1)
      end, { timeout = RETRY_MS, type = "oneshot" })
    end
    return
  end

  apply(monitors)
end

M.setup = function()
  bind_workspaces(0)
end

return M
