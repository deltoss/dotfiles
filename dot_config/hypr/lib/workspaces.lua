local M = {}

local function bind_workspaces()
  local monitors = hl.get_monitors()
  if monitors == nil or #monitors == 0 then
    return
  end

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

M.setup = bind_workspaces

return M
